*&---------------------------------------------------------------------
*& CREATE_DEEP_ENTITY - create a composite object (header + children)
*&---------------------------------------------------------------------
*& REFERENCE COOKBOOK - READ BEFORE COPYING
*&
*& Independent reference method body. Types (zcl_zsm_mpc_ext=>ts_deep,
*& zsm_s_header, zsm_tt_item) and FM ZSM_F_DATA are placeholders for the
*& artefacts your own SEGW project generates.
*&
*& AUTHORIZATION BOUNDARY
*& SAP Gateway authenticates the caller and checks that the user may reach
*& the SERVICE. It does not authorize the BUSINESS operation. This example
*& shows Gateway plumbing only: production code must enforce the business
*& authorization appropriate to the application - either here, before the
*& call, or verifiably inside the called function module. No authorization
*& object is invented in this repository.
*&
*& TRANSACTION (SAP LUW)
*& The commit rule applied below: validate the business return table
*& FIRST, commit ONLY on success. See the root README, section
*& "Transaction Handling (SAP LUW)".
*&---------------------------------------------------------------------

  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.

    DATA lt_return TYPE bapiret2_t.

    CASE iv_entity_name.
      WHEN 'Header'.

        DATA ls_deep TYPE zcl_zsm_mpc_ext=>ts_deep.

        DATA(lo_message_container) = mo_context->get_message_container( ).

        " ---------------------------------------------------------------
        " 1) Read the deep request payload.
        "    A malformed payload is a client error - do not continue as if
        "    the read had succeeded.
        " ---------------------------------------------------------------
        TRY.
            io_data_provider->read_entry_data( IMPORTING es_data = ls_deep ).
          CATCH /iwbep/cx_mgw_tech_exception INTO DATA(lx_tech).
            lo_message_container->add_message_text_only( iv_msg_type = 'E'
                                                         iv_msg_text = 'Request payload could not be read' ).

            RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                                    message_container = lo_message_container
                                    previous          = lx_tech ).
        ENDTRY.

        " ---------------------------------------------------------------
        " 2) Split the deep structure into the flat structures the
        "    business API expects. The nested component names (items)
        "    mirror the navigation properties - see MPC_EXT/TYPES/Types.abap.
        " ---------------------------------------------------------------
        DATA(ls_header) = CORRESPONDING zsm_s_header( ls_deep ).
        DATA(lt_items)  = CORRESPONDING zsm_tt_item( ls_deep-items ).

        " ---------------------------------------------------------------
        " 3) Call the business API.
        " ---------------------------------------------------------------
        CALL FUNCTION 'ZSM_F_DATA'
          EXPORTING is_header = ls_header
          IMPORTING es_header = ls_header       " server-assigned keys come back here
          TABLES    it_items  = lt_items
                    et_return = lt_return.

        " ---------------------------------------------------------------
        " 4) Persist the backend messages for support (Gateway error log).
        " ---------------------------------------------------------------
        IF lt_return IS NOT INITIAL.
          me->/iwbep/if_sb_dpc_comm_services~rfc_save_log( iv_entity_type = iv_entity_name
                                                           it_return      = lt_return
                                                           it_key_tab     = it_key_tab ).
        ENDIF.

        " ---------------------------------------------------------------
        " 5) TRANSACTION DECISION - the important part.
        "    E (error), A (abort) and X (exit) all mean the operation
        "    failed. On failure: surface the messages and raise. Do NOT
        "    commit - committing here would persist a partially created
        "    composite object and report HTTP 201 for a failed request.
        " ---------------------------------------------------------------
        lo_message_container->add_messages_from_bapi( it_bapi_messages          = lt_return
                                                      iv_add_to_response_header = abap_true ).

        IF line_exists( lt_return[ type = 'E' ] )
        OR line_exists( lt_return[ type = 'A' ] )
        OR line_exists( lt_return[ type = 'X' ] ).
          RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                                  message_container = lo_message_container ).
        ENDIF.

        " Success only. commit_work( ) is the SEGW-generated DPC helper;
        " its exact behaviour is release-dependent - NEEDS OFFICIAL
        " VERIFICATION for your SAP_GWFND release.
        " Note: inside a $batch changeset, committing per operation breaks
        " changeset atomicity - see BATCH/README.md.
        me->/iwbep/if_sb_dpc_comm_services~commit_work( ).

        " ---------------------------------------------------------------
        " 6) Return the CREATED entity, not the request payload, so the
        "    client learns the server-assigned key.
        " ---------------------------------------------------------------
        ls_deep = CORRESPONDING #( BASE ( ls_deep ) ls_header ).
        ls_deep-items = CORRESPONDING #( lt_items ).

        copy_data_to_ref( EXPORTING is_data = ls_deep
                          CHANGING  cr_data = er_deep_entity ).

      WHEN OTHERS.
        " An unsupported deep-create target must not return an empty 201.
        DATA(lo_msg) = mo_context->get_message_container( ).
        lo_msg->add_message_text_only( iv_msg_type = 'E'
                                       iv_msg_text = |Deep create is not supported for entity { iv_entity_name }| ).

        RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception( message_container = lo_msg ).
    ENDCASE.

  ENDMETHOD.

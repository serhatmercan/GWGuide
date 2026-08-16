*&---------------------------------------------------------------------
*& UPDATE_ENTITY - PUT / MERGE on a single entity
*&---------------------------------------------------------------------
*& REFERENCE COOKBOOK - READ BEFORE COPYING
*&
*& This file contains INDEPENDENT reference method bodies. They are NOT
*& meant to be pasted together into one DPC_EXT class. Types and function
*& module names are placeholders for your own generated artefacts.
*&
*& AUTHORIZATION BOUNDARY
*& Gateway authenticates the caller and checks service access; it does not
*& authorize the business operation. Production code must enforce the
*& application's own authorization before writing - here, or verifiably
*& inside the called function module. No authorization object is invented
*& in this repository.
*&
*& TRANSACTION (SAP LUW)
*& Validate the business return table BEFORE committing. See the root
*& README, section "Transaction Handling (SAP LUW)".
*&---------------------------------------------------------------------

  " ---------------------------------------------------------------------
  " Example 1 - SKELETON ONLY.
  " Shows how to read the request payload and how to return messages.
  " It performs NO write and therefore owns no transaction. Add your own
  " persistence plus the commit rule from example 2 before using it.
  " ---------------------------------------------------------------------
  METHOD xxx_update_entity.

    DATA ls_data   LIKE er_entity.        " er_entity is a STRUCTURE here
    DATA lt_return TYPE bapiret2_t.

    DATA(lo_message_container) = mo_context->get_message_container( ).

    " Read the request payload.
    TRY.
        io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).
      CATCH /iwbep/cx_mgw_tech_exception INTO DATA(lx_tech).
        lo_message_container->add_message_text_only( iv_msg_type = 'E'
                                                     iv_msg_text = 'Request payload could not be read' ).

        RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                                message_container = lo_message_container
                                previous          = lx_tech ).
    ENDTRY.

    " Keys arrive separately from the payload and carry the conversion exit
    " already applied when read through get_converted_keys( ).
    DATA ls_keys TYPE zcl_zsm_tst_mpc=>ts_keys.
    io_tech_request_context->get_converted_keys( IMPORTING es_key_values = ls_keys ).

    " <-- perform the actual update here, then apply the commit rule from
    "     example 2. Nothing is written in this skeleton.

    " Echo the updated entity back to the client.
    er_entity = ls_data.

    " Success/info messages reach a Fiori client through the sap-message
    " response header. Use a message class in productive code so the text
    " is translatable - a hard-coded literal is not.
    APPEND VALUE #( type = 'S' id = 'ZSM_M_01' number = '002' ) TO lt_return.

    lo_message_container->add_messages_from_bapi( it_bapi_messages          = lt_return
                                                  iv_add_to_response_header = abap_true ).

  ENDMETHOD.


  " ---------------------------------------------------------------------
  " Example 2 - update through a remote-enabled function module, with the
  " full local-vs-remote branch and the correct commit rule.
  " ---------------------------------------------------------------------
  METHOD xxx_update_entity.

    CONSTANTS lc_rfc_name TYPE tfdir-funcname VALUE 'ZSM_FM_001'.

    DATA ls_data     TYPE zcl_zsm_tst_mpc=>ts_main.
    DATA ls_keys     TYPE zcl_zsm_tst_mpc=>ts_keys.
    DATA lt_return   TYPE bapiret2_t.
    DATA lv_exc_msg  TYPE string.
    DATA lv_subrc    TYPE sy-subrc.

    DATA(lo_message_container) = mo_context->get_message_container( ).

    " 1) Payload and keys.
    TRY.
        io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).
      CATCH /iwbep/cx_mgw_tech_exception INTO DATA(lx_tech).
        lo_message_container->add_message_text_only( iv_msg_type = 'E'
                                                     iv_msg_text = 'Request payload could not be read' ).

        RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                                message_container = lo_message_container
                                previous          = lx_tech ).
    ENDTRY.

    io_tech_request_context->get_converted_keys( IMPORTING es_key_values = ls_keys ).

    " ---------------------------------------------------------------
    " 2) Resolve the destination from the SERVICE CONFIGURATION
    "    (system alias in /IWFND/MAINT_SERVICE) rather than from a
    "    hard-coded sy-sysid map. See DESTINATION/Destination.abap for
    "    why that matters.
    "    An initial/NONE destination means embedded deployment: hub and
    "    backend are the same system, so call locally.
    " ---------------------------------------------------------------
    DATA(lo_dp_facade)   = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
    DATA(lv_destination) = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

    IF lv_destination IS INITIAL OR lv_destination = 'NONE'.
      " Local call - shares the caller's LUW.
      TRY.
          CALL FUNCTION lc_rfc_name
            EXPORTING is_data   = ls_data
            TABLES    et_return = lt_return.

          lv_subrc = sy-subrc.
        CATCH cx_root INTO DATA(lx_root).
          lv_subrc   = 1001.
          lv_exc_msg = lx_root->get_text( ).
      ENDTRY.
    ELSE.
      " Remote call - runs in its OWN LUW on the target system.
      CALL FUNCTION lc_rfc_name
        DESTINATION lv_destination
        EXPORTING  is_data               = ls_data
        TABLES     et_return             = lt_return
        EXCEPTIONS system_failure        = 1000 MESSAGE lv_exc_msg
                   communication_failure = 1001 MESSAGE lv_exc_msg
                   OTHERS                = 1002.

      lv_subrc = sy-subrc.
    ENDIF.

    " ---------------------------------------------------------------
    " 3) An RFC/communication failure is a TECHNICAL problem (5xx-class),
    "    not a business rejection. Do not flatten it into a business
    "    exception, and do not expose raw internal text to the client.
    " ---------------------------------------------------------------
    IF lv_subrc <> 0.
      lo_message_container->add_message_text_only(
          iv_msg_type = 'E'
          iv_msg_text = 'The backend system could not be reached. Please contact support.' ).

      " lv_exc_msg holds the RFC error text. Write it to your application
      " log / the Gateway error log - never into the HTTP response, where
      " it can disclose program, table and structure names.

      RAISE EXCEPTION NEW /iwbep/cx_mgw_tech_exception(
                              message_container = lo_message_container ).
    ENDIF.

    " 4) Persist backend messages for support.
    IF lt_return IS NOT INITIAL.
      me->/iwbep/if_sb_dpc_comm_services~rfc_save_log( iv_entity_type = iv_entity_name
                                                       it_return      = lt_return
                                                       it_key_tab     = it_key_tab ).
    ENDIF.

    lo_message_container->add_messages_from_bapi( it_bapi_messages          = lt_return
                                                  iv_add_to_response_header = abap_true ).

    " ---------------------------------------------------------------
    " 5) TRANSACTION DECISION.
    "    E / A / X mean the business operation failed -> raise, do NOT
    "    commit. Committing here would persist a failed update and return
    "    HTTP 204 as if it had worked.
    " ---------------------------------------------------------------
    IF line_exists( lt_return[ type = 'E' ] )
    OR line_exists( lt_return[ type = 'A' ] )
    OR line_exists( lt_return[ type = 'X' ] ).
      RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                              message_container = lo_message_container ).
    ENDIF.

    " Success only.
    " A remote call runs in its own LUW on the target system, so the commit
    " has to be issued THERE - hence iv_rfc_dest. A local call shares this
    " LUW. commit_work( ) is the SEGW-generated DPC helper; its exact
    " signature and behaviour are release-dependent -
    " NEEDS OFFICIAL VERIFICATION for your SAP_GWFND release.
    me->/iwbep/if_sb_dpc_comm_services~commit_work( iv_rfc_dest = lv_destination ).

  ENDMETHOD.

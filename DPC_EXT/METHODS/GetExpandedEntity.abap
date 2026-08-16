*&---------------------------------------------------------------------
*& GET_EXPANDED_ENTITY - custom $expand handling for a SINGLE entity
*&---------------------------------------------------------------------
*& REFERENCE COOKBOOK - READ BEFORE COPYING
*&
*& Independent reference method body. Not intended to be pasted together
*& with the other files into one DPC_EXT class. Types such as
*& zcl_zsm_001_mpc_ext=>ts_deep and FM ZSM_GET_DATA are placeholders.
*&
*& Routing reminder:
*&   GET .../DeepSet('1')?$expand=Items -> GET_EXPANDED_ENTITY    (ER_ENTITY)
*&   GET .../DeepSet?$expand=Items      -> GET_EXPANDED_ENTITYSET (ER_ENTITYSET)
*&
*& SIGNATURE
*& The super call below matches the documented interface of
*& /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITY:
*&
*&   IMPORTING  iv_entity_name  iv_entity_set_name  iv_source_name
*&              it_key_tab  it_navigation_path
*&              io_expand  io_tech_request_context
*&   EXPORTING  er_entity  es_response_context
*&              et_expanded_clauses  et_expanded_tech_clauses
*&
*& A single entity is addressed by key, so this method receives NO query
*& options: no is_paging, no it_filter_select_options, no it_order and no
*& iv_filter_string. Those belong to GET_EXPANDED_ENTITYSET.
*&---------------------------------------------------------------------

  METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entity.

    DATA ls_deep    TYPE zcl_zsm_001_mpc_ext=>ts_deep.
    DATA ls_header  TYPE zsm_s_header.
    DATA lt_items   TYPE zsm_tt_item.
    DATA lt_objects TYPE zsm_tt_object.
    DATA lt_return  TYPE bapiret2_t.
    DATA lv_error   TYPE abap_bool.

    CASE io_tech_request_context->get_entity_type_name( ).
      WHEN 'Deep'.

        " ---------------------------------------------------------------
        " 1) Key extraction.
        "    it_key_tab carries the EXTERNAL key value, so the conversion
        "    exit still has to be applied before hitting the backend.
        "    Type the key variable from the real domain - never CHAR1,
        "    which silently truncates.
        " ---------------------------------------------------------------
        DATA(lv_key) = CONV zsm_key( VALUE #( it_key_tab[ name = 'Key' ]-value OPTIONAL ) ).

        IF lv_key IS INITIAL.
          " Missing key is a client error, not a silent empty response.
          DATA(lo_message_container) = mo_context->get_message_container( ).
          lo_message_container->add_message_text_only( iv_msg_type = 'E'
                                                       iv_msg_text = 'Key is missing in the request' ).

          RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                                  message_container = lo_message_container ).
        ENDIF.

        lv_key = |{ lv_key ALPHA = IN }|.

        " ---------------------------------------------------------------
        " 2) Read header + children in one backend call.
        " ---------------------------------------------------------------
        CALL FUNCTION 'ZSM_GET_DATA'
          EXPORTING iv_key     = lv_key
          IMPORTING ev_error   = lv_error
                    es_header  = ls_header
          TABLES    it_items   = lt_items
                    it_objects = lt_objects
                    et_return  = lt_return.

        lo_message_container = mo_context->get_message_container( ).

        " ---------------------------------------------------------------
        " 3) A backend failure must not be reported as an empty success.
        " ---------------------------------------------------------------
        IF lv_error = abap_true OR line_exists( lt_return[ type = 'E' ] ).
          lo_message_container->add_messages_from_bapi( it_bapi_messages          = lt_return
                                                        iv_add_to_response_header = abap_true ).

          RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                                  message_container = lo_message_container ).
        ENDIF.

        " ---------------------------------------------------------------
        " 4) Not found.
        "    OData V2 expects 404 for a GET on a non-existent entity.
        "    A business exception carrying a clear message is the portable
        "    form. Gateway also offers message codes that map to specific
        "    HTTP statuses, but the exact constant is release-specific -
        "    NEEDS OFFICIAL VERIFICATION before using one here.
        " ---------------------------------------------------------------
        IF ls_header IS INITIAL.
          lo_message_container->add_message_text_only( iv_msg_type = 'E'
                                                       iv_msg_text = 'Entity not found' ).

          RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                                  message_container = lo_message_container ).
        ENDIF.

        " ---------------------------------------------------------------
        " 5) Build ONE deep structure and return exactly that structure.
        "    Nested component names must match the navigation properties.
        " ---------------------------------------------------------------
        ls_deep = VALUE #( BASE CORRESPONDING #( ls_header )
                           items   = CORRESPONDING #( lt_items )
                           objects = CORRESPONDING #( lt_objects ) ).

        copy_data_to_ref( EXPORTING is_data = ls_deep
                          CHANGING  cr_data = er_entity ).

        " Tell the framework which $expand clauses were resolved here,
        " otherwise it will try to resolve them again.
        et_expanded_tech_clauses = VALUE #( ( `ITEMS` ) ( `OBJECTS` ) ).

        lo_message_container->add_messages_from_bapi( it_bapi_messages          = lt_return
                                                      iv_add_to_response_header = abap_true ).

      WHEN OTHERS.
        " Delegate everything else - and let framework exceptions propagate.
        super->/iwbep/if_mgw_appl_srv_runtime~get_expanded_entity(
          EXPORTING iv_entity_name           = iv_entity_name
                    iv_entity_set_name       = iv_entity_set_name
                    iv_source_name           = iv_source_name
                    it_key_tab               = it_key_tab
                    it_navigation_path       = it_navigation_path
                    io_expand                = io_expand
                    io_tech_request_context  = io_tech_request_context
          IMPORTING er_entity                = er_entity
                    es_response_context      = es_response_context
                    et_expanded_clauses      = et_expanded_clauses
                    et_expanded_tech_clauses = et_expanded_tech_clauses ).
    ENDCASE.

  ENDMETHOD.

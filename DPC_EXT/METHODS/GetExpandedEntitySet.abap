*&---------------------------------------------------------------------
*& GET_EXPANDED_ENTITYSET - custom $expand handling for a collection
*&---------------------------------------------------------------------
*& REFERENCE COOKBOOK - READ BEFORE COPYING
*&
*& This file contains INDEPENDENT reference method bodies.
*& They are NOT meant to be pasted together into one DPC_EXT class:
*&   - each METHOD block is a separate, self-contained example
*&   - identifiers such as zcl_zsm_*_mpc_ext, zsm_*, ZSM_GET_DATA are
*&     placeholders - replace them with the types your SEGW project
*&     generated
*&   - helper objects (mo_context, lo_dp_facade, ...) come from the
*&     generated DPC class
*&
*& Implement GET_EXPANDED_ENTITYSET (not GET_EXPANDED_ENTITY) whenever a
*& COLLECTION is requested with $expand. The framework routes:
*&   GET .../HeaderSet('1')?$expand=Items  -> GET_EXPANDED_ENTITY    (ER_ENTITY)
*&   GET .../HeaderSet?$expand=Items       -> GET_EXPANDED_ENTITYSET (ER_ENTITYSET)
*&
*& NEEDS OFFICIAL VERIFICATION: the exact parameter list of
*& /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITYSET varies by
*& SAP_GWFND release. Check the interface in your own system (SE24) and
*& adjust the super call below accordingly.
*&---------------------------------------------------------------------

  " GET_EXPANDED_ENTITYSET: read header + children in one backend call and
  " report the navigation properties that were resolved here.
  METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entityset.

    DATA lt_deep    TYPE STANDARD TABLE OF zcl_zsm_001_mpc_ext=>ts_deep WITH DEFAULT KEY.
    DATA ls_header  TYPE zsm_s_header.
    DATA lt_items   TYPE zsm_tt_item.
    DATA lt_objects TYPE zsm_tt_object.
    DATA lt_return  TYPE bapiret2_t.
    DATA lv_error   TYPE abap_bool.

    CASE io_tech_request_context->get_entity_type_name( ).
      WHEN 'Deep'.

        " ---------------------------------------------------------------
        " 1) $filter -> ABAP range
        "    convert_select_option( ) applies the conversion exit and
        "    preserves the real sign/option semantics (EQ, BT, CP, ...).
        " ---------------------------------------------------------------
        DATA(lo_filter) = io_tech_request_context->get_filter( ).
        DATA lr_key TYPE RANGE OF zsm_key.

        LOOP AT lo_filter->get_filter_select_options( ) ASSIGNING FIELD-SYMBOL(<ls_select_option>).
          CASE <ls_select_option>-property.
            WHEN 'Key'.
              lo_filter->convert_select_option( EXPORTING is_select_option = <ls_select_option>
                                                IMPORTING et_select_option = lr_key ).
          ENDCASE.
        ENDLOOP.

        " ---------------------------------------------------------------
        " 2) Read header + children in ONE backend call.
        "    Pass the whole range - do not silently reduce a multi-value
        "    filter to its first entry.
        " ---------------------------------------------------------------
        CALL FUNCTION 'ZSM_GET_DATA'
          EXPORTING ir_key     = lr_key
          IMPORTING ev_error   = lv_error
                    es_header  = ls_header
          TABLES    it_items   = lt_items
                    it_objects = lt_objects
                    et_return  = lt_return.

        " ---------------------------------------------------------------
        " 3) Backend failure must NOT become an empty HTTP 200.
        " ---------------------------------------------------------------
        DATA(lo_message_container) = mo_context->get_message_container( ).

        IF lv_error = abap_true OR line_exists( lt_return[ type = 'E' ] ).
          lo_message_container->add_messages_from_bapi( it_bapi_messages          = lt_return
                                                        iv_add_to_response_header = abap_true ).

          RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                                  message_container = lo_message_container ).
        ENDIF.

        " ---------------------------------------------------------------
        " 4) Build the deep line.
        "    The nested component names (ITEMS / OBJECTS) must match the
        "    navigation properties of the entity type - see
        "    MPC_EXT/TYPES/Types.abap.
        " ---------------------------------------------------------------
        APPEND VALUE #( BASE CORRESPONDING #( ls_header )
                        items   = CORRESPONDING #( lt_items )
                        objects = CORRESPONDING #( lt_objects ) ) TO lt_deep.

        " Alternative construction style - functionally equivalent, pick ONE:
*        APPEND INITIAL LINE TO lt_deep ASSIGNING FIELD-SYMBOL(<ls_deep>).
*        <ls_deep>         = CORRESPONDING #( ls_header ).
*        <ls_deep>-items   = CORRESPONDING #( lt_items ).
*        <ls_deep>-objects = CORRESPONDING #( lt_objects ).

        " ---------------------------------------------------------------
        " 5) Return the collection and declare which $expand clauses this
        "    method already resolved. Without et_expanded_tech_clauses the
        "    framework tries to resolve them again.
        "    et_expanded_tech_clauses -> technical (ABAP) component names.
        " ---------------------------------------------------------------
        copy_data_to_ref( EXPORTING is_data = lt_deep
                          CHANGING  cr_data = er_entityset ).

        et_expanded_tech_clauses = VALUE #( ( `ITEMS` ) ( `OBJECTS` ) ).

        " Non-error messages (S / W / I) still belong in the response.
        lo_message_container->add_messages_from_bapi( it_bapi_messages          = lt_return
                                                      iv_add_to_response_header = abap_true ).

      WHEN OTHERS.
        " Everything this method does not handle itself must fall back to
        " the generated implementation - and its exceptions must propagate.
        super->/iwbep/if_mgw_appl_srv_runtime~get_expanded_entityset(
          EXPORTING iv_entity_name           = iv_entity_name
                    iv_entity_set_name       = iv_entity_set_name
                    iv_source_name           = iv_source_name
                    it_filter_select_options = it_filter_select_options
                    is_paging                = is_paging
                    it_key_tab               = it_key_tab
                    it_navigation_path       = it_navigation_path
                    it_order                 = it_order
                    iv_filter_string         = iv_filter_string
                    iv_search_string         = iv_search_string
                    io_expand                = io_expand
                    io_tech_request_context  = io_tech_request_context
          IMPORTING er_entityset             = er_entityset
                    es_response_context      = es_response_context
                    et_expanded_clauses      = et_expanded_clauses
                    et_expanded_tech_clauses = et_expanded_tech_clauses ).
    ENDCASE.

  ENDMETHOD.


*&---------------------------------------------------------------------
*& Independent example - multi-level deep structure (header -> items -> details)
*&
*& Shows the SHAPE of a two-level expand. The data is hard-coded on
*& purpose so the nesting is readable; replace it with your own read
*& logic.
*&---------------------------------------------------------------------
  METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entityset.

    CASE io_tech_request_context->get_entity_type_name( ).
      WHEN 'Header'.

        DATA lt_details         TYPE STANDARD TABLE OF zcl_zsm_gw_001_mpc_ext=>ts_detail    WITH DEFAULT KEY.
        DATA lt_multi_item_deep TYPE STANDARD TABLE OF zcl_zsm_gw_001_mpc_ext=>ts_multi_item_deep WITH DEFAULT KEY.
        DATA lt_multi_deep      TYPE STANDARD TABLE OF zcl_zsm_gw_001_mpc_ext=>ts_multi_deep      WITH DEFAULT KEY.

        " Sample data only - each row carries its own components.
        lt_details = VALUE #( ( id = '01' key = '001' type = 'ABC' message = 'Test I'   )
                              ( id = '01' key = '001' type = 'ABC' message = 'Test II'  )
                              ( id = '01' key = '001' type = 'DEF' message = 'Test III' )
                              ( id = '01' key = '002' type = 'ABC' message = 'Test IV'  )
                              ( id = '01' key = '002' type = 'GHI' message = 'Test V'   ) ).

        lt_multi_item_deep = VALUE #( ( id      = '01'
                                        key     = '001'
                                        text    = 'Text'
                                        details = CORRESPONDING #( lt_details ) ) ).

        lt_multi_deep = VALUE #( ( id    = '01'
                                   value = 'JDOE'
                                   items = CORRESPONDING #( lt_multi_item_deep ) ) ).

        copy_data_to_ref( EXPORTING is_data = lt_multi_deep
                          CHANGING  cr_data = er_entityset ).

        " Both nesting levels are resolved here, so both are declared.
        et_expanded_tech_clauses = VALUE #( ( `ITEMS` ) ( `DETAILS` ) ).

      WHEN OTHERS.
        super->/iwbep/if_mgw_appl_srv_runtime~get_expanded_entityset(
          EXPORTING iv_entity_name           = iv_entity_name
                    iv_entity_set_name       = iv_entity_set_name
                    iv_source_name           = iv_source_name
                    it_filter_select_options = it_filter_select_options
                    is_paging                = is_paging
                    it_key_tab               = it_key_tab
                    it_navigation_path       = it_navigation_path
                    it_order                 = it_order
                    iv_filter_string         = iv_filter_string
                    iv_search_string         = iv_search_string
                    io_expand                = io_expand
                    io_tech_request_context  = io_tech_request_context
          IMPORTING er_entityset             = er_entityset
                    es_response_context      = es_response_context
                    et_expanded_clauses      = et_expanded_clauses
                    et_expanded_tech_clauses = et_expanded_tech_clauses ).
    ENDCASE.

  ENDMETHOD.

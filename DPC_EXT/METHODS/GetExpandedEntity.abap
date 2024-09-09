METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entity.

  DATA(lt_returns) = VALUE bapiret2_t( ).
  DATA(lv_error)   = abap_false.

  CASE io_tech_request_context->get_entity_type_name( ).
    WHEN 'Deep'.
      DATA: ls_deep TYPE zsm_deep,
            lv_key  TYPE char1.

      LOOP AT it_key_tab INTO DATA(is_key).
        CASE is_key-name.
          WHEN 'Key'.
            lv_key = |{ is_key-value ALPHA = IN }|.
        ENDCASE.
      ENDLOOP.

      CALL FUNCTION 'ZSM_GET_DATA'
        IMPORTING
          ev_error   = lv_error
          ev_key     = lv_key
        TABLES
          is_header  = ls_header
          it_items	 = lt_items
          it_objects = lt_objects
          et_return  = lt_returns.

      IF lv_error EQ abap_false.
        ls_deep         = CORRESPONDING zcl_zsm_deep=>ts_deep( ls_header ).
        ls_data-items   = CORRESPONDING #( lt_items ).
        ls_data-objects = CORRESPONDING #( lt_objects ).
      ENDIF.

      copy_data_to_ref( EXPORTING is_data = ls_data CHANGING cr_data = er_entity ).
      et_expanded_tech_clauses = VALUE #( ( `ITEMS` ) ( `OBJECTS` ) ).

      mo_context->get_message_container( )->add_messages_from_bapi( it_bapi_messages          = lt_returns
                                                					          iv_add_to_response_header = abap_true ).
    WHEN OTHERS.
      TRY.
        super->/iwbep/if_mgw_appl_srv_runtime~get_expanded_entity( EXPORTING iv_entity_name           = iv_entity_name
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
        CATCH /iwbep/cx_mgw_busi_exception /iwbep/cx_mgw_tech_exception.
      ENDTRY.
  ENDCASE.
ENDMETHOD.
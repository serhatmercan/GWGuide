METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entity.

  DATA(returns)   = VALUE bapiret2_t( ).
  DATA(has_error) = abap_false.

  CASE io_tech_request_context->get_entity_type_name( ).
    WHEN 'Deep'.

      DATA(ls_deep) = VALUE zsm_deep( ).
      DATA lv_key TYPE char1.

      LOOP AT it_key_tab INTO DATA(is_key).
        CASE is_key-name.
          WHEN 'Key'.
            lv_key = |{ is_key-value ALPHA = IN }|.
        ENDCASE.
      ENDLOOP.

      CALL FUNCTION 'ZSM_GET_DATA'
        IMPORTING
          ev_error   = has_error
          ev_key     = lv_key
        TABLES
          is_header  = ls_header
          it_items	 = lt_items
          it_objects = lt_objects
          et_return  = returns.

      IF has_error = abap_false.
        DATA(ls_data)      = CORRESPONDING zcl_zsm_deep=>ts_deep( ls_header ).
        ls_data-to_items   = CORRESPONDING #( lt_items ).
        ls_data-to_objects = CORRESPONDING #( lt_objects ).
      ENDIF.

      copy_data_to_ref( EXPORTING is_data = plan_deep CHANGING cr_data = er_entity ).
      et_expanded_tech_clauses = VALUE #( ( `TO_ITEMS` ) ( `TO_OBJECTS` ) ).

      DATA(message_container) = mo_context->get_message_container( ).

      message_container->add_messages_from_bapi( it_bapi_messages          = returns
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
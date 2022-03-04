METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entity.

  DATA(returns)        = VALUE bapiret2_t( ).
  DATA(has_error)      = abap_false.
  DATA(filter)         = io_tech_request_context->get_filter( ).
  DATA(select_options) = filter->get_filter_select_options( ).
  DATA range_key       TYPE RANGE OF zsm_key.

  CASE io_tech_request_context->get_entity_type_name( ).
    WHEN 'Deep'.

      DATA(ls_deep) TYPE TABLE OF zcl_zsm_deep=>ts_deep.
      DATA lv_key TYPE char1.

      LOOP AT select_options ASSIGNING FIELD-SYMBOL(<select_option>).
        CASE <select_option>-property.
          WHEN 'Key'.
            filter->convert_select_option( EXPORTING is_select_option = <select_option> IMPORTING et_select_option = range_key ).
            lv_key = |{ range_key[ 1 ]-low. ALPHA = IN }|.
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
    	APPEND INITIAL LINE TO ls_deep ASSIGNING FIELD-SYMBOL(<fs_data>).
        <fs_data>   		 = CORRESPONDING #( ls_header ).
        <fs_data>-to_items   = CORRESPONDING #( lt_items ).
        <fs_data>-to_objects = CORRESPONDING #( lt_objects ).
      ENDIF.

      copy_data_to_ref( EXPORTING is_data = ls_deep CHANGING cr_data = er_entityset ).
      et_expanded_tech_clauses = VALUE #( ( `TO_ITEMS` ) ( `TO_OBJECTS` ) ).

      mo_context->get_message_container( )->add_messages_from_bapi( it_bapi_messages          = returns
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
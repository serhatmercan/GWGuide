METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entity.

  DATA(lo_filter)         = io_tech_request_context->get_filter( ).
  DATA(lt_select_options) = lo_filter->get_filter_select_options( ).  
  DATA(lt_returns)        = VALUE bapiret2_t( ).
  DATA(lv_error)          = abap_false.
    
  DATA lt_range_keys TYPE RANGE OF zsm_key.

  CASE io_tech_request_context->get_entity_type_name( ).
    WHEN 'Deep'.

      DATA ls_deep TYPE TABLE OF zcl_zsm_deep=>ts_deep.
      DATA lv_key TYPE char1.

      LOOP AT lt_select_options ASSIGNING FIELD-SYMBOL(<fs_select_option>).
        CASE <fs_select_option>-property.
          WHEN 'Key'.
            lo_filter->convert_select_option( EXPORTING is_select_option = <fs_select_option> IMPORTING et_select_option = lt_range_keys ).
            lv_key = |{ lt_range_keys[ 1 ]-low ALPHA = IN }|.
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
    	APPEND INITIAL LINE TO ls_deep ASSIGNING FIELD-SYMBOL(<fs_data>).
        <fs_data>   		  = CORRESPONDING #( ls_header ).
        <fs_data>-items   = CORRESPONDING #( lt_items ).
        <fs_data>-objects = CORRESPONDING #( lt_objects ).
      ENDIF.

      copy_data_to_ref( EXPORTING is_data = ls_deep CHANGING cr_data = er_entityset ).
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
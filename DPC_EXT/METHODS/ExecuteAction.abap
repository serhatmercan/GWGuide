  METHOD /iwbep/if_mgw_appl_srv_runtime~execute_action.

    DATA: ls_parameter TYPE /iwbep/s_mgw_name_value_pair,
          lt_return    TYPE bapiret2_tab,
          ls_deep	   TYPE zcl_zsm_mpc_ext=>ts_deep,
          ls_value     TYPE zsm_s_value.

	io_tech_request_context->get_converted_parameters( IMPORTING es_parameter_values = ls_value ).

    DATA(lo_parameters) = io_tech_request_context->get_parameters( ).

    IF iv_action_name = 'GetData'.

      ls_deep-key = VALUE #( lo_parameters[ name = 'KEY' ]-value OPTIONAL ).

      CALL FUNCTION 'ZSM_F_DATA'
        EXPORTING
          iv_key  = ls_deep-key
        IMPORTING
          ev_key  = ls_deep-key
        TABLES
        et_return = lt_return.

      IF lt_return[] IS NOT INITIAL.
        me->/iwbep/if_sb_dpc_comm_services~rfc_save_log(
          EXPORTING
            iv_entity_type = CONV string( lv_entity_name )
            it_return      = lt_return
            it_key_tab     = it_key_tab ).
      ENDIF.

      copy_data_to_ref( EXPORTING is_data = ls_deep CHANGING cr_data = er_data ).
      
      mo_context->get_message_container( )->add_messages_from_bapi( it_bapi_messages          = lt_return
                                            						iv_add_to_response_header = abap_true ).                

    ENDIF.

  ENDMETHOD.
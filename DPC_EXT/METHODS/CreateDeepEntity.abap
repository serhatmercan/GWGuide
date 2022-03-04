  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.

    DATA(lv_entity_name) = io_tech_request_context->get_entity_type_name( ).
	DATA lt_return TYPE bapiret2_t.

    IF iv_entity_name = 'Header'.

      DATA: ls_deep 	TYPE zcl_zsm_mpc_ext=>ts_deep,
            ls_header   TYPE zsm_s_header,
            lt_items	TYPE TABLE OF zsm_s_header.

      io_data_provider->read_entry_data( IMPORTING es_data = ls_deep ).
	
      ls_header	= CORRESPONDING #( ls_deep ).
      lt_items	= CORRESPONDING #( ls_deep-to_items ).

      CALL FUNCTION 'ZSM_F_DATA'
        EXPORTING
          is_header	= ls_header
        TABLES
          it_items  = lt_items
          et_return = lt_return.

      IF lt_return[] IS NOT INITIAL.
        me->/iwbep/if_sb_dpc_comm_services~rfc_save_log(
          EXPORTING
            iv_entity_type = CONV string( lv_entity_name )
            it_return      = lt_return
            it_key_tab     = it_key_tab ).
      ENDIF.

	  mo_context->get_message_container( )->add_messages_from_bapi( it_bapi_messages          = lt_return
                                            						iv_add_to_response_header = abap_true ).   

      me->/iwbep/if_sb_dpc_comm_services~commit_work( ).

      copy_data_to_ref(
        EXPORTING
          is_data = ls_deep
        CHANGING
          cr_data = er_deep_entity ).
	
     ENDIF.

  ENDMETHOD.
METHOD XXX_UPDATE_ENTITY.
*---------------------*
* - Read After Create -
*---------------------*
	TRY.
    DATA ls_data LIKE er_entity.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).       

  CATCH /iwbep/cx_mgw_tech_exception.
  ENDTRY.

	er_entity-key = ls_data-key.
	
	mo_context->get_message_container( )->add_messages_from_bapi( it_bapi_messages          = lt_return
                                            					          iv_add_to_response_header = abap_true ).
ENDMETHOD.
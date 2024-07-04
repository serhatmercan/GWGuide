METHOD HEADER_CREATE_ENTITY.
*-------------------------*
* - Read After Create - I
*-------------------------*

	TRY.
        DATA: ls_data   LIKE er_entity,
              ls_return TYPE bapiret2,
              lt_return TYPE bapiret2_t.

        io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).       

      CATCH /iwbep/cx_mgw_tech_exception.
    ENDTRY.

	er_entity-key = ls_data-key.
  
  APPEND ls_return TO lt_return.

	mo_context->get_message_container( )->add_messages_from_bapi( it_bapi_messages          = lt_return
                                            					          iv_add_to_response_header = abap_true ).

*-------------------------*
* - Read After Create - II
*-------------------------*
er_entity = CORRESPONDING #( is_data ).

mo_context->get_message_container( )->add_messages_from_bapi( it_bapi_messages          = et_return
                                                              iv_add_to_response_header = External_true ).
ENDMETHOD.
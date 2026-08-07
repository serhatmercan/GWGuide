  " CREATE_ENTITY: read back the created entry from the data provider and return it, plus BAPI message propagation
  METHOD header_create_entity.
    " ------------------------
    " Read After Create   -
    " ------------------------
    TRY.
        DATA ls_data   LIKE er_entity.
        DATA ls_return TYPE bapiret2.
        DATA lt_return TYPE bapiret2_t.

        io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).

      CATCH /iwbep/cx_mgw_tech_exception INTO DATA(lx_tech_exception).
        mo_context->get_message_container( )->add_message(iv_msgid = lx_tech_exception->get_text( )).
    ENDTRY.

    er_entity-key = ls_data-key.

    APPEND ls_return TO lt_return.

    mo_context->get_message_container( )->add_messages_from_bapi( it_bapi_messages          = lt_return
                                                                  iv_add_to_response_header = abap_true ).
  ENDMETHOD.

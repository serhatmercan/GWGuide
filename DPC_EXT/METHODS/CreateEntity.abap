*&---------------------------------------------------------------------
*& CREATE_ENTITY - POST on an entity set
*&---------------------------------------------------------------------
*& REFERENCE COOKBOOK - READ BEFORE COPYING
*&
*& SKELETON EXAMPLE. It demonstrates the Gateway plumbing of a create:
*& reading the request payload, returning the created entity, and
*& propagating BAPI messages. It performs NO persistence - no INSERT, no
*& BAPI call - and therefore owns no transaction.
*&
*& For a complete create including the commit rule see
*& CreateDeepEntity.abap; for the remote-call variant see UpdateEntity.abap.
*&
*& AUTHORIZATION BOUNDARY
*& Gateway authenticates the caller and checks service access; it does not
*& authorize the business operation. Add the application's own
*& authorization check before any persistence. No authorization object is
*& invented in this repository.
*&---------------------------------------------------------------------

  METHOD header_create_entity.

    DATA ls_data   LIKE er_entity.
    DATA lt_return TYPE bapiret2_t.

    DATA(lo_message_container) = mo_context->get_message_container( ).

    " ---------------------------------------------------------------
    " 1) Read the request payload.
    "    read_entry_data( ) is the only supported way to get the POST body
    "    in CREATE_ENTITY. A malformed payload is a client error: raise,
    "    do not fall through and report success.
    " ---------------------------------------------------------------
    TRY.
        io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).
      CATCH /iwbep/cx_mgw_tech_exception INTO DATA(lx_tech_exception).
        " add_message_text_only( ) is the API for free text.
        " add_message( ) expects a message CLASS id / number / variables -
        " passing an exception text into iv_msg_id truncates it to the
        " message-id field length and produces a meaningless message.
        lo_message_container->add_message_text_only( iv_msg_type = 'E'
                                                     iv_msg_text = 'Request payload could not be read' ).

        RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                                message_container = lo_message_container
                                previous          = lx_tech_exception ).
    ENDTRY.

    " ---------------------------------------------------------------
    " 2) <-- perform the actual create here (BAPI / RFC / INSERT).
    "        Then apply the commit rule shown in CreateDeepEntity.abap:
    "          - add the messages to the container
    "          - on E / A / X: raise, do NOT commit
    "          - only on success: commit
    " ---------------------------------------------------------------

    " ---------------------------------------------------------------
    " 3) Return the CREATED entity.
    "    A real read-after-create re-reads the persisted record so the
    "    client receives the server-assigned key; echoing the request
    "    payload (as done here, because nothing was persisted) does not
    "    give the client a usable key.
    " ---------------------------------------------------------------
    er_entity = ls_data.

    " ---------------------------------------------------------------
    " 4) Propagate business messages, if the create produced any.
    "    Only add lt_return when it actually holds messages - appending an
    "    empty BAPIRET2 line emits a blank sap-message header entry that
    "    Fiori clients will try to display.
    " ---------------------------------------------------------------
    IF lt_return IS NOT INITIAL.
      lo_message_container->add_messages_from_bapi( it_bapi_messages          = lt_return
                                                    iv_add_to_response_header = abap_true ).
    ENDIF.

  ENDMETHOD.

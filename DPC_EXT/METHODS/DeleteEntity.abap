*&---------------------------------------------------------------------
*& DELETE_ENTITY - DELETE on a single entity
*&---------------------------------------------------------------------
*& REFERENCE COOKBOOK - READ BEFORE COPYING
*&
*& Independent reference method body. zsm_t_data is a placeholder for your
*& own custom table.
*&
*& AUTHORIZATION BOUNDARY - READ THIS BEFORE COPYING THE DELETE
*& This example demonstrates Gateway plumbing only. SAP Gateway
*& authenticated the caller and checked that the user may reach the
*& SERVICE; it did NOT decide whether that user may delete THIS business
*& object. Production code must enforce the business authorization
*& appropriate to the application before executing the write. This
*& repository deliberately does not invent an authorization object,
*& because the correct one is application-specific.
*&
*& TRANSACTION (SAP LUW)
*& No COMMIT WORK is issued here on purpose. Transaction ownership for a
*& direct database write depends on the request context:
*&   - a standalone request may be committed by the framework at the end
*&     of the request
*&   - inside a $batch changeset the changeset is meant to be atomic, so
*&     committing per operation breaks that atomicity (see BATCH/README.md)
*& Decide who owns the LUW for your service and write it down. Do not add
*& a blanket "commit after every write" rule. The exact framework
*& behaviour is release-specific - NEEDS OFFICIAL VERIFICATION.
*&---------------------------------------------------------------------

  METHOD xxxset_delete_entity.

    " ---------------------------------------------------------------
    " 1) Key extraction.
    "    it_key_tab carries the EXTERNAL key value, so the conversion exit
    "    must still be applied. get_converted_keys( ) does this for you and
    "    is the preferred route - see GetEntity.abap.
    " ---------------------------------------------------------------
    DATA(lv_material) = CONV matnr( VALUE #( it_key_tab[ name = 'Material' ]-value OPTIONAL ) ).

    DATA(lo_message_container) = mo_context->get_message_container( ).

    IF lv_material IS INITIAL.
      lo_message_container->add_message_text_only( iv_msg_type = 'E'
                                                   iv_msg_text = 'Key is missing in the request' ).

      RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                              message_container = lo_message_container ).
    ENDIF.

    lv_material = |{ lv_material ALPHA = IN }|.

    " ---------------------------------------------------------------
    " 2) <-- BUSINESS AUTHORIZATION CHECK BELONGS HERE.
    "        An OData DELETE reaching this line means only that the caller
    "        is authenticated and may call the service.
    " ---------------------------------------------------------------

    " ---------------------------------------------------------------
    " 3) Delete.
    "    Supply the COMPLETE key of the table. If zsm_t_data has a
    "    composite key, a WHERE clause on one field deletes every matching
    "    row - an OData DELETE must affect exactly the addressed entity.
    " ---------------------------------------------------------------
    DELETE FROM zsm_t_data WHERE material = lv_material.

    " ---------------------------------------------------------------
    " 4) Not found.
    "    OData V2 expects 404 for a DELETE on a non-existent resource.
    "    Without this check, deleting the same key twice succeeds twice.
    "    A business exception with a clear message is the portable form;
    "    Gateway message codes that map to a specific HTTP status are
    "    release-specific - NEEDS OFFICIAL VERIFICATION before using one.
    " ---------------------------------------------------------------
    IF sy-subrc <> 0.
      lo_message_container->add_message_text_only( iv_msg_type = 'E'
                                                   iv_msg_text = 'Entity not found' ).

      RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                              message_container = lo_message_container ).
    ENDIF.

  ENDMETHOD.

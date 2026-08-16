*&---------------------------------------------------------------------
*& GET_ENTITY - read a single entity by key
*&---------------------------------------------------------------------
*& REFERENCE COOKBOOK - READ BEFORE COPYING
*&
*& Independent reference method body. Types are placeholders for your own
*& generated MPC types.
*&
*& The two key-reading APIs are NOT interchangeable:
*&
*&   get_converted_keys( )  keys with the CONVERSION EXIT already applied
*&                          (internal format - ready for a database
*&                          comparison).  <-- PREFERRED
*&
*&   get_keys( )            the RAW external key values exactly as they
*&                          appeared in the URI. You must apply the
*&                          conversion exit yourself.
*&
*& Getting this wrong produces the classic intermittent "entity not found":
*& MARA-MATNR is stored zero-padded, so WHERE matnr = '4711' finds nothing
*& while WHERE matnr = '000000000000004711' works.
*&---------------------------------------------------------------------

  METHOD xxxset_get_entity.

    DATA(lo_message_container) = mo_context->get_message_container( ).

    " ---------------------------------------------------------------
    " Approach 1 (PREFERRED) - get_converted_keys( )
    " Fills a structure of the generated key type, conversion exits
    " already applied. Nothing further to do before selecting.
    " ---------------------------------------------------------------
    DATA ls_keys TYPE zcl_zsm_mpc=>ts_xxx.

    io_tech_request_context->get_converted_keys( IMPORTING es_key_values = ls_keys ).

    " ---------------------------------------------------------------
    " Approach 2 - get_keys( ), raw external values.
    " Use it when you need the value exactly as the client sent it.
    " Remember the ALPHA/conversion-exit step.
    " ---------------------------------------------------------------
*    DATA(lt_keys)     = io_tech_request_context->get_keys( ).
*    DATA(lv_material) = CONV matnr( VALUE #( lt_keys[ name = 'Material' ]-value OPTIONAL ) ).
*    lv_material = |{ lv_material ALPHA = IN }|.     " <- do NOT omit this

    IF ls_keys-material IS INITIAL.
      lo_message_container->add_message_text_only( iv_msg_type = 'E'
                                                   iv_msg_text = 'Key is missing in the request' ).

      RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                              message_container = lo_message_container ).
    ENDIF.

    " ---------------------------------------------------------------
    " <-- BUSINESS AUTHORIZATION CHECK BELONGS HERE.
    "     Reaching this line only means the caller is authenticated and
    "     may call the service - not that they may see this record.
    " ---------------------------------------------------------------

    " ---------------------------------------------------------------
    " Read. Select the fields the entity type actually exposes rather
    " than SELECT * - on a wide standard table most columns would be read
    " and discarded by INTO CORRESPONDING FIELDS OF.
    " ---------------------------------------------------------------
    SELECT SINGLE matnr, mtart, matkl, meins
      FROM mara
      WHERE matnr = @ls_keys-material
      INTO CORRESPONDING FIELDS OF @er_entity.

    " ---------------------------------------------------------------
    " Not found -> OData V2 expects 404.
    " Returning an entity populated with only the echoed key and HTTP 200
    " makes a missing record indistinguishable from an empty one, and a
    " Fiori object page renders blank with no explanation.
    "
    " A business exception with a clear message is the portable form.
    " Gateway also offers message codes that map to a specific HTTP
    " status, but the exact constant is release-specific -
    " NEEDS OFFICIAL VERIFICATION before using one here.
    " ---------------------------------------------------------------
    IF sy-subrc <> 0.
      lo_message_container->add_message_text_only( iv_msg_type = 'E'
                                                   iv_msg_text = 'Entity not found' ).

      RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                              message_container = lo_message_container ).
    ENDIF.

  ENDMETHOD.

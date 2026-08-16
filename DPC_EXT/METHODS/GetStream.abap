*&---------------------------------------------------------------------
*& GET_STREAM - return a media resource ($value)
*&---------------------------------------------------------------------
*& REFERENCE COOKBOOK - READ BEFORE COPYING
*&
*& Independent reference method body. Types and FM ZSM_GET_DMS are
*& placeholders for your own artefacts.
*&
*& Triggered by:  GET .../DocumentSet('0000000001')/$value
*&
*& AUTHORIZATION BOUNDARY - READ THIS BEFORE COPYING
*& The document key comes entirely from the REQUEST URI. Gateway
*& authenticated the caller and checked that the user may reach the
*& SERVICE; it did NOT decide whether that user may read THIS document.
*& Without an explicit business authorization check, any authenticated
*& user who can reach the service can enumerate keys and download every
*& document (an insecure direct object reference).
*&
*& Enforce the application's own authorization below, or verify that the
*& called function module does it - and write down which. This repository
*& deliberately does not invent an authorization object, because the
*& correct one is application-specific.
*&---------------------------------------------------------------------

  METHOD /iwbep/if_mgw_appl_srv_runtime~get_stream.

    CONSTANTS lc_default_mime TYPE string VALUE 'application/octet-stream'.

    DATA lt_documents TYPE STANDARD TABLE OF zsm_s_dms_data WITH DEFAULT KEY.
    DATA ls_stream    TYPE ty_s_media_resource.

    DATA(lo_message_container) = mo_context->get_message_container( ).

    IF io_tech_request_context->get_entity_type_name( ) <> 'Document'.
      lo_message_container->add_message_text_only( iv_msg_type = 'E'
                                                   iv_msg_text = 'Stream read is not supported for this entity' ).

      RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                              message_container = lo_message_container ).
    ENDIF.

    " ---------------------------------------------------------------
    " 1) Key from the URI. it_key_tab carries the EXTERNAL value, so the
    "    conversion exit still applies.
    " ---------------------------------------------------------------
    DATA(lv_document_id) = CONV doknr( VALUE #( it_key_tab[ name = 'DocumentID' ]-value OPTIONAL ) ).

    IF lv_document_id IS INITIAL.
      lo_message_container->add_message_text_only( iv_msg_type = 'E'
                                                   iv_msg_text = 'Document key is missing in the request' ).

      RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                              message_container = lo_message_container ).
    ENDIF.

    lv_document_id = |{ lv_document_id ALPHA = IN }|.

    " ---------------------------------------------------------------
    " 2) <-- BUSINESS AUTHORIZATION CHECK FOR lv_document_id BELONGS HERE.
    "        This is the line that prevents key enumeration.
    " ---------------------------------------------------------------

    " ---------------------------------------------------------------
    " 3) Read the content.
    " ---------------------------------------------------------------
    CALL FUNCTION 'ZSM_GET_DMS'
      EXPORTING iv_document_id = lv_document_id
      IMPORTING et_dms_data    = lt_documents.

    " ---------------------------------------------------------------
    " 4) Not found -> OData V2 expects 404, not an empty HTTP 200.
    "    A business exception with a clear message is the portable form.
    "    Gateway message codes that map to a specific HTTP status are
    "    release-specific - NEEDS OFFICIAL VERIFICATION before using one.
    " ---------------------------------------------------------------
    IF NOT line_exists( lt_documents[ 1 ] ).
      lo_message_container->add_message_text_only( iv_msg_type = 'E'
                                                   iv_msg_text = 'Document not found' ).

      RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                              message_container = lo_message_container ).
    ENDIF.

    DATA(ls_document) = lt_documents[ 1 ].

    DATA(lv_content)   = ls_document-file_content.
    DATA(lv_file_name) = CONV string( ls_document-file_name ).
    DATA(lv_mime_type) = COND string( WHEN ls_document-mime_type IS NOT INITIAL
                                      THEN CONV string( ls_document-mime_type )
                                      ELSE lc_default_mime ).

    " ---------------------------------------------------------------
    " 5) OPTIONAL: PDF metadata stamping via Adobe Document Services.
    "    Guarded on the actual MIME type - feeding non-PDF bytes to ADS is
    "    at best a wasted round trip. The ADS call is also a synchronous
    "    remote round trip on every download, so keep it conditional.
    "    Exceptions are NOT swallowed: a failed stamping must not silently
    "    serve a half-processed file as HTTP 200.
    " ---------------------------------------------------------------
    IF lv_mime_type = 'application/pdf'.
      TRY.
          DATA(lo_pdf_object) = NEW cl_fp_pdf_object( connection = 'ADS' ).

          lo_pdf_object->set_document( pdfdata = lv_content ).
          lo_pdf_object->set_metadata( metadata = VALUE sfpmetadata( title = CONV #( lv_document_id ) ) ).
          lo_pdf_object->execute( ).
          lo_pdf_object->get_document( IMPORTING pdfdata = lv_content ).

        CATCH cx_fp_runtime_internal
              cx_fp_runtime_system
              cx_fp_runtime_usage INTO DATA(lx_fp).

          " Infrastructure failure -> technical exception (5xx-class), not
          " a business error. The internal text stays in the log, not in
          " the HTTP response.
          lo_message_container->add_message_text_only(
              iv_msg_type = 'E'
              iv_msg_text = 'The document could not be prepared. Please contact support.' ).

          RAISE EXCEPTION NEW /iwbep/cx_mgw_tech_exception(
                                  message_container = lo_message_container
                                  previous          = lx_fp ).
      ENDTRY.
    ENDIF.

    " ---------------------------------------------------------------
    " 6) Content-Disposition.
    "    'attachment' is the conservative default: it stops the browser
    "    rendering attacker-supplied content inside the application's
    "    origin. Use 'inline' only when you control the content type.
    "
    "    The file name is sanitised rather than encoded: a plain ASCII
    "    quoted filename is understood everywhere. Anything that could
    "    break out of the header (quote, backslash, CR/LF) is removed.
    "    RFC 6266 also defines filename*=UTF-8''... for non-ASCII names -
    "    not implemented here, because correct behaviour across clients
    "    would need verification on a real system.
    " ---------------------------------------------------------------
    REPLACE ALL OCCURRENCES OF REGEX `[\\/:*?"<>|\r\n\t]` IN lv_file_name WITH ``.
    CONDENSE lv_file_name.

    IF lv_file_name IS INITIAL.
      lv_file_name = |{ lv_document_id }|.
    ENDIF.

    set_header( VALUE #( name  = 'Content-Disposition'
                         value = |attachment; filename="{ lv_file_name }"| ) ).

    " ---------------------------------------------------------------
    " 7) Return the stream. The MIME type here becomes the response
    "    Content-Type.
    "
    "    NEEDS OFFICIAL VERIFICATION: the concrete stream structure type
    "    (ty_s_media_resource here) depends on what the generated DPC/MPC
    "    provides in your release - check the generated class.
    " ---------------------------------------------------------------
    ls_stream = VALUE #( mime_type = lv_mime_type
                         value     = lv_content ).

    copy_data_to_ref( EXPORTING is_data = ls_stream
                      CHANGING  cr_data = er_stream ).

  ENDMETHOD.

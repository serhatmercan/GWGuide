*&---------------------------------------------------------------------
*& CREATE_STREAM - upload a media resource
*&---------------------------------------------------------------------
*& REFERENCE COOKBOOK - READ BEFORE COPYING
*&
*& Independent reference method body. Types and FM ZSM_CREATE_DMS are
*& placeholders for your own artefacts.
*&
*& Triggered by:  POST .../DocumentSet   with a binary body,
*&                Content-Type: <mime>, Slug: <file name>
*& Requires the entity type to be flagged as media in the model -
*& see DATA_MODEL/README.md.
*&
*& TRUST MODEL - THE IMPORTANT PART
*&   IT_KEY_TAB          comes from the REQUEST URI. It is the addressed
*&                       business key. Use THIS to decide what the upload
*&                       is attached to.
*&   IV_SLUG             is the client-supplied "Slug" HTTP HEADER. It is
*&                       metadata only - a suggested file name. It is
*&                       fully attacker-controllable.
*&   IS_MEDIA_RESOURCE   -value is the uploaded content, -mime_type the
*&                       client-declared content type. Also untrusted.
*&
*& Never derive a business key, an owner, or an authorization decision
*& from IV_SLUG or from the declared MIME type.
*&
*& AUTHORIZATION BOUNDARY
*& Gateway authenticates the caller and checks service access; it does not
*& authorize attaching a document to this business object. Enforce the
*& application's own authorization before storing. No authorization object
*& is invented in this repository.
*&---------------------------------------------------------------------

  METHOD /iwbep/if_mgw_appl_srv_runtime~create_stream.

    CONSTANTS lc_max_filename_len TYPE i VALUE 128.

    DATA lt_data   TYPE zsm_tt_data.
    DATA lt_return TYPE bapiret2_t.
    DATA ls_data   TYPE zcl_zsm_mpc=>ts_data.

    DATA(lo_message_container) = mo_context->get_message_container( ).

    IF iv_entity_name <> 'Document'.
      " An unsupported stream target must not return an empty HTTP 201.
      lo_message_container->add_message_text_only(
          iv_msg_type = 'E'
          iv_msg_text = |Stream create is not supported for entity { iv_entity_name }| ).

      RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                              message_container = lo_message_container ).
    ENDIF.

    " ---------------------------------------------------------------
    " 1) BUSINESS KEY - from the URI, never from the Slug header.
    " ---------------------------------------------------------------
    DATA(lv_key) = CONV zsm_key( VALUE #( it_key_tab[ name = 'Key' ]-value OPTIONAL ) ).

    IF lv_key IS INITIAL.
      lo_message_container->add_message_text_only( iv_msg_type = 'E'
                                                   iv_msg_text = 'Key is missing in the request' ).

      RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                              message_container = lo_message_container ).
    ENDIF.

    lv_key = |{ lv_key ALPHA = IN }|.

    " ---------------------------------------------------------------
    " 2) <-- BUSINESS AUTHORIZATION CHECK FOR lv_key BELONGS HERE.
    " ---------------------------------------------------------------

    " ---------------------------------------------------------------
    " 3) FILE NAME - client-supplied metadata, so validate it.
    "    Strip anything that could be interpreted as a path, and anything
    "    that could break a later HTTP header (CR/LF), then bound the
    "    length. The name is persisted and is echoed back in a
    "    Content-Disposition header by GET_STREAM.
    " ---------------------------------------------------------------
    DATA(lv_file_name) = CONV string( iv_slug ).

    REPLACE ALL OCCURRENCES OF REGEX `[\\/:*?"<>|\r\n\t]` IN lv_file_name WITH ``.
    REPLACE ALL OCCURRENCES OF `..`                       IN lv_file_name WITH ``.

    CONDENSE lv_file_name.

    IF lv_file_name IS INITIAL.
      lv_file_name = |upload_{ lv_key }|.
    ENDIF.

    IF strlen( lv_file_name ) > lc_max_filename_len.
      lv_file_name = lv_file_name(lc_max_filename_len).
    ENDIF.

    " File extension, for information only. It is derived from a
    " client-supplied name and must NOT be treated as proof of content
    " type - validate the actual content in the storage layer if the
    " distinction matters.
    DATA(lv_file_type) = COND string(
        WHEN lv_file_name CA '.'
        THEN substring_after( val = lv_file_name sub = '.' occ = -1 )
        ELSE `` ).

    " ---------------------------------------------------------------
    " 4) CONTENT and MIME type.
    "    The declared MIME type is client-supplied. Restrict it to what
    "    the application actually accepts; the list below is an example -
    "    adapt it. Also enforce a maximum upload size.
    " ---------------------------------------------------------------
    DATA(lv_mime_type) = CONV string( is_media_resource-mime_type ).
    DATA(lv_content)   = is_media_resource-value.

    IF lv_content IS INITIAL.
      lo_message_container->add_message_text_only( iv_msg_type = 'E'
                                                   iv_msg_text = 'The uploaded file is empty' ).

      RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                              message_container = lo_message_container ).
    ENDIF.

    DATA(lt_allowed_mime) = VALUE string_table( ( `application/pdf` )
                                                ( `image/png`       )
                                                ( `image/jpeg`      ) ).

    IF NOT line_exists( lt_allowed_mime[ table_line = lv_mime_type ] ).
      lo_message_container->add_message_text_only(
          iv_msg_type = 'E'
          iv_msg_text = |Content type { lv_mime_type } is not accepted| ).

      RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                              message_container = lo_message_container ).
    ENDIF.

    " ---------------------------------------------------------------
    " 5) Store.
    " ---------------------------------------------------------------
    APPEND VALUE #( key          = lv_key
                    file_name    = lv_file_name
                    file_type    = lv_file_type
                    file_content = lv_content
                    mime_type    = lv_mime_type ) TO lt_data.

    CALL FUNCTION 'ZSM_CREATE_DMS'
      EXPORTING it_import = lt_data
      IMPORTING es_data   = ls_data          " created document, incl. its id
      TABLES    et_return = lt_return.

    IF lt_return IS NOT INITIAL.
      me->/iwbep/if_sb_dpc_comm_services~rfc_save_log( iv_entity_type = iv_entity_name
                                                       it_key_tab     = it_key_tab
                                                       it_return      = lt_return ).
    ENDIF.

    lo_message_container->add_messages_from_bapi( it_bapi_messages          = lt_return
                                                  iv_add_to_response_header = abap_true ).

    " ---------------------------------------------------------------
    " 6) A failed upload must NOT return HTTP 201.
    "    Raising is the only way the client learns it failed - a bare
    "    RETURN here would report success. Messages are already in the
    "    container, so they travel with the exception.
    "
    "    Do not push error details into bespoke HTTP headers: the message
    "    container plus the sap-message header is the supported channel,
    "    and unescaped message text in a header is a header-injection risk.
    " ---------------------------------------------------------------
    IF line_exists( lt_return[ type = 'E' ] )
    OR line_exists( lt_return[ type = 'A' ] )
    OR line_exists( lt_return[ type = 'X' ] ).
      RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                              message_container = lo_message_container ).
    ENDIF.

    " ---------------------------------------------------------------
    " 7) Return the CREATED entity so the client learns the document id.
    " ---------------------------------------------------------------
    copy_data_to_ref( EXPORTING is_data = ls_data
                      CHANGING  cr_data = er_entity ).

  ENDMETHOD.

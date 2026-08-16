*&---------------------------------------------------------------------
*& GET_ENTITYSET (media) - expose a $value stream URL per row
*&---------------------------------------------------------------------
*& REFERENCE COOKBOOK - READ BEFORE COPYING
*&
*& Independent reference method body. ZSM_SRV and the entity/property
*& names are placeholders for your own service.
*&
*& Pattern: a media entity's binary content lives at .../$value. Building
*& that URL server-side and returning it as a plain string property lets a
*& Fiori attachment list bind straight to it, instead of composing the URL
*& in the UI.
*&
*& AUTHORIZATION BOUNDARY
*& The URL returned here is only a pointer. Whoever calls it lands in
*& GET_STREAM, and THAT is where the business authorization for the
*& document content must be enforced - see GetStream.abap. Returning a URL
*& is not an access decision.
*&---------------------------------------------------------------------

  METHOD documentset_get_entityset.

    CONSTANTS lc_service_root TYPE string VALUE '/sap/opu/odata/sap/ZSM_SRV'.

    " No TRY/CATCH: exceptions raised by super must reach the framework.
    " Swallowing them would return HTTP 200 with an empty collection and a
    " Fiori client would show "no data" instead of an error.
    super->documentset_get_entityset( EXPORTING iv_entity_name           = iv_entity_name
                                                iv_entity_set_name       = iv_entity_set_name
                                                iv_source_name           = iv_source_name
                                                it_filter_select_options = it_filter_select_options
                                                is_paging                = is_paging
                                                it_key_tab               = it_key_tab
                                                it_navigation_path       = it_navigation_path
                                                it_order                 = it_order
                                                iv_filter_string         = iv_filter_string
                                                iv_search_string         = iv_search_string
                                                io_tech_request_context  = io_tech_request_context
                                      IMPORTING et_entityset             = et_entityset
                                                es_response_context      = es_response_context ).

    LOOP AT et_entityset ASSIGNING FIELD-SYMBOL(<ls_document>).

      " Key values must be escaped before being interpolated into a URL.
      " An unescaped apostrophe breaks the OData key literal, and OData V2
      " additionally requires a literal ' inside a string key to be doubled.
      DATA(lv_file_id) = escape( val    = replace( val  = CONV string( <ls_document>-file_id )
                                                   sub  = `'`
                                                   with = `''`
                                                   occ  = 0 )
                                 format = cl_abap_format=>e_url_full ).

      DATA(lv_tor_id) = escape( val    = replace( val  = CONV string( <ls_document>-tor_id )
                                                  sub  = `'`
                                                  with = `''`
                                                  occ  = 0 )
                                format = cl_abap_format=>e_url_full ).

      " Composite-key form. For a single-key entity set it would simply be
      "   |{ lc_service_root }/DocumentSet('{ lv_file_id }')/$value|
      <ls_document>-url = |{ lc_service_root }/DocumentSet(FileId='{ lv_file_id }',TorId='{ lv_tor_id }')/$value|.

    ENDLOOP.

  ENDMETHOD.

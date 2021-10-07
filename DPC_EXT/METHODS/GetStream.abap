  METHOD /iwbep/if_mgw_appl_srv_runtime~get_stream.

    TRY.
        CASE io_tech_request_context->get_entity_type_name( ).
          WHEN 'Print'.

            DATA: lv_mimetype TYPE nte_mimetype VALUE 'application/pdf',
                  lv_content  TYPE xstring,
                  lv_filename TYPE rsbfilename.
                  
            DATA(lv_outtype) = 'attachment'.
            lv_outtype = 'inline'.

            DATA: lv_key      TYPE char1,
                  lv_pdf      TYPE xstring,
                  lv_pdf_name TYPE text40,
                  lt_return   TYPE TABLE OF bapiret2.

            lv_key = VALUE #( it_key_tab[ name = 'KEY' ]-VALUE OPTIONAL ).

            CALL FUNCTION 'ZSM_PRINT'
              EXPORTING
                iv_key		= lv_key
              IMPORTING
                ev_pdf      = lv_pdf
                ev_pdf_adi  = lv_pdf_name
              TABLES
                et_return   = lt_return.

            lv_content  = lv_pdf.
            lv_filename = lv_pdf_name.
        ENDCASE.
      CATCH cx_root.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception.
    ENDTRY.

    DATA(ls_stream) = VALUE ty_s_media_resource( mime_type = lv_mimetype VALUE = lv_content ).

    TRY.
        DATA ls_meta TYPE sfpmetadata.
        DATA(lo_fp) = cl_fp=>get_reference( ).
        DATA(lo_pdfobj) = lo_fp->create_pdf_object( connection = 'ADS' ).

        ls_meta-title = lv_pdf_name.

        lo_pdfobj->set_document( pdfdata = ls_stream-value ).
        lo_pdfobj->set_metadata( metadata = ls_meta ).
        lo_pdfobj->execute( ).
        lo_pdfobj->get_document( IMPORTING pdfdata = ls_stream-value ).
      CATCH cx_fp_runtime_internal
            cx_fp_runtime_system
            cx_fp_runtime_usage INTO DATA(lx_fpex).
    ENDTRY.

    me->set_header( VALUE #( name = 'Content-Disposition' VALUE = |{ lv_outtype }; filename="{ escape( val = lv_filename format = cl_abap_format=>e_url ) }"| ) ).
    me->copy_data_to_ref( EXPORTING is_data = ls_stream CHANGING cr_data = er_stream ).

  ENDMETHOD.
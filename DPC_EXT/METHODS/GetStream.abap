  METHOD /iwbep/if_mgw_appl_srv_runtime~get_stream.

	DATA: ls_meta      TYPE sfpmetadata,
          ls_stream    TYPE ty_s_media_resource,
		  lv_mime_type TYPE nte_mimetype VALUE 'application/pdf',
          lv_content   TYPE xstring,
          lv_file_name TYPE rsbfilename.
    
    DATA(lo_fp) 	  = cl_fp=>get_reference( ).
    DATA(lo_pdf_obj)  = lo_fp->create_pdf_object( connection = 'ADS' ).              
	DATA(lv_out_type) = 'attachment'. "inline"

	DATA: lv_key      TYPE char1,
    	  lv_pdf      TYPE xstring,
          lv_pdf_name TYPE text40,
          lt_return   TYPE TABLE OF bapiret2.
    
    CASE io_tech_request_context->get_entity_type_name( ).
      WHEN 'Document'.
    	DATA: lt_documents   TYPE zsm_tt_document,
    	      lv_document_id TYPE doknr.
    	
    	lv_document_id = it_key_tab[ name = 'DocumentID' ]-value.
    	
    	CALL FUNCTION 'ZSM_GET_DMS'
          EXPORTING
            iv_document_id = lv_document_id
          IMPORTING
            et_dms_data    = lt_documents.

        IF lt_documents[] IS NOT INITIAL.
          lv_content   = lt_documents[ 1 ]-file_content.
          lv_mime_type = lt_documents[ 1 ]-mime_type.
          lv_file_name = lt_documents[ 1 ]-file_name.
        ENDIF.
    ENDCASE. 
    
    TRY.
        lo_pdf_obj->set_document( pdfdata = lv_content ).
        ls_meta-title = lv_document_id.
        lo_pdf_obj->set_metadata( metadata = ls_meta ).
        lo_pdf_obj->execute( ).
        lo_pdf_obj->get_document( IMPORTING pdfdata = lv_content ).

      CATCH cx_fp_runtime_internal
            cx_fp_runtime_system
            cx_fp_runtime_usage INTO DATA(lx_fpex).
    ENDTRY.
    
    ls_stream = VALUE ty_s_media_resource( mime_type = lv_mime_type value = lv_content ).

    me->set_header( VALUE #( name = 'Content-Disposition' value = |{ lv_out_type }; filename="{ escape( val = lv_file_name format = cl_abap_format=>e_url ) }"| ) ).
    me->copy_data_to_ref( EXPORTING is_data = ls_stream CHANGING cr_data = er_stream ).

ENDMETHOD.
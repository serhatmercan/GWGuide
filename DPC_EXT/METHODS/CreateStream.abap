  METHOD /iwbep/if_mgw_appl_srv_runtime~create_stream.
  
  DATA: lt_return      TYPE bapiret2_t,
        lv_content     TYPE xstring,
        lv_file_name   TYPE rsbfilename,
        lv_form_key    TYPE zmm_013_d_dms_tipi,
        lv_material_no TYPE matnr,
        lv_mimetype    TYPE nte_mimetype.

    IF iv_entity_name EQ 'DocumentSet'.
      DATA: ls_data TYPE zcl_zsm_mpc=>ts_data,
            lt_data TYPE zsm_tt_data.
    
      lv_key		   = VALUE #( it_key_tab[ name = 'Key' ]-value OPTIONAL ) .
      lv_file_name = CONV rsbfilename( iv_slug ).
      lv_mimetype  = CONV nte_mimetype( is_media_resource-mime_type ).
      lv_content   = is_media_resource-value.
	  
	  SPLIT iv_slug AT '&&' INTO DATA(lv_file_name) DATA(lv_key) DATA(lv_value).	
    SPLIT lv_file_name AT '.' INTO TABLE DATA(lt_filename).
    READ TABLE lt_filename INTO DATA(lv_filetype) INDEX lines( lt_filename ).
      
    APPEND VALUE #( key			      = lv_key
                    dosya_tipi    = lv_filetype
                    dosya_icerigi = lv_content
                    mimetype      = lv_mimetype
                    filename      = lv_file_name
                  ) TO lt_data.

      CALL FUNCTION 'ZSM_CREATE_DMS'
        EXPORTING
          it_import = lt_data
        TABLES
          et_return = lt_return.  
          
      copy_data_to_ref( EXPORTING is_data = ls_data
                         CHANGING cr_data = er_entity ).
    ENDIF.
    
    IF line_exists( lt_return[ type = 'E' ] ).
      /iwbep/if_sb_dpc_comm_services~rfc_save_log( iv_entity_type = iv_entity_name
                                                   it_key_tab     = it_key_tab
                                                   it_return      = lt_return ).
      RETURN.
    ENDIF.
    
    mo_context->get_message_container( )->add_messages_from_bapi( it_bapi_messages          = lt_return
                                            					            iv_add_to_response_header = abap_true ).

  ENDMETHOD.
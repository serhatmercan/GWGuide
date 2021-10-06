METHOD define.

	super->define( ).
	
	TRY.
		zcl_util=>set_display_format( EXPORTING iv_entity_name = 'Header' iv_property = 'Key' CHANGING co_model = model ).
    CATCH /iwbep/cx_mgw_med_exception.
    ENDTRY.

    TRY.
		zcl_util=>set_filter_to_single_value( EXPORTING iv_entity_name = 'Header' iv_property = 'Key' CHANGING co_model = model ).
    CATCH /iwbep/cx_mgw_med_exception.
    ENDTRY.
    
    TRY.
        zcl_util=>set_label( EXPORTING iv_entity_name = 'Header' iv_property = 'Key' iv_text = '001' io_object = me CHANGING co_model = model ).
	CATCH /iwbep/cx_mgw_med_exception.
    ENDTRY.

	TRY.
      zcl_util=>set_media( EXPORTING iv_entity_name = 'Document' ).  
    CATCH /iwbep/cx_mgw_med_exception.
    ENDTRY.	

ENDMETHOD.
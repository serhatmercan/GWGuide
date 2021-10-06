CLASS ZCL_UTIL.

	" ATTRIBUTES "
	DATA: mo_entity 	 TYPE REF TO /IWBEP/IF_MGW_ODATA_ENTITY_TYP.
	DATA: mo_cl_property TYPE REF TO /IWBEP/CL_MGW_ODATA_PROPERTY.
	DATA: mo_if_property TYPE REF TO /IWBEP/IF_MGW_ODATA_PROPERTY.
	DATA: mo_annotation  TYPE REF TO /IWBEP/IF_MGW_ODATA_ANNOTATION.
	
	" METHODS "
	
	" SET DISPLAY FORMAT "
	DATA: iv_entity_name TYPE /IWBEP/MED_EXTERNAL_NAME.
	DATA: iv_property	 TYPE /IWBEP/MED_EXTERNAL_NAME.
	DATA: co_model		 TYPE REF TO /IWBEP/IF_MGW_ODATA_MODEL.
	
	METHOD set_display_format.
		mo_cl_property ?= co_model->get_entity_type( iv_entity_name )->get_property( iv_property ).
        mo_annotation  = property->/iwbep/if_mgw_odata_annotatabl~create_annotation( /iwbep/if_mgw_med_odata_types=>gc_sap_namespace ).
        mo_annotation->add( iv_key = 'display-format' iv_value = 'Date' ).
        mo_annotation->add( iv_key = 'display-format' iv_value = 'NonNegative' ).
	ENDMETHOD set_display_format.
	
	" SET FILTER FIELD "
	DATA: iv_entity_name TYPE /IWBEP/MED_EXTERNAL_NAME.
	DATA: iv_property	 TYPE /IWBEP/MED_EXTERNAL_NAME.
	DATA: co_model		 TYPE REF TO /IWBEP/IF_MGW_ODATA_MODEL.
	
	METHOD set_filter_to_single_value.
		mo_cl_property ?= co_model->get_entity_type( iv_entity_name )->get_property( iv_property ).
		mo_annotation = mo_cl_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( iv_annotation_namespace = /iwbep/if_mgw_med_odata_types=>gc_sap_namespace ).
		mo_annotation->add( iv_key = 'filter-restriction' iv_value = 'single-value').
	ENDMETHOD.
	
	" SET LABEL "
	DATA: iv_entity_name TYPE /IWBEP/MED_EXTERNAL_NAME.
	DATA: iv_property	 TYPE /IWBEP/MED_EXTERNAL_NAME.
	DATA: iv_text		 TYPE TEXTPOOLKY.
	DATA: io_object		 TYPE OBJECT.
	DATA: co_model		 TYPE REF TO  /IWBEP/IF_MGW_ODATA_MODEL.
	
	METHOD SET_LABEL.
		mo_entity = co_model->get_entity_type( iv_entity_name = iv_entity_name ).
	    mo_if_property = mo_entity->get_property( iv_property_name = iv_property ).
	    mo_if_property->set_label_from_text_element( EXPORTING iv_text_element_symbol = iv_text io_object_ref = io_object ).
	ENDMETHOD SET_LABEL.
	
	" SET MEDIA "
	DATA: iv_entity_name TYPE /IWBEP/MED_EXTERNAL_NAME.
	DATA: iv_property	 TYPE /IWBEP/MED_EXTERNAL_NAME.
	
	METHOD set_media.
		DATA(lo_entity_document) = model->get_entity_type( iv_entity_name = iv_entity_name ).
	
	    IF lo_entity_document IS BOUND.
	    	lo_entity_document->set_is_media( iv_is_media = abap_true ).
	        lo_entity_document->get_property( iv_property_name = 'Mimetype' )->set_as_content_type( ).
		ENDIF.
	ENDMETHOD set_media.
	
ENDCLASS.
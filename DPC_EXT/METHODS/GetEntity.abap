METHOD xxxset_get_entity.
	" Read Data - I
	DATA(ls_data) = VALUE zcl_zsm_mpc=>ts_xxx( ).

	io_tech_request_context->get_converted_keys( IMPORTING es_key_values = ls_data ).
	
	IF ls_data-value IS NOT INITIAL.
	ENDIF.
	
	" Read Data - II
	DATA(lt_keys) = io_tech_request_context->get_keys( ).
	DATA(lv_material) = VALUE #( lt_keys[ name = 'Material' ]-value OPTIONAL ).

  IF lv_material IS NOT INITIAL.
    er_entity-material = lv_material.

    SELECT SINGLE *
      FROM mara
      WHERE matnr EQ @lv_material
      INTO CORRESPONDING FIELDS OF er_entity.
  ENDIF.
ENDMETHOD.
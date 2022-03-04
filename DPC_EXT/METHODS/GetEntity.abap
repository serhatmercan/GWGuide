  METHOD xxxset_get_entity.
	
	DATA(ls_data) = value zcl_zsm_mpc=>ts_xxx( ).
	io_tech_request_context->get_converted_keys( importing es_key_values = ls_data ).
	
	IF ls_data-value IS NOT INITIAL.
	ENDIF.
	
    READ TABLE it_key_tab INTO DATA(is_key_tab) WITH KEY name = 'Matnr'.
    IF is_key_tab-value IS NOT INITIAL.

      SELECT SINGLE *
        INTO CORRESPONDING FIELDS OF er_entity
        FROM mara
        WHERE matnr EQ is_key_tab-value.

    ENDIF.

  ENDMETHOD.
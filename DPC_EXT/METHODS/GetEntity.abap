  METHOD xxxset_get_entity.
	
	" Read Data - I
	DATA(ls_data) = value zcl_zsm_mpc=>ts_xxx( ).
	io_tech_request_context->get_converted_keys( importing es_key_values = ls_data ).
	
	IF ls_data-value IS NOT INITIAL.
	ENDIF.
	
	" Read Data - II
	DATA lt_key TYPE /iwbep/t_mgw_tech_pairs.
	
	lt_key = io_tech_request_context->get_keys( ).
	
	READ TABLE lt_key INTO DATA(ls_key) WITH KEY name = 'ID'.
    IF is_key_tab-value IS NOT INITIAL.
      er_entity-ID = ls_key-value.
    ENDIF.
	
	" Read Data - III
    READ TABLE it_key_tab INTO DATA(is_key_tab) WITH KEY name = 'Matnr'.
    IF is_key_tab-value IS NOT INITIAL.
      SELECT SINGLE *
        INTO CORRESPONDING FIELDS OF er_entity
        FROM mara
        WHERE matnr EQ is_key_tab-value.
    ENDIF.

  ENDMETHOD.
  METHOD xxxset_delete_entity.

    READ TABLE it_key_tab INTO DATA(is_key_tab) WITH KEY name = 'Matnr'.
    IF is_key_tab-value IS NOT INITIAL.
      DELETE FROM mara matnr EQ is_key_tab-value.
    ENDIF.

  ENDMETHOD.
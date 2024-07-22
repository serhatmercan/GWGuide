METHOD xxxset_delete_entity.
  DATA(lv_material) = VALUE #( it_key_tab[ name = 'Material' ]-value OPTIONAL ).

  IF lv_material IS NOT INITIAL.
    DELETE FROM zsm_t_data WHERE material EQ lv_material.
  ENDIF.
ENDMETHOD.
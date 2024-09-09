METHOD /iwbep/if_mgw_appl_srv_runtime~get_entityset.
  TRY.
      FIELD-SYMBOLS <fs_entityset> TYPE table.

      CALL METHOD super->/iwbep/if_mgw_appl_srv_runtime~get_entityset
        EXPORTING
          iv_entity_name           = iv_entity_name
          iv_entity_set_name       = iv_entity_set_name
          iv_source_name           = iv_source_name
          it_filter_select_options = it_filter_select_options
          it_order                 = it_order
          is_paging                = is_paging
          it_navigation_path       = it_navigation_path
          it_key_tab               = it_key_tab
          iv_filter_string         = iv_filter_string
          iv_search_string         = iv_search_string
          io_tech_request_context  = io_tech_request_context
        IMPORTING
          er_entityset             = er_entityset
          es_response_context      = es_response_context.

      ASSIGN er_entityset->* TO <fs_entityset>.

      " Alternative - I
      IF sy-subrc EQ 0 AND it_order IS NOT INITIAL.
          /iwbep/cl_mgw_data_util=>orderby( EXPORTING it_order = it_order CHANGING ct_data = <fs_entityset> ).
      ENDIF.

      " Alternative - II
      IF sy-subrc EQ 0 AND it_order IS NOT INITIAL.
        DATA(lt_sorter) = VALUE abap_sortorder_tab( FOR ls_order IN it_order
                                                    ( name       = ls_order-property
                                                      descending = xsdbool( ls_order-order EQ 'desc' ) ) ).

        SORT <fs_entityset> BY (lt_sorter).
      ENDIF.

      " Alternative - III
      IF sy-subrc EQ 0 AND it_order IS NOT INITIAL.
        DATA(lt_order) = it_order.

        LOOP AT lt_order ASSIGNING FIELD-SYMBOL(<fs_order>).
          me->convert_property_field( CHANGING cv_property = <fs_order>-property ).
        ENDLOOP.

        /iwbep/cl_mgw_data_util=>orderby( EXPORTING it_order = lt_order CHANGING ct_data = <fs_entityset> ).
      ENDIF.
    CATCH /iwbep/cx_mgw_busi_exception.
    CATCH /iwbep/cx_mgw_tech_exception.
  ENDTRY.
ENDMETHOD.

" Level: Static Method 
" Visibility: Public
" Description: Convert Property Field 
" cv_property TYPE string (optional)
METHOD convert_property_field.
  DATA(lo_regex_pattern) = cl_abap_regex=>create_pcre( pattern = `[A-Z]{1}[a-z]+` ).
  DATA(lo_matcher) = lo_regex_pattern->create_matcher( text = cv_property ).
  DATA lv_formatted_text TYPE string.

  WHILE lo_matcher->find_next( ).
    DATA(lv_match) = lo_matcher->get_match( ).
    DATA(lv_match_text) = cv_property+lv_match-offset(lv_match-length).

    TRANSLATE lv_match_text TO UPPER CASE.

    lv_formatted_text = lv_formatted_text && lv_match_text && '_'.
  ENDWHILE.

  IF strlen( lv_formatted_text ) > 0.
    lv_formatted_text = substring( val = lv_formatted_text off = 0 len = strlen( lv_formatted_text ) - 1 ).
  ENDIF.

  cv_property = lv_formatted_text.
ENDMETHOD.
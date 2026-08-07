  " GET_ENTITYSET: super call + custom paging tweak + manual sort by mapped field name
  METHOD xxxset_get_entityset.
    DATA ls_paging TYPE /iwbep/s_mgw_paging.
    DATA lt_otab   TYPE abap_sortorder_tab.

    TRY.
        ls_paging = is_paging.

        IF line_exists( it_order[ order = 'desc' ] ).
          ls_paging-top = 9999.
        ENDIF.

        super->orderslistset_get_entityset( EXPORTING iv_entity_name           = iv_entity_name
                                                      iv_entity_set_name       = iv_entity_set_name
                                                      iv_source_name           = iv_source_name
                                                      it_filter_select_options = it_filter_select_options
                                                      is_paging                = ls_paging
                                                      it_key_tab               = it_key_tab
                                                      it_navigation_path       = it_navigation_path
                                                      it_order                 = it_order
                                                      iv_filter_string         = iv_filter_string
                                                      iv_search_string         = iv_search_string
                                                      io_tech_request_context  = io_tech_request_context
                                            IMPORTING et_entityset             = et_entityset
                                                      es_response_context      = es_response_context ).

        LOOP AT it_order REFERENCE INTO DATA(lr_order).
          CASE lr_order->property.
            WHEN 'OrderNo'.
              lr_order->property = 'ORDER_NO'.
          ENDCASE.

          APPEND VALUE #( name       = lr_order->property
                          descending = ( lr_order->order = 'desc' ) ) TO lt_otab.
        ENDLOOP.

        IF lt_otab IS NOT INITIAL.
          SORT et_entityset BY (lt_otab).
        ENDIF.
      CATCH /iwbep/cx_mgw_busi_exception.
      CATCH /iwbep/cx_mgw_tech_exception.
    ENDTRY.
  ENDMETHOD.

  " GET_ENTITYSET: manual SELECT + explicit filter/paging/sort utility calls
  METHOD xxxset_get_entityset.
    DATA(lr_matnr) = VALUE range_t_matnr( ).

    " Build a range table from the incoming $filter select options for MATNR
    IF line_exists( it_filter_select_options[ property = 'Matnr' ] ).
      lr_matnr = VALUE #(
          FOR ls_select IN it_filter_select_options[ property = 'Matnr' ]-select_options
          ( sign = 'I' option = 'EQ' low = |{ ls_select-low ALPHA = IN }| high = |{ ls_select-high ALPHA = IN }| ) ).
    ENDIF.

    SELECT * FROM mara
      WHERE matnr IN @lr_matnr
      INTO CORRESPONDING FIELDS OF TABLE @et_entityset.

    " Filtering
    /iwbep/cl_mgw_data_util=>filtering( EXPORTING it_select_options = it_filter_select_options
                                        CHANGING  ct_data           = et_entityset ).

    " Inline Count
    es_response_context-inlinecount = COND #( WHEN io_tech_request_context->has_inlinecount( ) = abap_true
                                              THEN lines(
et_entityset )
                                              ELSE 0 ).

    " Inline Count II
    es_response_context-inlinecount = LINES( et_entityset ).

    " Paging
    /iwbep/cl_mgw_data_util=>paging( EXPORTING is_paging = is_paging
                                     CHANGING  ct_data   = et_entityset ).

    " Sorting
    /iwbep/cl_mgw_data_util=>orderby( EXPORTING it_order = it_order
                                      CHANGING  ct_data  = et_entityset ).
  ENDMETHOD.

  " GET_ENTITYSET: RFC/BAPI-based read via remote destination, with filter-to-range conversion
  METHOD xxxset_get_entityset.
    CONSTANTS lc_rfc_name TYPE tfdir-funcname VALUE 'ZSM_F_TEST'.

    DATA ls_converted_keys LIKE LINE OF et_entityset.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lr_name_first     TYPE zif_zsm_f_test=>zmm_tt_name_first_range.
    DATA lr_user_uname     LIKE RANGE OF ls_converted_keys-uname.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA ls_paging         TYPE /iwbep/s_mgw_paging.
    DATA lt_details        TYPE zcl_zsm_tst_mpc_ext=>tt_user_detail.
    DATA lt_return         TYPE bapiret2_t.
    DATA lv_username       TYPE zif_zsm_f_test=>syst-uname.

    DATA(lo_filter) = io_tech_request_context->get_filter( ).
    DATA(lt_filter_select_options) = lo_filter->get_filter_select_options( ).
    DATA(lv_destination) = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

    ls_paging-skip = io_tech_request_context->get_skip( ).
    ls_paging-top  = io_tech_request_context->get_top( ).

    LOOP AT lt_filter_select_options INTO DATA(ls_filter).
      CASE ls_filter-property.
        WHEN 'NAME_FIRST'.
          lo_filter->convert_select_option( EXPORTING is_select_option = ls_filter
                                            IMPORTING et_select_option = lr_name_first ).
        WHEN 'UNAME'.
          lo_filter->convert_select_option( EXPORTING is_select_option = ls_filter
                                            IMPORTING et_select_option = lr_user_uname ).
          lv_username = VALUE #( lr_user_uname[ 1 ]-low OPTIONAL ).
      ENDCASE.
    ENDLOOP.

    TRY.
        IF lv_destination IS INITIAL OR lv_destination = 'NONE'.
          CALL FUNCTION lc_rfc_name
            EXPORTING iv_uname = lv_username
            IMPORTING details  = lt_details
            TABLES    return   = lt_return.
        ELSE.
          CALL FUNCTION lc_rfc_name
            DESTINATION lv_destination
            EXPORTING iv_uname = lv_username
            IMPORTING details  = lt_details
            TABLES    return   = lt_return.
        ENDIF.

        IF line_exists( lt_return[ type = 'E' ] ).
          RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                                  message_container = me->mo_context->get_message_container( ) ).
        ENDIF.

        et_entityset = CORRESPONDING #( lt_details ).
      CATCH cx_root INTO DATA(lx_root).
        lo_message->add_message_text_only( iv_msg_type = 'E'
                                           iv_msg_text = lx_root->get_text( ) ).
        RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception( message_container = lo_message ).
    ENDTRY.
  ENDMETHOD.

  " GET_ENTITYSET: super call + custom orderby field-name conversion (CamelCase -> DB field)
  METHOD xxxset_get_entityset.
    TRY.
        DATA(lt_order) = it_order.

        super->xxxset_get_entityset( EXPORTING iv_entity_name           = iv_entity_name
                                               iv_entity_set_name       = iv_entity_set_name
                                               iv_source_name           = iv_source_name
                                               it_filter_select_options = it_filter_select_options
                                               is_paging                = is_paging
                                               it_key_tab               = it_key_tab
                                               it_navigation_path       = it_navigation_path
                                               it_order                 = it_order
                                               iv_filter_string         = iv_filter_string
                                               iv_search_string         = iv_search_string
                                               io_tech_request_context  = io_tech_request_context
                                     IMPORTING et_entityset             = et_entityset
                                               es_response_context      = es_response_context ).

        LOOP AT lt_order ASSIGNING FIELD-SYMBOL(<fs_order>).
          zsm_cl_util=>convert_property_field( CHANGING cv_property = <fs_order>-property ).
        ENDLOOP.

        /iwbep/cl_mgw_data_util=>orderby( EXPORTING it_order = lt_order
                                          CHANGING  ct_data  = et_entityset ).
      CATCH /iwbep/cx_mgw_busi_exception.
      CATCH /iwbep/cx_mgw_tech_exception.
    ENDTRY.
  ENDMETHOD.

  " cv_property TYPE string (optional)
  METHOD convert_property_field.
    DATA(lo_regex_pattern) = cl_abap_regex=>create_pcre( pattern = `[A-Z]{1}[a-z]+` ).
    DATA(lo_matcher) = lo_regex_pattern->create_matcher( text = cv_property ).
    DATA lv_formatted_text TYPE string.

    WHILE lo_matcher->find_next( ).
      DATA(lv_match) = lo_matcher->get_match( ).
      DATA(lv_match_text) = cv_property+lv_match-offset(lv_match-length).

      TRANSLATE lv_match_text TO UPPER CASE.

      lv_formatted_text = |{ lv_formatted_text }{ lv_match_text }_|.
    ENDWHILE.

    IF strlen( lv_formatted_text ) > 0.
      lv_formatted_text = substring( val = lv_formatted_text
                                     off = 0
                                     len = strlen( lv_formatted_text ) - 1 ).
    ENDIF.

    cv_property = lv_formatted_text.
  ENDMETHOD.

  " GET_ENTITYSET: value help (search help) backed entity set via SHLP API
  METHOD valuehelpset_get_entityset.
    DATA ls_converted_keys        LIKE LINE OF et_entityset.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA ls_message               TYPE bapiret2.
    DATA lr_pernr                 LIKE RANGE OF ls_converted_keys-pernr.
    DATA lt_selopt                TYPE ddshselops.
    DATA lt_filter_select_options TYPE /iwbep/t_mgw_select_option.
    DATA lt_result_list           TYPE /iwbep/if_sb_gendpc_shlp_data=>tt_result_list.
    DATA lv_max_hits              TYPE i.

    lt_filter_select_options = lo_filter->get_filter_select_options( ).

    LOOP AT lt_filter_select_options INTO DATA(ls_filter).
      " TODO: variable is assigned but never used (ABAP cleaner)
      LOOP AT ls_filter-select_options INTO DATA(ls_filter_range).
        CASE ls_filter-property.
          WHEN 'PERNR'.
            lo_filter->convert_select_option( EXPORTING is_select_option = ls_filter
                                              IMPORTING et_select_option = lr_pernr ).

            LOOP AT lr_pernr INTO DATA(ls_pernr).
              APPEND VALUE #( sign      = ls_pernr-sign
                              option    = ls_pernr-option
                              low       = ls_pernr-low
                              high      = ls_pernr-high
                              shlpname  = 'PM02'
                              shlpfield = 'PERNR' ) TO lt_selopt.
            ENDLOOP.
        ENDCASE.
      ENDLOOP.
    ENDLOOP.

    APPEND VALUE #( sign      = 'I'
                    option    = 'CP'
                    low       = '*'
                    high      = '*'
                    shlpname  = 'PM02'
                    shlpfield = 'WERKS' ) TO lt_selopt.

    me->/iwbep/if_sb_gendpc_shlp_data~get_search_help_values( EXPORTING it_selopt         = lt_selopt
                                                                        iv_call_shlt_exit = 'X'
                                                                        iv_maxrows        = lv_max_hits
                                                                        iv_sort           = 'X'
                                                                        iv_shlp_name      = 'PM02'
                                                              IMPORTING es_message        = ls_message
                                                                        et_return_list    = lt_result_list ).

    LOOP AT lt_result_list INTO DATA(ls_result_list).
      " TODO: variable is assigned but never used (ABAP cleaner)
      APPEND INITIAL LINE TO et_entityset ASSIGNING FIELD-SYMBOL(<fs_entityset>).

      CASE ls_result_list-field_name.
        WHEN 'PERNR'.
          fs_entityset-pernr = ls_result_list-field_value.
        WHEN 'WERKS'.
          fs_entityset-werks = ls_result_list-field_value.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  " GET_ENTITYSET: manual $top/$skip paging applied to an already-fetched internal table
  METHOD xxxset_get_entityset.
    DATA ls_paging TYPE /iwbep/s_mgw_paging.
    DATA lv_skip   TYPE int4.
    DATA lv_top    TYPE int4.

    ls_paging-top  = io_tech_request_context->get_top( ).
    ls_paging-skip = io_tech_request_context->get_skip( ).

    lv_skip = COND #( WHEN ls_paging-skip IS NOT INITIAL
                      THEN ls_paging-skip + 1
                      ELSE 0 ).

    lv_top = COND #(
      WHEN ls_paging-top <> 0 AND lv_skip IS NOT INITIAL THEN ls_paging-top + lv_skip - 1
      WHEN ls_paging-top <> 0 AND lv_skip IS INITIAL     THEN ls_paging-top
      ELSE                                                    0 ).

    LOOP AT lt_data INTO DATA(ls_data) FROM lv_skip TO lv_top.
      APPEND CORRESPONDING #( ls_data ) TO et_entityset.
    ENDLOOP.
  ENDMETHOD.
  

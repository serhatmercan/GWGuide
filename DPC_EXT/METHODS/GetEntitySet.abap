  METHOD xxxset_get_entityset.

    DATA(lt_order) = it_order.
    DATA: ls_paging   TYPE /iwbep/s_mgw_paging,
          lt_otab     TYPE abap_sortorder_tab.          

    TRY.
        ls_paging = is_paging.

        IF line_exists( it_order[ ORDER = 'desc' ] ).
          ls_paging-top = 9999.
        ENDIF.

        CALL METHOD super->orderslistset_get_entityset
          EXPORTING
            iv_entity_name           = iv_entity_name
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
          IMPORTING
            et_entityset             = et_entityset
            es_response_context      = es_response_context.

        LOOP AT lt_order REFERENCE INTO DATA(lr_order).
          CASE lr_order->property.
            WHEN 'OrderNo'.
              lr_order->property = 'ORDER_NO'.
          ENDCASE.
        ENDLOOP.

        LOOP AT lt_order INTO DATA(ls_order).
          APPEND INITIAL LINE TO lt_otab  ASSIGNING FIELD-SYMBOL(<fs_otab>).
          <fs_otab>-name = ls_order-property.
          IF ls_order-order EQ 'desc'.
            <fs_otab>-descending = abap_true.
          ENDIF.
        ENDLOOP.

        IF sy-subrc EQ 0.
          SORT et_entityset BY (lt_otab).
        ENDIF.

      CATCH /iwbep/cx_mgw_busi_exception .
      CATCH /iwbep/cx_mgw_tech_exception .
    ENDTRY.

  ENDMETHOD.
  
  METHOD xxxset_get_entityset.
	  IF line_exists( it_filter_select_options[ property = 'Matnr' ] ).
      DATA(lr_matnr) = VALUE range_t_matnr( FOR ls_select IN it_filter_select_options[ property = 'Matnr' ]-select_options ( sign = 'I' option = 'EQ' low = ls_select-low high = ls_select-high ) ).
    ENDIF.
    
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE et_entityset
      FROM mara.
      WHERE matnr IN lr_matnr.
    
    " Filtering
    /iwbep/cl_mgw_data_util=>filtering( EXPORTING it_select_options = it_filter_select_options CHANGING ct_data = et_entityset ).
    
    " Inline Count
    IF io_tech_request_context->has_inlinecount( ) EQ abap_true.
      es_response_context-inlinecount = lines( et_entityset ).
    ELSE.
      CLEAR es_response_context-inlinecount.
    ENDIF.

    " Paging
    /iwbep/cl_mgw_data_util=>paging( EXPORTING is_paging = is_paging CHANGING ct_data = et_entityset ).
    
    " Sorting
    /iwbep/cl_mgw_data_util=>orderby( EXPORTING it_order = it_order CHANGING ct_data = et_entityset ).
 
  ENDMETHOD.

  METHOD xxxset_get_entityset.
    CONSTANTS lc_rfc_name TYPE tfdir-funcname VALUE 'ZSM_F_TEST'.

    DATA: lo_filter                TYPE REF TO /iwbep/if_mgw_req_filter,
          ls_converted_keys        LIKE LINE OF et_entityset,
          lr_name_first            TYPE zif_zsm_f_test=>zmm_tt_name_first_range,
          lr_uname                 LIKE RANGE OF ls_converted_keys-uname,
          ls_paging                TYPE /iwbep/s_mgw_paging,
          lt_details               TYPE zcl_zsm_tst_mpc_ext=>tt_user_detail,
          lv_destination           TYPE rfcdest,
          lv_rfc_name              TYPE tfdir-funcname,
          lv_skip                  TYPE int4,
          lv_top                   TYPE int4,
          lv_user_name             TYPE zif_zsm_f_test=>syst-uname.

    DATA(lo_filter) = io_tech_request_context->get_filter( ).
    DATA(lt_filter_select_options) = lo_filter->get_filter_select_options( ).

    ls_paging-top = io_tech_request_context->get_top( ).
    ls_paging-skip = io_tech_request_context->get_skip( ).      
    lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

    LOOP AT lt_filter_select_options INTO DATA(ls_filter).
      LOOP AT ls_filter-select_options INTO DATA(ls_filter_range).
        CASE ls_filter-property.
          WHEN 'NAME_FIRST'.
            lo_filter->convert_select_option( EXPORTING is_select_option = ls_filter IMPORTING et_select_option = lr_name_first ).
          WHEN 'UNAME'.
            lo_filter->convert_select_option( EXPORTING is_select_option = ls_filter IMPORTING et_select_option = lr_uname ).
            lv_user_name = VALUE #( lr_uname[ 1 ]-low OPTIONAL ).
        ENDCASE.
      ENDLOOP.
    ENDLOOP.

    IF lv_destination IS INITIAL OR lv_destination EQ 'NONE'.
        CALL FUNCTION lc_rfc_name
          EXPORTING
            iv_uname = lv_user_name
          IMPORTING
            details  = lt_details
          TABLES
            return   = return.
    ELSE.
        CALL FUNCTION lc_rfc_name 
          DESTINATION lv_destination
          EXPORTING
            iv_uname  = lv_user_name
          IMPORTING
            details   = lt_details
          TABLES
            return    = return.
    ENDIF.

    et_entityset = CORRESPONDING #( lt_details ).
  ENDMETHOD.

  METHOD xxxset_get_entityset.
    TRY.
        DATA(lt_order) = it_order.

        CALL METHOD super->xxxset_get_entityset
          EXPORTING
            iv_entity_name           = iv_entity_name
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
          IMPORTING
            et_entityset             = et_entityset
            es_response_context      = es_response_context.

        LOOP AT lt_order ASSIGNING FIELD-SYMBOL(<fs_order>).
          zsm_cl_util=>convert_property_field( CHANGING property = <fs_order>-property ).
        ENDLOOP.

        /iwbep/cl_mgw_data_util=>orderby( EXPORTING it_order = lt_order CHANGING ct_data = et_entityset ).
      CATCH /iwbep/cx_mgw_busi_exception.
      CATCH /iwbep/cx_mgw_tech_exception.
    ENDTRY.
  ENDMETHOD.

  " property TYPE string (optional)
  METHOD convert_property_field.

    DATA(regex_pattern) = cl_abap_regex=>create_pcre( pattern = `[A-Z]{1}[a-z]+` ).
    DATA(matcher) = regex_pattern->create_matcher( text = property ).
    DATA formatted_text TYPE string.

    WHILE matcher->find_next( ).
      DATA(match) = matcher->get_match( ).
      DATA(match_text) = property+match-offset(match-length).

      TRANSLATE match_text TO UPPER CASE.

      formatted_text = formatted_text && match_text && '_'.
    ENDWHILE.

    IF strlen( formatted_text ) > 0.
      formatted_text = substring( val = formatted_text off = 0 len = strlen( formatted_text ) - 1 ).
    ENDIF.

    property = formatted_text.

  ENDMETHOD.

  METHOD valuehelpset_get_entityset.
    DATA: ls_converted_keys LIKE LINE OF et_entityset,
          ls_message        TYPE bapiret2,
          lr_pernr          LIKE RANGE OF ls_converted_keys-pernr,          
          lt_selopt         TYPE ddshselops,
          lt_result_list    TYPE /iwbep/if_sb_gendpc_shlp_data=>tt_result_list,
          lv_max_hits       TYPE i.

    DATA(lt_filter_select_options) = lo_filter->get_filter_select_options( ).

    LOOP AT lt_filter_select_options INTO DATA(ls_filter).
      LOOP AT ls_filter-select_options INTO DATA(ls_filter_range).
        CASE ls_filter-property.
          WHEN 'PERNR'.
            lo_filter->convert_select_option( EXPORTING is_select_option = ls_filter IMPORTING et_select_option = lr_pernr ).

            LOOP AT lr_pernr INTO DATA(ls_pernr).
              APPEND INITIAL LINE TO lt_selopt ASSIGNING FIELD-SYMBOL(<fs_selopt>).
              <fs_selopt> = VALUE #( sign = ls_pernr-sign option = ls_pernr-option low = ls_pernr-low high = ls_pernr-high shlpname = 'PM02' shlpfield = 'PERNR' ).
            ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    APPEND INITIAL LINE TO lt_selopt ASSIGNING <fs_selopt>.
    <fs_selopt> = VALUE #( sign = 'I' option = 'CP' low = '*' high = '*' shlpname = 'PM02' shlpfield = 'WERKS' ).

    me->/iwbep/if_sb_gendpc_shlp_data~get_search_help_values(
      EXPORTING
        it_selopt         = lt_selopt
        iv_call_shlt_exit = 'X'
        iv_maxrows        = lv_max_hits
        iv_sort           = 'X'
        iv_shlp_name      = 'PM02'
      IMPORTING
        es_message        = ls_message 
        et_return_list    = lt_result_list
    ).

    LOOP AT lt_result_list INTO DATA(ls_result_list).
      APPEND INITIAL LINE TO et_entityset ASSIGNING FIELD-SYMBOL(<fs_entityset>).

      CASE ls_result_list-field_name.
        WHEN 'PERNR'.
          fs_entityset-pernr = ls_result_list-field_value.
        WHEN 'WERKS'.
          fs_entityset-werks = ls_result_list-field_value.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  " TOP & SKIP
  METHOD xxxset_get_entityset.

    DATA: ls_paging TYPE /iwbep/s_mgw_paging,
          lv_skip   TYPE int4,
          lv_top    TYPE int4.

    ls_paging-top  = io_tech_request_context->get_top( ).
    ls_paging-skip = io_tech_request_context->get_skip( ).

    IF ls_paging-skip IS NOT INITIAL.
      lv_skip = ls_paging-skip + 1.
    ENDIF.

    IF ls_paging-top NE 0 AND lv_skip IS NOT INITIAL.
      lv_top = ls_paging-top + lv_skip - 1.
    ELSEIF ls_paging-top NE 0 AND lv_skip IS INITIAL.
      lv_top = ls_paging-top.
    ENDIF.

    LOOP AT lt_data INTO DATA(ls_data) FROM lv_skip TO lv_top.
      APPEND INITIAL LINE TO et_entityset ASSIGNING FIELD-SYMBOL(<fs_entityset>).
      <fs_entityset> = CORRESPONDING #( ls_data ).
    ENDLOOP.

  ENDMETHOD.
  METHOD xxxset_get_entityset.

    DATA(lt_order) = it_order.
    DATA ls_paging TYPE /iwbep/s_mgw_paging.
    DATA lt_otab   TYPE abap_sortorder_tab.

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
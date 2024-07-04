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
            /iwbep/cl_mgw_data_util=>orderby( EXPORTING it_order = it_order
                                              CHANGING  ct_data  = <fs_entityset> ).
        ENDIF.

        " Alternative - II
        IF sy-subrc EQ 0 AND it_order IS NOT INITIAL.
          DATA(lt_sorter) = VALUE abap_sortorder_tab( FOR ls_order IN it_order
                                                      ( name       = ls_order-property
                                                        descending = xsdbool( ls_order-order EQ 'desc' ) ) ).

          SORT <fs_entityset> BY (lt_sorter).
        ENDIF.
      CATCH /iwbep/cx_mgw_busi_exception.
      CATCH /iwbep/cx_mgw_tech_exception.
    ENDTRY.
ENDMETHOD.
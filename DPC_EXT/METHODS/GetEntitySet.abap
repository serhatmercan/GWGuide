*&---------------------------------------------------------------------
*& GET_ENTITYSET - query a collection ($filter / $orderby / $top / $skip /
*&                 $inlinecount)
*&---------------------------------------------------------------------
*& REFERENCE COOKBOOK - READ BEFORE COPYING
*&
*& This file contains SIX INDEPENDENT reference method bodies. They are
*& NOT meant to be pasted together into one DPC_EXT class:
*&   - several are deliberately named xxxset_get_entityset, because each
*&     is an alternative implementation of the SAME generated method
*&   - pick ONE approach per entity set
*&   - identifiers (zcl_zsm_*, zsm_cl_util, range_t_matnr, ...) are
*&     placeholders for the artefacts your SEGW project generated
*&   - helper objects (mo_context, lo_dp_facade) come from the generated
*&     DPC class
*&
*& THE ORDER THAT MATTERS
*& For a correct OData V2 collection response the conceptual order is:
*&
*&        FILTER  ->  INLINE COUNT  ->  SORT  ->  PAGE
*&
*&   - counting AFTER filtering but BEFORE paging is what makes __count
*&     usable for a paged table
*&   - sorting BEFORE paging is what makes "page 2" mean the second page
*&     of the sorted set. Sorting a page that has already been cut is a
*&     page-local sort and is NOT globally correct.
*&
*& PERFORMANCE - AND A LIMIT OF THESE EXAMPLES
*& Examples 2 and 6 filter/sort/page IN MEMORY. That is shown because it
*& makes the semantics visible, and it is fine for small, bounded result
*& sets. It is NOT a semantically complete large-dataset implementation:
*& example 2 caps the database read for safety, and everything after that
*& cap - remaining filters, inline count, sort, paging - therefore applies
*& to a bounded SAMPLE rather than the full result set. See the note at
*& the SELECT in example 2.
*&
*& Productive services over large tables must push $filter, $orderby and
*& $top/$skip down to the data source (SELECT ... WHERE ... ORDER BY ...
*& OFFSET ... UP TO n ROWS, plus a separate COUNT(*) for $inlinecount, or
*& the equivalent RFC/CDS parameters).
*&
*& AUTHORIZATION BOUNDARY
*& Gateway authenticates the caller and checks service access; it does not
*& authorize the business data returned. Add the application's own
*& authorization to the selection or filter the result accordingly. No
*& authorization object is invented in this repository.
*&---------------------------------------------------------------------


*&---------------------------------------------------------------------
*& Example 1 - call super, then ENRICH the result
*&
*& Correct use: add derived/computed values to the rows super returned.
*&
*& NOT correct: re-sorting or re-filtering here. super already applied
*& filtering, ordering AND paging, so et_entityset holds only the current
*& page. Re-sorting it produces a page-local order, which looks right on
*& page 1 and is wrong on every later page. If you need custom ordering,
*& own the whole query instead - see example 2.
*&---------------------------------------------------------------------
  METHOD xxxset_get_entityset.

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

    " Row-local enrichment only - does not change membership or order.
    LOOP AT et_entityset ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity>-display_text = |{ <ls_entity>-key } - { <ls_entity>-description }|.
    ENDLOOP.

    " No CATCH here on purpose: a business or technical exception raised by
    " super must reach the framework. Swallowing it would turn a backend
    " failure into HTTP 200 with an empty collection, which a Fiori client
    " renders as "no data" instead of an error.

  ENDMETHOD.


*&---------------------------------------------------------------------
*& Example 2 - own the whole query: SELECT + filter/count/sort/page
*&
*& The canonical in-memory implementation. Note the order of the four
*& steps and the conditional inline count.
*&---------------------------------------------------------------------
  METHOD xxxset_get_entityset.

    " ---------------------------------------------------------------
    " 1) $filter -> ABAP range.
    "    Use the filter object rather than hand-building the range:
    "    convert_select_option( ) applies the conversion exit AND keeps
    "    the real sign/option semantics. Hard-coding sign='I' option='EQ'
    "    silently mistranslates every BT (ge/le interval), CP
    "    (startswith/substringof), NE and exclusion filter.
    " ---------------------------------------------------------------
    DATA(lo_filter) = io_tech_request_context->get_filter( ).
    DATA lr_matnr TYPE RANGE OF matnr.

    LOOP AT lo_filter->get_filter_select_options( ) ASSIGNING FIELD-SYMBOL(<ls_select_option>).
      CASE <ls_select_option>-property.
        WHEN 'Matnr'.
          lo_filter->convert_select_option( EXPORTING is_select_option = <ls_select_option>
                                            IMPORTING et_select_option = lr_matnr ).
      ENDCASE.
    ENDLOOP.

    " ---------------------------------------------------------------
    " 2) Read - the demonstrated filter is PUSHED DOWN to the database.
    "
    "    lr_matnr is applied in the WHERE clause, so the Matnr filter is
    "    evaluated by the database and not in ABAP.
    "
    "    An EMPTY range is a no-op in Open SQL - "matnr IN @lr_matnr"
    "    matches EVERY row when no Matnr filter was sent. That is the most
    "    common cause of an accidental full-table read in a Gateway
    "    service. Guard against it with sap:required-in-filter in MPC_EXT,
    "    or with the sample cap below.
    "
    "    Select the entity fields explicitly instead of SELECT *.
    " ---------------------------------------------------------------
    SELECT matnr, mtart, matkl, meins
      FROM mara
      WHERE matnr IN @lr_matnr
      INTO CORRESPONDING FIELDS OF TABLE @et_entityset
      UP TO 5000 ROWS.                     " <- SAMPLE / SAFETY CAP, see below

    " ---------------------------------------------------------------
    " *** WHAT THE CAP COSTS - READ THIS BEFORE REUSING THE EXAMPLE ***
    "
    "    UP TO 5000 ROWS truncates at the DATABASE, i.e. BEFORE steps 3-6
    "    run. It is a safety limit that keeps this illustration bounded -
    "    it is NOT part of OData query semantics. Consequences:
    "
    "      - any $filter property OTHER than Matnr is evaluated in step 3,
    "        so matching rows beyond row 5000 were already discarded
    "      - the inline count in step 4 counts within the capped sample,
    "        not the true filtered total
    "      - the sort in step 5 orders the sample, so it is not a global
    "        ordering of the full result set
    "      - consequently $top/$skip in step 6 page a sample, not the set
    "
    "    This example therefore demonstrates the /IWBEP/CL_MGW_DATA_UTIL
    "    helpers and the ORDER they must run in. It is NOT a semantically
    "    complete large-dataset OData implementation.
    "
    "    For a productive service over a large table, push the work down:
    "    build the WHERE clause from ALL filtered properties, add
    "    ORDER BY for $orderby, and use OFFSET/UP TO n ROWS driven by
    "    $skip/$top - then a separate COUNT(*) for $inlinecount. Only the
    "    remainder that genuinely cannot be pushed down belongs in memory.
    " ---------------------------------------------------------------

    " ---------------------------------------------------------------
    " 3) FILTER - apply any remaining $filter properties in memory.
    "    (Matnr was already handled by the database above.)
    " ---------------------------------------------------------------
    /iwbep/cl_mgw_data_util=>filtering( EXPORTING it_select_options = it_filter_select_options
                                        CHANGING  ct_data           = et_entityset ).

    " ---------------------------------------------------------------
    " 4) INLINE COUNT - after filtering, before paging.
    "    Only when the client asked for it: per OData V2, __count must not
    "    appear unless $inlinecount=allpages was sent.
    " ---------------------------------------------------------------
    IF io_tech_request_context->has_inlinecount( ) = abap_true.
      es_response_context-inlinecount = lines( et_entityset ).
    ENDIF.

    " ---------------------------------------------------------------
    " 5) SORT - before paging, so paging cuts the sorted set.
    " ---------------------------------------------------------------
    /iwbep/cl_mgw_data_util=>orderby( EXPORTING it_order = it_order
                                      CHANGING  ct_data  = et_entityset ).

    " ---------------------------------------------------------------
    " 6) PAGE - $top / $skip last.
    " ---------------------------------------------------------------
    /iwbep/cl_mgw_data_util=>paging( EXPORTING is_paging = is_paging
                                     CHANGING  ct_data   = et_entityset ).

  ENDMETHOD.


*&---------------------------------------------------------------------
*& Example 3 - read through a remote-enabled function module
*&
*& Shows the supported way to turn $filter into ABAP ranges and to resolve
*& the destination from the service configuration (system alias) rather
*& than from a hard-coded map.
*&---------------------------------------------------------------------
  METHOD xxxset_get_entityset.

    CONSTANTS lc_rfc_name TYPE tfdir-funcname VALUE 'ZSM_F_TEST'.

    DATA lt_details  TYPE zcl_zsm_tst_mpc_ext=>tt_user_detail.
    DATA lt_return   TYPE bapiret2_t.
    DATA lv_exc_msg  TYPE string.
    DATA lv_subrc    TYPE sy-subrc.
    DATA lr_uname    TYPE RANGE OF syuname.

    DATA(lo_message_container) = mo_context->get_message_container( ).

    " 1) $filter -> ranges. Pass the WHOLE range to the backend; reducing a
    "    multi-value filter to its first value silently drops the rest.
    DATA(lo_filter) = io_tech_request_context->get_filter( ).

    LOOP AT lo_filter->get_filter_select_options( ) ASSIGNING FIELD-SYMBOL(<ls_select_option>).
      CASE <ls_select_option>-property.
        WHEN 'Uname'.
          lo_filter->convert_select_option( EXPORTING is_select_option = <ls_select_option>
                                            IMPORTING et_select_option = lr_uname ).
      ENDCASE.
    ENDLOOP.

    " 2) $top / $skip are available from the request context even where the
    "    method signature carries no is_paging.
    DATA(ls_paging) = VALUE /iwbep/s_mgw_paging( top  = io_tech_request_context->get_top( )
                                                 skip = io_tech_request_context->get_skip( ) ).

    " 3) Resolve the destination configured for this service in
    "    /IWFND/MAINT_SERVICE. Initial or 'NONE' means embedded deployment
    "    (hub = backend), so call locally.
    DATA(lo_dp_facade)   = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
    DATA(lv_destination) = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

    IF lv_destination IS INITIAL OR lv_destination = 'NONE'.
      TRY.
          CALL FUNCTION lc_rfc_name
            EXPORTING ir_uname  = lr_uname
            IMPORTING et_details = lt_details
            TABLES    et_return  = lt_return.

          lv_subrc = sy-subrc.
        CATCH cx_root INTO DATA(lx_root).
          lv_subrc   = 1001.
          lv_exc_msg = lx_root->get_text( ).
      ENDTRY.
    ELSE.
      CALL FUNCTION lc_rfc_name
        DESTINATION lv_destination
        EXPORTING  ir_uname              = lr_uname
        IMPORTING  et_details            = lt_details
        TABLES     et_return             = lt_return
        EXCEPTIONS system_failure        = 1000 MESSAGE lv_exc_msg
                   communication_failure = 1001 MESSAGE lv_exc_msg
                   OTHERS                = 1002.

      lv_subrc = sy-subrc.
    ENDIF.

    " 4) A communication/system failure is TECHNICAL (5xx-class), not a
    "    business rejection. Do not flatten it into a business exception,
    "    and do not put raw internal exception text into the response -
    "    it can disclose program, table and structure names.
    IF lv_subrc <> 0.
      lo_message_container->add_message_text_only(
          iv_msg_type = 'E'
          iv_msg_text = 'The backend system could not be reached. Please contact support.' ).

      RAISE EXCEPTION NEW /iwbep/cx_mgw_tech_exception(
                              message_container = lo_message_container ).
    ENDIF.

    " 5) Business errors -> populate the container FIRST, then raise.
    "    Raising with an empty container gives the client a generic error
    "    and discards the real BAPI messages.
    IF line_exists( lt_return[ type = 'E' ] )
    OR line_exists( lt_return[ type = 'A' ] )
    OR line_exists( lt_return[ type = 'X' ] ).
      lo_message_container->add_messages_from_bapi( it_bapi_messages          = lt_return
                                                    iv_add_to_response_header = abap_true ).

      RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                              message_container = lo_message_container ).
    ENDIF.

    et_entityset = CORRESPONDING #( lt_details ).

    " 6) Filter / count / sort / page - same order as example 2.
    /iwbep/cl_mgw_data_util=>filtering( EXPORTING it_select_options = it_filter_select_options
                                        CHANGING  ct_data           = et_entityset ).

    IF io_tech_request_context->has_inlinecount( ) = abap_true.
      es_response_context-inlinecount = lines( et_entityset ).
    ENDIF.

    /iwbep/cl_mgw_data_util=>orderby( EXPORTING it_order = it_order
                                      CHANGING  ct_data  = et_entityset ).

    /iwbep/cl_mgw_data_util=>paging( EXPORTING is_paging = ls_paging
                                     CHANGING  ct_data   = et_entityset ).

  ENDMETHOD.


*&---------------------------------------------------------------------
*& Example 4 - $orderby with OData-property -> ABAP-field mapping
*&
*& $orderby is fully client-controlled. A property name taken straight
*& from the request and handed to a DYNAMIC SORT is a remotely triggerable
*& runtime error: SORT ... BY ('DOESNOTEXIST') dumps.
*&
*& Therefore: map through an EXPLICIT ALLOW-LIST and ignore anything that
*& is not in it. Never mutate the caller's it_order - it is an IMPORTING
*& parameter; work on a local copy.
*&---------------------------------------------------------------------
  METHOD xxxset_get_entityset.

    " Explicit, auditable mapping: OData property -> ABAP component.
    " Anything not listed here is not sortable, by design.
    DATA(lt_sort_map) = VALUE ty_t_sort_map(
        ( property = 'OrderNo'     field = 'ORDER_NO' )
        ( property = 'Material'    field = 'MATNR'    )
        ( property = 'CreatedOn'   field = 'ERDAT'    )
        ( property = 'CompanyCode' field = 'BUKRS'    ) ).

    DATA lt_sortorder TYPE abap_sortorder_tab.

    " ... read your data into et_entityset here, then filter and count ...

    " Build the dynamic sort table from VALIDATED components only.
    LOOP AT it_order ASSIGNING FIELD-SYMBOL(<ls_order>).
      DATA(lv_field) = VALUE fieldname( lt_sort_map[ property = <ls_order>-property ]-field OPTIONAL ).

      IF lv_field IS INITIAL.
        " Unknown / non-sortable property: ignore it.
        " Raising a business exception instead is equally defensible -
        " what matters is that it never reaches the dynamic SORT.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( name       = lv_field
                      descending = xsdbool( <ls_order>-order = 'desc' ) ) TO lt_sortorder.
    ENDLOOP.

    IF lt_sortorder IS NOT INITIAL.
      SORT et_entityset BY (lt_sortorder).
    ENDIF.

    " ... then page ...

  ENDMETHOD.


*&---------------------------------------------------------------------
*& Example 5 - value help backed by a standard DDIC search help
*&
*& /IWBEP/IF_SB_GENDPC_SHLP_DATA~GET_SEARCH_HELP_VALUES( ) is the
*& SEGW-generated DPC's bridge to a DDIC search help, including its
*& search-help exit.
*&
*& AUTHORIZATION: PM02 is a STANDARD SAP search help over HR master data.
*& Exposing personnel numbers (and, depending on the search help, names)
*& through an OData entity set makes them reachable by anyone who can
*& reach the service. The search help does not carry your application's
*& HR authorization concept. Enforce it here, or do not expose this set.
*&---------------------------------------------------------------------
  METHOD valuehelpset_get_entityset.

    CONSTANTS lc_shlp_name TYPE shlpname VALUE 'PM02'.
    " Always cap a value help. An uncapped F4 over HR master data can
    " return the entire dataset over HTTP.
    CONSTANTS lc_max_hits  TYPE i        VALUE 200.

    DATA lt_selopt      TYPE ddshselops.
    DATA lt_result_list TYPE /iwbep/if_sb_gendpc_shlp_data=>tt_result_list.
    DATA ls_message     TYPE bapiret2.
    DATA lr_pernr       TYPE RANGE OF pernr_d.

    " 1) $filter -> search-help selection options.
    "    One CASE per property; no nested loop over select_options - that
    "    would run the conversion and the APPEND once per range line and
    "    duplicate every entry.
    DATA(lo_filter) = io_tech_request_context->get_filter( ).

    LOOP AT lo_filter->get_filter_select_options( ) ASSIGNING FIELD-SYMBOL(<ls_select_option>).
      CASE <ls_select_option>-property.
        WHEN 'Pernr'.
          lo_filter->convert_select_option( EXPORTING is_select_option = <ls_select_option>
                                            IMPORTING et_select_option = lr_pernr ).

          LOOP AT lr_pernr ASSIGNING FIELD-SYMBOL(<ls_pernr>).
            APPEND VALUE #( sign      = <ls_pernr>-sign
                            option    = <ls_pernr>-option
                            low       = <ls_pernr>-low
                            high      = <ls_pernr>-high
                            shlpname  = lc_shlp_name
                            shlpfield = 'PERNR' ) TO lt_selopt.
          ENDLOOP.
      ENDCASE.
    ENDLOOP.

    " 2) Honour $top where the caller supplied one, never exceeding the cap.
    DATA(lv_max_hits) = COND i( WHEN io_tech_request_context->get_top( ) BETWEEN 1 AND lc_max_hits
                                THEN io_tech_request_context->get_top( )
                                ELSE lc_max_hits ).

    " 3) Run the search help.
    me->/iwbep/if_sb_gendpc_shlp_data~get_search_help_values(
      EXPORTING it_selopt      = lt_selopt
                iv_maxrows     = lv_max_hits
                iv_sort        = abap_true
                iv_shlp_name   = lc_shlp_name
      IMPORTING es_message     = ls_message
                et_return_list = lt_result_list ).

    " 4) A failed search help must not look like an empty result.
    IF ls_message-type CA 'EAX'.
      DATA(lo_message_container) = mo_context->get_message_container( ).
      lo_message_container->add_messages_from_bapi(
          it_bapi_messages          = VALUE bapiret2_t( ( ls_message ) )
          iv_add_to_response_header = abap_true ).

      RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                              message_container = lo_message_container ).
    ENDIF.

    " 5) Map the result list into entities.
    "
    "    NEEDS OFFICIAL VERIFICATION: TT_RESULT_LIST is a FLAT list - one
    "    row per FIELD per RECORD - and the component that identifies the
    "    record position is release-specific. Check the type in SE11/SE24
    "    on your own system and group by that component, otherwise you get
    "    one entity per field instead of one entity per record.
    "
    "    The loop below maps a single-field result (PERNR only), which is
    "    correct without grouping. Extend it only after verifying the
    "    record-position component.
    LOOP AT lt_result_list ASSIGNING FIELD-SYMBOL(<ls_result>).
      CASE <ls_result>-field_name.
        WHEN 'PERNR'.
          APPEND VALUE #( pernr = <ls_result>-field_value ) TO et_entityset.
      ENDCASE.
    ENDLOOP.

    IF io_tech_request_context->has_inlinecount( ) = abap_true.
      es_response_context-inlinecount = lines( et_entityset ).
    ENDIF.

  ENDMETHOD.


*&---------------------------------------------------------------------
*& Example 6 - manual $top / $skip paging
*&
*& Shown to make explicit what /IWBEP/CL_MGW_DATA_UTIL=>PAGING( ) does
*& internally. Prefer the utility (example 2) in real code.
*&
*& The two classic bugs, both fixed here:
*&   - no $top sent  -> top = 0 -> "TO 0" returns NOTHING
*&   - no $skip sent -> skip = 0 -> "FROM 0" is not a valid start row
*&     (LOOP AT ... FROM/TO are 1-based row numbers)
*&---------------------------------------------------------------------
  METHOD xxxset_get_entityset.

    DATA lt_data TYPE STANDARD TABLE OF zcl_zsm_mpc=>ts_xxx WITH DEFAULT KEY.

    " ... read, filter, count and sort lt_data first ...

    DATA(lv_top)  = io_tech_request_context->get_top( ).
    DATA(lv_skip) = io_tech_request_context->get_skip( ).

    " First row to return (1-based).
    DATA(lv_from) = lv_skip + 1.

    " Last row to return. No $top means "to the end", not "nothing".
    DATA(lv_to) = COND i( WHEN lv_top > 0 THEN lv_skip + lv_top
                                          ELSE lines( lt_data ) ).

    IF lv_from > lines( lt_data ).
      " $skip beyond the end -> empty page, which is correct here.
      RETURN.
    ENDIF.

    IF lv_to > lines( lt_data ).
      lv_to = lines( lt_data ).
    ENDIF.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data>) FROM lv_from TO lv_to.
      APPEND CORRESPONDING #( <ls_data> ) TO et_entityset.
    ENDLOOP.

  ENDMETHOD.

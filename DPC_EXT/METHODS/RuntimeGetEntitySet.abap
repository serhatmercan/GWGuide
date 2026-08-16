*&---------------------------------------------------------------------
*& GET_ENTITYSET - the GENERIC runtime method
*&---------------------------------------------------------------------
*& REFERENCE COOKBOOK - READ BEFORE COPYING
*&
*& Independent reference method body. Not meant to be pasted together with
*& the other files into one DPC_EXT class.
*&
*& WHY THIS FILE LOOKS DIFFERENT FROM GetEntitySet.abap
*& There are two ways to implement a collection read, with DIFFERENT
*& signatures:
*&
*&   1. The GENERATED, per-entity-set method - <EntitySet>_GET_ENTITYSET.
*&      Exports a TYPED table: ET_ENTITYSET. Use it whenever you only need
*&      to handle one entity set. See GetEntitySet.abap.
*&
*&   2. The GENERIC runtime method -
*&      /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET.
*&      Exports ER_ENTITYSET TYPE REF TO data, so the result must be
*&      reached through a field symbol. Use it for cross-cutting behaviour
*&      that should apply to EVERY entity set of the service - which is
*&      what this file demonstrates.
*&
*& SIGNATURE
*& The documented core of /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET is:
*&
*&   IMPORTING  iv_entity_name  iv_source_name
*&              it_filter_select_options  it_order  is_paging
*&              iv_search_string  it_key_tab  it_navigation_path
*&              io_tech_request_context
*&   EXPORTING  er_entityset  es_response_context
*&
*& NEEDS OFFICIAL VERIFICATION (narrow): iv_entity_set_name and
*& iv_filter_string are passed in the super call below. Both are confirmed
*& present on the closely related GET_EXPANDED_ENTITYSET, but the two
*& published parameter lists for the plain GET_ENTITYSET omit them. Check
*& the interface in SE24 on your release and drop them from the super call
*& if they are not there.
*&---------------------------------------------------------------------

  METHOD /iwbep/if_mgw_appl_srv_runtime~get_entityset.

    FIELD-SYMBOLS <lt_entityset> TYPE STANDARD TABLE.

    " ---------------------------------------------------------------
    " 1) Delegate to the generated implementation.
    "    No TRY/CATCH: a business or technical exception raised by super
    "    must propagate unchanged. Catching it and returning normally
    "    would turn a backend failure into HTTP 200 with an empty
    "    collection; catching it and re-raising a BUSINESS exception would
    "    misreport an infrastructure failure (5xx-class) as a client error
    "    (4xx-class) and discard super's own message container.
    " ---------------------------------------------------------------
    super->/iwbep/if_mgw_appl_srv_runtime~get_entityset(
      EXPORTING iv_entity_name           = iv_entity_name
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
      IMPORTING er_entityset             = er_entityset
                es_response_context      = es_response_context ).

    " ---------------------------------------------------------------
    " 2) Reach the generic result through a field symbol.
    "    Test IS ASSIGNED rather than sy-subrc: any method call in between
    "    overwrites sy-subrc, so a later "IF sy-subrc = 0" would be testing
    "    something else entirely.
    " ---------------------------------------------------------------
    ASSIGN er_entityset->* TO <lt_entityset>.

    IF NOT <lt_entityset> IS ASSIGNED.
      RETURN.
    ENDIF.

    IF it_order IS INITIAL.
      RETURN.
    ENDIF.

    " ---------------------------------------------------------------
    " 3) Apply $orderby.
    "
    "    CAVEAT, and it applies to all three variants below: super has
    "    already applied paging, so <lt_entityset> holds only the CURRENT
    "    PAGE. Sorting it here is a PAGE-LOCAL sort - correct-looking on
    "    page 1 and wrong on every later page. Use this only when the
    "    result set is known to be unpaged or small enough to be returned
    "    in one page. For globally correct ordering, own the whole query
    "    (GetEntitySet.abap, example 2) so that sorting happens before
    "    paging.
    "
    "    The three variants below are MUTUALLY EXCLUSIVE alternatives.
    "    Exactly one is active; the others are commented out. Do not run
    "    two of them - the data would simply be sorted twice.
    " ---------------------------------------------------------------

    " --- Variant A (ACTIVE): the Gateway utility -------------------
    " Simplest, and it maps OData property names for you where the model
    " already matches the ABAP component names.
    /iwbep/cl_mgw_data_util=>orderby( EXPORTING it_order = it_order
                                      CHANGING  ct_data  = <lt_entityset> ).

    " --- Variant B: dynamic SORT with a validated allow-list -------
    " Use when you need SORT semantics the utility does not give you.
    " The allow-list is mandatory: $orderby is client-controlled, and a
    " property name that is not a real component makes a dynamic SORT dump.
*    DATA(lt_sort_map) = VALUE ty_t_sort_map(
*        ( property = 'OrderNo'   field = 'ORDER_NO' )
*        ( property = 'CreatedOn' field = 'ERDAT'    ) ).
*
*    DATA lt_sortorder TYPE abap_sortorder_tab.
*
*    LOOP AT it_order ASSIGNING FIELD-SYMBOL(<ls_order>).
*      DATA(lv_field) = VALUE fieldname( lt_sort_map[ property = <ls_order>-property ]-field OPTIONAL ).
*
*      IF lv_field IS INITIAL.
*        CONTINUE.                      " unknown / non-sortable property
*      ENDIF.
*
*      APPEND VALUE #( name       = lv_field
*                      descending = xsdbool( <ls_order>-order = 'desc' ) ) TO lt_sortorder.
*    ENDLOOP.
*
*    IF lt_sortorder IS NOT INITIAL.
*      SORT <lt_entityset> BY (lt_sortorder).
*    ENDIF.

    " --- Variant C: map property names, then use the utility -------
    " Same allow-list rule. Never mutate it_order itself - it is an
    " IMPORTING parameter; build a local copy.
*    DATA(lt_order) = VALUE /iwbep/t_mgw_sorting_order( ).
*
*    LOOP AT it_order ASSIGNING FIELD-SYMBOL(<ls_src_order>).
*      DATA(lv_mapped) = VALUE fieldname( lt_sort_map[ property = <ls_src_order>-property ]-field OPTIONAL ).
*
*      IF lv_mapped IS NOT INITIAL.
*        APPEND VALUE #( property = CONV #( lv_mapped )
*                        order    = <ls_src_order>-order ) TO lt_order.
*      ENDIF.
*    ENDLOOP.
*
*    /iwbep/cl_mgw_data_util=>orderby( EXPORTING it_order = lt_order
*                                      CHANGING  ct_data  = <lt_entityset> ).

  ENDMETHOD.

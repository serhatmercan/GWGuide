*&---------------------------------------------------------------------
*& EXECUTE_ACTION - OData V2 Function Imports
*&---------------------------------------------------------------------
*& REFERENCE COOKBOOK - READ BEFORE COPYING
*&
*& Two INDEPENDENT reference method bodies. They are NOT meant to be
*& pasted together into one DPC_EXT class - each is an alternative
*& implementation of the same generated method. Types and function module
*& names are placeholders.
*&
*& TERMINOLOGY (OData V2 / SAP Gateway)
*& A non-CRUDQ operation is a FUNCTION IMPORT. It is modelled in SEGW
*& under "Function Imports" (the SEGW tree labels the node "Actions") and
*& implemented in /IWBEP/IF_MGW_APPL_SRV_RUNTIME~EXECUTE_ACTION. These are
*& not OData V4 actions/functions and not RAP actions.
*&
*& HTTP METHOD
*& A function import is modelled for GET or POST:
*&   GET  - read-only. Safe and idempotent, may be prefetched or cached.
*&   POST - anything that CHANGES BUSINESS STATE.
*& Model state-changing function imports as POST. A state-changing GET may
*& be triggered by a browser prefetch, a proxy or a plain link, and in SAP
*& Gateway it also bypasses CSRF token enforcement, which only applies to
*& modifying HTTP methods.
*&
*& AVAILABLE CONTEXT
*& EXECUTE_ACTION receives iv_action_name, it_parameter,
*& io_tech_request_context and exports er_data. It has NO it_key_tab and
*& no entity name - a function import addresses no entity, so
*& entity-oriented logging parameters are not available here.
*&
*& AUTHORIZATION BOUNDARY
*& Gateway authenticates the caller and checks service access; it does not
*& authorize the operation the function import performs. Enforce the
*& application's own authorization before acting. No authorization object
*& is invented in this repository.
*&---------------------------------------------------------------------


*&---------------------------------------------------------------------
*& Example 1 - function import calling a business function module
*&---------------------------------------------------------------------
  METHOD /iwbep/if_mgw_appl_srv_runtime~execute_action.

    DATA ls_result TYPE zcl_zsm_mpc_ext=>ts_action_result.
    DATA lt_return TYPE bapiret2_t.

    DATA(lo_message_container) = mo_context->get_message_container( ).

    " ---------------------------------------------------------------
    " 1) Dispatch. An unknown function import must NOT return an empty
    "    HTTP 200 - that hides a modelling/typo error from the caller.
    " ---------------------------------------------------------------
    IF iv_action_name <> 'GetData'.
      lo_message_container->add_message_text_only(
          iv_msg_type = 'E'
          iv_msg_text = |Function import { iv_action_name } is not supported| ).

      RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                              message_container = lo_message_container ).
    ENDIF.

    " ---------------------------------------------------------------
    " 2) Parameters.
    "    get_converted_parameters( ) fills a structure of the generated
    "    parameter type with CONVERSION EXITS ALREADY APPLIED - the same
    "    relationship that get_converted_keys( ) has to get_keys( ).
    "    Prefer it over get_parameters( ), which returns raw external
    "    values you would have to convert yourself.
    " ---------------------------------------------------------------
    DATA ls_parameters TYPE zcl_zsm_mpc_ext=>ts_getdata_params.

    io_tech_request_context->get_converted_parameters( IMPORTING es_parameter_values = ls_parameters ).

    IF ls_parameters-key IS INITIAL.
      lo_message_container->add_message_text_only( iv_msg_type = 'E'
                                                   iv_msg_text = 'Parameter KEY is required' ).

      RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                              message_container = lo_message_container ).
    ENDIF.

    " Raw parameters, if you need the external value exactly as sent:
*    DATA(lt_parameters) = io_tech_request_context->get_parameters( ).
*    DATA(lv_key) = VALUE #( lt_parameters[ name = 'KEY' ]-value OPTIONAL ).

    " ---------------------------------------------------------------
    " 3) <-- BUSINESS AUTHORIZATION CHECK BELONGS HERE.
    " ---------------------------------------------------------------

    " ---------------------------------------------------------------
    " 4) Call the business API.
    " ---------------------------------------------------------------
    CALL FUNCTION 'ZSM_F_DATA'
      EXPORTING iv_key    = ls_parameters-key
      IMPORTING es_result = ls_result
      TABLES    et_return = lt_return.

    " ---------------------------------------------------------------
    " 5) Messages first, then the decision.
    "    E / A / X all mean failure - checking only 'E' misses aborts.
    "    Populate the container BEFORE raising and pass it to the
    "    exception, otherwise the client gets a generic Gateway error and
    "    the real messages are lost.
    " ---------------------------------------------------------------
    lo_message_container->add_messages_from_bapi( it_bapi_messages          = lt_return
                                                  iv_add_to_response_header = abap_true ).

    IF line_exists( lt_return[ type = 'E' ] )
    OR line_exists( lt_return[ type = 'A' ] )
    OR line_exists( lt_return[ type = 'X' ] ).
      RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                              message_container = lo_message_container ).
    ENDIF.

    " ---------------------------------------------------------------
    " 6) If this function import CHANGED business state, apply the same
    "    commit rule as the CRUD methods: commit only after the return
    "    table has been validated. See CreateDeepEntity.abap and the root
    "    README, "Transaction Handling (SAP LUW)". A read-only function
    "    import (as modelled here, HTTP GET) owns no transaction.
    " ---------------------------------------------------------------

    " ---------------------------------------------------------------
    " 7) Return the modelled return type.
    " ---------------------------------------------------------------
    copy_data_to_ref( EXPORTING is_data = ls_result
                      CHANGING  cr_data = er_data ).

  ENDMETHOD.


*&---------------------------------------------------------------------
*& Example 2 - minimal read-only function import
*&---------------------------------------------------------------------
  METHOD /iwbep/if_mgw_appl_srv_runtime~execute_action.

    DATA(lo_message_container) = mo_context->get_message_container( ).

    IF iv_action_name <> 'CheckMaterial'.
      lo_message_container->add_message_text_only(
          iv_msg_type = 'E'
          iv_msg_text = |Function import { iv_action_name } is not supported| ).

      RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                              message_container = lo_message_container ).
    ENDIF.

    DATA ls_parameters TYPE zcl_zsm_mpc_ext=>ts_checkmaterial_params.

    io_tech_request_context->get_converted_parameters( IMPORTING es_parameter_values = ls_parameters ).

    IF ls_parameters-material IS INITIAL.
      lo_message_container->add_message_text_only( iv_msg_type = 'E'
                                                   iv_msg_text = 'Parameter MATERIAL is required' ).

      RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                              message_container = lo_message_container ).
    ENDIF.

    " <-- BUSINESS AUTHORIZATION CHECK BELONGS HERE.
    "     Even a boolean existence check discloses information if the
    "     underlying object is restricted.

    TRY.
        DATA(ls_result) = VALUE zcl_zsm_mpc_ext=>ts_material_check(
                                    material = ls_parameters-material
                                    exists   = NEW zsm_cl_material( )->check_exists(
                                                       iv_material = ls_parameters-material ) ).

      CATCH cx_root INTO DATA(lx_root).
        " An unexpected failure is TECHNICAL, not a business rejection,
        " and its raw text must not reach the client - it can disclose
        " program, table and structure names.
        lo_message_container->add_message_text_only(
            iv_msg_type = 'E'
            iv_msg_text = 'The check could not be performed. Please contact support.' ).

        RAISE EXCEPTION NEW /iwbep/cx_mgw_tech_exception(
                                message_container = lo_message_container
                                previous          = lx_root ).
    ENDTRY.

    copy_data_to_ref( EXPORTING is_data = ls_result
                      CHANGING  cr_data = er_data ).

  ENDMETHOD.

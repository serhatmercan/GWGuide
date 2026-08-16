*&---------------------------------------------------------------------
*& Gateway error and message handling - CANONICAL REFERENCE
*&---------------------------------------------------------------------
*& This is the reference the other DPC_EXT examples in this repository
*& point at. It is a sequence of STATEMENT FRAGMENTS, not a complete
*& method: paste the parts you need into your own DPC_EXT method.
*&
*& THE TWO GATEWAY EXCEPTION TYPES - pick deliberately
*&
*&   /IWBEP/CX_MGW_BUSI_EXCEPTION   the request is wrong or the business
*&                                  rejected it (missing key, not found,
*&                                  validation failed, BAPI returned E).
*&                                  Client-side fault -> 4xx-class.
*&
*&   /IWBEP/CX_MGW_TECH_EXCEPTION   the system could not do its job (RFC
*&                                  communication failure, destination not
*&                                  reachable, unexpected CX_SY_*).
*&                                  Server-side fault -> 5xx-class.
*&
*& The distinction matters: monitoring, alerting, client retry logic and
*& support triage all depend on it. Do not flatten technical failures into
*& business exceptions, and do not report a business rejection as a system
*& failure.
*&
*& FOUR RULES THAT COVER MOST MISTAKES
*&   1. Populate the message container BEFORE raising, and pass it to the
*&      exception. Raising with an empty container gives the client a
*&      generic error and discards the real messages.
*&   2. Never leave a CATCH block empty. Swallowing a Gateway exception
*&      turns a backend failure into HTTP 200 with an empty payload, which
*&      a Fiori client renders as "no data" instead of an error.
*&   3. Never put raw exception text (CX_ROOT->get_text( )) into a
*&      response. It can disclose program, table and structure names. Log
*&      it; return a message the user can act on.
*&   4. Detecting an error and only writing it to a log is not error
*&      handling - if you do not raise, the client sees HTTP 200/201/204
*&      and believes the operation succeeded.
*&---------------------------------------------------------------------


*&---------------------------------------------------------------------
*& 1) The standard pattern: BAPI/RFC result -> messages -> exception
*&---------------------------------------------------------------------
DATA lt_return TYPE bapiret2_t.

DATA(lo_message_container) = mo_context->get_message_container( ).
DATA(lv_entity_name)       = io_tech_request_context->get_entity_type_name( ).

" ... call your BAPI / RFC, filling lt_return ...

" Persist the backend messages for support. rfc_save_log( ) writes the
" return table into the Gateway error log, correlated with the entity type
" and the key table - which is what makes an RFC-based DPC supportable.
" It is LOGGING ONLY: it does not commit, does not roll back and does not
" affect the response.
" NEEDS OFFICIAL VERIFICATION: its exact signature and log target are
" release-specific.
IF lt_return IS NOT INITIAL.
  me->/iwbep/if_sb_dpc_comm_services~rfc_save_log( iv_entity_type = lv_entity_name
                                                   it_return      = lt_return
                                                   it_key_tab     = it_key_tab ).
ENDIF.

" Surface ALL messages (S / W / I as well as errors) to the client.
" iv_add_to_response_header = abap_true puts them into the sap-message
" response header, which is what Fiori/UI5 reads.
lo_message_container->add_messages_from_bapi( it_bapi_messages          = lt_return
                                              iv_add_to_response_header = abap_true ).

" Decide. E (error), A (abort) and X (exit) all mean failure - checking
" only 'E' misses aborts.
IF line_exists( lt_return[ type = 'E' ] )
OR line_exists( lt_return[ type = 'A' ] )
OR line_exists( lt_return[ type = 'X' ] ).
  RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
                          message_container = lo_message_container ).
ENDIF.

" Only past this point may the operation be treated as successful - and
" only here may a commit be issued. See the root README, "Transaction
" Handling (SAP LUW)".


*&---------------------------------------------------------------------
*& 2) Free text vs message class
*&---------------------------------------------------------------------

" add_message_text_only( ) - for free text. Quick, but NOT translatable.
lo_message_container->add_message_text_only( iv_msg_type = 'E'
                                             iv_msg_text = 'Entity not found' ).

" add_message( ) - for a message class message (SE91). Translatable, and
" placeholders &1..&4 are filled from iv_msg_v1..v4. Prefer this in
" productive code.
"
" Note the parameter names: iv_msg_id is the message CLASS, iv_msg_number
" the message number. Passing free text into iv_msg_id truncates it to the
" message-id field length and produces a meaningless message - use
" add_message_text_only( ) for text.
lo_message_container->add_message( iv_msg_type   = 'E'
                                   iv_msg_id     = 'ZSM_M_01'
                                   iv_msg_number = '001'
                                   iv_msg_v1     = CONV #( lv_row )
                                   iv_msg_v2     = CONV #( lv_column )
                                   iv_msg_v3     = CONV #( lv_value )
                                   iv_msg_v4     = CONV #( '31.12.2024' ) ).
" ZSM_M_01 / 001 reads, for example:
"   "Invalid date format in row &1, column &2 (&3). Expected format: &4"


*&---------------------------------------------------------------------
*& 3) Technical failure - do NOT report it as a business error
*&---------------------------------------------------------------------
IF lv_subrc <> 0.                      " e.g. RFC communication_failure
  lo_message_container->add_message_text_only(
      iv_msg_type = 'E'
      iv_msg_text = 'The backend system could not be reached. Please contact support.' ).

  RAISE EXCEPTION NEW /iwbep/cx_mgw_tech_exception(
                          message_container = lo_message_container ).
ENDIF.


*&---------------------------------------------------------------------
*& 4) Wrapping an unexpected exception
*&---------------------------------------------------------------------
TRY.
    " ... call that may raise something unexpected ...

  CATCH cx_root INTO DATA(lx_root).
    " Keep the original exception via PREVIOUS so the chain survives for
    " the short dump / log. Return a safe message to the client - never
    " lx_root->get_text( ).
    lo_message_container->add_message_text_only(
        iv_msg_type = 'E'
        iv_msg_text = 'The request could not be processed. Please contact support.' ).

    RAISE EXCEPTION NEW /iwbep/cx_mgw_tech_exception(
                            message_container = lo_message_container
                            previous          = lx_root ).
ENDTRY.


*&---------------------------------------------------------------------
*& 5) Calling super - what NOT to do
*&---------------------------------------------------------------------

" WRONG - the failure disappears and the client gets an empty HTTP 200:
*    TRY.
*        super->xxxset_get_entityset( ... ).
*      CATCH /iwbep/cx_mgw_busi_exception.
*      CATCH /iwbep/cx_mgw_tech_exception.
*    ENDTRY.

" WRONG - a technical failure is misreported as a business error, and
" super's own message container is thrown away:
*    CATCH /iwbep/cx_mgw_tech_exception.
*      RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
*                              message_container = me->/iwbep/if_mgw_conv_srv_runtime~get_message_container( ) ).

" RIGHT - simply do not catch it. Let the framework map the exception the
" caller raised to the correct HTTP status:
*    super->xxxset_get_entityset( ... ).

" Also RIGHT - catch it to add context, then re-raise the SAME category
" with the original exception preserved:
*    TRY.
*        super->xxxset_get_entityset( ... ).
*      CATCH /iwbep/cx_mgw_busi_exception INTO DATA(lx_busi).
*        lo_message_container->add_message_text_only(
*            iv_msg_type = 'E'
*            iv_msg_text = 'Could not read the requested list' ).
*
*        RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception(
*                                message_container = lo_message_container
*                                previous          = lx_busi ).
*    ENDTRY.


*&---------------------------------------------------------------------
*& 6) Where to look when something goes wrong
*&---------------------------------------------------------------------
"   /IWFND/ERROR_LOG   hub-side errors (frontend server)
"   /IWBEP/ERROR_LOG   backend-side errors (where rfc_save_log writes)
"   /IWFND/GW_CLIENT   reproduce the request directly against the hub
"   ST22 / SM21        short dumps and system log for technical failures

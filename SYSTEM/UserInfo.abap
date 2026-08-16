*&---------------------------------------------------------------------
*& Request context - user identity and request metadata
*&---------------------------------------------------------------------
*& REFERENCE COOKBOOK - READ BEFORE COPYING
*&
*& Statement fragments for use inside a DPC_EXT method.
*&
*& THE RULE
*&   Authenticated identity  ->  SY-UNAME
*&   Request headers         ->  DIAGNOSTIC METADATA ONLY
*&
*& SY-UNAME is the authenticated ABAP session user. Gateway has already
*& authenticated the caller (SSO / SAML / OAuth / basic) and, in a hub
*& deployment, propagated that identity to the backend - so SY-UNAME is
*& the user the request actually runs as.
*&
*& HTTP request headers are supplied by the CLIENT. Unless a trusted
*& intermediary strips and re-sets a header, its value is
*& attacker-controllable. Using a header to decide who the caller is - for
*& an authorization check, an ownership test, or a "changed by" audit
*& field - is an authentication bypass.
*&
*& Read headers for correlation, tracing and diagnostics. Never for
*& identity or authorization.
*&---------------------------------------------------------------------


" ---------------------------------------------------------------------
" 1) AUTHENTICATED USER - use this for anything security-relevant
" ---------------------------------------------------------------------
DATA(lv_user) = sy-uname.

" Examples of correct use:
"   - stamping a "created by" / "changed by" field
"   - an AUTHORITY-CHECK on the acting user
"   - reading the user's own personalisation or worklist
"   - logging who triggered a business operation


" ---------------------------------------------------------------------
" 2) REQUEST METADATA - diagnostics only, never identity
"
" NEEDS OFFICIAL VERIFICATION: /IWBEP/CL_MGW_REQUEST is a concrete
" framework class, not a released API. Down-casting to it can break on
" upgrade, and ?= raises CX_SY_MOVE_CAST_ERROR if the runtime ever
" supplies a different implementation. Verify the supported way to read
" request details on your SAP_GWFND release before relying on this.
" ---------------------------------------------------------------------
DATA lo_request TYPE REF TO /iwbep/cl_mgw_request.

TRY.
    lo_request ?= io_tech_request_context.

    DATA(ls_request_details) = lo_request->get_request_details( ).

    " Session / correlation identifier - useful for tracing one request
    " across the hub, the backend and the application log.
    DATA(lv_session_id) = VALUE string(
        ls_request_details-technical_request-request_header[ name = 'jsessionid' ]-value OPTIONAL ).

    " A caller-supplied user name. It is NOT proof of identity - it is a
    " claim made by the client. Treat it as an untrusted hint only: log it
    " if useful, and never branch business logic on it.
    DATA(lv_claimed_user_hint) = VALUE string(
        ls_request_details-technical_request-request_header[ name = 'request_user' ]-value OPTIONAL ).

    " The same name may also appear among the context parameters, depending
    " on the caller and the deployment. Same rule: untrusted.
    DATA(lv_claimed_user_hint_ctx) = VALUE string(
        ls_request_details-context_params[ name = 'request_user' ]-value OPTIONAL ).

  CATCH cx_sy_move_cast_error.
    " The runtime supplied a different implementation - fall back to what
    " is guaranteed.
    CLEAR: lv_session_id, lv_claimed_user_hint, lv_claimed_user_hint_ctx.
ENDTRY.

" Do not log a session identifier into a long-lived application log:
" a session id is a credential for the duration of the session.


" ---------------------------------------------------------------------
" 3) WRONG - do not do this
" ---------------------------------------------------------------------
" Deciding what the request may do based on a client-supplied header:
*    DATA(lv_username) = VALUE xubname(
*        ls_request_details-technical_request-request_header[ name = 'request_user' ]-value OPTIONAL ).
*
*    SELECT ... WHERE created_by = @lv_username ...      " <- caller picks the data
*    AUTHORITY-CHECK ... ID 'UNAME' FIELD lv_username.   " <- caller picks the identity

" RIGHT - the authenticated session user:
*    SELECT ... WHERE created_by = @sy-uname ...


" ---------------------------------------------------------------------
" 4) Other useful session values
" ---------------------------------------------------------------------
DATA(lv_client)   = sy-mandt.      " logon client
DATA(lv_language) = sy-langu.      " logon language - drives text-table reads
DATA(lv_date)     = sy-datum.
DATA(lv_time)     = sy-uzeit.

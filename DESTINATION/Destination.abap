*&---------------------------------------------------------------------
*& RFC destination resolution in a Gateway DPC
*&---------------------------------------------------------------------
*& REFERENCE COOKBOOK - READ BEFORE COPYING
*&
*& Three INDEPENDENT patterns, separated by "---". Pattern 2 is the one to
*& use in productive code.
*&
*& THE THREE CONCEPTS - keep them apart
*&
*&   System alias        Gateway configuration. Maintained per service in
*&                       /IWFND/MAINT_SERVICE. Says WHICH backend this
*&                       service talks to in THIS system. Transportable,
*&                       maintainable by Basis, no code change needed.
*&
*&   RFC destination     SM59 object the alias points at. Holds host,
*&                       client, and the authentication method (trusted
*&                       RFC, technical user, ...).
*&
*&   Local execution     Embedded deployment: the hub and the backend are
*&                       the same system. The alias resolves to
*&                       initial/'NONE' and the function module must be
*&                       called WITHOUT a DESTINATION.
*&
*&   Remote execution    Hub deployment: hub and backend are separate
*&                       systems. CALL FUNCTION ... DESTINATION.
*&
*& TRANSACTION CONSEQUENCE - easy to miss
*& A remote CALL FUNCTION ... DESTINATION runs in its OWN LUW on the
*& target system. Your local COMMIT WORK does not reach it: the commit
*& must be issued on that destination. A local call shares your LUW.
*& The same DPC code path therefore needs a DIFFERENT commit strategy
*& depending on which branch it took. See UpdateEntity.abap and the root
*& README, "Transaction Handling (SAP LUW)".
*&
*& SECURITY
*& A trusted ("TRUSTING@...") destination PROPAGATES THE CALLER'S IDENTITY
*& without re-authentication. It does NOT propagate authorization: the
*& called function module is still responsible for checking whether that
*& user may perform the business action. Where a destination uses a
*& TECHNICAL user instead, the caller's identity is lost entirely and all
*& business authorization must happen before the call.
*&
*& All system IDs and destination names below are neutral placeholders.
*&---------------------------------------------------------------------

" ---------------------------------------------------------------------
" Pattern 1 - read the configured alias straight from the Gateway tables
"
" DIAGNOSTIC USE ONLY. Useful for understanding how /IWFND/MAINT_SERVICE
" stores its configuration, or for a one-off analysis report.
"
" Do NOT use this in productive code:
"   - /IWFND/C_MGDEAM, /IWFND/I_MED_SRH and /IWFND/C_DFSYAL are framework
"     -internal tables/views, not a released API; their structure can
"     change between SAP_GWFND releases and support packages
"   - it bypasses the framework's own determination and caching
"   - hard-coding service_version breaks silently once the service is
"     versioned
" Use Pattern 2 instead.
"
" NEEDS OFFICIAL VERIFICATION: table and field names vary by release.
" ---------------------------------------------------------------------
SELECT SINGLE mgdeam~system_alias, dfsyal~rfc_dest
  FROM /iwfnd/c_mgdeam AS mgdeam
  INNER JOIN /iwfnd/i_med_srh AS med_srh ON med_srh~srv_identifier EQ mgdeam~service_id
  INNER JOIN /iwfnd/c_dfsyal  AS dfsyal  ON dfsyal~system_alias    EQ mgdeam~system_alias
  WHERE med_srh~service_name    EQ 'TASKPROCESSING'   " standard SAP service, example only
    AND med_srh~service_version EQ '1'
    AND dfsyal~is_default       EQ @abap_true
  INTO @DATA(ls_alias).

---

" ---------------------------------------------------------------------
" Pattern 2 - RESOLVE FROM THE SERVICE CONFIGURATION  (USE THIS ONE)
"
" Asks the framework which destination THIS service is configured with,
" through the data-provider facade. Release-safe, transport-friendly, and
" it handles embedded and hub deployment from one code path.
" ---------------------------------------------------------------------
DATA lv_exc_msg TYPE string.
DATA lv_subrc   TYPE sy-subrc.

CONSTANTS lc_rfc_name TYPE tfdir-funcname VALUE 'ZSM_F_RFC'.

DATA(lo_dp_facade)   = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
DATA(lv_destination) = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

IF lv_destination IS INITIAL OR lv_destination = 'NONE'.

  " EMBEDDED deployment - hub and backend are the same system.
  " Call locally; the call shares this LUW.
  TRY.
      CALL FUNCTION lc_rfc_name
        EXPORTING iv_data = iv_data
        IMPORTING et_data = et_data.

      lv_subrc = sy-subrc.

    CATCH cx_root INTO DATA(lx_root).
      lv_subrc   = 1001.
      lv_exc_msg = lx_root->get_text( ).
  ENDTRY.

ELSE.

  " HUB deployment - separate backend. The call runs in its OWN LUW there.
  " system_failure / communication_failure are RFC-layer exceptions and
  " only apply to a call WITH a DESTINATION. MESSAGE captures the RFC error
  " text.
  CALL FUNCTION lc_rfc_name
    DESTINATION lv_destination
    EXPORTING  iv_data               = iv_data
    IMPORTING  et_data               = et_data
    EXCEPTIONS system_failure        = 1000 MESSAGE lv_exc_msg
               communication_failure = 1001 MESSAGE lv_exc_msg
               OTHERS                = 1002.

  lv_subrc = sy-subrc.

ENDIF.

" Act on the captured state - capturing it and then ignoring it is only
" half the pattern. A communication failure is TECHNICAL, not a business
" rejection, and the raw text must not reach the client.
IF lv_subrc <> 0.
  DATA(lo_message_container) = mo_context->get_message_container( ).

  lo_message_container->add_message_text_only(
      iv_msg_type = 'E'
      iv_msg_text = 'The backend system could not be reached. Please contact support.' ).

  RAISE EXCEPTION NEW /iwbep/cx_mgw_tech_exception(
                          message_container = lo_message_container ).
ENDIF.

---

" ---------------------------------------------------------------------
" Pattern 3 - resolve from sy-sysid
"
" LAST RESORT. Shown because it is common in the field, and because its
" drawbacks are worth understanding:
"
"   - it duplicates in ABAP what the system alias already expresses as
"     configuration, so every new system (sandbox, second QA, project
"     landscape) needs a code change and a transport
"   - an unknown system must NEVER fall through to production. The ELSE
"     branch below raises instead of guessing.
"
" Prefer Pattern 2. Use this only where no system alias is maintained for
" the service and the mapping genuinely has to live in code.
"
" DEV / QAS / PRD and EXAMPLE_RFC_* are neutral placeholders - replace them
" with your own landscape's values.
" ---------------------------------------------------------------------
DATA(lv_dest) = SWITCH rfcdest( sy-sysid
                                WHEN 'DEV' THEN 'EXAMPLE_RFC_DEV'
                                WHEN 'QAS' THEN 'EXAMPLE_RFC_QAS'
                                WHEN 'PRD' THEN 'EXAMPLE_RFC_PRD'
                                ELSE            'NONE' ).

IF lv_dest = 'NONE'.
  " Fail loudly rather than silently routing an unrecognised system
  " somewhere it does not belong.
  DATA(lo_msg) = mo_context->get_message_container( ).

  lo_msg->add_message_text_only(
      iv_msg_type = 'E'
      iv_msg_text = |No RFC destination is configured for system { sy-sysid }| ).

  RAISE EXCEPTION NEW /iwbep/cx_mgw_tech_exception( message_container = lo_msg ).
ENDIF.

METHOD XXX_UPDATE_ENTITY.
*---------------------*
* - Read After Create -
*---------------------*
	TRY.
    DATA: ls_data   LIKE er_entity,
          ls_return TYPE bapiret2,
          lt_return TYPE bapiret2_t.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).       

  CATCH /iwbep/cx_mgw_tech_exception.
  ENDTRY.

	er_entity-key = ls_data-key.

  APPEND ls_return TO lt_return.
	
	mo_context->get_message_container( )->add_messages_from_bapi( it_bapi_messages          = lt_return
                                            					          iv_add_to_response_header = abap_true ).
ENDMETHOD.

METHOD XXX_UPDATE_ENTITY.

  DATA: lo_dp_facade   TYPE REF TO /iwbep/if_mgw_dp_facade,
        ls_data        TYPE zcl_zsm_tst_mpc=>ts_main,
        ls_keys        LIKE er_entity,    
        lv_destination TYPE rfcdest.

  io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).
  io_tech_request_context->get_converted_keys( IMPORTING es_key_values  = ls_keys ).
  lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

  lv_destination = SWITCH #( sy-sysid WHEN 'TFD' THEN 'TRUSTING@TSD'
                                      WHEN 'TFQ' THEN 'TRUSTING@TSQ'
                                      ELSE 'TRUSTING@TFP' ).

  lv_rfc_name = 'ZTG_MM_FM_MODIFY_USER_PASSWORD'.
  lv_uname = ls_keys-uname.

  IF lv_destination IS INITIAL OR lv_destination EQ 'NONE'.
    TRY.
        CALL FUNCTION lv_rfc_name
          EXPORTING
            iv_uname       = lv_uname
          TABLES
          et_return        = lt_return
          EXCEPTIONS
            system_failure = 1000 message lv_exc_msg
            OTHERS         = 1002.
      CATCH cx_root INTO lx_root.
        lv_exc_msg = lx_root->if_message~get_text( ).
    ENDTRY.
  ELSE.
    CALL FUNCTION lv_rfc_name 
      DESTINATION lv_destination
      EXPORTING
        iv_uname              = lv_uname
      TABLES
        et_return             = lt_return
      EXCEPTIONS
        system_failure        = 1000 MESSAGE lv_exc_msg
        communication_failure = 1001 MESSAGE lv_exc_msg
        OTHERS                = 1002.
  ENDIF.

  IF lt_return IS NOT INITIAL.
    me->/iwbep/if_sb_dpc_comm_services~rfc_save_log(
      EXPORTING
        it_key_tab     = it_key_tab 
        it_return      = lt_return 
        iv_entity_type = iv_entity_name ).
  ENDIF.

  me->/iwbep/if_sb_dpc_comm_services~commit_work( EXPORTING iv_rfc_dest = lv_destination ) .

ENDMETHOD.
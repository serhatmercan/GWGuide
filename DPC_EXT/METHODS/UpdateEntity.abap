METHOD xxx_update_entity.
*-----------------------*
* - Read After Create   * 
*-----------------------*
	TRY.
    DATA: ls_data   TYPE LINE OF er_entity,
          lt_return TYPE bapiret2_t.
    
    DATA(lo_message_container) = mo_context->get_message_container( )

    io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).
    
    er_entity-key = ls_data-key.

    APPEND VALUE #( type = 'S' message = 'Entity updated successfully' ) TO lt_return.

    lo_message_container->add_messages_from_bapi( EXPORTING it_bapi_messages          = lt_return
                                                            iv_add_to_response_header = abap_true ).

  CATCH /iwbep/cx_mgw_tech_exception INTO DATA(lx_tech_exception).
    lo_message_container->add_message( iv_msg_type = 'E'
                                       iv_msg_id   = lx_tech_exception->get_text( ) ).
  ENDTRY.
ENDMETHOD.

METHOD xxx_update_entity.
  DATA: lo_dp_facade   TYPE REF TO /iwbep/if_mgw_dp_facade,
        ls_data        TYPE zcl_zsm_tst_mpc=>ts_main,
        ls_keys        TYPE zcl_zsm_tst_mpc=>ts_keys,   
        lt_return      TYPE bapiret2_t,
        lv_destination TYPE rfcdest,
        lv_exc_msg     TYPE string,
        lv_rfc_name    TYPE tfdir-funcname,
        lx_root        TYPE REF TO cx_root,
        lv_username    TYPE syuname,.

  io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).

  io_tech_request_context->get_converted_keys( IMPORTING es_key_values = ls_keys ).

  lv_destination = SWITCH #( sy-sysid WHEN 'TFD' THEN 'TRUSTING@TSD'
                                      WHEN 'TFQ' THEN 'TRUSTING@TSQ'
                                      ELSE 'TRUSTING@TFP' ).
  lv_rfc_name = 'ZSM_FM_001'.
  lv_username = ls_keys-uname.

  IF lv_destination IS INITIAL OR lv_destination EQ 'NONE'.
    TRY.
        CALL FUNCTION lv_rfc_name
          EXPORTING
            iv_uname       = lv_username
          TABLES
            et_return      = lt_return
          EXCEPTIONS
            system_failure = 1000 MESSAGE lv_exc_msg
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
    me->/iwbep/if_sb_dpc_comm_services~rfc_save_log( EXPORTING it_key_tab     = it_key_tab 
                                                               it_return      = lt_return 
                                                               iv_entity_type = iv_entity_name ).
  ENDIF.

  me->/iwbep/if_sb_dpc_comm_services~commit_work( EXPORTING iv_rfc_dest = lv_destination ).
ENDMETHOD.
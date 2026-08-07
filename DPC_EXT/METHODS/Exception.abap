" Reusable business-exception / message-container patterns (log to /IWBEP/ERROR_LOG via rfc_save_log, raise busi exception)
DATA lo_message_container TYPE REF TO /iwbep/if_message_container.
DATA lt_return            TYPE bapiret2_t.

DATA(lv_entity_name) = io_tech_request_context->get_entity_type_name( ).

IF line_exists( lt_return[ type = 'E' ] ).
  me->/iwbep/if_sb_dpc_comm_services~rfc_save_log( iv_entity_type = lv_entity_name
                                                   it_return      = lt_return
                                                   it_key_tab     = it_key_tab ).
ENDIF.

lo_message_container = mo_context->get_message_container( ).
" TODO: check spelling: Occured (typo) -> Occurred (ABAP cleaner)
lo_message_container->add_message_text_only( iv_msg_type = 'E'
                                             " TODO: check spelling: Occured (typo) -> Occurred (ABAP cleaner)
                                             iv_msg_text = 'Error Occured' ).
lo_message_container->add_messages_from_bapi( it_bapi_messages          = lt_return
                                              iv_add_to_response_header = abap_true ).

RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception( message_container = lo_message_container ).

" Add Message To Message Container
lo_message_container->add_message( iv_msg_type   = /iwbep/cl_cos_logger=>error
                                   iv_msg_id     = 'ZSM_M_01'
                                   iv_msg_v1     = CONV #( lv_tabix )
                                   iv_msg_v2     = CONV #( ls_map-colex )
                                   iv_msg_v3     = CONV #( <fs> )
                                   iv_msg_v4     = CONV #( '13.11.2024' )
                                   iv_msg_number = '001' ). " &1. satırın &2 sütunundaki tarih formatta hata var (&3) Örnek Format &4

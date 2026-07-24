  METHOD /iwbep/if_mgw_appl_srv_runtime~execute_action.
    DATA lo_message    TYPE REF TO /iwbep/if_message_container.
    DATA ls_deep       TYPE zcl_zsm_mpc_ext=>ts_deep.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA ls_value      TYPE zsm_s_value.
    DATA lt_parameters TYPE REF TO /iwbep/if_mgw_parameter.
    DATA lt_return     TYPE bapiret2_tab.

    lo_message = me->mo_context->get_message_container( ).

    io_tech_request_context->get_converted_parameters( IMPORTING es_parameter_values = ls_value ).

    lt_parameters = io_tech_request_context->get_parameters( ).

    IF iv_action_name <> 'GetData'.
      RETURN.
    ENDIF.

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(lv_customer) = CONV #( VALUE #( lt_parameters[ name = 'CUSTOMER' ]-value OPTIONAL ) ).
    ls_deep-key = VALUE #( lt_parameters[ name = 'KEY' ]-value OPTIONAL ).

    CALL FUNCTION 'ZSM_F_DATA'
      EXPORTING iv_key    = ls_deep-key
      IMPORTING ev_key    = ls_deep-key
      TABLES    et_return = lt_return.

    IF lt_return IS NOT INITIAL.
      me->/iwbep/if_sb_dpc_comm_services~rfc_save_log( iv_entity_type = lv_entity_name
                                                       it_return      = lt_return
                                                       it_key_tab     = it_key_tab ).
    ENDIF.

    " TODO: variable is assigned but never used (ABAP cleaner)
    LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<fs_return>) WHERE type CA 'EAX'.
      lo_message->add_messages_from_bapi( it_bapi_messages = lt_return ).
      RAISE EXCEPTION NEW /iwbep/cx_mgw_busi_exception( ).
    ENDLOOP.

    copy_data_to_ref( EXPORTING is_data = ls_deep
                      CHANGING  cr_data = er_data ).

    mo_context->get_message_container( )->add_messages_from_bapi( it_bapi_messages          = lt_return
                                                                  iv_add_to_response_header = abap_true ).
  ENDMETHOD.

  METHOD /iwbep/if_mgw_appl_srv_runtime~execute_action.
    DATA(lt_parameters) = io_tech_request_context->get_parameters( ).

    IF iv_action_name = 'CheckPA'.
      DATA(lv_material) = CONV matnr( VALUE #( lt_parameters[ name = 'MATERIAL' ]-value OPTIONAL ) ).
      DATA(ls_pa_exist) = VALUE zcl_zsm_mpc_ext=>paexist(
                                    material = lv_material
                                    exist    = NEW zsm_cl_pa( )->check_is_there_pa( iv_material = lv_material ) ).

      copy_data_to_ref( EXPORTING is_data = ls_pa_exist
                        CHANGING  cr_data = er_data ).
    ENDIF.
  ENDMETHOD.

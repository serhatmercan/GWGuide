" Get Destination
SELECT SINGLE rfc_dest FROM /iwfnd/c_mgdeam
    INNER JOIN /iwfnd/i_med_srh on /iwfnd/i_med_srh~srv_identifier eq /iwfnd/c_mgdeam~service_id
    INNER JOIN /iwfnd/c_dfsyal ON /iwfnd/c_dfsyal~system_alias EQ /iwfnd/c_mgdeam~system_alias
    INTO @DATA(lv_destination)
    WHERE service_name EQ 'TASKPROCESSING'
      AND service_version EQ '1'
      AND is_default EQ @abap_true.

---
" Get RFC Destination
DATA lo_dp_facade TYPE REF TO /iwbep/if_mgw_dp_facade.
DATA ls_expanded_clause LIKE LINE OF et_expanded_tech_clauses. 
DATA lv_rfc_name TYPE tfdir-funcname.
DATA lv_destination TYPE rfcdest. 

lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ). 
lv_rfc_name = 'ZSM_F_RFC'.

    IF lv_destination IS INITIAL OR lv_destination EQ 'NONE'.

      TRY.
          CALL FUNCTION lv_rfc_name
            EXPORTING
              iv_data        = iv_data
            IMPORTING
              et_data        = et_data
            EXCEPTIONS
              system_failure = 1000 message lv_exc_msg
              OTHERS         = 1002.

          lv_subrc = sy-subrc.
	    CATCH cx_root INTO lx_root.
          lv_subrc = 1001.
          lv_exc_msg = lx_root->if_message~get_text( ).
      ENDTRY.

    ELSE.

      CALL FUNCTION lv_rfc_name DESTINATION lv_destination
        EXPORTING
          iv_data               = iv_data
        IMPORTING
          et_data               = et_data
        EXCEPTIONS
          system_failure        = 1000 MESSAGE lv_exc_msg
          communication_failure = 1001 MESSAGE lv_exc_msg
          OTHERS                = 1002.

      lv_subrc = sy-subrc.

    ENDIF. 
---
" Get RFC Destination w/ System ID
DATA lv_destination TYPE rfcdest. 

lv_destination = SWITCH #( sy-sysid WHEN 'FIP' THEN 'ELPCLNT100_RFC' ELSE 'ELTCLNT100_RFC' ).

" Get Destination
SELECT SINGLE rfc_dest FROM /iwfnd/c_mgdeam
    INNER JOIN /iwfnd/i_med_srh on /iwfnd/i_med_srh~srv_identifier eq /iwfnd/c_mgdeam~service_id
    INNER JOIN /iwfnd/c_dfsyal ON /iwfnd/c_dfsyal~system_alias EQ /iwfnd/c_mgdeam~system_alias
    INTO @DATA(lv_destination)
    WHERE service_name EQ 'TASKPROCESSING'
      AND service_version EQ '1'
      AND is_default EQ @abap_true.

---
" Get RFC Destination
DATA lo_dp_facade TYPE REF TO /iwbep/if_mgw_dp_facade.
DATA ls_expanded_clause LIKE LINE OF et_expanded_tech_clauses. 
DATA lv_rfc_name TYPE tfdir-funcname.
DATA lv_destination TYPE rfcdest. 

lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ). 
lv_rfc_name = 'ZSM_F_RFC'.

    IF lv_destination IS INITIAL OR lv_destination EQ 'NONE'.

      TRY.
          CALL FUNCTION lv_rfc_name
            EXPORTING
              iv_data        = iv_data
            IMPORTING
              et_data        = et_data
            EXCEPTIONS
              system_failure = 1000 message lv_exc_msg
              OTHERS         = 1002.

          lv_subrc = sy-subrc.
	    CATCH cx_root INTO lx_root.
          lv_subrc = 1001.
          lv_exc_msg = lx_root->if_message~get_text( ).
      ENDTRY.

    ELSE.

      CALL FUNCTION lv_rfc_name DESTINATION lv_destination
        EXPORTING
          iv_data               = iv_data
        IMPORTING
          et_data               = et_data
        EXCEPTIONS
          system_failure        = 1000 MESSAGE lv_exc_msg
          communication_failure = 1001 MESSAGE lv_exc_msg
          OTHERS                = 1002.

      lv_subrc = sy-subrc.

    ENDIF. 
---
" Get RFC Destination w/ System ID
DATA lv_destination TYPE rfcdest. 

lv_destination = SWITCH #( sy-sysid WHEN 'FIP' THEN 'ELPCLNT100_RFC' ELSE 'ELTCLNT100_RFC' ).


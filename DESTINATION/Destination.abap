" Get Destination
SELECT SINGLE rfc_dest 
  FROM /iwfnd/c_mgdeam AS mgdeam
  INNER JOIN /iwfnd/i_med_srh AS med_srh ON med_srh~srv_identifier EQ mgdeam~service_id
  INNER JOIN /iwfnd/c_dfsyal AS dfsyal ON dfsyal~system_alias EQ mgdeam~system_alias
  WHERE med_srh~service_name EQ 'TASKPROCESSING'
    AND med_srh~service_version EQ '1'
    AND dfsyal~is_default EQ @abap_true
  INTO @DATA(lv_destination).
---
" Get RFC Destination
DATA: lo_dp_facade       TYPE REF TO /iwbep/if_mgw_dp_facade,
      ls_expanded_clause LIKE LINE OF et_expanded_tech_clauses,
      lv_destination     TYPE rfcdest,
      lv_exc_msg         TYPE string,
      lv_rfc_name        TYPE tfdir-funcname VALUE 'ZSM_F_RFC',
      lv_subrc           TYPE sy-subrc.

lo_dp_facade = /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
lv_destination = /iwbep/cl_sb_gen_dpc_rt_util=>get_rfc_destination( io_dp_facade = lo_dp_facade ).

IF lv_destination IS INITIAL OR lv_destination = 'NONE'.
  TRY.
      CALL FUNCTION lv_rfc_name
        EXPORTING
          iv_data = iv_data
        IMPORTING
          et_data = et_data
        EXCEPTIONS
          system_failure = 1000 MESSAGE lv_exc_msg
          OTHERS = 1002.

      lv_subrc = sy-subrc.
    CATCH cx_root INTO DATA(lx_root).
      lv_subrc = 1001.
      lv_exc_msg = lx_root->if_message~get_text( ).
  ENDTRY.
ELSE.
  CALL FUNCTION lv_rfc_name DESTINATION lv_destination
    EXPORTING
      iv_data = iv_data
    IMPORTING
      et_data = et_data
    EXCEPTIONS
      system_failure = 1000 MESSAGE lv_exc_msg
      communication_failure = 1001 MESSAGE lv_exc_msg
      OTHERS = 1002.

  lv_subrc = sy-subrc.
ENDIF.
---
" Get RFC Destination w/ System ID
DATA(lv_destination) = SWITCH rfcdest( sy-sysid WHEN 'FIP' THEN 'ELPCLNT100_RFC' 
                                                ELSE 'ELTCLNT100_RFC' ).
---

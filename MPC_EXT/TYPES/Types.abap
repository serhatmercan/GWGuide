CLASS zcl_zsm_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zsm_mpc
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES: BEGIN OF ts_deep.
             INCLUDE TYPE ts_header.
    TYPES:   
             detail  TYPE ts_detail,
             items	 TYPE STANDARD TABLE OF ts_item WITH DEFAULT KEY,
             objects TYPE STANDARD TABLE OF ts_object WITH DEFAULT KEY,
           END OF ts_deep.
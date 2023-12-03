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

    TYPES: BEGIN OF ts_multi_item_deep.
            INCLUDE TYPE ts_item.
    TYPES:
            details TYPE STANDARD TABLE OF ts_detail WITH DEFAULT KEY,
           END OF ts_multi_item_deep.

    TYPES: BEGIN OF ts_multi_deep.
            INCLUDE TYPE ts_header.
    TYPES:
            items TYPE STANDARD TABLE OF ts_multi_item_deep WITH DEFAULT KEY,
           END OF ts_multi_deep.
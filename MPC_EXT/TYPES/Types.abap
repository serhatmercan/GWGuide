*&---------------------------------------------------------------------
*& Deep-entity type definitions - TYPE FRAGMENT
*&---------------------------------------------------------------------
*& This file is a TYPE-DEFINITION FRAGMENT, not a class. Paste these
*& TYPES into the PUBLIC SECTION of your generated MPC_EXT class, where
*& ts_header / ts_item / ts_object / ts_detail already exist as the
*& structures generated from your entity types.
*&
*& These types are the contract consumed by:
*&   DPC_EXT/METHODS/CreateDeepEntity.abap
*&   DPC_EXT/METHODS/GetExpandedEntity.abap
*&   DPC_EXT/METHODS/GetExpandedEntitySet.abap
*&
*& TWO RULES THAT DECIDE WHETHER A DEEP ENTITY WORKS
*&
*& 1. NAMING - the nested component name must match the NAVIGATION
*&    PROPERTY name of the association in the model. Component "items"
*&    serves navigation property "Items"; component "objects" serves
*&    "Objects". A mismatch is the number-one cause of "the deep entity
*&    returns empty children" - it fails silently, not at activation.
*&    The technical (ABAP) component names are what you report in
*&    et_expanded_tech_clauses.
*&
*& 2. CARDINALITY - the ABAP shape must match the association cardinality:
*&      1..n  ->  a nested TABLE      (items, objects, details)
*&      1..1  ->  a nested STRUCTURE
*&    A 1..1 navigation property backed by a table (or the reverse) fails
*&    at runtime, not at activation.
*&
*& INCLUDE TYPE is a standalone statement: it ends with a period, and the
*& TYPES: chain has to be reopened afterwards. That is why each block
*& below reads BEGIN OF ... / INCLUDE TYPE ... . / TYPES: ... / END OF ...
*&---------------------------------------------------------------------

    " ------------------------------------------------------------------
    " Single-level deep entity:  Header
    "                              +-- Items    (1..n)
    "                              +-- Objects  (1..n)
    " Used by CREATE_DEEP_ENTITY and GET_EXPANDED_ENTITY(SET).
    " ------------------------------------------------------------------
    TYPES: BEGIN OF ts_deep.
             INCLUDE TYPE ts_header.
    TYPES:   items   TYPE STANDARD TABLE OF ts_item   WITH DEFAULT KEY,
             objects TYPE STANDARD TABLE OF ts_object WITH DEFAULT KEY,
           END OF ts_deep.

    TYPES tt_deep TYPE STANDARD TABLE OF ts_deep WITH DEFAULT KEY.


    " ------------------------------------------------------------------
    " Two-level deep entity:  Header
    "                           +-- Items          (1..n)
    "                                 +-- Details  (1..n)
    "
    " Build the innermost level first, then nest outwards. Both nesting
    " levels must be reported in et_expanded_tech_clauses when the method
    " resolves them itself:
    "     et_expanded_tech_clauses = VALUE #( ( `ITEMS` ) ( `DETAILS` ) ).
    " ------------------------------------------------------------------
    TYPES: BEGIN OF ts_multi_item_deep.
             INCLUDE TYPE ts_item.
    TYPES:   details TYPE STANDARD TABLE OF ts_detail WITH DEFAULT KEY,
           END OF ts_multi_item_deep.

    TYPES: BEGIN OF ts_multi_deep.
             INCLUDE TYPE ts_header.
    TYPES:   items TYPE STANDARD TABLE OF ts_multi_item_deep WITH DEFAULT KEY,
           END OF ts_multi_deep.

    TYPES tt_multi_deep TYPE STANDARD TABLE OF ts_multi_deep WITH DEFAULT KEY.


    " ------------------------------------------------------------------
    " Variant: a 1..1 navigation property is a nested STRUCTURE, not a
    " table.
    " ------------------------------------------------------------------
    TYPES: BEGIN OF ts_deep_with_single.
             INCLUDE TYPE ts_header.
    TYPES:   detail TYPE ts_detail,                                        " 1..1
             items  TYPE STANDARD TABLE OF ts_item WITH DEFAULT KEY,       " 1..n
           END OF ts_deep_with_single.

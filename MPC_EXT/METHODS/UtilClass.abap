*&---------------------------------------------------------------------
*& ZCL_SM_MPC_UTIL - reusable MPC_EXT annotation helper
*&---------------------------------------------------------------------
*& Wraps the repetitive /IWBEP MED annotation calls used from an MPC_EXT
*& DEFINE method: labels, semantics, display formats, filter restrictions,
*& value help, media, tree-table annotations.
*&
*& This file IS a complete class definition + implementation - unlike most
*& other files in this repository, which are cookbook method bodies.
*& See Define.abap for how it is called.
*&
*& EXCEPTION STRATEGY - FAIL LOUD
*& Every method propagates /IWBEP/CX_MGW_MED_EXCEPTION instead of
*& swallowing it. A MED exception means a modelling name does not exist -
*& a typo in an entity, property or action name. Swallowing it produces a
*& service that ACTIVATES SUCCESSFULLY with silently incomplete metadata,
*& and the failure only surfaces much later as "the value help doesn't
*& appear" or "the field isn't filterable", with nothing pointing at
*& DEFINE. Let DEFINE decide how to handle it - see Define.abap.
*&
*& All working variables are method-local on purpose: shared instance
*& attributes used as scratch space make each method depend on what ran
*& before it, and can silently annotate the wrong entity.
*&---------------------------------------------------------------------

CLASS zcl_sm_mpc_util DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING io_model        TYPE REF TO /iwbep/if_mgw_odata_model
                io_va_model     TYPE REF TO /iwbep/if_mgw_vocan_model
                iv_service_name TYPE string OPTIONAL.

    "! Vocabulary annotation com.sap.vocabularies.Common.v1.ValueList.
    "! @parameter iv_annotation_target | <Namespace>.<EntityType>/<Property>
    "! @parameter iv_entity_set_name   | entity set that provides the values
    "! @parameter iv_key_name          | property carrying the KEY - bound InOut
    "! @parameter iv_text_name          | property carrying the DESCRIPTION - display only
    METHODS add_value_help
      IMPORTING iv_annotation_target TYPE /iwbep/mgw_med_vocan_target
                iv_entity_set_name   TYPE string
                iv_key_name          TYPE string
                iv_text_name         TYPE string.

    METHODS add_auto_expand_include
      IMPORTING iv_entity_name      TYPE /iwbep/med_external_name
                iv_include_name     TYPE /iwbep/med_external_name
                iv_dummy_field      TYPE /iwbep/med_external_name
                iv_bind_conversions TYPE abap_bool DEFAULT abap_true
      RAISING   /iwbep/cx_mgw_med_exception.

    METHODS set_as_email
      IMPORTING iv_entity_name TYPE /iwbep/med_external_name
                iv_property    TYPE /iwbep/med_external_name
      RAISING   /iwbep/cx_mgw_med_exception.

    "! sap:text - pairs a key property with its description property.
    METHODS set_as_text
      IMPORTING iv_entity_name          TYPE /iwbep/med_external_name
                iv_property             TYPE /iwbep/med_external_name
                iv_property_description TYPE /iwbep/med_annotation_value
      RAISING   /iwbep/cx_mgw_med_exception.

    "! sap:unit - pairs an amount/quantity property with its unit property.
    METHODS set_as_unit
      IMPORTING iv_entity_name   TYPE /iwbep/med_external_name
                iv_property      TYPE /iwbep/med_external_name
                iv_property_unit TYPE /iwbep/med_annotation_value
      RAISING   /iwbep/cx_mgw_med_exception.

    METHODS set_disable_conversion_exit
      IMPORTING iv_entity_name TYPE /iwbep/med_external_name
                iv_property    TYPE /iwbep/med_external_name
      RAISING   /iwbep/cx_mgw_med_exception.

    METHODS set_display_date
      IMPORTING iv_entity_name TYPE /iwbep/med_external_name
                iv_property    TYPE /iwbep/med_external_name
      RAISING   /iwbep/cx_mgw_med_exception.

    METHODS set_display_non_negative
      IMPORTING iv_entity_name TYPE /iwbep/med_external_name
                iv_property    TYPE /iwbep/med_external_name
      RAISING   /iwbep/cx_mgw_med_exception.

    METHODS set_display_upper_case
      IMPORTING iv_entity_name TYPE /iwbep/med_external_name
                iv_property    TYPE /iwbep/med_external_name
      RAISING   /iwbep/cx_mgw_med_exception.

    "! Fixed-value dropdown: property-level value list + entity-set-level
    "! sap:semantics='fixed-values'. For small, stable domains this avoids
    "! a value-help round trip entirely.
    METHODS set_drop_down_list
      IMPORTING iv_entity_name          TYPE /iwbep/med_external_name
                iv_entity_set_name      TYPE /iwbep/med_external_name
                iv_property             TYPE /iwbep/med_external_name
                iv_property_description TYPE /iwbep/med_annotation_value
      RAISING   /iwbep/cx_mgw_med_exception.

    METHODS set_filterable
      IMPORTING iv_entity_name TYPE /iwbep/med_external_name
                iv_property    TYPE /iwbep/med_external_name
                iv_filterable  TYPE abap_bool DEFAULT abap_true
      RAISING   /iwbep/cx_mgw_med_exception.

    "! sap:filter-restriction='interval' - the UI offers a from/to range.
    METHODS set_filter_interval
      IMPORTING iv_entity_name TYPE /iwbep/med_external_name
                iv_property    TYPE /iwbep/med_external_name
      RAISING   /iwbep/cx_mgw_med_exception.

    "! sap:filter-restriction='multi-value' - several discrete values.
    METHODS set_filter_multi_value
      IMPORTING iv_entity_name TYPE /iwbep/med_external_name
                iv_property    TYPE /iwbep/med_external_name
      RAISING   /iwbep/cx_mgw_med_exception.

    "! sap:filter-restriction='single-value' - exactly one value.
    METHODS set_filter_single
      IMPORTING iv_entity_name TYPE /iwbep/med_external_name
                iv_property    TYPE /iwbep/med_external_name
      RAISING   /iwbep/cx_mgw_med_exception.

    "! sap:required-in-filter='true' - the client must supply this filter.
    "! Useful to stop an unbounded read of a large table.
    METHODS set_required_filter
      IMPORTING iv_entity_name TYPE /iwbep/med_external_name
                iv_property    TYPE /iwbep/med_external_name
      RAISING   /iwbep/cx_mgw_med_exception.

    "! sap:applicable-path - the named property decides at runtime whether
    "! the function import is offered.
    METHODS set_function_import_triggable
      IMPORTING iv_action_name TYPE /iwbep/med_external_name
                iv_property    TYPE /iwbep/med_annotation_value
      RAISING   /iwbep/cx_mgw_med_exception.

    "! Makes a function import input parameter optional.
    METHODS set_function_import_nullable
      IMPORTING iv_action_name TYPE /iwbep/med_external_name
                iv_parameter   TYPE /iwbep/med_external_name
                iv_nullable    TYPE abap_bool DEFAULT abap_true
      RAISING   /iwbep/cx_mgw_med_exception.

    "! Static sap:label. Not translatable - prefer
    "! set_label_from_text_element( ) in productive code.
    METHODS set_label
      IMPORTING iv_entity_name TYPE /iwbep/med_external_name
                iv_property    TYPE /iwbep/med_external_name
                iv_label       TYPE /iwbep/med_annotation_value
      RAISING   /iwbep/cx_mgw_med_exception.

    "! Translatable label taken from a text symbol of io_object.
    "! Deliberately does NOT also add a static sap:label - that would
    "! override the translatable text and defeat the purpose.
    METHODS set_label_from_text_element
      IMPORTING io_object      TYPE REF TO object
                iv_entity_name TYPE /iwbep/med_external_name
                iv_property    TYPE /iwbep/med_external_name
                iv_text        TYPE textpoolky
      RAISING   /iwbep/cx_mgw_med_exception.

    "! Turns the entity type into a media resource ($value endpoint) and
    "! marks the property that carries the MIME type.
    METHODS set_media
      IMPORTING iv_entity_name    TYPE /iwbep/med_external_name
                iv_mime_property  TYPE /iwbep/med_external_name
      RAISING   /iwbep/cx_mgw_med_exception.

    "! Renames a property in the external (OData) model.
    METHODS set_name
      IMPORTING iv_entity_name TYPE /iwbep/med_external_name
                iv_property    TYPE /iwbep/med_external_name
                iv_new_name    TYPE /iwbep/med_external_name
      RAISING   /iwbep/cx_mgw_med_exception.

    METHODS set_sortable
      IMPORTING iv_entity_name TYPE /iwbep/med_external_name
                iv_property    TYPE /iwbep/med_external_name
                iv_sortable    TYPE abap_bool DEFAULT abap_true
      RAISING   /iwbep/cx_mgw_med_exception.

    METHODS set_updatable
      IMPORTING iv_entity_name TYPE /iwbep/med_external_name
                iv_property    TYPE /iwbep/med_external_name
                iv_updatable   TYPE abap_bool DEFAULT abap_true
      RAISING   /iwbep/cx_mgw_med_exception.

    "! The five sap:hierarchy-* annotations that drive a UI5 TreeTable.
    "! All of them reference the SAME node-id property.
    METHODS set_tree_table_properties
      IMPORTING iv_entity_name           TYPE /iwbep/med_external_name
                iv_node_id_field         TYPE /iwbep/med_external_name
                iv_level_field           TYPE /iwbep/med_external_name
                iv_parent_relation_field TYPE /iwbep/med_external_name
                iv_drill_down_field      TYPE /iwbep/med_external_name
                iv_magnitude_field       TYPE /iwbep/med_external_name OPTIONAL
      RAISING   /iwbep/cx_mgw_med_exception.

  PRIVATE SECTION.

    CONSTANTS gc_sap                  TYPE /iwbep/med_anno_namespace   VALUE 'sap' ##NO_TEXT.

    CONSTANTS gc_applicable_path      TYPE /iwbep/med_annotation_key   VALUE 'applicable-path' ##NO_TEXT.
    CONSTANTS gc_display_format       TYPE /iwbep/med_annotation_key   VALUE 'display-format' ##NO_TEXT.
    CONSTANTS gc_filter_restriction   TYPE /iwbep/med_annotation_key   VALUE 'filter-restriction' ##NO_TEXT.
    CONSTANTS gc_label                TYPE /iwbep/med_annotation_key   VALUE 'label' ##NO_TEXT.
    CONSTANTS gc_required_in_filter   TYPE /iwbep/med_annotation_key   VALUE 'required-in-filter' ##NO_TEXT.
    CONSTANTS gc_semantics            TYPE /iwbep/med_annotation_key   VALUE 'semantics' ##NO_TEXT.
    CONSTANTS gc_text                 TYPE /iwbep/med_annotation_key   VALUE 'text' ##NO_TEXT.
    CONSTANTS gc_unit                 TYPE /iwbep/med_annotation_key   VALUE 'unit' ##NO_TEXT.

    CONSTANTS gc_node_for             TYPE /iwbep/med_annotation_key   VALUE 'hierarchy-node-for' ##NO_TEXT.
    CONSTANTS gc_level_for            TYPE /iwbep/med_annotation_key   VALUE 'hierarchy-level-for' ##NO_TEXT.
    CONSTANTS gc_parent_node_for      TYPE /iwbep/med_annotation_key   VALUE 'hierarchy-parent-node-for' ##NO_TEXT.
    CONSTANTS gc_drill_state_for      TYPE /iwbep/med_annotation_key   VALUE 'hierarchy-drill-state-for' ##NO_TEXT.
    CONSTANTS gc_descendant_count_for TYPE /iwbep/med_annotation_key   VALUE 'hierarchy-node-descendant-count-for' ##NO_TEXT.

    CONSTANTS gc_date                 TYPE /iwbep/med_annotation_value VALUE 'Date' ##NO_TEXT.
    CONSTANTS gc_email                TYPE /iwbep/med_annotation_value VALUE 'email' ##NO_TEXT.
    CONSTANTS gc_fixed_values         TYPE /iwbep/med_annotation_value VALUE 'fixed-values' ##NO_TEXT.
    CONSTANTS gc_interval             TYPE /iwbep/med_annotation_value VALUE 'interval' ##NO_TEXT.
    CONSTANTS gc_multi_value          TYPE /iwbep/med_annotation_value VALUE 'multi-value' ##NO_TEXT.
    CONSTANTS gc_non_negative         TYPE /iwbep/med_annotation_value VALUE 'NonNegative' ##NO_TEXT.
    CONSTANTS gc_single_value         TYPE /iwbep/med_annotation_value VALUE 'single-value' ##NO_TEXT.
    CONSTANTS gc_true                 TYPE /iwbep/med_annotation_value VALUE 'true' ##NO_TEXT.
    CONSTANTS gc_upper_case           TYPE /iwbep/med_annotation_value VALUE 'UpperCase' ##NO_TEXT.

    DATA go_model        TYPE REF TO /iwbep/if_mgw_odata_model.
    DATA go_va_model     TYPE REF TO /iwbep/if_mgw_vocan_model.
    DATA gv_service_name TYPE string.

    "! Convenience: fetch a property reference in one step.
    METHODS get_property
      IMPORTING iv_entity_name    TYPE /iwbep/med_external_name
                iv_property       TYPE /iwbep/med_external_name
      RETURNING VALUE(ro_property) TYPE REF TO /iwbep/if_mgw_odata_property
      RAISING   /iwbep/cx_mgw_med_exception.

    "! Convenience: fetch a property and create its sap: annotation.
    METHODS get_sap_annotation
      IMPORTING iv_entity_name      TYPE /iwbep/med_external_name
                iv_property         TYPE /iwbep/med_external_name
      RETURNING VALUE(ro_annotation) TYPE REF TO /iwbep/if_mgw_odata_annotation
      RAISING   /iwbep/cx_mgw_med_exception.

ENDCLASS.


CLASS zcl_sm_mpc_util IMPLEMENTATION.

  METHOD constructor.
    go_model        = io_model.
    go_va_model     = io_va_model.
    gv_service_name = iv_service_name.
  ENDMETHOD.


  METHOD get_property.
    ro_property = go_model->get_entity_type( iv_entity_name = iv_entity_name
                            )->get_property( iv_property_name = iv_property ).
  ENDMETHOD.


  METHOD get_sap_annotation.
    ro_annotation = get_property( iv_entity_name = iv_entity_name
                                  iv_property    = iv_property
                    )->/iwbep/if_mgw_odata_annotatabl~create_annotation( gc_sap ).
  ENDMETHOD.


  METHOD add_value_help.
    " Builds:
    "   <Annotation Term="com.sap.vocabularies.Common.v1.ValueList">
    "     <Record>
    "       <PropertyValue Property="CollectionPath" String="<entity set>"/>
    "       <PropertyValue Property="Parameters">
    "         <Collection>
    "           <Record Type="...ValueListParameterInOut">
    "             <PropertyValue Property="LocalDataProperty" PropertyPath="<key>"/>
    "             <PropertyValue Property="ValueListProperty" String="<key>"/>
    "           </Record>
    "           <Record Type="...ValueListParameterDisplayOnly">
    "             <PropertyValue Property="ValueListProperty" String="<text>"/>
    "           </Record>
    "
    " The InOut record is what writes the SELECTED VALUE back into the
    " field being value-helped, so it must bind the KEY property - binding
    " the text here would write the description into the key field.
    " The DisplayOnly record adds the description column to the dialog.

    DATA(lo_target)     = go_va_model->create_annotations_target( iv_annotation_target ).
    DATA(lo_annotation) = lo_target->create_annotation( iv_term = 'com.sap.vocabularies.Common.v1.ValueList' ).
    DATA(lo_record)     = lo_annotation->create_record( ).

    " Which entity set provides the values.
    lo_record->create_property( 'CollectionPath' )->create_simple_value( )->set_string( iv_entity_set_name ).

    DATA(lo_collection) = lo_record->create_property( 'Parameters' )->create_collection( ).

    " InOut - the KEY.
    DATA(lo_inout) = lo_collection->create_record( 'com.sap.vocabularies.Common.v1.ValueListParameterInOut' ).
    lo_inout->create_property( 'LocalDataProperty' )->create_simple_value( )->set_property_path( iv_key_name ).
    lo_inout->create_property( 'ValueListProperty' )->create_simple_value( )->set_string( iv_key_name ).

    " DisplayOnly - the DESCRIPTION.
    DATA(lo_display) = lo_collection->create_record( 'com.sap.vocabularies.Common.v1.ValueListParameterDisplayOnly' ).
    lo_display->create_property( 'ValueListProperty' )->create_simple_value( )->set_string( iv_text_name ).
  ENDMETHOD.


  METHOD add_auto_expand_include.
    go_model->get_entity_type( iv_entity_name = iv_entity_name
             )->add_auto_expand_include( iv_include_name     = iv_include_name
                                         iv_dummy_field      = iv_dummy_field
                                         iv_bind_conversions = iv_bind_conversions ).
  ENDMETHOD.


  METHOD set_as_email.
    get_sap_annotation( iv_entity_name = iv_entity_name
                        iv_property    = iv_property
        )->add( iv_key   = gc_semantics
                iv_value = gc_email ).
  ENDMETHOD.


  METHOD set_as_text.
    get_sap_annotation( iv_entity_name = iv_entity_name
                        iv_property    = iv_property
        )->add( iv_key   = gc_text
                iv_value = iv_property_description ).
  ENDMETHOD.


  METHOD set_as_unit.
    get_sap_annotation( iv_entity_name = iv_entity_name
                        iv_property    = iv_property
        )->add( iv_key   = gc_unit
                iv_value = iv_property_unit ).
  ENDMETHOD.


  METHOD set_disable_conversion_exit.
    get_property( iv_entity_name = iv_entity_name
                  iv_property    = iv_property )->disable_conversion( ).
  ENDMETHOD.


  METHOD set_display_date.
    get_sap_annotation( iv_entity_name = iv_entity_name
                        iv_property    = iv_property
        )->add( iv_key   = gc_display_format
                iv_value = gc_date ).
  ENDMETHOD.


  METHOD set_display_non_negative.
    get_sap_annotation( iv_entity_name = iv_entity_name
                        iv_property    = iv_property
        )->add( iv_key   = gc_display_format
                iv_value = gc_non_negative ).
  ENDMETHOD.


  METHOD set_display_upper_case.
    get_sap_annotation( iv_entity_name = iv_entity_name
                        iv_property    = iv_property
        )->add( iv_key   = gc_display_format
                iv_value = gc_upper_case ).
  ENDMETHOD.


  METHOD set_drop_down_list.
    " Property level: the value list is a fixed set.
    get_property( iv_entity_name = iv_entity_name
                  iv_property    = iv_property
        )->set_value_list( /iwbep/if_mgw_odata_property=>gcs_value_list_type_property-fixed_values ).

    " Entity-set level: the set itself holds fixed values.
    go_model->get_entity_set( iv_entity_set_name
             )->create_annotation( gc_sap )->add( iv_key   = gc_semantics
                                                  iv_value = gc_fixed_values ).

    " Pair the key with its description so the UI can show both.
    set_as_text( iv_entity_name          = iv_entity_name
                 iv_property             = iv_property
                 iv_property_description = iv_property_description ).
  ENDMETHOD.


  METHOD set_filterable.
    get_property( iv_entity_name = iv_entity_name
                  iv_property    = iv_property )->set_filterable( iv_filterable ).
  ENDMETHOD.


  METHOD set_filter_interval.
    get_sap_annotation( iv_entity_name = iv_entity_name
                        iv_property    = iv_property
        )->add( iv_key   = gc_filter_restriction
                iv_value = gc_interval ).
  ENDMETHOD.


  METHOD set_filter_multi_value.
    get_sap_annotation( iv_entity_name = iv_entity_name
                        iv_property    = iv_property
        )->add( iv_key   = gc_filter_restriction
                iv_value = gc_multi_value ).
  ENDMETHOD.


  METHOD set_filter_single.
    get_sap_annotation( iv_entity_name = iv_entity_name
                        iv_property    = iv_property
        )->add( iv_key   = gc_filter_restriction
                iv_value = gc_single_value ).
  ENDMETHOD.


  METHOD set_required_filter.
    get_sap_annotation( iv_entity_name = iv_entity_name
                        iv_property    = iv_property
        )->add( iv_key   = gc_required_in_filter
                iv_value = gc_true ).
  ENDMETHOD.


  METHOD set_function_import_triggable.
    go_model->get_action( iv_action_name = iv_action_name
             )->/iwbep/if_mgw_odata_annotatabl~create_annotation( gc_sap
             )->add( iv_key   = gc_applicable_path
                     iv_value = iv_property ).
  ENDMETHOD.


  METHOD set_function_import_nullable.
    go_model->get_action( iv_action_name = iv_action_name
             )->get_input_parameter( iv_name = iv_parameter
             )->set_nullable( iv_nullable = iv_nullable ).
  ENDMETHOD.


  METHOD set_label.
    get_sap_annotation( iv_entity_name = iv_entity_name
                        iv_property    = iv_property
        )->add( iv_key   = gc_label
                iv_value = iv_label ).
  ENDMETHOD.


  METHOD set_label_from_text_element.
    " Translatable label from a text symbol. Deliberately no additional
    " static sap:label here - that would override this and make the text
    " element pointless.
    get_property( iv_entity_name = iv_entity_name
                  iv_property    = iv_property
        )->set_label_from_text_element( iv_text_element_symbol = iv_text
                                        io_object_ref          = io_object ).
  ENDMETHOD.


  METHOD set_media.
    DATA(lo_entity) = go_model->get_entity_type( iv_entity_name = iv_entity_name ).

    " Both calls are needed: set_is_media( ) creates the $value endpoint,
    " set_as_content_type( ) tells Gateway which property carries the MIME
    " type of the returned stream.
    lo_entity->set_is_media( iv_is_media = abap_true ).
    lo_entity->get_property( iv_property_name = iv_mime_property )->set_as_content_type( ).
  ENDMETHOD.


  METHOD set_name.
    get_property( iv_entity_name = iv_entity_name
                  iv_property    = iv_property )->set_name( iv_new_name ).
  ENDMETHOD.


  METHOD set_sortable.
    get_property( iv_entity_name = iv_entity_name
                  iv_property    = iv_property )->set_sortable( iv_sortable ).
  ENDMETHOD.


  METHOD set_updatable.
    get_property( iv_entity_name = iv_entity_name
                  iv_property    = iv_property )->set_updatable( iv_updatable ).
  ENDMETHOD.


  METHOD set_tree_table_properties.
    " Each annotation sits on a DIFFERENT property, but they all reference
    " the SAME node-id property as their value - that is what links the
    " hierarchy together.
    DATA(lv_node_id) = CONV /iwbep/med_annotation_value( iv_node_id_field ).

    get_sap_annotation( iv_entity_name = iv_entity_name
                        iv_property    = iv_node_id_field
        )->add( iv_key = gc_node_for iv_value = lv_node_id ).

    get_sap_annotation( iv_entity_name = iv_entity_name
                        iv_property    = iv_level_field
        )->add( iv_key = gc_level_for iv_value = lv_node_id ).

    get_sap_annotation( iv_entity_name = iv_entity_name
                        iv_property    = iv_parent_relation_field
        )->add( iv_key = gc_parent_node_for iv_value = lv_node_id ).

    get_sap_annotation( iv_entity_name = iv_entity_name
                        iv_property    = iv_drill_down_field
        )->add( iv_key = gc_drill_state_for iv_value = lv_node_id ).

    " Optional - only when the model carries a descendant-count property.
    IF iv_magnitude_field IS NOT INITIAL.
      get_sap_annotation( iv_entity_name = iv_entity_name
                          iv_property    = iv_magnitude_field
          )->add( iv_key = gc_descendant_count_for iv_value = lv_node_id ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

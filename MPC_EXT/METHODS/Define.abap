" Define in Method
METHOD define.
	super->define( ).

  CONSTANTS: lc_aggregate            TYPE /iwbep/med_annotation_value VALUE 'aggregate',
             lc_applicable_path      TYPE /iwbep/med_annotation_key   VALUE 'applicable-path',
             lc_date                 TYPE /iwbep/med_annotation_value VALUE 'Date',
             lc_descendant_count_for TYPE /iwbep/med_annotation_key   VALUE 'hierarchy-node-descendant-count-for',
             lc_display_format       TYPE /iwbep/med_annotation_key   VALUE 'display-format',
             lc_drill_state_for      TYPE /iwbep/med_annotation_key   VALUE 'hierarchy-drill-state-for',
             lc_filter_restriction   TYPE /iwbep/med_annotation_key   VALUE 'filter-restriction',
             lc_email                TYPE /iwbep/med_annotation_value VALUE 'email',
             lc_fixed_values         TYPE /iwbep/med_annotation_value VALUE 'fixed-values',
             lc_interval             TYPE /iwbep/med_annotation_value VALUE 'interval',
             lc_multi_value          TYPE /iwbep/med_annotation_value VALUE 'multi-value',
             lc_node_for             TYPE /iwbep/med_annotation_key   VALUE 'hierarchy-node-for',
             lc_non_negative         TYPE /iwbep/med_annotation_value VALUE 'NonNegative',
             lc_label                TYPE /iwbep/med_annotation_key   VALUE 'label',
             lc_level_for            TYPE /iwbep/med_annotation_key   VALUE 'hierarchy-level-for',
             lc_parent_node_for      TYPE /iwbep/med_annotation_key   VALUE 'hierarchy-parent-node-for',
             lc_required_in_filter   TYPE /iwbep/med_annotation_key   VALUE 'required-in-filter',
             lc_sap                  TYPE /iwbep/med_anno_namespace   VALUE 'sap',
             lc_semantics            TYPE /iwbep/med_annotation_key   VALUE 'semantics',
             lc_single_value         TYPE /iwbep/med_annotation_value VALUE 'single-value',
             lc_text                 TYPE /iwbep/med_annotation_key   VALUE 'text',
             lc_true                 TYPE /iwbep/med_annotation_value VALUE 'true',
             lc_unit                 TYPE /iwbep/med_annotation_key   VALUE 'unit',
             lc_upper_case           TYPE /iwbep/med_annotation_value VALUE 'UpperCase'.

  TRY.           
    DATA(lo_action) = model->get_action( iv_action_name = 'GetPersonelInformation' ).
    DATA(lo_entity) = model->get_entity_type( iv_entity_name = 'Header' ).
    DATA(lv_property) = lo_entity->get_property( 'Key' ).
    DATA(lo_annotation) = lv_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( lc_sap );

    " Add Value Help
    DATA(lo_va_target) = vocab_anno_model->create_annotations_target( '/SM/ZSM_ODATA_TEST_SRV.Header/Key' ).
    DATA(lo_va) = lo_va_target->create_annotation( iv_term = 'com.sap.vocabularies.Common.v1.ValueList' ).
    DATA(lo_va_record) = lo_va->create_record( ).
    DATA(lo_va_property) = lo_va_record->create_property( 'CollectionPath' ).
    DATA(lo_va_collection) = lo_va_record->create_property( 'Parameters' )->create_collection( ).

    lo_va_property->create_simple_value( )->set_string( 'KeyVHSet' ).

    lo_va_record = lo_va_collection->create_record( 'com.sap.vocabularies.Common.v1.ValueListParameterInOut' ).
    lo_va_property = lo_va_record->create_property( 'LocalDataProperty' ).
    lo_va_property->create_simple_value( )->set_property_path( 'Key' ).
    lo_va_property = lo_va_record->create_property( 'ValueListProperty' ).
    lo_va_property->create_simple_value( )->set_string( 'Key' ).

    lo_va_record = lo_va_collection->create_record( 'com.sap.vocabularies.Common.v1.ValueListParameterDisplayOnly' ).
    lo_va_property = lo_va_record->create_property( 'ValueListProperty' ).
    lo_va_property->create_simple_value( )->set_property_path( 'Text' ).  
    
    " Set as E-Mail
    lo_annotation->add( iv_key = lc_semantics iv_value = lc_email ).

    " Set as Text (Key & Description)
    lo_annotation->add( iv_key = lc_text iv_value = 'Description' ).

    " Set as Unit (Amount & Unit)
    lo_annotation->add( iv_key = lc_unit iv_value = 'Unit' ).

    " Set Disable Conversion Exit
    lv_property->disable_conversion( ).

    " Set Display Date
    lo_annotation->add( iv_key = lc_display_format iv_value = lc_date ).

    " Set Display Non Negative
    lo_annotation->add( iv_key = lc_display_format iv_value = lc_non_negative ).

    " Set Display Upper Case
    lo_annotation->add( iv_key = lc_display_format iv_value = lc_upper_case ).

    " Set Drop Down List - I
    lv_property->set_value_list( /iwbep/if_mgw_odata_property=>gcs_value_list_type_property-fixed_values ).
    me->set_as_text( iv_entity_name = 'Header' iv_property = 'Key' iv_property_description = 'Description' ).

    " Set Drop Down List - II
    model->get_entity_set( 'HeaderSet' )->create_annotation( lc_sap )->add( iv_key = lc_semantics iv_value = lc_fixed_values ).
    me->set_as_text( iv_entity_name = 'Header' iv_property = 'Key' iv_property_description = 'Description' ).

    " Set Filterable
    lv_property->set_filterable( abap_true ).

    " Set Filter Interval
    lo_annotation->add( iv_key = lc_filter_restriction iv_value = lc_interval ).

    " Set Filter Mandatory
    lo_annotation->add( iv_key = lc_required_in_filter iv_value = lc_true ).

    " Set Filter Multi Value
    lo_annotation->add( iv_key = lc_filter_restriction iv_value = lc_multi_value ).

    " Set Filter Single
    lo_annotation->add( iv_key = lc_filter_restriction iv_value = lc_single_value ).

    " Set Function Import Triggable
    lo_action->/iwbep/if_mgw_odata_annotatabl~create_annotation( lc_sap )->add( iv_key = lc_applicable_path iv_value = 'ID' ).

    " Set Function Import Property Nullable
    lo_action->get_input_parameter( iv_name = 'ID' )->set_nullable( iv_nullable = abap_true ).

    " Set Label
    lo_annotation->add( iv_key = lc_label iv_value = 'SMERCAN' ).

    " Set Label From Text Element (Text | 001)
    lo_property->set_label_from_text_element( EXPORTING iv_text_element_symbol = 'Text' io_object_ref = me ).
    lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( lc_sap )->add( EXPORTING iv_key = lc_label iv_value = 'SMERCAN' ).

    " Set Media
    lo_entity->set_is_media( iv_is_media = abap_true ).
    lo_entity->get_property( iv_property_name = 'Mimetype' )->set_as_content_type( ).

    " Set Name
    lo_entity->add_auto_expand_include( EXPORTING iv_include_name     = 'ZSM_S_TST'
                                                  iv_dummy_field      = 'DUMMY'
                                                  iv_bind_conversions = 'X' ).
    lv_property->set_name( 'SMERCAN' ).

    " Set Required Filter
    lo_annotation->add( iv_key = lc_required_in_filter iv_value = lc_true ).

    " Set Sortable
    lv_property->set_sortable( abap_true ).

    " Set Tree Table Properties
    IF lo_entity IS BOUND.
      TRY.
        lv_property = lo_entity->get_property( 'Header' ).
        lo_annotation = lv_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( lc_sap ).
        lo_annotation->add( iv_key = lc_node_for iv_value = 'NodeID' ).
      CATCH /iwbep/cx_mgw_med_exception.
      ENDTRY.

      TRY.
        lv_property = lo_entity->get_property( 'Level' ).
        lo_annotation = lv_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( lc_sap ).
        lo_annotation->add( iv_key = lc_level_for iv_value = 'NodeID' ).
      CATCH /iwbep/cx_mgw_med_exception.
      ENDTRY.
    
      TRY.
        lv_property = lo_entity->get_property( 'Parent' ).
        lo_annotation = lv_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( lc_sap ).
        lo_annotation->add( iv_key = lc_parent_node_for iv_value = 'NodeID' ).
      CATCH /iwbep/cx_mgw_med_exception.
      ENDTRY.
    
      TRY.
        lo_property = lo_entity->get_property( 'Drill' ).
        lo_annotation = lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( lc_sap ).
        lo_annotation->add( iv_key = lc_drill_state_for iv_value = 'NodeID' ).
      CATCH /iwbep/cx_mgw_med_exception.
      ENDTRY.
    
      " Extra
      TRY.
        lo_property = lo_entity->get_property( 'Magnitute' ).
        lo_annotation = lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( lc_sap ).
        lo_annotation->add( iv_key = lc_descendant_count_for iv_value = 'NodeID' ).
      CATCH /iwbep/cx_mgw_med_exception.
      ENDTRY.
    ENDIF.

    " Set Updatable
    lv_property->set_updatable( abap_true ).
  CATCH /iwbep/cx_mgw_med_exception INTO DATA(lo_exception).
  ENDTRY.
ENDMETHOD.

" Define w/ Util Class
METHOD define.
  DATA lo_mpc_util TYPE REF TO zcl_sm_mpc_util.

  CREATE OBJECT lo_mpc_util EXPORTING io_model = model io_va_model = vocab_anno_model iv_service_name = 'ZSM_ODATA_TEST_SRV'.

  super->define( ).

  lo_mpc_util->add_value_help( iv_annotation_target = '/SM/ZSM_ODATA_TEST_SRV.Header/Key' iv_entity_set_name = 'KeyVHSet' iv_key_name = 'Key' iv_text_name = 'Text' ).
  lo_mpc_util->set_as_email( iv_entity_name = 'Header' iv_property = 'Key' ).
  lo_mpc_util->set_as_text( iv_entity_name = 'Header' iv_property = 'Amount' iv_property_description = 'Unit' ).
  lo_mpc_util->set_disable_conversion_exit( iv_entity_name = 'Header' iv_property = 'Amount' ).
  lo_mpc_util->set_display_date( iv_entity_name = 'Header' iv_property = 'Key' ).
  lo_mpc_util->set_display_non_negative( iv_entity_name = 'Header' iv_property = 'Key' ).
  lo_mpc_util->set_display_upper_case( iv_entity_name = 'Header' iv_property = 'Key' ).
  lo_mpc_util->set_drop_down_list( iv_entity_name = 'Header' iv_entity_set_name = 'KeyVHSet' iv_property = 'Key' iv_property_description = 'Text' ).
  lo_mpc_util->set_filterable( iv_entity_name = 'Header' iv_property = 'Key' ).
  lo_mpc_util->set_filter_interval( iv_entity_name = 'Header' iv_property = 'Key' ).
  lo_mpc_util->set_filter_mandatory( iv_entity_name = 'Header' iv_property = 'Key' ).
  lo_mpc_util->set_filter_multi_value( iv_entity_name = 'Header' iv_property = 'Key').
  lo_mpc_util->set_filter_single( iv_entity_name = 'Header' iv_property = 'Key' ).
  lo_mpc_util->set_function_import_triggable( iv_action_name = 'GetPersonelInformation' iv_property = 'ID' ).
  lo_mpc_util->set_label( iv_entity_name = 'Header' iv_property = 'Key' ).
  lo_mpc_util->set_label_from_text_element( io_object = me iv_entity_name = 'Header' iv_property = 'Key' iv_text = 'Text' ).
  lo_mpc_util->set_label_from_text_element( io_object = me iv_entity_name = 'Header' iv_property = 'Key' iv_text = '001' ).
  lo_mpc_util->set_media( iv_entity_name = 'Document' iv_property = 'Mimetype' ).
  lo_mpc_util->set_name( iv_entity_name = 'Header' iv_property = 'Key' ).
  lo_mpc_util->set_required_filter( iv_entity_name = 'Header' iv_property = 'Key' ).
  lo_mpc_util->set_sortable( iv_entity_name = 'Header' iv_property = 'Key' ).
  lo_mpc_util->set_tree_table_properties( iv_entity_name = 'Header' iv_node_id_field = 'NodeID' iv_level_field = 'Level'
                                          iv_parent_relation_field = 'Parent' iv_drill_down_field = 'Drill' iv_magnitude_field = 'Magnitute' ).
  lo_mpc_util->set_updatable( iv_entity_name = 'Header' iv_property = 'Key' ).
ENDMETHOD.

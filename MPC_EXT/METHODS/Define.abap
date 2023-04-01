METHOD define.

	super->define( ).

  " Date Format "
  model->get_entity_type( 'Header' )->get_property( 'Key' )->/iwbep/if_mgw_odata_annotatabl~create_annotation( /iwbep/if_mgw_med_odata_types=>gc_sap_namespace )->add( iv_key = 'display-format' iv_value = 'Date' ).

ENDMETHOD.

METHOD define.

  DATA lo_mpc_util TYPE REF TO zcl_sm_mpc_util.

  CREATE OBJECT lo_mpc_util
    EXPORTING
      io_model        = model
      io_va_model     = vocab_anno_model
      iv_service_name = 'ZSM_ODATA_TEST_SRV'.

  super->define( ).

  lo_mpc_util->add_value_help(
    iv_annotation_target = '/SM/ZSM_ODATA_TEST_SRV.Header/Key'
    iv_entity_set_name   = 'KeyVHSet'
    iv_key_name          = 'Key'
    iv_text_name         = 'Text'
  ).

  lo_mpc_util->set_as_email(
    iv_entity_name = 'Header'
    iv_property    = 'Key'
  ).

  lo_mpc_util->set_as_text(
    iv_entity_name          = 'Header'
    iv_property             = 'Amount'
    iv_property_description = 'Unit'
  ).

  lo_mpc_util->set_disable_conversion_exit(
    iv_entity_name = 'Header'
    iv_property    = 'Amount'
  ).

  lo_mpc_util->set_display_date(
    iv_entity_name = 'Header'
    iv_property    = 'Key'
  ).

  lo_mpc_util->set_display_non_negative(
    iv_entity_name = 'Header'
    iv_property    = 'Key'
  ).

  lo_mpc_util->set_display_upper_case(
    iv_entity_name = 'Header'
    iv_property    = 'Key'
  ).

  lo_mpc_util->set_drop_down_list(
    iv_entity_name          = 'Header'
    iv_entity_set_name      = 'KeyVHSet'
    iv_property             = 'Key'
    iv_property_description = 'Text'
  ).

  lo_mpc_util->set_filterable(
    iv_entity_name = 'Header'
    iv_property    = 'Key'
  ).

  lo_mpc_util->set_filter_interval(
    iv_entity_name = 'Header'
    iv_property    = 'Key'
  ).

  lo_mpc_util->set_filter_mandatory(
    iv_entity_name = 'Header'
    iv_property    = 'Key'
  ).

  lo_mpc_util->set_filter_multi_value(
    iv_entity_name = 'Header'
    iv_property    = 'Key'
  ).

  lo_mpc_util->set_filter_single(
    iv_entity_name = 'Header'
    iv_property    = 'Key'
  ).

  lo_mpc_util->set_function_import_triggable(
    iv_action_name = 'GetPersonelInformation'
    iv_property    = 'ID'
  ).

  lo_mpc_util->set_label(
    iv_entity_name = 'Header'
    iv_property    = 'Key'
  ).

  lo_mpc_util->set_label_from_text_element(
    io_object      = me
    iv_entity_name = 'Header'
    iv_property    = 'Key'
    iv_text        = 'Text'
  ).

  lo_mpc_util->set_media(
    iv_entity_name = 'Document'
    iv_property    = 'Mimetype'
  ).

  lo_mpc_util->set_name(
    iv_entity_name = 'Header'
    iv_property    = 'Key'
  ).

  lo_mpc_util->set_required_filter(
    iv_entity_name = 'Header'
    iv_property    = 'Key'
  ).

  lo_mpc_util->set_sortable(
    iv_entity_name = 'Header'
    iv_property    = 'Key'
  ).

  lo_mpc_util->set_tree_table_properties(
    iv_entity_name           = 'Header'
    iv_node_id_field         = 'NodeID'
    iv_level_field           = 'Level'
    iv_parent_relation_field = 'Parent'
    iv_drill_down_field      = 'Drill'
    iv_magnitude_field       = 'Magnitute'
  ).

  lo_mpc_util->set_updatable(
    iv_entity_name = 'Header'
    iv_property    = 'Key'
  ).

ENDMETHOD.

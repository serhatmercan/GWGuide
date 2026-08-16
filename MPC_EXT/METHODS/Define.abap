*&---------------------------------------------------------------------
*& MPC_EXT DEFINE - model annotations
*&---------------------------------------------------------------------
*& REFERENCE COOKBOOK - READ BEFORE COPYING
*&
*& Three INDEPENDENT reference implementations of the SAME generated
*& method (DEFINE of the MPC_EXT class). Pick ONE approach - they are not
*& meant to be pasted together. Entity, property and service names are
*& placeholders for your own model.
*&
*&   Example 1  minimal, focused DEFINE
*&   Example 2  annotation catalogue, applied directly
*&   Example 3  the same catalogue behind ZCL_SM_MPC_UTIL (UtilClass.abap)
*&
*& Examples 2 and 3 exist as a deliberate raw-vs-helper comparison.
*&
*& ALWAYS call super->define( ) FIRST. Forgetting it discards the
*& generated model and is a classic MPC_EXT bug.
*&
*& EXCEPTION STRATEGY
*& /IWBEP/CX_MGW_MED_EXCEPTION means a modelling name does not exist - a
*& typo in an entity, property or action name. Handle it PER ANNOTATION,
*& not once around the whole method: one broad TRY with a single CATCH
*& means the first typo silently skips every remaining annotation, the
*& service still activates, and the metadata is quietly incomplete. The
*& failure then surfaces much later as "the value help doesn't appear",
*& with nothing pointing back at DEFINE.
*&---------------------------------------------------------------------


*&---------------------------------------------------------------------
*& Example 1 - minimal DEFINE: render one property as a date
*&---------------------------------------------------------------------
  METHOD define.

    CONSTANTS lc_sap            TYPE /iwbep/med_anno_namespace   VALUE 'sap' ##NO_TEXT.
    CONSTANTS lc_display_format TYPE /iwbep/med_annotation_key   VALUE 'display-format' ##NO_TEXT.
    CONSTANTS lc_date           TYPE /iwbep/med_annotation_value VALUE 'Date' ##NO_TEXT.

    super->define( ).

    TRY.
        DATA(lo_entity)     = model->get_entity_type( iv_entity_name = 'Header' ).
        DATA(lo_property)   = lo_entity->get_property( 'CreatedOn' ).
        DATA(lo_annotation) = lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( lc_sap ).

        lo_annotation->add( iv_key   = lc_display_format
                            iv_value = lc_date ).

      CATCH /iwbep/cx_mgw_med_exception INTO DATA(lx_med).
        " Do not swallow silently. During development, re-raising or
        " asserting makes a modelling typo visible immediately.
        ASSERT lx_med IS NOT BOUND.
    ENDTRY.

  ENDMETHOD.


*&---------------------------------------------------------------------
*& Example 2 - annotation catalogue, applied directly in DEFINE
*&
*& A reference list of the annotations this repository uses. Note the
*& groups marked "PICK ONE": several annotations below are MUTUALLY
*& EXCLUSIVE and would produce contradictory metadata if applied to the
*& same property together. Only one option per group is active; the rest
*& are commented out.
*&
*& No TRY/CATCH here, deliberately. The generated DEFINE method is
*& declared to propagate /IWBEP/CX_MGW_MED_EXCEPTION, so a modelling typo
*& surfaces immediately instead of silently skipping the rest of the
*& annotations. Wrapping each block in TRY ... CATCH ... ENDTRY with an
*& empty handler is the anti-pattern this repository warns about.
*& (Verify the RAISING clause on DEFINE in your own generated MPC class.)
*&---------------------------------------------------------------------
  METHOD define.

    CONSTANTS lc_sap                  TYPE /iwbep/med_anno_namespace   VALUE 'sap' ##NO_TEXT.

    CONSTANTS lc_applicable_path      TYPE /iwbep/med_annotation_key   VALUE 'applicable-path' ##NO_TEXT.
    CONSTANTS lc_display_format       TYPE /iwbep/med_annotation_key   VALUE 'display-format' ##NO_TEXT.
    CONSTANTS lc_filter_restriction   TYPE /iwbep/med_annotation_key   VALUE 'filter-restriction' ##NO_TEXT.
    CONSTANTS lc_label                TYPE /iwbep/med_annotation_key   VALUE 'label' ##NO_TEXT.
    CONSTANTS lc_required_in_filter   TYPE /iwbep/med_annotation_key   VALUE 'required-in-filter' ##NO_TEXT.
    CONSTANTS lc_semantics            TYPE /iwbep/med_annotation_key   VALUE 'semantics' ##NO_TEXT.
    CONSTANTS lc_text                 TYPE /iwbep/med_annotation_key   VALUE 'text' ##NO_TEXT.
    CONSTANTS lc_unit                 TYPE /iwbep/med_annotation_key   VALUE 'unit' ##NO_TEXT.

    CONSTANTS lc_node_for             TYPE /iwbep/med_annotation_key   VALUE 'hierarchy-node-for' ##NO_TEXT.
    CONSTANTS lc_level_for            TYPE /iwbep/med_annotation_key   VALUE 'hierarchy-level-for' ##NO_TEXT.
    CONSTANTS lc_parent_node_for      TYPE /iwbep/med_annotation_key   VALUE 'hierarchy-parent-node-for' ##NO_TEXT.
    CONSTANTS lc_drill_state_for      TYPE /iwbep/med_annotation_key   VALUE 'hierarchy-drill-state-for' ##NO_TEXT.
    CONSTANTS lc_descendant_count_for TYPE /iwbep/med_annotation_key   VALUE 'hierarchy-node-descendant-count-for' ##NO_TEXT.

    CONSTANTS lc_date                 TYPE /iwbep/med_annotation_value VALUE 'Date' ##NO_TEXT.
    CONSTANTS lc_email                TYPE /iwbep/med_annotation_value VALUE 'email' ##NO_TEXT.
    CONSTANTS lc_fixed_values         TYPE /iwbep/med_annotation_value VALUE 'fixed-values' ##NO_TEXT.
    CONSTANTS lc_interval             TYPE /iwbep/med_annotation_value VALUE 'interval' ##NO_TEXT.
    CONSTANTS lc_multi_value          TYPE /iwbep/med_annotation_value VALUE 'multi-value' ##NO_TEXT.
    CONSTANTS lc_non_negative         TYPE /iwbep/med_annotation_value VALUE 'NonNegative' ##NO_TEXT.
    CONSTANTS lc_single_value         TYPE /iwbep/med_annotation_value VALUE 'single-value' ##NO_TEXT.
    CONSTANTS lc_true                 TYPE /iwbep/med_annotation_value VALUE 'true' ##NO_TEXT.
    CONSTANTS lc_upper_case           TYPE /iwbep/med_annotation_value VALUE 'UpperCase' ##NO_TEXT.

    super->define( ).

    " =================================================================
    " Value help (vocabulary annotation)
    "
    " The annotation target is <Namespace>.<EntityType>/<Property>, where
    " the namespace is the service's model namespace.
    " NEEDS OFFICIAL VERIFICATION: the exact namespace prefix depends on
    " your service and development namespace - check $metadata.
    " =================================================================
    DATA(lo_va_target)  = vocab_anno_model->create_annotations_target( 'ZSM_ODATA_TEST_SRV.Header/Key' ).
    DATA(lo_va)         = lo_va_target->create_annotation( iv_term = 'com.sap.vocabularies.Common.v1.ValueList' ).
    DATA(lo_va_record)  = lo_va->create_record( ).

    lo_va_record->create_property( 'CollectionPath' )->create_simple_value( )->set_string( 'KeyVHSet' ).

    DATA(lo_va_collection) = lo_va_record->create_property( 'Parameters' )->create_collection( ).

    " InOut binds the KEY - this record writes the selected value back
    " into the field being value-helped.
    DATA(lo_va_inout) = lo_va_collection->create_record(
                            'com.sap.vocabularies.Common.v1.ValueListParameterInOut' ).
    lo_va_inout->create_property( 'LocalDataProperty' )->create_simple_value( )->set_property_path( 'Key' ).
    lo_va_inout->create_property( 'ValueListProperty' )->create_simple_value( )->set_string( 'Key' ).

    " DisplayOnly adds the description column to the dialog.
    DATA(lo_va_display) = lo_va_collection->create_record(
                              'com.sap.vocabularies.Common.v1.ValueListParameterDisplayOnly' ).
    lo_va_display->create_property( 'ValueListProperty' )->create_simple_value( )->set_string( 'Text' ).


    " =================================================================
    " Semantics
    " =================================================================
    model->get_entity_type( 'Header' )->get_property( 'Email'
         )->/iwbep/if_mgw_odata_annotatabl~create_annotation( lc_sap
         )->add( iv_key = lc_semantics iv_value = lc_email ).

    " Key + description pairing.
    model->get_entity_type( 'Header' )->get_property( 'Key'
         )->/iwbep/if_mgw_odata_annotatabl~create_annotation( lc_sap
         )->add( iv_key = lc_text iv_value = 'Description' ).

    " Amount + unit pairing.
    model->get_entity_type( 'Header' )->get_property( 'Amount'
         )->/iwbep/if_mgw_odata_annotatabl~create_annotation( lc_sap
         )->add( iv_key = lc_unit iv_value = 'Currency' ).

    " =================================================================
    " Display format - PICK ONE per property. These are mutually
    " exclusive; applying several to one property is contradictory.
    " =================================================================
    DATA(lo_anno_created) = model->get_entity_type( 'Header' )->get_property( 'CreatedOn'
                                 )->/iwbep/if_mgw_odata_annotatabl~create_annotation( lc_sap ).

    lo_anno_created->add( iv_key = lc_display_format iv_value = lc_date ).          " date only
*        lo_anno_created->add( iv_key = lc_display_format iv_value = lc_non_negative ). " no minus sign
*        lo_anno_created->add( iv_key = lc_display_format iv_value = lc_upper_case ).   " upper case


    " Suppress the conversion exit for a property (raw internal value).
    model->get_entity_type( 'Header' )->get_property( 'Amount' )->disable_conversion( ).

    " =================================================================
    " Filter restrictions - PICK ONE per property.
    " =================================================================
    DATA(lo_anno_key) = model->get_entity_type( 'Header' )->get_property( 'Key'
                             )->/iwbep/if_mgw_odata_annotatabl~create_annotation( lc_sap ).

    lo_anno_key->add( iv_key = lc_filter_restriction iv_value = lc_single_value ).  " exactly one value
*        lo_anno_key->add( iv_key = lc_filter_restriction iv_value = lc_multi_value ).  " several values
*        lo_anno_key->add( iv_key = lc_filter_restriction iv_value = lc_interval ).     " from / to range

    " Independent of the restriction above: force the client to supply
    " this filter. Useful to prevent an unbounded read of a large table.
    lo_anno_key->add( iv_key = lc_required_in_filter iv_value = lc_true ).


    " =================================================================
    " Property flags
    " =================================================================
    DATA(lo_prop_key) = model->get_entity_type( 'Header' )->get_property( 'Key' ).

    lo_prop_key->set_filterable( abap_true ).
    lo_prop_key->set_sortable( abap_true ).
    lo_prop_key->set_updatable( abap_true ).

    " Rename a property in the external model.
*        lo_prop_key->set_name( 'KeyId' ).


    " Entity-SET level flags shape what a Fiori UI renders (Create /
    " Delete buttons, paging). They are METADATA, not security - a direct
    " HTTP request is unaffected. Enforce authorization in DPC_EXT.
    DATA(lo_entity_set) = model->get_entity_set( 'HeaderSet' ).

    lo_entity_set->set_creatable( abap_true ).
    lo_entity_set->set_updatable( abap_true ).
    lo_entity_set->set_deletable( abap_false ).
    lo_entity_set->set_pageable( abap_true ).


    " =================================================================
    " Labels - PICK ONE. A text element is translatable; a static label
    " is not. Applying both means the static one wins and the text
    " element is pointless.
    " =================================================================
    DATA(lo_prop_label) = model->get_entity_type( 'Header' )->get_property( 'Key' ).

    " Translatable - text symbol 001 of this class (see TextElements.png).
    lo_prop_label->set_label_from_text_element( iv_text_element_symbol = '001'
                                                io_object_ref          = me ).

    " Static alternative:
*        lo_prop_label->/iwbep/if_mgw_odata_annotatabl~create_annotation( lc_sap
*                     )->add( iv_key = lc_label iv_value = 'Key' ).


    " =================================================================
    " Fixed-value dropdown - PICK ONE mechanism.
    " =================================================================
    " Property level.
    model->get_entity_type( 'Header' )->get_property( 'Status'
         )->set_value_list( /iwbep/if_mgw_odata_property=>gcs_value_list_type_property-fixed_values ).

    " Entity-set level alternative.
*        model->get_entity_set( 'StatusVHSet' )->create_annotation( lc_sap
*             )->add( iv_key = lc_semantics iv_value = lc_fixed_values ).


    " =================================================================
    " Media resource - both calls are required.
    " set_is_media( ) creates the $value endpoint; set_as_content_type( )
    " marks the property carrying the MIME type of the stream.
    " =================================================================
    DATA(lo_document) = model->get_entity_type( 'Document' ).

    lo_document->set_is_media( iv_is_media = abap_true ).
    lo_document->get_property( iv_property_name = 'MimeType' )->set_as_content_type( ).


    " Include a structure and auto-expand its fields into the entity type.
    model->get_entity_type( 'Header' )->add_auto_expand_include( iv_include_name     = 'ZSM_S_TST'
                                                                 iv_dummy_field      = 'DUMMY'
                                                                 iv_bind_conversions = abap_true ).

    " =================================================================
    " Function import annotations
    " =================================================================
    DATA(lo_action) = model->get_action( iv_action_name = 'GetPersonnelInformation' ).

    " sap:applicable-path - the named property decides at runtime
    " whether the function import is offered to the user.
    lo_action->/iwbep/if_mgw_odata_annotatabl~create_annotation( lc_sap
             )->add( iv_key = lc_applicable_path iv_value = 'IsReleasable' ).

    " Make an input parameter optional.
    lo_action->get_input_parameter( iv_name = 'Id' )->set_nullable( iv_nullable = abap_true ).


    " =================================================================
    " Tree table (UI5 TreeTable) - five annotations on five DIFFERENT
    " properties, all referencing the SAME node-id property.
    " =================================================================
    DATA(lo_tree) = model->get_entity_type( 'Header' ).

    lo_tree->get_property( 'NodeId' )->/iwbep/if_mgw_odata_annotatabl~create_annotation( lc_sap
          )->add( iv_key = lc_node_for iv_value = 'NodeId' ).

    lo_tree->get_property( 'Level' )->/iwbep/if_mgw_odata_annotatabl~create_annotation( lc_sap
          )->add( iv_key = lc_level_for iv_value = 'NodeId' ).

    lo_tree->get_property( 'ParentNodeId' )->/iwbep/if_mgw_odata_annotatabl~create_annotation( lc_sap
          )->add( iv_key = lc_parent_node_for iv_value = 'NodeId' ).

    lo_tree->get_property( 'DrillState' )->/iwbep/if_mgw_odata_annotatabl~create_annotation( lc_sap
          )->add( iv_key = lc_drill_state_for iv_value = 'NodeId' ).

    " Optional - number of descendants below the node.
    lo_tree->get_property( 'Magnitude' )->/iwbep/if_mgw_odata_annotatabl~create_annotation( lc_sap
          )->add( iv_key = lc_descendant_count_for iv_value = 'NodeId' ).


  ENDMETHOD.


*&---------------------------------------------------------------------
*& Example 3 - the same catalogue behind ZCL_SM_MPC_UTIL
*&
*& Same result as example 2, with the boilerplate removed. The helper
*& propagates /IWBEP/CX_MGW_MED_EXCEPTION (fail loud) so a modelling typo
*& is visible here rather than silently skipped - see UtilClass.abap.
*&---------------------------------------------------------------------
  METHOD define.

    super->define( ).

    DATA(lo_mpc_util) = NEW zcl_sm_mpc_util( io_model        = model
                                             io_va_model     = vocab_anno_model
                                             iv_service_name = 'ZSM_ODATA_TEST_SRV' ).

    TRY.
        " Value help - iv_key_name is bound InOut, iv_text_name is shown.
        lo_mpc_util->add_value_help( iv_annotation_target = 'ZSM_ODATA_TEST_SRV.Header/Key'
                                     iv_entity_set_name   = 'KeyVHSet'
                                     iv_key_name          = 'Key'
                                     iv_text_name         = 'Text' ).

        " Semantics
        lo_mpc_util->set_as_email( iv_entity_name = 'Header'
                                   iv_property    = 'Email' ).

        lo_mpc_util->set_as_text( iv_entity_name          = 'Header'
                                  iv_property             = 'Key'
                                  iv_property_description = 'Description' ).

        lo_mpc_util->set_as_unit( iv_entity_name   = 'Header'
                                  iv_property      = 'Amount'
                                  iv_property_unit = 'Currency' ).

        " Display
        lo_mpc_util->set_display_date( iv_entity_name = 'Header'
                                       iv_property    = 'CreatedOn' ).

        lo_mpc_util->set_disable_conversion_exit( iv_entity_name = 'Header'
                                                  iv_property    = 'Amount' ).

        " Filters - pick one restriction per property
        lo_mpc_util->set_filterable( iv_entity_name = 'Header'
                                     iv_property    = 'Key' ).

        lo_mpc_util->set_filter_single( iv_entity_name = 'Header'
                                        iv_property    = 'Key' ).

        lo_mpc_util->set_required_filter( iv_entity_name = 'Header'
                                          iv_property    = 'Key' ).

        lo_mpc_util->set_sortable( iv_entity_name = 'Header'
                                   iv_property    = 'Key' ).

        lo_mpc_util->set_updatable( iv_entity_name = 'Header'
                                    iv_property    = 'Key' ).

        " Labels - translatable
        lo_mpc_util->set_label_from_text_element( io_object      = me
                                                  iv_entity_name = 'Header'
                                                  iv_property    = 'Key'
                                                  iv_text        = '001' ).

        " Static alternative:
*        lo_mpc_util->set_label( iv_entity_name = 'Header'
*                                iv_property    = 'Key'
*                                iv_label       = 'Key' ).

        " Dropdown
        lo_mpc_util->set_drop_down_list( iv_entity_name          = 'Header'
                                         iv_entity_set_name      = 'StatusVHSet'
                                         iv_property             = 'Status'
                                         iv_property_description = 'Text' ).

        " Media
        lo_mpc_util->set_media( iv_entity_name   = 'Document'
                                iv_mime_property = 'MimeType' ).

        " Function import
        lo_mpc_util->set_function_import_triggable( iv_action_name = 'GetPersonnelInformation'
                                                    iv_property    = 'IsReleasable' ).

        lo_mpc_util->set_function_import_nullable( iv_action_name = 'GetPersonnelInformation'
                                                   iv_parameter   = 'Id' ).

        " Tree table
        lo_mpc_util->set_tree_table_properties( iv_entity_name           = 'Header'
                                                iv_node_id_field         = 'NodeId'
                                                iv_level_field           = 'Level'
                                                iv_parent_relation_field = 'ParentNodeId'
                                                iv_drill_down_field      = 'DrillState'
                                                iv_magnitude_field       = 'Magnitude' ).

      CATCH /iwbep/cx_mgw_med_exception INTO DATA(lx_med).
        " One place to decide what a modelling error means for this
        " service. Failing visibly during development beats a service that
        " activates with silently incomplete metadata.
        ASSERT lx_med IS NOT BOUND.
    ENDTRY.

  ENDMETHOD.

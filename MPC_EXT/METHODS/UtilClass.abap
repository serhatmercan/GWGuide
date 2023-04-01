CLASS zcl_sm_mpc_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS add_value_help
      IMPORTING
        !iv_annotation_target TYPE /iwbep/mgw_med_vocan_target
        !iv_entity_set_name   TYPE string
        !iv_key_name          TYPE string
        !iv_text_name         TYPE string .
    METHODS constructor
      IMPORTING
        !io_model        TYPE REF TO /iwbep/if_mgw_odata_model
        !io_va_model     TYPE REF TO /iwbep/if_mgw_vocan_model
        !iv_service_name TYPE string .
    METHODS set_as_email
      IMPORTING
        !iv_entity_name TYPE /iwbep/med_external_name
        !iv_property    TYPE /iwbep/med_external_name
      RAISING
        /iwbep/cx_mgw_med_exception .
    METHODS set_as_text
      IMPORTING
        !iv_entity_name          TYPE /iwbep/med_external_name
        !iv_property             TYPE /iwbep/med_external_name
        !iv_property_description TYPE /iwbep/med_annotation_value
      RAISING
        /iwbep/cx_mgw_med_exception .
    METHODS set_as_unit
      IMPORTING
        !iv_entity_name   TYPE /iwbep/med_external_name
        !iv_property      TYPE /iwbep/med_external_name
        !iv_property_unit TYPE /iwbep/med_annotation_value
      RAISING
        /iwbep/cx_mgw_med_exception .
    METHODS set_disable_conversion_exit
      IMPORTING
        !iv_entity_name TYPE /iwbep/med_external_name
        !iv_property    TYPE /iwbep/med_external_name
      RAISING
        /iwbep/cx_mgw_med_exception .
    METHODS set_display_date
      IMPORTING
        !iv_entity_name TYPE /iwbep/med_external_name
        !iv_property    TYPE /iwbep/med_external_name
      RAISING
        /iwbep/cx_mgw_med_exception .
    METHODS set_display_non_negative
      IMPORTING
        !iv_entity_name TYPE /iwbep/med_external_name
        !iv_property    TYPE /iwbep/med_external_name
      RAISING
        /iwbep/cx_mgw_med_exception .
    METHODS set_display_upper_case
      IMPORTING
        !iv_entity_name TYPE /iwbep/med_external_name
        !iv_property    TYPE /iwbep/med_external_name
      RAISING
        /iwbep/cx_mgw_med_exception .
    METHODS set_drop_down_list
      IMPORTING
        !iv_entity_name          TYPE /iwbep/med_external_name
        !iv_entity_set_name      TYPE /iwbep/med_external_name
        !iv_property             TYPE /iwbep/med_external_name
        !iv_property_description TYPE /iwbep/med_annotation_value
      RAISING
        /iwbep/cx_mgw_med_exception .
    METHODS set_filterable
      IMPORTING
        !iv_entity_name TYPE /iwbep/med_external_name
        !iv_property    TYPE /iwbep/med_external_name
      RAISING
        /iwbep/cx_mgw_med_exception .
    METHODS set_filter_interval
      IMPORTING
        !iv_entity_name TYPE /iwbep/med_external_name
        !iv_property    TYPE /iwbep/med_external_name
      RAISING
        /iwbep/cx_mgw_med_exception .
    METHODS set_filter_mandatory
      IMPORTING
        !iv_entity_name TYPE /iwbep/med_external_name
        !iv_property    TYPE /iwbep/med_external_name
      RAISING
        /iwbep/cx_mgw_med_exception .
    METHODS set_filter_multi_value
      IMPORTING
        !iv_entity_name TYPE /iwbep/med_external_name
        !iv_property    TYPE /iwbep/med_external_name
      RAISING
        /iwbep/cx_mgw_med_exception .
    METHODS set_filter_single
      IMPORTING
        !iv_entity_name TYPE /iwbep/med_external_name
        !iv_property    TYPE /iwbep/med_external_name
      RAISING
        /iwbep/cx_mgw_med_exception .
    METHODS set_function_import_triggable
      IMPORTING
        !iv_action_name TYPE /iwbep/med_external_name
        !iv_property    TYPE /iwbep/med_annotation_value
      RAISING
        /iwbep/cx_mgw_med_exception .
    METHODS set_label
      IMPORTING
        !iv_entity_name TYPE /iwbep/med_external_name
        !iv_property    TYPE /iwbep/med_external_name
      RAISING
        /iwbep/cx_mgw_med_exception .
    METHODS set_label_from_text_element
      IMPORTING
        !io_object      TYPE REF TO object
        !iv_entity_name TYPE /iwbep/med_external_name
        !iv_property    TYPE /iwbep/med_external_name
        !iv_text        TYPE textpoolky
      RAISING
        /iwbep/cx_mgw_med_exception .
    METHODS set_media
      IMPORTING
        !iv_entity_name TYPE /iwbep/med_external_name
        !iv_property    TYPE /iwbep/med_external_name
      RAISING
        /iwbep/cx_mgw_med_exception .
    METHODS set_name
      IMPORTING
        !iv_entity_name TYPE /iwbep/med_external_name
        !iv_property    TYPE /iwbep/med_external_name
      RAISING
        /iwbep/cx_mgw_med_exception .
    METHODS set_required_filter
      IMPORTING
        !iv_entity_name TYPE /iwbep/med_external_name
        !iv_property    TYPE /iwbep/med_external_name
      RAISING
        /iwbep/cx_mgw_med_exception .
    METHODS set_sortable
      IMPORTING
        !iv_entity_name TYPE /iwbep/med_external_name
        !iv_property    TYPE /iwbep/med_external_name
      RAISING
        /iwbep/cx_mgw_med_exception .
    METHODS set_tree_table_properties
      IMPORTING
        !iv_entity_name           TYPE /iwbep/med_external_name
        !iv_node_id_field         TYPE /iwbep/med_external_name
        !iv_level_field           TYPE /iwbep/med_external_name
        !iv_parent_relation_field TYPE /iwbep/med_external_name
        !iv_drill_down_field      TYPE /iwbep/med_external_name
        !iv_magnitude_field       TYPE /iwbep/med_external_name
      RAISING
        /iwbep/cx_mgw_med_exception .
    METHODS set_updatable
      IMPORTING
        !iv_entity_name TYPE /iwbep/med_external_name
        !iv_property    TYPE /iwbep/med_external_name
      RAISING
        /iwbep/cx_mgw_med_exception .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS gc_aggregate TYPE /iwbep/med_annotation_value VALUE 'aggregate' ##NO_TEXT.
    CONSTANTS gc_applicable_path TYPE /iwbep/med_annotation_key VALUE 'applicable-path' ##NO_TEXT.
    CONSTANTS gc_date TYPE /iwbep/med_annotation_value VALUE 'Date' ##NO_TEXT.
    CONSTANTS gc_descendant_count_for TYPE /iwbep/med_annotation_key VALUE 'hierarchy-node-descendant-count-for' ##NO_TEXT.
    CONSTANTS gc_display_format TYPE /iwbep/med_annotation_key VALUE 'display-format' ##NO_TEXT.
    CONSTANTS gc_drill_state_for TYPE /iwbep/med_annotation_key VALUE 'hierarchy-drill-state-for' ##NO_TEXT.
    CONSTANTS gc_filter_restriction TYPE /iwbep/med_annotation_key VALUE 'filter-restriction' ##NO_TEXT.
    CONSTANTS gc_fixed_values TYPE /iwbep/med_annotation_value VALUE 'fixed-values' ##NO_TEXT.
    CONSTANTS gc_email TYPE /iwbep/med_annotation_value VALUE 'email' ##NO_TEXT.
    CONSTANTS gc_interval TYPE /iwbep/med_annotation_value VALUE 'interval' ##NO_TEXT.
    CONSTANTS gc_multi_value TYPE /iwbep/med_annotation_value VALUE 'multi-value' ##NO_TEXT.
    CONSTANTS gc_node_for TYPE /iwbep/med_annotation_key VALUE 'hierarchy-node-for' ##NO_TEXT.
    CONSTANTS gc_non_negative TYPE /iwbep/med_annotation_value VALUE 'NonNegative' ##NO_TEXT.
    CONSTANTS gc_label TYPE /iwbep/med_annotation_key VALUE 'label' ##NO_TEXT.
    CONSTANTS gc_level_for TYPE /iwbep/med_annotation_key VALUE 'hierarchy-level-for' ##NO_TEXT.
    CONSTANTS gc_parent_node_for TYPE /iwbep/med_annotation_key VALUE 'hierarchy-parent-node-for' ##NO_TEXT.
    CONSTANTS gc_required_in_filter TYPE /iwbep/med_annotation_key VALUE 'required-in-filter' ##NO_TEXT.
    CONSTANTS gc_sap TYPE /iwbep/med_anno_namespace VALUE 'sap' ##NO_TEXT.
    CONSTANTS gc_semantics TYPE /iwbep/med_annotation_key VALUE 'semantics' ##NO_TEXT.
    CONSTANTS gc_single_value TYPE /iwbep/med_annotation_value VALUE 'single-value' ##NO_TEXT.
    CONSTANTS gc_text TYPE /iwbep/med_annotation_key VALUE 'text' ##NO_TEXT.
    CONSTANTS gc_true TYPE /iwbep/med_annotation_value VALUE 'true' ##NO_TEXT.
    CONSTANTS gc_unit TYPE /iwbep/med_annotation_key VALUE 'unit' ##NO_TEXT.
    CONSTANTS gc_upper_case TYPE /iwbep/med_annotation_value VALUE 'UpperCase' ##NO_TEXT.
    DATA go_annotation TYPE REF TO /iwbep/if_mgw_odata_annotation .
    DATA go_entity TYPE REF TO /iwbep/if_mgw_odata_entity_typ .
    DATA go_entity_set TYPE REF TO /iwbep/if_mgw_odata_entity_set .
    DATA go_model TYPE REF TO /iwbep/if_mgw_odata_model .
    DATA go_property TYPE REF TO /iwbep/if_mgw_odata_property .
    DATA go_va TYPE REF TO /iwbep/if_mgw_vocan_annotation .
    DATA go_va_collection TYPE REF TO /iwbep/if_mgw_vocan_collection .
    DATA go_va_model TYPE REF TO /iwbep/if_mgw_vocan_model .
    DATA go_va_property TYPE REF TO /iwbep/if_mgw_vocan_property .
    DATA go_va_record TYPE REF TO /iwbep/if_mgw_vocan_record .
    DATA go_va_target TYPE REF TO /iwbep/if_mgw_vocan_ann_target .
    DATA gv_service_name TYPE string .
ENDCLASS.



CLASS ZCL_SM_MPC_UTIL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->ADD_VALUE_HELP
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ANNOTATION_TARGET           TYPE        /IWBEP/MGW_MED_VOCAN_TARGET
* | [--->] IV_ENTITY_SET_NAME             TYPE        STRING
* | [--->] IV_KEY_NAME                    TYPE        STRING
* | [--->] IV_TEXT_NAME                   TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD add_value_help.

    go_va_target = go_va_model->create_annotations_target( iv_annotation_target ).
    go_va = go_va_target->create_annotation( iv_term = 'com.sap.vocabularies.Common.v1.ValueList' ).
    go_va_record = go_va->create_record( ).
    go_va_property = go_va_record->create_property( 'CollectionPath' ).
    go_va_collection  = go_va_record->create_property( 'Parameters' )->create_collection( ).

    go_va_property->create_simple_value( )->set_string( iv_entity_set_name ).

    go_va_record = go_va_collection->create_record( 'com.sap.vocabularies.Common.v1.ValueListParameterInOut' ).
    go_va_property = go_va_record->create_property( 'LocalDataProperty' ).
    go_va_property->create_simple_value( )->set_property_path( iv_text_name ).
    go_va_property = go_va_record->create_property( 'ValueListProperty' ).
    go_va_property->create_simple_value( )->set_string( iv_text_name ).

    go_va_record = go_va_collection->create_record( 'com.sap.vocabularies.Common.v1.ValueListParameterDisplayOnly' ).
    go_va_property = go_va_record->create_property( 'ValueListProperty' ).
    go_va_property->create_simple_value( )->set_property_path( iv_text_name ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_MODEL                       TYPE REF TO /IWBEP/IF_MGW_ODATA_MODEL
* | [--->] IO_VA_MODEL                    TYPE REF TO /IWBEP/IF_MGW_VOCAN_MODEL
* | [--->] IV_SERVICE_NAME                TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD constructor.
    go_model = io_model.
    go_va_model = io_va_model.
    gv_service_name = iv_service_name.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->SET_AS_EMAIL
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY                    TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_as_email.

    TRY.
        go_entity = go_model->get_entity_type( iv_entity_name = iv_entity_name ).
        go_entity->get_property( iv_property )->/iwbep/if_mgw_odata_annotatabl~create_annotation( gc_sap )->add( iv_key = gc_semantics iv_value = gc_email ).
      CATCH /iwbep/cx_mgw_med_exception.
    ENDTRY.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->SET_AS_TEXT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY                    TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY_DESCRIPTION        TYPE        /IWBEP/MED_ANNOTATION_VALUE
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_as_text.

    TRY.
        go_model->get_entity_type( iv_entity_name )->get_property( iv_property )->/iwbep/if_mgw_odata_annotatabl~create_annotation( gc_sap )->add( iv_key = gc_text iv_value = iv_property_description ).
      CATCH /iwbep/cx_mgw_med_exception  .
    ENDTRY.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->SET_AS_UNIT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY                    TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY_UNIT               TYPE        /IWBEP/MED_ANNOTATION_VALUE
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_as_unit.

    TRY.
        go_entity = go_model->get_entity_type( iv_entity_name = iv_entity_name ).
        go_entity->get_property( iv_property )->/iwbep/if_mgw_odata_annotatabl~create_annotation( gc_sap )->add( iv_key = gc_unit iv_value = iv_property_unit ).
      CATCH /iwbep/cx_mgw_med_exception.
    ENDTRY.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->SET_DISABLE_CONVERSION_EXIT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY                    TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_disable_conversion_exit.
    TRY.
        go_model->get_entity_type( iv_entity_name )->get_property( iv_property )->disable_conversion( ).
      CATCH /iwbep/cx_mgw_med_exception  .
    ENDTRY.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->SET_DISPLAY_DATE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY                    TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_display_date.

    TRY.
        go_annotation  = go_model->get_entity_type( iv_entity_name )->get_property( iv_property )->/iwbep/if_mgw_odata_annotatabl~create_annotation( gc_sap ).
        go_annotation->add( iv_key = gc_display_format iv_value = gc_date ).
      CATCH /iwbep/cx_mgw_med_exception  .
    ENDTRY.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->SET_DISPLAY_NON_NEGATIVE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY                    TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_display_non_negative.

    TRY.
        go_annotation  = go_model->get_entity_type( iv_entity_name )->get_property( iv_property )->/iwbep/if_mgw_odata_annotatabl~create_annotation( gc_sap ).
        go_annotation->add( iv_key = gc_display_format iv_value = gc_non_negative ).
      CATCH /iwbep/cx_mgw_med_exception  .
    ENDTRY.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->SET_DISPLAY_UPPER_CASE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY                    TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_display_upper_case.

    TRY.
        go_annotation  = go_model->get_entity_type( iv_entity_name )->get_property( iv_property )->/iwbep/if_mgw_odata_annotatabl~create_annotation( gc_sap ).
        go_annotation->add( iv_key = gc_display_format iv_value = gc_upper_case ).
      CATCH /iwbep/cx_mgw_med_exception  .
    ENDTRY.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->SET_DROP_DOWN_LIST
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_ENTITY_SET_NAME             TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY                    TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY_DESCRIPTION        TYPE        /IWBEP/MED_ANNOTATION_VALUE
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_drop_down_list.
    TRY.
        go_model->get_entity_type( iv_entity_name )->get_property( iv_property )->set_value_list( /iwbep/if_mgw_odata_property=>gcs_value_list_type_property-fixed_values ).

        me->set_as_text(
          iv_entity_name          = iv_entity_name
          iv_property             = iv_property
          iv_property_description = iv_property_description
        ).
      CATCH /iwbep/cx_mgw_med_exception.
    ENDTRY.

    TRY.
        go_model->get_entity_set( iv_entity_set_name )->create_annotation( gc_sap )->add( iv_key = gc_semantics iv_value = gc_fixed_values ).

        me->set_as_text(
          iv_entity_name          = iv_entity_name
          iv_property             = iv_property
          iv_property_description = iv_property_description
        ).
      CATCH /iwbep/cx_mgw_med_exception.
    ENDTRY.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->SET_FILTERABLE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY                    TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_filterable.

    TRY.
        go_model->get_entity_type( iv_entity_name = iv_entity_name )->get_property( iv_property_name = iv_property )->set_filterable( abap_true ).
      CATCH /iwbep/cx_mgw_med_exception  .
    ENDTRY.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->SET_FILTER_INTERVAL
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY                    TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_filter_interval.

    TRY.
        go_annotation = go_model->get_entity_type( iv_entity_name )->get_property( iv_property )->/iwbep/if_mgw_odata_annotatabl~create_annotation( gc_sap ).
        go_annotation->add( iv_key = gc_filter_restriction iv_value = gc_interval ).
      CATCH /iwbep/cx_mgw_med_exception  .
    ENDTRY.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->SET_FILTER_MANDATORY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY                    TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_filter_mandatory.

    TRY.
        go_annotation = go_model->get_entity_type( iv_entity_name )->get_property( iv_property )->/iwbep/if_mgw_odata_annotatabl~create_annotation( gc_sap ).
        go_annotation->add( iv_key = gc_required_in_filter iv_value = gc_true ).
      CATCH /iwbep/cx_mgw_med_exception  .
    ENDTRY.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->SET_FILTER_MULTI_VALUE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY                    TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_filter_multi_value.

    TRY.
        go_annotation = go_model->get_entity_type( iv_entity_name )->get_property( iv_property )->/iwbep/if_mgw_odata_annotatabl~create_annotation( gc_sap ).
        go_annotation->add( iv_key = gc_filter_restriction iv_value = gc_multi_value ).
      CATCH /iwbep/cx_mgw_med_exception  .
    ENDTRY.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->SET_FILTER_SINGLE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY                    TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_filter_single.

    TRY.
        go_annotation = go_model->get_entity_type( iv_entity_name )->get_property( iv_property )->/iwbep/if_mgw_odata_annotatabl~create_annotation( gc_sap ).
        go_annotation->add( iv_key = gc_filter_restriction iv_value = gc_single_value ).
      CATCH /iwbep/cx_mgw_med_exception  .
    ENDTRY.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->SET_FUNCTION_IMPORT_TRIGGABLE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ACTION_NAME                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY                    TYPE        /IWBEP/MED_ANNOTATION_VALUE
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_function_import_triggable.

    TRY.
        go_model->get_action( iv_action_name = iv_action_name )->/iwbep/if_mgw_odata_annotatabl~create_annotation( gc_sap )->add( iv_key = gc_applicable_path iv_value = iv_property ).
      CATCH /iwbep/cx_mgw_med_exception  .
    ENDTRY.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->SET_LABEL
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY                    TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_label.

    TRY.
        go_property = go_model->get_entity_type( iv_entity_name = iv_entity_name )->get_property( iv_property_name = iv_property ).
        go_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( iv_annotation_namespace = gc_sap )->add( iv_key = gc_label iv_value = 'SMERCAN' ).
      CATCH /iwbep/cx_mgw_med_exception  .
    ENDTRY.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->SET_LABEL_FROM_TEXT_ELEMENT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_OBJECT                      TYPE REF TO OBJECT
* | [--->] IV_ENTITY_NAME                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY                    TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_TEXT                        TYPE        TEXTPOOLKY
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_label_from_text_element.

    TRY.
        go_property = go_model->get_entity_type( iv_entity_name = iv_entity_name )->get_property( iv_property_name = iv_property ).
        go_property->set_label_from_text_element( EXPORTING iv_text_element_symbol = iv_text io_object_ref = io_object ).
        go_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( gc_sap )->add( EXPORTING iv_key = gc_label iv_value = 'SMERCAN' ).
      CATCH /iwbep/cx_mgw_med_exception.
    ENDTRY.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->SET_MEDIA
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY                    TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_media.

    TRY.
        go_entity = go_model->get_entity_type( iv_entity_name = iv_entity_name ).
        go_entity->set_is_media( iv_is_media = abap_true ).
        go_entity->get_property( iv_property_name = iv_property )->set_as_content_type( ).
      CATCH /iwbep/cx_mgw_med_exception.
    ENDTRY.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->SET_NAME
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY                    TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_name.

    TRY.
        go_entity = go_model->get_entity_type( iv_entity_name = iv_entity_name ).
        go_entity->add_auto_expand_include(
          EXPORTING
            iv_include_name     = 'ZSM_S_TST'
            iv_dummy_field      = 'DUMMY'
            iv_bind_conversions = 'X'
            ).
        go_entity->get_property( iv_property_name = iv_property )->set_name( 'SMERCAN' ).
      CATCH /iwbep/cx_mgw_med_exception.
    ENDTRY.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->SET_REQUIRED_FILTER
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY                    TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_required_filter.

    TRY.
        go_property = go_model->get_entity_type( iv_entity_name = iv_entity_name )->get_property( iv_property_name = iv_property ).
        go_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( gc_sap )->add( iv_key = gc_required_in_filter iv_value = gc_true ).
      CATCH /iwbep/cx_mgw_med_exception.
    ENDTRY.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->SET_SORTABLE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY                    TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_sortable.

    TRY.
        go_model->get_entity_type( iv_entity_name = iv_entity_name )->get_property( iv_property_name = iv_property )->set_sortable( abap_true ).
      CATCH /iwbep/cx_mgw_med_exception  .
    ENDTRY.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->SET_TREE_TABLE_PROPERTIES
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_NODE_ID_FIELD               TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_LEVEL_FIELD                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PARENT_RELATION_FIELD       TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_DRILL_DOWN_FIELD            TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_MAGNITUDE_FIELD             TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_tree_table_properties.

    TRY.
        go_entity = go_model->get_entity_type( iv_entity_name = iv_entity_name ).
      CATCH /iwbep/cx_mgw_med_exception.
    ENDTRY.

    IF go_entity IS BOUND.
      TRY .
          go_property ?= go_entity->get_property( iv_node_id_field ).
          go_annotation = go_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( gc_sap ).
          go_annotation->add( iv_key = gc_node_for iv_value = CONV #( iv_node_id_field ) ).
        CATCH /iwbep/cx_mgw_med_exception.
      ENDTRY.

      TRY .
          go_property ?= go_entity->get_property( iv_level_field ).
          go_annotation = go_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( gc_sap ).
          go_annotation->add( iv_key = gc_level_for iv_value = CONV #( iv_node_id_field ) ).
        CATCH /iwbep/cx_mgw_med_exception.
      ENDTRY.

      TRY .
          go_property ?= go_entity->get_property( iv_parent_relation_field ).
          go_annotation = go_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( gc_sap ).
          go_annotation->add( iv_key = gc_parent_node_for iv_value = CONV #( iv_node_id_field ) ).
        CATCH /iwbep/cx_mgw_med_exception.
      ENDTRY.

      TRY .
          go_property ?= go_entity->get_property( iv_drill_down_field ).
          go_annotation = go_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( gc_sap ).
          go_annotation->add( iv_key = gc_drill_state_for iv_value = CONV #( iv_node_id_field ) ).
        CATCH /iwbep/cx_mgw_med_exception.
      ENDTRY.

      IF iv_magnitude_field IS NOT INITIAL.
        TRY .
            go_property ?= go_entity->get_property( iv_magnitude_field ).
            go_annotation = go_property->/iwbep/if_mgw_odata_annotatabl~create_annotation( gc_sap ).
            go_annotation->add( iv_key = gc_descendant_count_for iv_value = CONV #( iv_node_id_field ) ).
          CATCH /iwbep/cx_mgw_med_exception.
        ENDTRY.
      ENDIF.

    ENDIF.


  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SM_MPC_UTIL->SET_UPDATABLE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [--->] IV_PROPERTY                    TYPE        /IWBEP/MED_EXTERNAL_NAME
* | [!CX!] /IWBEP/CX_MGW_MED_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_updatable.

    TRY.
        go_model->get_entity_type( iv_entity_name = iv_entity_name )->get_property( iv_property_name = iv_property )->set_updatable( abap_true ).
      CATCH /iwbep/cx_mgw_med_exception  .
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
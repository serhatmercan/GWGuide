METHOD documentet_get_entity.
  TRY.
      CALL METHOD super->documentset_get_entity
        EXPORTING
          iv_entity_name          = iv_entity_name
          iv_entity_set_name      = iv_entity_set_name
          iv_source_name          = iv_source_name
          it_key_tab              = it_key_tab
          io_request_object       = io_request_object
          io_tech_request_context = io_tech_request_context
          it_navigation_path      = it_navigation_path
        IMPORTING
          er_entity               = er_entity
          es_response_context     = es_response_context.

      er_entity-url = |/sap/opu/odata/sap/ZSM_DOCUMENT_SRV/DocumentSet(MaterialNo='{ er_entity-material_no }',DocumentID='{ er_entity-document_id }')/$value|.
    CATCH /iwbep/cx_mgw_busi_exception.
    CATCH /iwbep/cx_mgw_tech_exception.
  ENDTRY.
ENDMETHOD.
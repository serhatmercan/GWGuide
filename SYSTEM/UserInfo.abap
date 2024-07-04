DATA: lr_request_ctx TYPE REF TO /iwbep/cl_mgw_request,
      ls_request     TYPE /iwbep/if_mgw_core_srv_runtime=>ty_s_mgw_request_context,
      lv_jsessionid  TYPE ztm_jsessionid,
      lv_username    TYPE xubname.

lr_request_ctx ?= io_tech_request_context.
ls_request = lr_request_ctx->get_request_details( ).

" Get Session ID
lv_jsessionid = VALUE #( ls_request-technical_request-request_header[ name = 'jsessionid' ]-value OPTIONAL ).

" Get Username
lv_username = VALUE #( ls_request-context_params[ name = 'request_user' ]-value OPTIONAL ).
lv_username = VALUE #( ls_request-technical_request-request_header[ name = 'request_user' ]-value OPTIONAL ).
method MAILSSET_GET_ENTITYSET.

  DATA:
*        ls_clientes  LIKE LINE OF  lt_clientes,
        ls_entityset    LIKE LINE OF  et_entityset,
        lt_filters TYPE /iwbep/t_mgw_select_option,
        ls_filter_select_options TYPE /iwbep/s_mgw_select_option,
        ls_select_options TYPE /iwbep/s_cod_select_option,
        lr_kunnr type range of kunnr,
        ls_kunnr like line of lr_kunnr,
        lv_kunnr TYPE BAPI4001_1-OBJKEY,
        lt_mails TYPE STANDARD TABLE OF BAPIADSMTP,
        ls_mails LIKE LINE OF lt_mails,
        lt_comentario TYPE STANDARD TABLE OF BAPICOMREM,
        ls_comentario LIKE LINE OF lt_comentario,
        lr_comm type RANGE OF AD_REMARK2,
        ls_comm LIKE LINE OF lr_comm,
        lt_return TYPE STANDARD TABLE OF BAPIRET2,
        ls_key_tab TYPE /iwbep/s_mgw_name_value_pair,
        lv_e_kunnr   TYPE kna1-kunnr.

  DATA ls_sortorder TYPE abap_sortorder.
  DATA lt_sortorder TYPE abap_sortorder_tab.
  DATA ls_order TYPE /iwbep/s_mgw_sorting_order.

  " Obtener cliente de la sesión
  DATA:
        lv_cliente TYPE kna1-kunnr,
        lv_rol TYPE zclirole.

  sy-uname = '100541B'.

  CALL METHOD zcl_zsv_seleccion_clie_dpc_ext=>obtener_cliente_sesion
    EXPORTING
      io_context              = io_tech_request_context
    IMPORTING
      e_kunnr                 = lv_e_kunnr
      e_rol                   = lv_rol
    EXCEPTIONS
      cliente_no_seleccionado = 1
      OTHERS                  = 2.
*  IF sy-subrc <> 0.
*    " No se pudo determinar cliente del usuario
*  ENDIF.


*  IF lv_rol EQ zcl_zsv_seleccion_clie_dpc_ext=>c_rol_profertil.
*    " Es usuario profertil
*  ENDIF.


*   *Filtros
  lt_filters = io_tech_request_context->get_filter( )->get_filter_select_options( ).

  READ TABLE lt_filters INTO ls_filter_select_options WITH KEY property = 'COMENTARIO'.
  IF sy-subrc EQ 0.
    LOOP AT ls_filter_select_options-select_options INTO ls_select_options.
      CLEAR ls_comm.
      ls_comm-sign = ls_select_options-sign.
      ls_comm-option = ls_select_options-option.
      ls_comm-low = ls_select_options-low.
      ls_comm-high = ls_select_options-high.
      APPEND ls_comm TO lr_comm.
    ENDLOOP.
  ENDIF.

*
  READ TABLE lt_filters INTO ls_filter_select_options WITH KEY property = 'KUNNR'.
  IF sy-subrc EQ 0.
    LOOP AT ls_filter_select_options-select_options INTO ls_select_options.
    CLEAR ls_kunnr.
      ls_kunnr-sign = ls_select_options-sign.
      ls_kunnr-option = ls_select_options-option.
      ls_kunnr-low = ls_select_options-low.
      ls_kunnr-high = ls_select_options-high.
      APPEND ls_kunnr TO lr_kunnr.
    ENDLOOP.
  ENDIF.

  READ TABLE lr_kunnr INTO ls_kunnr INDEX 1.
  lv_kunnr = ls_kunnr-low.

  CALL FUNCTION 'BAPI_ADDRESSORG_GETDETAIL'
    EXPORTING
      OBJ_TYPE                   = 'KNA1'
      OBJ_ID                     = lv_kunnr
*      OBJ_ID                     = '0000100606'
    TABLES
      BAPIADSMTP                 = lt_mails
      BAPICOMREM                 = lt_comentario
      RETURN                     = lt_return.

  LOOP AT lt_mails INTO ls_mails.
    ls_entityset-kunnr = lv_kunnr.
*    ls_entityset-kunnr = '0000100606'.
    ls_entityset-id = ls_mails-CONSNUMBER.
    ls_entityset-mail = ls_mails-E_MAIL.
    ls_entityset-estandar = ls_mails-STD_NO.
    ls_entityset-noutiliza = ls_mails-FLG_NOUSE.
      READ TABLE lt_comentario INTO ls_comentario WITH KEY CONSNUMBER = ls_mails-CONSNUMBER COMM_TYPE = 'INT'.
      IF sy-subrc EQ 0.
        ls_entityset-comentario = ls_comentario-COMM_NOTES.
      ELSE.
        clear ls_comentario.
      ENDIF.
    APPEND ls_entityset TO et_entityset.
  ENDLOOP.

  IF lr_comm[] IS NOT INITIAL.
    DELETE et_entityset WHERE comentario NOT IN lr_comm.
  ENDIF.

  IF io_tech_request_context->has_inlinecount( ) EQ abap_true.
    es_response_context-inlinecount = lines( et_entityset ).
  ENDIF.

  LOOP AT it_order INTO ls_order.
    ls_sortorder-name = condense( to_upper( ls_order-property ) ).
    IF to_upper( ls_order-order ) EQ 'DESC'.
      ls_sortorder-descending = abap_true.
    ENDIF.
    APPEND ls_sortorder TO lt_sortorder.
  ENDLOOP.
  IF lt_sortorder[] IS NOT INITIAL.
    SORT et_entityset BY (lt_sortorder).
  ELSE.
    SORT et_entityset BY kunnr DESCENDING.
  ENDIF.
*
  CALL METHOD /iwbep/cl_mgw_data_util=>paging
    EXPORTING
      is_paging = is_paging
    CHANGING
      ct_data   = et_entityset.
endmethod.
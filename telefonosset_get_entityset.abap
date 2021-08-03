method TELEFONOSSET_GET_ENTITYSET.
  DATA:
        lv_cod_area TYPE T005K-TELEFTO,
*        ls_clientes  LIKE LINE OF  lt_clientes,
        ls_entityset    LIKE LINE OF  et_entityset,
        lt_filters TYPE /iwbep/t_mgw_select_option,
        ls_filter_select_options TYPE /iwbep/s_mgw_select_option,
        ls_select_options TYPE /iwbep/s_cod_select_option,
        lr_kunnr type range of kunnr,
        ls_kunnr like line of lr_kunnr,
        lv_kunnr TYPE BAPI4001_1-OBJKEY,
        lt_tel TYPE STANDARD TABLE OF BAPIADTEL,
        ls_tel LIKE LINE OF lt_tel,
        lt_comentario TYPE STANDARD TABLE OF BAPICOMREM,
        ls_comentario LIKE LINE OF lt_comentario,
        lr_extension type RANGE OF AD_REMARK2,
        ls_extension LIKE LINE OF lr_extension,
        lt_return TYPE STANDARD TABLE OF BAPIRET2,
        ls_key_tab TYPE /iwbep/s_mgw_name_value_pair,
        lr_nombre    TYPE RANGE OF BAPICOMREM,
        ls_nombre    LIKE LINE OF lr_nombre.

  DATA ls_sortorder TYPE abap_sortorder.
  DATA lt_sortorder TYPE abap_sortorder_tab.
  DATA ls_order TYPE /iwbep/s_mgw_sorting_order.



*   *Filtros
  lt_filters = io_tech_request_context->get_filter( )->get_filter_select_options( ).

  READ TABLE lt_filters INTO ls_filter_select_options WITH KEY property = 'EXTENSION'.
  IF sy-subrc EQ 0.
    LOOP AT ls_filter_select_options-select_options INTO ls_select_options.
      CLEAR ls_extension.
      ls_extension-sign = ls_select_options-sign.
      ls_extension-option = ls_select_options-option.
      ls_extension-low = ls_select_options-low.
      ls_extension-high = ls_select_options-high.
      APPEND ls_extension TO lr_extension.
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

  READ TABLE lt_filters INTO ls_filter_select_options WITH KEY property = 'COMENTARIO'.
  IF sy-subrc EQ 0.
    LOOP AT ls_filter_select_options-select_options INTO ls_select_options.
      CLEAR ls_nombre.
      ls_nombre-sign = ls_select_options-sign.
      ls_nombre-option = ls_select_options-option.
      ls_nombre-low = ls_select_options-low.
      ls_nombre-high = ls_select_options-high.
      TRANSLATE ls_nombre-low TO UPPER CASE.
      TRANSLATE ls_nombre-high TO UPPER CASE.
      APPEND ls_nombre TO lr_nombre.
    ENDLOOP.
  ENDIF.

  READ TABLE lr_kunnr INTO ls_kunnr INDEX 1.
  lv_kunnr = ls_kunnr-low.


  CALL FUNCTION 'BAPI_ADDRESSORG_GETDETAIL'
    EXPORTING
      OBJ_TYPE    = 'KNA1'
*      OBJ_ID      = '0000100606'
      OBJ_ID      = lv_kunnr
    TABLES
      BAPIADTEL   = lt_tel
      BAPICOMREM  = lt_comentario
      RETURN      = lt_return.
*
*  SELECT SINGLE TELEFTO
*      FROM T005K
*      INTO et_entityset-telefto
*      WHERE land1 EQ er_entityset-land1.

  LOOP AT lt_tel INTO ls_tel.
    ls_entityset-kunnr = lv_kunnr.
*    ls_entityset-kunnr = '0000100606'.
    ls_entityset-id = ls_tel-CONSNUMBER.
    ls_entityset-telefono = ls_tel-TELEPHONE.
    ls_entityset-pais = ls_tel-COUNTRYISO.
    "Trae +54 telefono + extensión
*    ls_entityset-codigo = ls_tel-TEL_NO.
*    / EXTENSION es el Tipo de Contacto (Logistico, Comercial, Créditos)
    ls_entityset-extension = ls_tel-EXTENSION.
    ls_entityset-estandar = ls_tel-STD_NO.
    ls_entityset-noutiliza = ls_tel-FLG_NOUSE.
*     / COMENTARIO es el Nombre
      READ TABLE lt_comentario INTO ls_comentario WITH KEY CONSNUMBER = ls_tel-CONSNUMBER COMM_TYPE = 'TEL'.
      IF sy-subrc EQ 0.
        ls_entityset-comentario = ls_comentario-COMM_NOTES.
      ELSE.
        clear ls_comentario.
      ENDIF.
    APPEND ls_entityset TO et_entityset.
  ENDLOOP.

  IF lr_extension[] IS NOT INITIAL.
    DELETE et_entityset WHERE extension NOT IN lr_extension.
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
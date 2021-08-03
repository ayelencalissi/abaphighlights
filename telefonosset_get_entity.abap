method TELEFONOSSET_GET_ENTITY.
  DATA: ls_key_tab TYPE /iwbep/s_mgw_name_value_pair,
        lv_kunnr TYPE ZCL_ZSV_DATOS_MAESTROS_MPC=>TS_TELEFONOS-KUNNR,
        lv_id TYPE ZCL_ZSV_DATOS_MAESTROS_MPC=>TS_TELEFONOS-ID,
        lt_tel TYPE STANDARD TABLE OF BAPIADTEL,
        ls_tel LIKE LINE OF lt_tel,
        lt_comentario TYPE STANDARD TABLE OF BAPICOMREM,
        ls_comentario LIKE LINE OF lt_comentario,
        lt_return TYPE STANDARD TABLE OF BAPIRET2,
        lv_obj_id TYPE BAPI4001_1-OBJKEY.

  READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'Kunnr'.
  IF sy-subrc EQ 0.
    lv_kunnr = ls_key_tab-value.
  ENDIF.
*
  READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'Id'.
  IF sy-subrc EQ 0.
    lv_id = ls_key_tab-value.
  ENDIF.

  lv_obj_id = lv_kunnr.

  CALL FUNCTION 'BAPI_ADDRESSORG_GETDETAIL'
    EXPORTING
      OBJ_TYPE                   = 'KNA1'
      OBJ_ID                     = lv_obj_id
    TABLES
      BAPIADTEL                  = lt_tel
      BAPICOMREM                 = lt_comentario
      RETURN                     = lt_return.

  READ TABLE lt_tel INTO ls_tel WITH KEY CONSNUMBER = lv_id.
  IF sy-subrc EQ 0.
    er_entity-telefono = ls_tel-TELEPHONE.
    er_entity-id = ls_tel-CONSNUMBER.
    er_entity-kunnr = lv_kunnr.
    er_entity-estandar = ls_tel-STD_NO.
  ELSE.
    CLEAR er_entity.
  ENDIF.

  READ TABLE lt_comentario INTO ls_comentario WITH KEY CONSNUMBER = lv_id COMM_TYPE = 'TEL'.
  IF sy-subrc EQ 0.
    er_entity-comentario = ls_comentario-COMM_NOTES.
    er_entity-id = ls_comentario-CONSNUMBER.
  ELSE.
    CLEAR er_entity.
  ENDIF.
endmethod.
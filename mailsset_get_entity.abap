method MAILSSET_GET_ENTITY.
  DATA: ls_key_tab TYPE /iwbep/s_mgw_name_value_pair,
        lv_kunnr TYPE ZCL_ZSV_DATOS_MAESTROS_MPC=>TS_MAILS-KUNNR,
        lv_id TYPE ZCL_ZSV_DATOS_MAESTROS_MPC=>TS_MAILS-ID,
        lt_mails TYPE STANDARD TABLE OF BAPIADSMTP,
        ls_mails LIKE LINE OF lt_mails,
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
      BAPIADSMTP                 = lt_mails
      BAPICOMREM                 = lt_comentario
      RETURN                     = lt_return.

  READ TABLE lt_mails INTO ls_mails WITH KEY CONSNUMBER = lv_id.
  IF sy-subrc EQ 0.
    er_entity-mail = ls_mails-E_MAIL.
    er_entity-id = ls_mails-CONSNUMBER.
    er_entity-kunnr = lv_kunnr.
    er_entity-estandar = ls_mails-STD_NO.
  ELSE.
    CLEAR er_entity.
  ENDIF.

  READ TABLE lt_comentario INTO ls_comentario WITH KEY CONSNUMBER = lv_id COMM_TYPE = 'INT'.
  IF sy-subrc EQ 0.
    er_entity-comentario = ls_comentario-COMM_NOTES.
    er_entity-id = ls_comentario-CONSNUMBER.
  ELSE.
    CLEAR er_entity.
  ENDIF.



endmethod.
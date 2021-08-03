method MAILSSET_DELETE_ENTITY.
  DATA:
  lv_obj_type TYPE bapi4001_1-objtype,
  lv_obj_id TYPE bapi4001_1-objkey,
  lv_address_number TYPE bapi4001_1-addr_no,
  lv_kunnr TYPE ZCL_ZSV_DATOS_MAESTROS_MPC=>TS_MAILS-KUNNR,
  lv_id TYPE ZCL_ZSV_DATOS_MAESTROS_MPC=>TS_MAILS-ID,
  ls_key_tab TYPE /iwbep/s_mgw_name_value_pair.
*  is_entity LIKE er_entity.

  DATA:
  lt_bapiadsmtp TYPE STANDARD TABLE OF bapiadsmtp,
  lt_bapicomrem TYPE STANDARD TABLE OF bapicomrem,
  lt_bapiadsmt_x TYPE STANDARD TABLE OF bapiadsmtx,
  lt_bapicomre_x TYPE STANDARD TABLE OF bapicomrex,
  lt_return TYPE  STANDARD TABLE OF bapiret2.

  DATA:
  ls_bapiadsmtp TYPE bapiadsmtp,
  ls_bapicomrem TYPE bapicomrem,
  ls_bapiadsmt_x TYPE bapiadsmtx,
  ls_bapicomre_x TYPE bapicomrex,
  ls_return TYPE bapiret2.

* //////// DELETE /////////
  READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'Kunnr'.
    IF sy-subrc EQ 0.
        lv_kunnr = ls_key_tab-value.
    ENDIF.

  READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'Id'.
    IF sy-subrc EQ 0.
        lv_id = ls_key_tab-value.
    ENDIF.
*
* Buscar como tomar el id del mail para poder BORRAR
* ls_bapiadsmtp-CONSNUMBER = '099'.
*

  lv_obj_type = 'KNA1'.
  lv_obj_id = lv_kunnr.
*
  CLEAR ls_bapiadsmtp.
*  ls_bapiadsmtp-e_mail = is_entity-mail.
  ls_bapiadsmtp-CONSNUMBER = lv_id.
*  ls_bapiadsmtp-EMAIL_SRCH = is_entity-mail.
  APPEND ls_bapiadsmtp TO lt_bapiadsmtp.

  CLEAR ls_bapiadsmt_x.
  ls_bapiadsmt_x-UPDATEFLAG = 'D'.
*  ls_bapiadsmt_x-e_mail = 'X'.
*  ls_bapiadsmt_x-EMAIL_SRCH = 'X'.
  APPEND ls_bapiadsmt_x TO lt_bapiadsmt_x.

  CLEAR ls_bapicomrem.
*  ls_bapicomrem-COMM_NOTES = is_entity-comentario.
*  ls_bapicomrem-COMM_TYPE = 'INT'.
*  ls_bapicomrem-langu = sy-langu.
*  ls_bapicomrem-langu_iso = sy-langu.
  ls_bapicomrem-CONSNUMBER = lv_id.
  APPEND ls_bapicomrem TO lt_bapicomrem.

  CLEAR ls_bapicomre_x.
*  ls_bapicomre_x-COMM_NOTES = 'X'.
*  ls_bapicomre_x-COMM_TYPE = 'X'.
*  ls_bapicomre_x-langu = 'X'.
*  ls_bapicomre_x-langu_iso = 'X'.
  ls_bapicomre_x-updateflag = 'D'.
  APPEND ls_bapicomre_x TO lt_bapicomre_x.

  CALL FUNCTION 'BAPI_ADDRESSORG_CHANGE'
    EXPORTING
      obj_type       = lv_obj_type
      obj_id         = lv_obj_id
    IMPORTING
      address_number = lv_address_number
    TABLES
      bapiadsmtp     = lt_bapiadsmtp
      bapicomrem     = lt_bapicomrem
      bapiadsmt_x    = lt_bapiadsmt_x
      bapicomre_x    = lt_bapicomre_x
      return         = lt_return.


  READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.
  IF sy-subrc EQ 0.
    " hubo error
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
     mo_context->get_message_container( )->add_messages_from_bapi(
       it_bapi_messages = lt_return
       iv_determine_leading_msg = /iwbep/if_message_container=>gcs_leading_msg_search_option-first ).

    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
    EXPORTING
            textid            = /iwbep/cx_mgw_busi_exception=>business_error
            message_container = mo_context->get_message_container( ).
  ELSE.
    " update OK
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDIF.
endmethod.
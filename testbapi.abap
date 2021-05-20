*&---------------------------------------------------------------------*
*& Report  Y_TEST_05
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT y_test_05.

DATA:
lv_obj_type TYPE bapi4001_1-objtype,
lv_obj_id TYPE bapi4001_1-objkey,
lv_address_number TYPE bapi4001_1-addr_no.

DATA:
lt_bapiadtel TYPE STANDARD TABLE OF bapiadtel,
lt_bapiadsmtp TYPE STANDARD TABLE OF bapiadsmtp,
lt_bapicomrem TYPE STANDARD TABLE OF bapicomrem,
lt_bapiadtel_x TYPE STANDARD TABLE OF bapiadtelx,
lt_bapiadsmt_x TYPE STANDARD TABLE OF bapiadsmtx,
lt_bapicomre_x TYPE STANDARD TABLE OF bapicomrex,
lt_return TYPE  STANDARD TABLE OF bapiret2.

DATA:
ls_bapiadtel TYPE bapiadtel,
ls_bapiadsmtp TYPE bapiadsmtp,
ls_bapicomrem TYPE bapicomrem,
ls_bapiadtel_x TYPE bapiadtelx,
ls_bapiadsmt_x TYPE bapiadsmtx,
ls_bapicomre_x TYPE bapicomrex,
ls_return TYPE bapiret2.



START-OF-SELECTION.

*
  lv_obj_type = 'KNA1'.
  lv_obj_id = '0000100606'.
*
  CLEAR ls_bapiadsmtp.
  ls_bapiadsmtp-e_mail = 'cuartomail@gmail.com'.
*  ls_bapiadsmtp-CONSNUMBER = '099'.
  ls_bapiadsmtp-EMAIL_SRCH = 'cuartomail@gmail.com'.
  APPEND ls_bapiadsmtp TO lt_bapiadsmtp.

  CLEAR ls_bapiadsmt_x.
  ls_bapiadsmt_x-UPDATEFLAG = 'I'.
  ls_bapiadsmt_x-e_mail = 'X'.
  ls_bapiadsmt_x-EMAIL_SRCH = 'X'.
  APPEND ls_bapiadsmt_x TO lt_bapiadsmt_x.

  CLEAR ls_bapicomrem.
  ls_bapicomrem-COMM_NOTES = 'ZF96_CREDITOS'.
  ls_bapicomrem-COMM_TYPE = 'INT'.
  ls_bapicomrem-langu = sy-langu.
  ls_bapicomrem-langu_iso = sy-langu.
*  ls_bapicomrem-CONSNUMBER = '099'.
  APPEND ls_bapicomrem TO lt_bapicomrem.

  CLEAR ls_bapicomre_x.
  ls_bapicomre_x-COMM_NOTES = 'X'.
  ls_bapicomre_x-COMM_TYPE = 'X'.
  ls_bapicomre_x-langu = 'X'.
  ls_bapicomre_x-langu_iso = 'X'.
  ls_bapicomre_x-updateflag = 'I'.
  APPEND ls_bapicomre_x TO lt_bapicomre_x.

END-OF-SELECTION.

  CALL FUNCTION 'BAPI_ADDRESSORG_CHANGE'
    EXPORTING
      obj_type       = lv_obj_type
      obj_id         = lv_obj_id
    IMPORTING
      address_number = lv_address_number
    TABLES
      bapiadtel      = lt_bapiadtel
      bapiadsmtp     = lt_bapiadsmtp
      bapicomrem     = lt_bapicomrem
      bapiadtel_x    = lt_bapiadtel_x
      bapiadsmt_x    = lt_bapiadsmt_x
      bapicomre_x    = lt_bapicomre_x
      return         = lt_return.

  READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.
  IF sy-subrc EQ 0.
    " hubo error
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    WRITE: /'Error'.
    WRITE: / ls_return-TYPE,
        ls_return-ID,
        ls_return-NUMBER,
        ls_return-MESSAGE,
        ls_return-MESSAGE_V1,
        ls_return-MESSAGE_V2,
        ls_return-MESSAGE_V3,
        ls_return-MESSAGE_V4.
  ELSE.
    " update OK
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    WRITE: /'Bien'.
  ENDIF.

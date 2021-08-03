method TELEFONOSSET_DELETE_ENTITY.
  DATA:
    lv_obj_type TYPE bapi4001_1-objtype,
    lv_obj_id TYPE bapi4001_1-objkey,
    lv_address_number TYPE bapi4001_1-addr_no,
    lv_kunnr TYPE ZCL_ZSV_DATOS_MAESTROS_MPC=>TS_TELEFONOS-KUNNR,
    lv_id TYPE ZCL_ZSV_DATOS_MAESTROS_MPC=>TS_TELEFONOS-ID,
    ls_key_tab TYPE /iwbep/s_mgw_name_value_pair.
*    is_entity LIKE er_entity.

  DATA:
    lt_bapiadtel      TYPE STANDARD TABLE OF bapiadtel,
    lt_bapiadtel_x    TYPE STANDARD TABLE OF bapiadtelx,
    lt_bapicomrem     TYPE STANDARD TABLE OF bapicomrem,
    lt_bapicomre_x    TYPE STANDARD TABLE OF bapicomrex,
    lt_return         TYPE STANDARD TABLE OF bapiret2.

  DATA:
    ls_bapiadtel      TYPE bapiadtel,
    ls_bapiadtel_x    TYPE bapiadtelx,
    ls_bapicomrem     TYPE bapicomrem,
    ls_bapicomre_x    TYPE bapicomrex,
    ls_return         TYPE bapiret2.

* //////// DELETE /////////
  READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'Kunnr'.
    IF sy-subrc EQ 0.
        lv_kunnr = ls_key_tab-value.
    ENDIF.

  READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'Id'.
    IF sy-subrc EQ 0.
        lv_id = ls_key_tab-value.
    ENDIF.

  lv_obj_type = 'KNA1'.
  lv_obj_id = lv_kunnr.

 CLEAR ls_bapiadtel.
*    ls_bapiadtel-TELEPHONE = is_entity-telefono.
    ls_bapiadtel-CONSNUMBER = lv_id.
*    ls_bapiadtel-EXTENSION = is_entity-extension.
  APPEND ls_bapiadtel TO lt_bapiadtel.

  CLEAR ls_bapiadtel_x.
    ls_bapiadtel_x-UPDATEFLAG = 'D'.
  APPEND ls_bapiadtel_x TO lt_bapiadtel_x.

  CLEAR ls_bapicomrem.
*    ls_bapicomrem-COMM_NOTES = is_entity-comentario.
*    ls_bapicomrem-COMM_TYPE = 'TEL'.
*    ls_bapicomrem-langu = sy-langu.
*    ls_bapicomrem-langu_iso = sy-langu.
     ls_bapicomrem-CONSNUMBER = lv_id.
  APPEND ls_bapicomrem TO lt_bapicomrem.

  CLEAR ls_bapicomre_x.
*    ls_bapicomre_x-COMM_NOTES = 'X'.
*    ls_bapicomre_x-COMM_TYPE = 'X'.
*    ls_bapicomre_x-langu = 'X'.
*    ls_bapicomre_x-langu_iso = 'X'.
    ls_bapicomre_x-updateflag = 'D'.
  APPEND ls_bapicomre_x TO lt_bapicomre_x.

  CALL FUNCTION 'BAPI_ADDRESSORG_CHANGE'
    EXPORTING
      OBJ_TYPE                          = lv_obj_type
      OBJ_ID                            = lv_obj_id
   IMPORTING
     ADDRESS_NUMBER                    = lv_address_number
   TABLES
     BAPIADTEL                         = lt_bapiadtel
     BAPICOMREM                        = lt_bapicomrem
     BAPIADTEL_X                       = lt_bapiadtel_x
     BAPICOMRE_X                       = lt_bapicomre_x
     RETURN                            = lt_return.


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
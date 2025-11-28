  METHOD print_form.

    TYPES: sx_addr_type TYPE char03, "R/3 Addresstype
           sx_addr      TYPE string.  "Address in plain string

    TYPES: BEGIN OF sx_address,                     "SAPconnect general addr
             type    TYPE sx_addr_type,
             address TYPE sx_addr,
           END OF sx_address.


    DATA: ls_head      TYPE zreco_hdr,
          ls_curr      TYPE zreco_rboc,
          ls_vers      TYPE zreco_vers,
          ls_bform     TYPE zreco_recb,
          ls_fpdf      TYPE zreco_fpdf,
          lt_cform     TYPE TABLE OF zreco_rcai,
          ls_cform     TYPE zreco_rcai,
          ls_random    TYPE zreco_rand,
          lt_mail      TYPE TABLE OF zreco_refi,
          ls_mail      TYPE zreco_refi,
*          ls_denetim   TYPE zreco_audt,
*          lt_receiver  TYPE somlreci1_t,
*          ls_receiver  TYPE somlreci1,
*          lt_line      TYPE TABLE OF tline,
*          ls_line      TYPE tline,
          lt_cdun      TYPE TABLE OF zreco_cdun,
          ls_cdun      TYPE zreco_cdun,
          ls_address   TYPE sx_address,
          lv_pdfbase64 TYPE string,
          lv_spras     TYPE spras.

    DATA: lv_number   TYPE zreco_number,
          lv_random   TYPE zreco_random,
          lv_laiso    TYPE c LENGTH 2,
          lv_posnr    TYPE n LENGTH 3,
          lv_only_loc TYPE abap_boolean,
          lv_line     TYPE int2.

    DATA: ls_h001      TYPE zreco_hdr, "hkizilkaya
          ls_reia      TYPE zreco_reia, "hkizilkaya
          ls_note      TYPE zreco_note, "hkizilkaya
          ls_bsid_temp TYPE zreco_tbsd, "hkizilkaya
          ls_ifld      TYPE zreco_ifld, "hkizilkaya
*          ls_t001      TYPE i_companycode,
          lv_param     TYPE c LENGTH 1. "hkizilkaya

    DATA: lv_mail       TYPE string,
          lv_lines_mail TYPE i.
    FIELD-SYMBOLS: <ls_mail> TYPE zreco_refi.

    DATA: BEGIN OF ls_temp,
            ltext TYPE string,
          END OF ls_temp,
          lt_temp LIKE STANDARD TABLE OF ls_temp,
          BEGIN OF ls_void,
            mnumber TYPE zreco_number,
          END OF ls_void,
          lt_void LIKE STANDARD TABLE OF ls_void.


    CLEAR: ls_vers, ls_head, ls_curr, ls_bform,
           ls_random, lv_number, lv_random,
           lv_posnr, lt_mail[], lt_cdun[],
           gv_subrc, gs_htxt, gs_dtxt, gs_otxt,
           gt_dunning[], lt_cform, lt_cform[],
           gt_opening[].

    DATA(ls_out) = VALUE #( gt_out_c[ 1 ] OPTIONAL ).


    SELECT SINGLE *
             FROM zreco_adrs
            WHERE bukrs EQ @ls_out-bukrs
           INTO @gs_adrs.

    SELECT SINGLE companycode AS bukrs , Currency AS waers  FROM i_companycode WHERE CompanyCode  EQ @gs_adrs-bukrs INTO @DATA(ls_t001).

*    IF gs_account_info-land1 IS NOT INITIAL.
*      IF gs_account_info-land1 EQ 'TR'.
    lv_spras = 'T'.
*      ELSEIF gs_account_info-land1 EQ 'BG'..
*        lv_spras = 'W'.
*      ELSE.
*        lv_spras = 'E'.
*      ENDIF.
*    ENDIF.

************gt_mail_list ve gt_receiver ile ilgili işlemler****************



*    IF gv_otf IS NOT INITIAL.
*    IF iV_output IS NOT INITIAL.
**      REFRESH gt_receivers.
**
*      IF gt_email[] IS NOT INITIAL.
*        LOOP AT gt_email INTO gs_email.
*
*          gs_receivers-receiver = gs_email-email.
*          gs_receivers-rec_type = 'U'.
*          APPEND gs_receivers TO gt_receivers .
*          CLEAR: gs_receivers .
*        ENDLOOP.
*      ELSE.
**        LOOP AT gt_mail_list INTO gs_mail_list WHERE kunnr EQ gs_account-kunnr
**                                                 AND lifnr EQ gs_account-lifnr.
**          gs_receivers-receiver = gs_mail_list-receiver.
**          gs_receivers-rec_type = 'U'.
**          APPEND gs_receivers TO gt_receivers .
**          CLEAR: gs_receivers .
**    ENDLOOP.
*
*      ENDIF.
*    ENDIF.
*
** Geçerli e-posta kontrolü
*
*      DELETE gt_receivers WHERE receiver IS INITIAL.
*
*      SORT gt_receivers BY receiver.
*
*      DELETE ADJACENT DUPLICATES FROM gt_receivers COMPARING receiver.
*
*      LOOP AT gt_receivers INTO gs_receivers.
*
*        ls_address-type = 'INT'.
*        ls_address-address = gs_receivers-receiver.
*
*        CALL FUNCTION 'SX_INTERNET_ADDRESS_TO_NORMAL'
*          EXPORTING
*            address_unstruct    = ls_address
*          EXCEPTIONS
*            error_address_type  = 1
*            error_address       = 2
*            error_group_address = 3.
*
*        IF sy-subrc NE 0.
*          CALL METHOD go_log->bal_log_msg_add
*            EXPORTING
*              i_type       = /itetr/reco_if_common_types=>mc_msg_e
*              i_no         = '034'
*              i_id         = /itetr/reco_if_common_types=>mc_msg_class
*              i_v1         = gs_account-hesap_no
*              i_v2         = gs_receivers-receiver
*              i_v3         = ''
*              i_v4         = ''
*              i_log_handle = gv_log_handle
*            EXCEPTIONS
*              OTHERS       = 1.
*          DELETE gt_receivers.
*          CONTINUE.
*        ELSE.
*
*          READ TABLE gt_e002 TRANSPORTING NO FIELDS
*          WITH KEY receiver = gs_receivers-receiver.
*
*          IF sy-subrc EQ 0.
*            CALL METHOD go_log->bal_log_msg_add
*              EXPORTING
*                i_type       = /itetr/reco_if_common_types=>mc_msg_e
*                i_no         = '205'
*                i_id         = /itetr/reco_if_common_types=>mc_msg_class
*                i_v1         = gs_receivers-receiver
*                i_v2         = ''
*                i_v3         = ''
*                i_v4         = ''
*                i_log_handle = gv_log_handle
*              EXCEPTIONS
*                OTHERS       = 1.
*            DELETE gt_receivers.
*
*            CONTINUE.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*
*
    IF gt_receivers[] IS INITIAL.
*        CALL METHOD go_log->bal_log_msg_add
*          EXPORTING
*            i_type       = /itetr/reco_if_common_types=>mc_msg_e
*            i_no         = '127'
*            i_id         = /itetr/reco_if_common_types=>mc_msg_class
*            i_v1         = gs_account-hesap_no
*            i_v2         = ''
*            i_v3         = ''
*            i_v4         = ''
*            i_log_handle = gv_log_handle
*          EXCEPTIONS
*            OTHERS       = 1.
*      gv_subrc = 4.
    ENDIF.
*    ENDIF.
*    CHECK gv_subrc EQ 0.

    SELECT SINGLE * FROM zreco_flds
   WHERE hesap_tur EQ @gs_account-hesap_tur
   INTO @DATA(gs_flds).

* Form metinleri

    SELECT *
    FROM zreco_htxt
    INTO TABLE @DATA(gt_htxt).


    READ TABLE gt_htxt INTO DATA(gs_htxt)
    WITH KEY bukrs = ls_out-bukrs
             spras = lv_spras "gs_account-spras
             mtype = 'C'
            ftype = '01'.

    IF sy-subrc NE 0.

*      SELECT SINGLE laiso FROM t002
*        WHERE spras EQ @gs_account-spras
*        INTO @lv_laiso.

*      CALL METHOD go_log->bal_log_msg_add
*        EXPORTING
*          i_type       = /itetr/reco_if_common_types=>mc_msg_e
*          i_no         = '092'
*          i_id         = /itetr/reco_if_common_types=>mc_msg_class
*          i_v1         = gs_account-hesap_no
*          i_v2         = ''
*          i_v3         = ''
*          i_v4         = ''
*          i_log_handle = gv_log_handle
*        EXCEPTIONS
*          OTHERS       = 1.
*      gv_subrc = 4.

*      EXIT.
    ELSE.
*      IF p_verzn IS NOT INITIAL.
** Ihtar metinleri
*        READ TABLE gt_dtxt INTO gs_dtxt
*        WITH KEY bukrs = gs_adrs-bukrs
*                 spras = gs_account-spras
*                 ftype = '01'.
*
*        IF sy-subrc NE 0.
*
*          SELECT SINGLE laiso FROM t002 INTO lv_laiso
*            WHERE spras EQ gs_account-spras.
*
**          CALL METHOD go_log->bal_log_msg_add
**            EXPORTING
**              i_type       = /itetr/reco_if_common_types=>mc_msg_e
**              i_no         = '156'
**              i_id         = /itetr/reco_if_common_types=>mc_msg_class
**              i_v1         = lv_laiso
**              i_v2         = gs_account-hesap_no
**              i_v3         = ''
**              i_v4         = ''
**              i_log_handle = gv_log_handle
**            EXCEPTIONS
**              OTHERS       = 1.
*          gv_subrc = 4.
*
*          EXIT.
*
*        ENDIF.
*      ENDIF.
    ENDIF.

*    CHECK gv_subrc EQ 0.

* Adres ve iletişim alanları
    CLEAR gs_adrc.

    SELECT SINGLE * FROM zreco_ddl_i_address2
  WHERE AddressID EQ @gs_account-adrnr
  INTO CORRESPONDING FIELDS OF  @gs_adrc.


    IF sy-subrc NE 0.
*      CLEAR gt_account_info.
*      READ TABLE gt_account_info INTO gs_account_info WITH KEY kunnr = gs_account-kunnr
*                                                               lifnr = gs_account-lifnr.

*      IF sy-subrc EQ 0.
*        gs_adrc-name1 = gs_account_info-name1.
*        gs_adrc-name2 = gs_account_info-name2.
*      ENDIF.
    ENDIF.

*    gs_adrc-telf1 = gs_account-telf1.
*    gs_adrc-telf2 = gs_account-telf2.
*    gs_adrc-telfx = gs_account-telfx.

*    CLEAR sy-subrc.

* Form tipine ve dile göre özel form belirlenmiş mi?
*      SELECT SINGLE tdsfname FROM /itetr/reco_frm INTO gv_sf_name
*        WHERE bukrs EQ gs_adrs-bukrs
*        AND ftype EQ p_ftype
*        AND spras EQ gs_account-spras.
*
*      IF sy-subrc NE 0.
** Form tipine göre özel form belirlenmiş mi?
*        SELECT SINGLE tdsfname FROM /itetr/reco_frm INTO gv_sf_name
*          WHERE bukrs EQ gs_adrs-bukrs
*          AND ftype EQ p_ftype.
*
*        IF sy-subrc NE 0.
*          gv_sf_name = '/ITETR/RECO_SF_FORM_001'.
*        ENDIF.
*
*      ENDIF.
*
*      IF r_dform EQ 'X'.
*        gv_sf_name = '/ITETR/RECO_SF_FORM_002'.
*      ENDIF.
*
*      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*        EXPORTING
*          formname           = gv_sf_name
*        IMPORTING
*          fm_name            = gv_fm_name
*        EXCEPTIONS
*          no_form            = 1
*          no_function_module = 2
*          OTHERS             = 3.
*
*      IF sy-subrc NE 0.
*        gv_subrc = 4.
*
*        CALL METHOD go_log->bal_log_msg_add
*          EXPORTING
*            i_type       = sy-msgty
*            i_no         = sy-msgno
*            i_id         = sy-msgid
*            i_v1         = sy-msgv1
*            i_v2         = sy-msgv2
*            i_v3         = sy-msgv3
*            i_v4         = sy-msgv4
*            i_log_handle = gv_log_handle
*          EXCEPTIONS
*            OTHERS       = 1.
*      ENDIF.
*
*    ENDIF.


    CLEAR lv_only_loc.

    IF gv_no_local IS INITIAL.
      LOOP AT gt_cform_sf INTO gs_cform_sf WHERE xsum EQ 'X'
                                             AND waers EQ ls_t001-waers.
        lv_only_loc = 'X'.
        EXIT.
      ENDLOOP.

      IF gs_adrs-no_local_curr IS NOT INITIAL.
        LOOP AT gt_cform_sf INTO gs_cform_sf WHERE xsum EQ 'X'
                                               AND waers EQ ''.
          lv_only_loc = 'X'.
          EXIT.
        ENDLOOP.
      ENDIF.

      LOOP AT gt_cform_sf INTO gs_cform_sf WHERE xsum EQ 'X'
                           AND waers NE ls_t001-waers.

        IF gs_adrs-no_local_curr IS NOT INITIAL.
          CHECK gs_cform_sf-waers IS NOT INITIAL.
        ENDIF.

        CLEAR lv_only_loc .
        EXIT.
      ENDLOOP.
    ENDIF.

    LOOP AT gt_cform_sf INTO gs_cform_sf.
      MOVE-CORRESPONDING gs_cform_sf TO ls_temp.
*      IF p_waers IS NOT INITIAL.
      ls_curr-waers = gs_cform_sf-waers.
*      ENDIF.
      COLLECT ls_temp INTO lt_temp.
    ENDLOOP.

*    DESCRIBE TABLE lt_temp LINES lv_line.

    IF lines( lt_temp ) GT 1.
      CLEAR lv_only_loc.
    ENDIF.


*    IF iv_output IS NOT INITIAL.
*
*      IF p_verzn IS INITIAL. "İhtar da yapma
** Bir başka kullanıcı başka bir ekrandan göndermiş mi kontrolü?
** Table lock çok fazla mutabakat sayısında sıkıntı yarattığı için
** tek tek kontrol eklendi
*
*        DATA lv_found(1).
*
*        CLEAR lv_found.
*        LOOP AT gt_h001 INTO ls_h001 WHERE bukrs     EQ gs_adrs-bukrs
*                                             AND gsber     EQ gs_adrs-gsber
*                                             AND monat     EQ p_period
*                                             AND gjahr     EQ p_gjahr
*                                             AND hesap_tur EQ gs_account-hesap_tur
*                                             AND hesap_no  EQ gs_account-hesap_no.
*
*          LOOP AT gt_reia INTO ls_reia WHERE bukrs EQ gs_adrs-bukrs
*                                               AND gsber EQ gs_adrs-gsber
*                                               AND monat EQ p_period
*                                               AND gjahr EQ p_gjahr
*                                               AND mnumber EQ ls_h001-mnumber
*                                               AND ( mresult EQ 'H' OR mresult EQ 'T' ).
*            lv_found = abap_true.
*            EXIT.
*          ENDLOOP.
*
*          IF lv_found EQ abap_true.
*            EXIT.
*          ENDIF.
*
*        ENDLOOP.
*
*        IF lv_found EQ abap_false.
*          " <-- hkizilkaya Gönderim Kontrol Kaldırıma
**          SELECT COUNT( * ) FROM /itetr/reco_hdr
**            WHERE bukrs EQ gs_adrs-bukrs
**            AND monat EQ p_period
**            AND gjahr EQ p_gjahr
**            AND hesap_tur EQ gs_account-hesap_tur
**            AND hesap_no EQ gs_account-hesap_no
**            AND mtype EQ gv_mtype
**            AND ftype EQ p_ftype
**            AND daily EQ ''
**            AND loekz EQ ''
**            AND pwaers EQ ''.
*          " hkizilkaya Gönderim Kontrol Kaldırıma -->
*
*          " <-- hkizilkaya Onceki gonderim mutabık ise tekrar gonderim yapılamasın
*          IF r_dform IS INITIAL.
*            SELECT COUNT( * )
*              FROM /itetr/reco_hdr AS hdr
*              INNER JOIN /itetr/reco_reia AS reia
*              ON hdr~mnumber = reia~mnumber
*              AND hdr~bukrs = reia~bukrs
*              AND hdr~gsber = reia~gsber
*              AND hdr~monat = reia~monat
*              AND hdr~gjahr = reia~gjahr
*              WHERE hdr~bukrs EQ gs_adrs-bukrs
*              AND hdr~monat EQ p_period
*              AND hdr~gjahr EQ p_gjahr
*              AND hdr~hesap_tur EQ gs_account-hesap_tur
*              AND hdr~hesap_no EQ gs_account-hesap_no
*              AND hdr~mtype EQ gv_mtype
*              AND hdr~ftype EQ p_ftype
*              AND hdr~daily EQ ''
*              AND hdr~loekz EQ ''
*              AND hdr~pwaers EQ ''
*              AND reia~mresult EQ 'E'.
*          ENDIF.
*          " hkizilkaya Onceki gonderim mutabık ise tekrar gonderim yapılamasın -->
*        ELSE.
*          sy-subrc = '4'.
*        ENDIF.
*
*        IF sy-subrc NE 0.
*
*          CLEAR gv_subrc.
*
*          IF p_waers IS NOT INITIAL.
*            SELECT COUNT( * ) FROM /itetr/reco_rboc
*              WHERE bukrs EQ gs_adrs-bukrs
*              AND monat EQ p_period
*              AND gjahr EQ p_gjahr
*              AND hesap_tur EQ gs_account-hesap_tur
*              AND hesap_no EQ gs_account-hesap_no
*              AND waers EQ ls_curr-waers
*              AND ftype EQ p_ftype
*              AND loekz EQ ''.
*            IF sy-subrc NE 0.
*              CLEAR gv_subrc.
*            ELSE.
*              gv_subrc = 4. "Para birimi bazında gönderildi.
*            ENDIF.
*          ENDIF.
*        ELSE.
*          gv_subrc = 4. "Bu hesap türü ve hesap için gönderildi.
*        ENDIF.
*      ELSE.
*        CLEAR gv_subrc.
*      ENDIF.

    IF gv_subrc EQ 0.
*      get_number_and_random( EXPORTING iv_bukrs = gs_adrs-bukrs
*                                       iv_gjahr = p_gjahr
*                             CHANGING cv_number = lv_number
*                                      cv_random = lv_random ).
      TRY.
          lv_number = cl_system_uuid=>create_uuid_c22_static( ).
          lv_random = cl_system_uuid=>create_uuid_c22_static( ).
        CATCH cx_root INTO DATA(lx_err).
      ENDTRY..
    ELSE.

*      CALL METHOD go_log->bal_log_msg_add
*        EXPORTING
*          i_type       = /itetr/reco_if_common_types=>mc_msg_e
*          i_no         = '169'
*          i_id         = /itetr/reco_if_common_types=>mc_msg_class
*          i_v1         = p_period
*          i_v2         = ''
*          i_v3         = ''
*          i_v4         = ''
*          i_log_handle = gv_log_handle
*        EXCEPTIONS
*          OTHERS       = 1.
*      gv_subrc = 4.

*      EXIT.
    ENDIF.

* Başlık Bilgileri
*    CHECK gv_subrc EQ 0.



    MOVE-CORRESPONDING gs_account TO ls_head.
    ls_head-bukrs     = gs_adrs-bukrs.
    ls_head-gsber     = gs_adrs-gsber.
    ls_head-mnumber   = lv_number.
    ls_head-monat     = ls_out-period.
    ls_head-gjahr     = ls_out-gjahr.
*      ls_head-padest    = p_print.
*      ls_head-b_date_selection = gv_b_sel.
*      ls_head-c_date_selection = gv_c_sel.
    ls_head-randomkey = lv_random.
    ls_head-mtype     = 'C'.
    ls_head-moutput   = iv_output.
*      ls_head-no_xausz  = p_xausz.

*      IF p_exch IS NOT INITIAL.
*        ls_head-kurst = gs_adrs-kurst.
*        ls_head-xexchange = p_exch.
*      ENDIF.

    ls_head-xstatu = space.
*      ls_head-xall   = p_all.
*      ls_head-xtran  = p_tran.
*      ls_head-xno_value = gv_no_value.
    ls_head-xno_local_curr = gv_no_local.
*      ls_head-xno_kursf = gv_no_kursf.
*      ls_head-xzero = p_zero.
*      ls_head-xumskz = p_sgli.
*      ls_head-xopen = gv_open_item.
    ls_head-ftype = '01'.
*      ls_head-xdiff = p_diff. "hkizilkaya
*      ls_head-xbli = gv_bli.
    ls_head-land1 = 'TR'. "gs_account_info-land1. "hkizilkaya

*    IF p_dmbtr IS NOT INITIAL.
*      ls_head-dmbtr = p_dmbtr.
*    ENDIF.
*
*    IF p_verzn IS NOT INITIAL.
*      ls_head-verzn = p_verzn.
*    ENDIF.
*
*    IF p_daily IS NOT INITIAL.
*      ls_head-daily = p_daily.
*      ls_head-rdate = p_rdate.
*    ENDIF.



*sektör bilgisi
    SELECT SINGLE Industry FROM i_customer WHERE customer = @ls_head-hesap_no INTO @ls_head-brsch..
    IF sy-subrc <> 0.
      SELECT SINGLE Industry FROM i_supplier WHERE supplier = @ls_head-hesap_no INTO @ls_head-brsch..
    ENDIF.

*      IF p_waers IS NOT INITIAL.
*        ls_head-pwaers = p_waers.
*
*        MOVE-CORRESPONDING ls_head TO ls_curr.
*      ENDIF.


* Versiyon bilgileri
    MOVE-CORRESPONDING ls_head TO ls_vers.

    ls_vers-version = 1.
    ls_vers-vstatu  = 'G'.
    ls_vers-ernam   = sy-uname.
    ls_vers-erdat   = sy-datum.
    ls_vers-erzei   = sy-uzeit.

** B Formu bilgileri
*      IF r_mform IS INITIAL.
*        MOVE-CORRESPONDING ls_head TO ls_bform.
*        MOVE-CORRESPONDING ls_vers TO ls_bform.
*        MOVE-CORRESPONDING gs_bform TO ls_bform.
*      ENDIF.

    LOOP AT gt_cform_sf INTO gs_cform_sf.
      MOVE-CORRESPONDING ls_head TO ls_cform.
      MOVE-CORRESPONDING ls_vers TO ls_cform.
      MOVE-CORRESPONDING gs_account  TO ls_cform.
      MOVE-CORRESPONDING gs_cform_sf TO ls_cform.
      APPEND ls_cform TO lt_cform.
    ENDLOOP.

    IF lt_cform[] IS INITIAL.

      gv_subrc = 4.

*          CALL METHOD go_log->bal_log_msg_add
*            EXPORTING
*              i_type       = /itetr/reco_if_common_types=>mc_msg_e
*              i_no         = '149'
*              i_id         = /itetr/reco_if_common_types=>mc_msg_class
*              i_v1         = ''
*              i_v2         = ''
*              i_v3         = ''
*              i_v4         = ''
*              i_log_handle = gv_log_handle
*            EXCEPTIONS
*              OTHERS       = 1.
    ENDIF.

*    CHECK gv_subrc EQ 0.

*    IF gv_otf EQ 'X'.
*      IF iv_output NE 'F'.
*
*      ELSE.
**          REFRESH gt_body.
*      ENDIF.

    ls_random-bukrs     = gs_adrs-bukrs.
    ls_random-mnumber   = lv_number.
    ls_random-randomkey = lv_random.
    ls_random-datum     = sy-datum.
    ls_random-uzeit     = sy-uzeit.

*    ENDIF.


*    * Notelar
*      IF gt_note[] IS NOT INITIAL.
*
*        gs_thead-tdobject = 'TEXT'.
*        CONCATENATE '/ITETR/' ls_head-bukrs lv_number
*        INTO gs_thead-tdname .
*        gs_thead-tdid     = 'ST'.
*        gs_thead-tdspras  = ls_head-spras.
*
*        LOOP AT gt_note INTO ls_note.
*
*          ls_line-tdline = ls_note-line .
*
*          APPEND ls_line TO lt_line.
*
*        ENDLOOP.
*
*        CALL FUNCTION 'SAVE_TEXT'
*          EXPORTING
*            client   = sy-mandt
*            header   = gs_thead
*          TABLES
*            lines    = lt_line
*          EXCEPTIONS
*            id       = 1
*            language = 2
*            name     = 3
*            object   = 4
*            OTHERS   = 5.
*
*        IF sy-subrc EQ 0.
*          CALL FUNCTION 'COMMIT_TEXT'
*            EXPORTING
*              object   = gs_thead-tdobject
*              name     = gs_thead-tdname
*              id       = gs_thead-tdid
*              language = gs_thead-tdspras.
*        ENDIF.
*
*      ENDIF.
*
*    ELSE.
*
*      ls_head-xopen = gv_open_item.
*
*    ENDIF.




** İhtar kalemleri
*    IF p_verzn IS NOT INITIAL.
*
*      LOOP AT gt_bsid_temp INTO ls_bsid_temp WHERE hesap_no EQ gs_account-hesap_no.
*
*        CLEAR: lt_cdun, gt_dunning.
*
*        MOVE-CORRESPONDING ls_bsid_temp TO ls_cdun.
*        MOVE-CORRESPONDING ls_head TO ls_cdun.
*
*        ls_cdun-gjahr_b = ls_bsid_temp-gjahr.
*        ls_cdun-verzn   = ls_bsid_temp-verzn.
*        ls_cdun-mdatum  = gv_last_date.
*
*        MOVE-CORRESPONDING ls_cdun TO gs_dunning.
*
*        READ TABLE gt_ifld INTO ls_ifld WITH KEY blart = ls_cdun-blart.
*
*        IF sy-subrc EQ 0.
*          CASE ls_ifld-xfield.
*            WHEN 'XBLNR'.
*              gs_dunning-invoice_number = ls_cdun-xblnr.
*            WHEN 'BKTXT'.
*              gs_dunning-invoice_number = ls_cdun-bktxt.
*            WHEN 'XREF1_HD'.
*              gs_dunning-invoice_number = ls_cdun-xref1_hd.
*            WHEN 'XREF2_HD'.
*              gs_dunning-invoice_number = ls_cdun-xref2_hd.
*            WHEN 'XBLNR_ALT'.
*              gs_dunning-invoice_number = ls_cdun-xblnr_alt.
*            WHEN 'AWKEY'.
*              gs_dunning-invoice_number = ls_cdun-awkey.
*            WHEN 'BELNR'.
*              gs_dunning-invoice_number = ls_cdun-belnr.
*          ENDCASE.
*        ELSE.
*          READ TABLE gt_ifld INTO ls_ifld WITH KEY blart = ''. "Tüm belgeler için
*
*          IF sy-subrc EQ 0.
*            CASE ls_ifld-xfield.
*              WHEN 'XBLNR'.
*                gs_dunning-invoice_number = ls_cdun-xblnr.
*              WHEN 'BKTXT'.
*                gs_dunning-invoice_number = ls_cdun-bktxt.
*              WHEN 'XREF1_HD'.
*                gs_dunning-invoice_number = ls_cdun-xref1_hd.
*              WHEN 'XREF2_HD'.
*                gs_dunning-invoice_number = ls_cdun-xref2_hd.
*              WHEN 'XBLNR_ALT'.
*                gs_dunning-invoice_number = ls_cdun-xblnr_alt.
*              WHEN 'AWKEY'.
*                gs_dunning-invoice_number = ls_cdun-awkey.
*              WHEN 'BELNR'.
*                gs_dunning-invoice_number = ls_cdun-belnr.
*            ENDCASE.
*          ELSE.
*            gs_dunning-invoice_number = ls_cdun-belnr.
*          ENDIF.
*
*        ENDIF.
*
*        COLLECT ls_cdun INTO lt_cdun.
*        COLLECT gs_dunning INTO gt_dunning.
*
*      ENDLOOP.
*
*      LOOP AT gt_dunning INTO gs_dunning.
*
*        CLEAR gs_dunning_times.
*
*        READ TABLE gt_dunning_times INTO gs_dunning_times
*        WITH KEY hesap_no = gs_account-hesap_no
*                 belnr    = gs_dunning-belnr
*                 bldat    = gs_dunning-bldat.
*
*        gs_dunning-count_dunning = gs_dunning_times-count_dunning + 1.
*
*        MODIFY gt_dunning FROM gs_dunning.
*
*      ENDLOOP.
*
*      SORT gt_dunning BY verzn DESCENDING.
*
*    ENDIF.

** Açık kalemleri gönder
*    IF gv_open_item IS NOT INITIAL.
*      LOOP AT gt_bsid_temp INTO ls_bsid_temp WHERE hesap_no EQ gs_account-hesap_no.
*
**        CLEAR gt_opening.
*
*        IF gs_adrs-zero_wrbtr EQ 'X'.
*          CHECK ls_bsid_temp-wrbtr NE 0.
*        ENDIF.
*
*        MOVE-CORRESPONDING ls_bsid_temp TO gs_opening.
*        MOVE-CORRESPONDING ls_head TO gs_opening.
*
*        IF ls_bsid_temp-verzn GT 0.
*          gs_opening-verzn = ls_bsid_temp-verzn.
*        ENDIF.
*
**        COLLECT gs_opening INTO gt_opening.
*        APPEND gs_opening TO gt_opening.
*
*      ENDLOOP.
*
*      IF sy-subrc NE 0.
*        CLEAR ls_head-xopen.
*      ENDIF.
*
*
** Açık kalem metinleri
*      READ TABLE gt_otxt INTO gs_otxt
*      WITH KEY bukrs = gs_adrs-bukrs
*               spras = gs_account-spras
*               ftype = p_ftype.

*    ENDIF.

    IF iv_output NE 'T' AND iv_output NE 'S'.
      "Takip raporuna aktarma dışında

*      CLEAR: gv_odk.

* Gönderen iletişim bilgileri

      DATA lo_zreco_common  TYPE REF TO zreco_common.
      CREATE OBJECT lo_zreco_common.

      lo_zreco_common->zreco_contact_m(
          EXPORTING
            is_adrs     = gs_adrs
            i_hesap_tur = gs_account-hesap_tur
            i_hesap_no  = gs_account-hesap_no
            i_ktokl     = gs_account-ktokl
            i_mtype     = 'C'
            i_ftype     = '01'
            i_uname     = sy-uname
          IMPORTING
            e_name      = gs_adrs-m_name
            e_telefon   = gs_adrs-m_telefon
            e_email     = gs_adrs-m_email
      ).

*      IF gv_spl_dmbtr NE 0.
*        gv_odk = 'X'.
*      ENDIF.
      SORT gt_cform_sf BY ltext waers wrbtr .

      " <--- hkizilkaya mutabakat dilini ülkeye göre

*      IF gs_account_info-land1 IS NOT INITIAL.
*        IF gs_account_info-land1 EQ 'TR'.
      lv_spras = 'T'.
*        ELSEIF gs_account_info-land1 EQ 'BG'..
*          lv_spras = 'W'.
*        ELSE.
*          lv_spras = 'E'.
*    ENDIF.
*  ENDIF.

    ENDIF.


    DATA : ls_data TYPE zreco_s_pdf_data."zreco_s_carihesapmutabakat_pdf.

    """""""""""""" Şirket Bilgileri

    DATA: lv_vergid         TYPE string,
          lv_vergino        TYPE string,
          lv_telefon        TYPE string,
          lv_faks           TYPE string,
          lv_mersis         TYPE string,
          lv_ticaret        TYPE string,
          lv_imza           TYPE string,
          lv_unvan          TYPE string,
          lv_adres_1        TYPE string,
          lv_adres_2        TYPE string,
          lv_vd_vkn         TYPE string,
          lv_tsicil         TYPE string,
          lv_ilgili_adi     TYPE string,
          lv_ilgili_telefon TYPE string,
          lv_logo           TYPE string.

* Şirket Unvanı
    lv_unvan = gs_adrs-name.

* Adres
    CONCATENATE gs_adrs-adres1  gs_adrs-adres2 INTO lv_adres_1
    SEPARATED BY space.

    lv_telefon = gs_adrs-telefon.

    lv_faks = gs_adrs-faks.

    lv_vergid  = gs_adrs-vergidairesi.

    lv_vergino = gs_adrs-verginumarasi.

    lv_ticaret = gs_adrs-ticaretsicil.

    lv_mersis  = gs_adrs-mersisno.

    lv_imza    = gs_adrs-imza_logo.

    lv_logo    = gs_adrs-sap_logo.

    " Şehir
    lv_adres_2 = gs_adrs-kent.

    " Semt / Şehir
    IF gs_adrs-semt IS NOT INITIAL.
      CONCATENATE gs_adrs-semt '/' lv_adres_2 INTO lv_adres_2.
    ENDIF.

    " Posta Kodu Semt / Şehir
    IF gs_adrs-pkod IS NOT INITIAL.
      CONCATENATE gs_adrs-pkod lv_adres_2
      INTO lv_adres_2 SEPARATED BY space.
    ENDIF.

    "Telefon
    IF lv_telefon IS NOT INITIAL.
      CONCATENATE 'Tel:' lv_telefon INTO lv_telefon
      SEPARATED BY space.
    ENDIF.

    "Faks
    IF lv_faks IS NOT INITIAL.
      CONCATENATE 'Fax :' lv_faks INTO lv_faks
      SEPARATED BY space.
    ENDIF.

    "Vergi dairesi
    CONCATENATE lv_vergid 'V.D.' lv_vergino INTO lv_vd_vkn
    SEPARATED BY space.


    "Ticaret sicil
    IF lv_ticaret IS NOT INITIAL.
      CONCATENATE 'Ticaret Sicil:' lv_ticaret INTO lv_tsicil
      SEPARATED BY space.
    ENDIF.

    "Mersis No
    IF lv_mersis IS NOT INITIAL.
      CONCATENATE 'Mersis No:' lv_mersis INTO lv_mersis
      SEPARATED BY space.
    ENDIF.

    " İlgili kişi adı
    IF gs_adrs-m_name IS NOT INITIAL.
      lv_ilgili_adi = gs_adrs-m_name.
    ENDIF.

    " İlgili kişi adı ve mail adresi
    IF lv_ilgili_adi IS NOT INITIAL.
      CONCATENATE lv_ilgili_adi '-' gs_adrs-m_email
      INTO lv_ilgili_adi
      SEPARATED BY space.
    ELSEIF gs_adrs-m_email IS NOT INITIAL.
      " İlgili kişi mail adresi
      lv_ilgili_adi = gs_adrs-m_email.
    ENDIF.

    "İlgili kişi telefonu
    IF gs_adrs-m_telefon IS NOT INITIAL.
      lv_ilgili_telefon = gs_adrs-m_telefon.
    ENDIF.

*    CONCATENATE lv_unvan lv_adres_1 lv_adres_2 lv_telefon lv_faks lv_vd_vkn
*    lv_tsicil
*    lv_mersis
*    lv_ilgili_adi
*    lv_ilgili_telefon
*     INTO ls_data-sirket_adres
*     SEPARATED BY space.
    CLEAR ls_data.

    "Her bir alan doluysa başına \n ekle ve CONCATENATE ile birleştir

*    IF lv_unvan IS NOT INITIAL.
*      ls_data-sirket_adres = lv_unvan.
*    ENDIF.

    IF lv_adres_1 IS NOT INITIAL.
      CONCATENATE ls_data-sirket_adres cl_abap_char_utilities=>cr_lf lv_adres_1 INTO ls_data-sirket_adres ."SEPARATED BY space.
    ENDIF.

    IF lv_adres_2 IS NOT INITIAL.
      CONCATENATE ls_data-sirket_adres cl_abap_char_utilities=>cr_lf lv_adres_2 INTO ls_data-sirket_adres ."SEPARATED BY space.
    ENDIF.

    IF lv_telefon IS NOT INITIAL.
      CONCATENATE ls_data-sirket_adres cl_abap_char_utilities=>cr_lf lv_telefon INTO ls_data-sirket_adres ."SEPARATED BY space.
    ENDIF.

    IF lv_faks IS NOT INITIAL.
      CONCATENATE ls_data-sirket_adres cl_abap_char_utilities=>cr_lf lv_faks INTO ls_data-sirket_adres ."SEPARATED BY space.
    ENDIF.

    IF lv_vd_vkn IS NOT INITIAL.
      CONCATENATE ls_data-sirket_adres cl_abap_char_utilities=>cr_lf lv_vd_vkn INTO ls_data-sirket_adres ."SEPARATED BY space.
    ENDIF.

    IF lv_tsicil IS NOT INITIAL.
      CONCATENATE ls_data-sirket_adres cl_abap_char_utilities=>cr_lf lv_tsicil INTO ls_data-sirket_adres ."SEPARATED BY space.
    ENDIF.

    IF lv_mersis IS NOT INITIAL.
      CONCATENATE ls_data-sirket_adres cl_abap_char_utilities=>cr_lf lv_mersis INTO ls_data-sirket_adres ."SEPARATED BY space.
    ENDIF.

    IF lv_ilgili_adi IS NOT INITIAL.
      CONCATENATE ls_data-sirket_adres cl_abap_char_utilities=>cr_lf lv_ilgili_adi INTO ls_data-sirket_adres ."SEPARATED BY space.
    ENDIF.

    IF lv_ilgili_telefon IS NOT INITIAL.
      CONCATENATE ls_data-sirket_adres cl_abap_char_utilities=>cr_lf lv_ilgili_telefon INTO ls_data-sirket_adres ."SEPARATED BY space.
    ENDIF.




    """""""""""""" Şirket Bilgileri
    """""""""""""" Müşteri Bilgileri


    DATA: lv_landx        TYPE string,
          lv_bezei        TYPE string,
          lv_name1        TYPE string,
          lv_cari_adres_1 TYPE string,
          lv_name2        TYPE string,
          lv_name3        TYPE string,
          lv_name4        TYPE string,
          lv_cari_adres_2 TYPE string,
          lv_telf1        TYPE string,
          lv_vd           TYPE string,
          lv_vkn_tckn     TYPE string,
          lv_len          TYPE i.


    lv_name1 = gs_adrc-OrganizationName1.

*    IF gs_flds-name2_use IS INITIAL.
*      IF gs_flds-name2_x IS NOT INITIAL.
    lv_name2 = gs_adrc-OrganizationName2.
*      ENDIF.
*    ELSE.
*      IF gs_flds-name2_x IS NOT INITIAL.
    CONCATENATE lv_cari_adres_1 gs_adrc-OrganizationName2 INTO lv_cari_adres_1
    SEPARATED BY space.
*      ENDIF.
*    ENDIF.

*    IF gs_flds-name3_use IS INITIAL.
*      IF gs_flds-name3_x IS NOT INITIAL.
    lv_name3 = gs_adrc-OrganizationName3.
*      ENDIF.
*    ELSE.
*      IF gs_flds-name3_x IS NOT INITIAL.
    CONCATENATE lv_cari_adres_1 gs_adrc-OrganizationName3 INTO lv_cari_adres_1
    SEPARATED BY space.
*      ENDIF.
*    ENDIF.

*    IF gs_flds-name4_use IS INITIAL.
*      IF gs_flds-name4_x IS NOT INITIAL..
*    lv_name4 = gs_adrc-OrganizationName4.
*      ENDIF.
*    ELSE.
*      IF gs_flds-name4_x IS NOT INITIAL.
*    CONCATENATE lv_cari_adres_1 gs_adrc-OrganizationName4 INTO lv_cari_adres_1
*    SEPARATED BY space.
*      ENDIF.
*    ENDIF.

*    IF gs_flds-street_x IS NOT INITIAL.
    CONCATENATE lv_cari_adres_1 gs_adrc-street INTO lv_cari_adres_1
    SEPARATED BY space.
*    ENDIF.
*
*    IF gs_flds-str_suppl1_x IS NOT INITIAL.
    CONCATENATE lv_cari_adres_1 gs_adrc-StreetPrefixName1 INTO lv_cari_adres_1
    SEPARATED BY space.
*    ENDIF.

*    IF gs_flds-str_suppl2_x IS NOT INITIAL.
    CONCATENATE lv_cari_adres_1 gs_adrc-StreetPrefixName2 INTO lv_cari_adres_1
    SEPARATED BY space.
*    ENDIF.

*    IF gs_flds-str_suppl3_x IS NOT INITIAL.
*      CONCATENATE lv_cari_adres_1 gs_adrc-str_suppl3 INTO lv_cari_adres_1
*      SEPARATED BY space.
*    ENDIF.

*    IF gs_flds-location_x IS NOT INITIAL.
    CONCATENATE lv_cari_adres_1 gs_adrc-DistrictName INTO lv_cari_adres_1
    SEPARATED BY space.
*    ENDIF.

*    IF gs_flds-building_x IS NOT INITIAL.
    CONCATENATE lv_cari_adres_1 gs_adrc-building INTO lv_cari_adres_1
    SEPARATED BY space.
*    ENDIF.

    IF gs_flds-roomnumber_x IS NOT INITIAL.
      CONCATENATE lv_cari_adres_1 gs_adrc-roomnumber INTO lv_cari_adres_1
      SEPARATED BY space.
    ENDIF.

    IF gs_flds-floor_x IS NOT INITIAL.
      CONCATENATE lv_cari_adres_1 gs_adrc-floor INTO lv_cari_adres_1
      SEPARATED BY space.
    ENDIF.

*    IF gs_flds-name_co_x IS NOT INITIAL.
*      CONCATENATE lv_cari_adres_1 gs_adrc-name_co INTO lv_cari_adres_1
*      SEPARATED BY space.
*    ENDIF.

*    IF gs_flds-house_num1_x IS NOT INITIAL.
    CONCATENATE lv_cari_adres_1 gs_adrc-HouseNumber INTO lv_cari_adres_1
    SEPARATED BY space.
*    ENDIF.

*    IF gs_flds-house_num2_x IS NOT INITIAL.
    CONCATENATE lv_cari_adres_1 gs_adrc-HouseNumberSupplementText INTO lv_cari_adres_1
    SEPARATED BY space.
*    ENDIF.

*    IF gs_flds-city2_x IS NOT INITIAL.
*      CONCATENATE lv_cari_adres_1 gs_adrc-ci INTO lv_cari_adres_1
*      SEPARATED BY space.
*    ENDIF.

*    IF gs_flds-home_city_x IS NOT INITIAL.
*      CONCATENATE lv_cari_adres_1 gs_adrc-home_city INTO lv_cari_adres_1
*      SEPARATED BY space.
*    ENDIF.

*    IF gs_flds-post_code1_x IS NOT INITIAL.
    CONCATENATE lv_cari_adres_2 gs_adrc-CompanyPostalCode INTO lv_cari_adres_2
    SEPARATED BY space.
*    ENDIF.

*    IF gs_flds-city1_x IS NOT INITIAL.
    CONCATENATE lv_cari_adres_2 gs_adrc-CityName INTO lv_cari_adres_2
    SEPARATED BY space.
*    ENDIF.

*    IF gs_flds-region_x IS NOT INITIAL.
*      IF gs_adrc-region IS NOT INITIAL.
*        SELECT SINGLE bezei FROM t005u INTO lv_bezei
*        WHERE spras EQ i_langu
*        AND land1 EQ is_adrc-country
*        AND bland EQ is_adrc-region.
*
*        CONCATENATE lv_cari_adres_2 lv_bezei INTO lv_cari_adres_2
*        SEPARATED BY space.
*
*      ENDIF.
*    ENDIF.

*    IF is_flds-country_x IS NOT INITIAL.
*      IF is_adrc-country IS NOT INITIAL.
*        SELECT SINGLE landx FROM t005t INTO lv_landx
*        WHERE spras EQ i_langu
*        AND land1 EQ is_adrc-country.
*
*        CONCATENATE lv_cari_adres_2 lv_landx INTO lv_cari_adres_2
*        SEPARATED BY space.
*
*      ENDIF.
*    ENDIF.

*    IF gs_flds-telf1_x IS NOT INITIAL AND
*       gs_adrc- IS NOT INITIAL.
*      CONCATENATE 'Tel:' gs_adrc-tel_number INTO lv_telf1
*      SEPARATED BY space.
*    ENDIF.

*    IF gs_flds-telf2_x IS NOT INITIAL AND
*       gs_adrc- IS NOT INITIAL.
*      CONCATENATE 'Mob:' is_adrc-telf2 INTO lv_telf2
*      SEPARATED BY space.
*    ENDIF.

*    IF gs_flds-telfx_x IS NOT INITIAL AND
*       gs_adrc-telfx IS NOT INITIAL.
*      CONCATENATE 'Fax:' is_adrc-telfx INTO lv_telfx
*      SEPARATED BY space.
*    ENDIF.

*    IF gs_flds-tax_office_x IS NOT INITIAL OR
*       gs_flds-tax_number_x IS NOT INITIAL.


    IF gs_account-vd IS NOT INITIAL.
      CONCATENATE gs_account-vd 'V.D.' INTO lv_vd
      SEPARATED BY space.
    ENDIF.

    IF gs_account-vkn_tckn IS NOT INITIAL.

      CLEAR lv_len.

      lv_len = strlen( gs_account-vkn_tckn ).

      IF lv_len EQ 11.
        CONCATENATE 'TCKN:' gs_account-vkn_tckn
        INTO lv_vkn_tckn SEPARATED BY space.
      ELSE.
        CONCATENATE 'VKN:' gs_account-vkn_tckn
        INTO lv_vkn_tckn SEPARATED BY space.
      ENDIF.

    ENDIF.

*    IF gs_flds-tax_office_x IS INITIAL.
*      CLEAR lv_vd.
*    ENDIF.

*    IF gs_flds-tax_number_x IS INITIAL.
*      CLEAR lv_vkn_tckn.
*    ENDIF.

*    ENDIF.

    SHIFT lv_cari_adres_1 LEFT DELETING LEADING space.
    SHIFT lv_cari_adres_2 LEFT DELETING LEADING space.


*    CONCATENATE lv_name1 lv_name2 lv_vd lv_vkn_tckn lv_telf1
*                lv_name3 lv_name4
*                lv_cari_adres_1 lv_cari_adres_2
*         INTO ls_data-cari_adres
*    SEPARATED BY space.

    "lv_name1
*    IF lv_name1 IS NOT INITIAL.
    ls_data-cari_adres = lv_name1.
*    ENDIF.

    "lv_name2
*    IF lv_name2 IS NOT INITIAL.
*      CONCATENATE ls_data-cari_adres cl_abap_char_utilities=>cr_lf lv_name2 INTO ls_data-cari_adres ."SEPARATED BY space.
*    ENDIF.

    "lv_vd
    IF lv_vd IS NOT INITIAL.
      CONCATENATE ls_data-cari_adres cl_abap_char_utilities=>cr_lf lv_vd INTO ls_data-cari_adres ."SEPARATED BY space.
    ENDIF.

    "lv_vkn_tckn
    IF lv_vkn_tckn IS NOT INITIAL.
      CONCATENATE ls_data-cari_adres cl_abap_char_utilities=>cr_lf lv_vkn_tckn INTO ls_data-cari_adres ."SEPARATED BY space.
    ENDIF.

    "lv_telf1
    IF lv_telf1 IS NOT INITIAL.
      CONCATENATE ls_data-cari_adres cl_abap_char_utilities=>cr_lf lv_telf1 INTO ls_data-cari_adres ."SEPARATED BY space.
    ENDIF.

    "lv_name3
    IF lv_name3 IS NOT INITIAL.
      CONCATENATE ls_data-cari_adres cl_abap_char_utilities=>cr_lf lv_name3 INTO ls_data-cari_adres ."SEPARATED BY space.
    ENDIF.

    "lv_name4
    IF lv_name4 IS NOT INITIAL.
      CONCATENATE ls_data-cari_adres cl_abap_char_utilities=>cr_lf lv_name4 INTO ls_data-cari_adres ."SEPARATED BY space.
    ENDIF.

    "lv_cari_adres_1
    IF lv_cari_adres_1 IS NOT INITIAL.
      CONCATENATE ls_data-cari_adres cl_abap_char_utilities=>cr_lf lv_cari_adres_1 INTO ls_data-cari_adres ."SEPARATED BY space.
    ENDIF.

    "lv_cari_adres_2
    IF lv_cari_adres_2 IS NOT INITIAL.
      CONCATENATE ls_data-cari_adres cl_abap_char_utilities=>cr_lf lv_cari_adres_2 INTO ls_data-cari_adres ."SEPARATED BY space.
    ENDIF.

    """""""""""""" Müşteri Bilgileri

    DATA  : gv_first_date TYPE d, "Dönem ilk tarih
            gv_last_date  TYPE d. "Dönem son tarih



    gv_first_date = |{ VALUE #( gt_out_c[ 1 ]-gjahr OPTIONAL ) }{ VALUE #( gt_out_c[ 1 ]-period OPTIONAL ) }01|.


    me->rp_last_day_of_months(
     EXPORTING
        day_in            = gv_first_date
      IMPORTING
        last_day_of_month = gv_last_date
*       EXCEPTIONS
*          day_in_no_date    = 1
    ).

    ls_data-duzenleme_tarihi = cl_abap_context_info=>get_system_date( ).
*    ls_data-takip            = lv_number.
    ls_data-mutabakat_tarihi = |{ gv_last_date+6(2) }.{ gv_last_date+4(2) }.{ gv_last_date+0(4) }|.
    ls_data-cari_no          = gs_account-hesap_no.
    ls_data-iletisim         = cl_abap_context_info=>get_user_formatted_name( )."gs_adrs-m_name.

    ls_data-cari_unvan = gs_adrc-OrganizationName1.
    ls_data-sirket_unvan =  lv_unvan.

    ls_data-sirket_kodu =  |{ VALUE #( gt_out_c[ 1 ]-bukrs OPTIONAL ) }|.
    ls_data-donemyil =  |{ VALUE #( gt_out_c[ 1 ]-period OPTIONAL ) } / { VALUE #( gt_out_c[ 1 ]-gjahr OPTIONAL ) }|.

    IF ls_out-nolocal IS NOT INITIAL.
      DELETE gt_cform_sf WHERE waers NE 'TRY'.
    ENDIF.

    DATA : lv_toplam TYPE dmbtr.
    DATA : lv_doviz_toplam TYPE dmbtr.
    DATA : lv_borc TYPE dmbtr.
    DATA : lv_doviz_borc TYPE dmbtr.

    LOOP AT gt_cform_sf INTO DATA(ls_form).
      APPEND INITIAL LINE TO ls_data-table1 ASSIGNING FIELD-SYMBOL(<fs_table1>).
      <fs_table1>-hesap_turu   = ls_form-ltext.
      <fs_table1>-doviz_bakiye = ls_form-wrbtr.
      <fs_table1>-pb           = ls_form-waers.
      <fs_table1>-try_bakiye   = ls_form-dmbtr.
      <fs_table1>-borc_alacak  = ls_form-debit_credit.
      <fs_table1>-cevap_doviz_bakiye = ls_form-wrbtr_c.
      <fs_table1>-pb2          = ls_form-waers_c.
      <fs_table1>-cevap_try_bakiye = ls_form-dmbtr_c.
      <fs_table1>-borc_alacak2 = ls_form-debit_credit_c.

      IF <fs_table1>-pb EQ 'TRY'.
        lv_toplam = lv_toplam + <fs_table1>-try_bakiye.
      ELSE.
        lv_doviz_toplam = lv_doviz_toplam + <fs_table1>-doviz_bakiye.
      ENDIF.

      IF <fs_table1>-pb2 EQ 'TRY'.
        lv_borc = lv_borc + <fs_table1>-cevap_try_bakiye.
      ELSE.
        lv_doviz_borc = lv_doviz_borc + <fs_table1>-cevap_doviz_bakiye.
      ENDIF.

    ENDLOOP.

    ls_data-toplam = lv_toplam.
    ls_data-doviz_toplam = lv_doviz_toplam.
    ls_data-borc = lv_borc.
    ls_data-doviz_borc = lv_doviz_borc.
    TRY.
        CALL TRANSFORMATION zreco_form_pdf_takip
        SOURCE form = ls_data
        RESULT XML DATA(lv_xml).



      CATCH cx_root INTO DATA(lo_root).
    ENDTRY.

    DATA(lv_base64_data) = cl_web_http_utility=>encode_x_base64( unencoded = lv_xml ).


    TRY.

        DATA lo_ads_util  TYPE REF TO zreco_cl_ads_util.
        CREATE OBJECT lo_ads_util.

        lo_ads_util->call_adobe(
          EXPORTING
            iv_form_name            = 'ZETR_DECO_AF_CARIHESAPMUT'
            iv_template_name        = 'CARIHESAPMUTABAKATI'
            iv_xml                  = lv_base64_data "base64 verisi
            iv_adobe_scenario       = 'ZCLDOBJ_CS_ADS'
            iv_adobe_system         = 'ZCLDOBJ_CSYS_ADS'
            iv_adobe_service_id     = 'ZCLDOBJ_OS_ADS_REST'
          IMPORTING
            ev_pdf                  = DATA(lv_pdf)
            ev_response_code        = DATA(lv_res_c)
            ev_response_text        = DATA(lv_res_t)
        ).
      CATCH cx_http_dest_provider_error.
        "handle exception
    ENDTRY.

    IF lv_pdf IS NOT INITIAL.
      gv_pdf = lv_pdf.
    ENDIF.

    IF iv_output EQ 'X'.
      send_grid_data_c( it_out_c = gt_cform_sf
                    i_head_c = ls_head
                    it_receivers = gt_receivers
                    i_param = ''
                     ).


      SELECT SINGLE *
      FROM i_businesspartner
      WHERE businesspartner =   @ls_out-hesap_no
      INTO @DATA(ls_businesspartner).
      IF ls_businesspartner IS NOT INITIAL.
        ls_head-smkod = ls_businesspartner-SearchTerm1.
        ls_head-salma = ls_businesspartner-BusinessPartnerGrouping.
      ENDIF.

      INSERT zreco_hdr FROM @ls_head.

      MOVE-CORRESPONDING ls_head TO ls_fpdf.
      ls_fpdf-pdf_file = lv_pdfbase64.
      INSERT zreco_fpdf FROM @ls_fpdf.

      INSERT zreco_vers FROM @ls_vers.

*      IF p_waers IS NOT INITIAL.
*        INSERT Zreco_rboc FROM ls_curr.
*      ENDIF.
*
*      IF r_mform IS INITIAL.
*        INSERT /itetr/reco_recb FROM ls_bform.
*      ENDIF.
*
*      IF r_bform IS INITIAL.
      MODIFY Zreco_rcai FROM TABLE @lt_cform.
*        COMMIT WORK AND WAIT.
*          INSERT /itetr/reco_rcai FROM TABLE lt_cform.
*      ENDIF.

*      IF iv_output EQ 'E' OR iv_output EQ 'K'.
      INSERT zreco_rand FROM @ls_random.
      INSERT zreco_refi FROM TABLE @lt_mail.
*      ENDIF.

*      IF iv_output EQ 'F'.
*        INSERT /itetr/reco_refi FROM TABLE lt_mail.
*      ENDIF.

*      IF p_verzn IS NOT INITIAL.
*        INSERT /itetr/reco_cdun FROM TABLE lt_cdun.
*      ENDIF.

*
    ENDIF.

  ENDMETHOD.
*&---------------------------------------------------------------------*
*&  BILDIRIM EKLEME FONKSIYON MODULLERI (15 adet)
*&---------------------------------------------------------------------*
*& Bu dosya SE37'de 15 ayri FM olarak olusturulur. Hepsinin imzasi
*& benzer, sadece bildirim_tip farkli. Mock class'ta log kaydi
*& olusturulur ve basarili referans no doner.
*&
*& FM LISTESI:
*&   1. ZMDPUTS_URETIM_BILDIRIMI_EKLE
*&   2. ZMDPUTS_ITHALAT_BILDIRIMI_EKLE
*&   3. ZMDPUTS_YETKILI_ITHALAT_EKLE           (orj: F_UTS_YETKILI_BAYI_ITHALAT_BILDIRIMI_EKLE)
*&   4. ZMDPUTS_VERME_BILDIRIMI_EKLE
*&   5. ZMDPUTS_KOZ_FIRMA_VERME_EKLE           (orj: F_UTS_KOZMETIK_FIRMA_VERME_BILDIRIMI_EKLE)
*&   6. ZMDPUTS_ALMA_BILDIRIMI_EKLE
*&   7. ZMDPUTS_TNY_VERME_EKLE                 (orj: F_UTS_TANIMSIZ_YERE_VERME_BILDIRIMI_EKLE)
*&   8. ZMDPUTS_TNY_IADE_ALMA_EKLE             (orj: F_UTS_TANIMSIZ_YERDEN_IADE_ALMA_BILDIRIMI_EKLE)
*&   9. ZMDPUTS_KULLANIM_BILDIRIM_EKLE         (orj: F_UTS_KULLANIM_BILDIRIMI_EKLE)
*&  10. ZMDPUTS_TUKETICIYE_VERME_EKLE          (orj: F_UTS_TUKETICIYE_VERME_BILDIRIMI_EKLE)
*&  11. ZMDPUTS_HEK_ZAYIAT_BILD_EKLE           (orj: F_UTS_HEK_ZAYIAT_BILDIRIM_EKLE)
*&  12. ZMDPUTS_ESSIZ_ALMA_BILD_EKLE           (orj: F_UTS_ESSIZ_KIMLIK_BILGISI_ALMA_BILDIRIMI_EKLE)
*&  13. ZMDPUTS_ESSIZ_KULLANIM_EKLE            (orj: F_UTS_ESSIZ_KIMLIK_BILGISI_KULLANIM_BILDIRIMI_EKLE)
*&  14. ZMDPUTS_ESSIZ_TNY_IADE_EKLE            (orj: F_UTS_ESSIZ_KIMLIK_BILGISI_TANIMSIZ_YERDEN_IADE_ALMA_BILDIRIMI_EKLE)
*&  15. ZMDPUTS_ESSIZ_TNY_VERME_EKLE           (orj: F_UTS_ESSIZ_KIMLIK_BILGISI_TANIMSIZ_YERE_VERME_BILDIRIMI_EKLE)
*&
*& NOT: SAP FM ismi max 30 karakter; orijinal isimler sigmadigi icin
*&      kisaltildi. Uzun ismi yorumda belirtildi.
*&---------------------------------------------------------------------*


*======================================================================
* 1. URETIM BILDIRIMI
*======================================================================
FUNCTION zmdputs_uretim_bildirimi_ekle.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IV_UNO) TYPE  CHAR23
*"     VALUE(IV_LNO) TYPE  CHAR20 OPTIONAL
*"     VALUE(IV_SNO) TYPE  CHAR20 OPTIONAL
*"     VALUE(IV_URT) TYPE  CHAR10          " Uretim tarihi YYYY-AA-GG
*"     VALUE(IV_SKT) TYPE  CHAR13 OPTIONAL " Son kullanma
*"     VALUE(IV_ADT) TYPE  I DEFAULT 1
*"     VALUE(IV_UDI) TYPE  STRING OPTIONAL
*"  EXPORTING
*"     VALUE(ES_CEVAP) TYPE  TY_UTS_CEVAP
*"----------------------------------------------------------------------

  es_cevap = zcl_zmdputs_mock=>get_instance( )->bildirim_kaydet(
    iv_bildirim_tip = gc_bildirim_tip-uretim
    iv_uno          = iv_uno
    iv_lno          = iv_lno
    iv_sno          = iv_sno
    iv_adt          = iv_adt
    iv_ek_bilgi     = |Uretim Tarihi: { iv_urt }; Son Kullanma: { iv_skt }| ).

ENDFUNCTION.


*======================================================================
* 2. ITHALAT BILDIRIMI
*======================================================================
FUNCTION zmdputs_ithalat_bildirimi_ekle.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IV_UNO) TYPE  CHAR23
*"     VALUE(IV_LNO) TYPE  CHAR20 OPTIONAL
*"     VALUE(IV_SNO) TYPE  CHAR20 OPTIONAL
*"     VALUE(IV_URT) TYPE  CHAR10
*"     VALUE(IV_SKT) TYPE  CHAR13 OPTIONAL
*"     VALUE(IV_ADT) TYPE  I DEFAULT 1
*"     VALUE(IV_GCB) TYPE  CHAR20          " Gumruk Cikis Beyannamesi
*"     VALUE(IV_FATURA_NO) TYPE  CHAR50
*"  EXPORTING
*"     VALUE(ES_CEVAP) TYPE  TY_UTS_CEVAP
*"----------------------------------------------------------------------

  es_cevap = zcl_zmdputs_mock=>get_instance( )->bildirim_kaydet(
    iv_bildirim_tip = gc_bildirim_tip-ithalat
    iv_uno          = iv_uno
    iv_lno          = iv_lno
    iv_sno          = iv_sno
    iv_adt          = iv_adt
    iv_bno          = iv_fatura_no
    iv_ek_bilgi     = |Uretim Tarihi: { iv_urt }; Son Kullanma: { iv_skt }; Gumruk Beyanname No: { iv_gcb }| ).

ENDFUNCTION.


*======================================================================
* 3. YETKILI BAYI ILE ITHALAT BILDIRIMI
*======================================================================
FUNCTION zmdputs_yetkili_ithalat_ekle.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IV_UNO) TYPE  CHAR23
*"     VALUE(IV_LNO) TYPE  CHAR20 OPTIONAL
*"     VALUE(IV_SNO) TYPE  CHAR20 OPTIONAL
*"     VALUE(IV_ADT) TYPE  I DEFAULT 1
*"     VALUE(IV_GCB) TYPE  CHAR20
*"     VALUE(IV_YETKILI_KUN) TYPE  NUMC10  " Yetkili bayi kurum no
*"  EXPORTING
*"     VALUE(ES_CEVAP) TYPE  TY_UTS_CEVAP
*"----------------------------------------------------------------------

  es_cevap = zcl_zmdputs_mock=>get_instance( )->bildirim_kaydet(
    iv_bildirim_tip = gc_bildirim_tip-yetkili_ithalat
    iv_uno          = iv_uno
    iv_lno          = iv_lno
    iv_sno          = iv_sno
    iv_adt          = iv_adt
    iv_kun          = iv_yetkili_kun
    iv_ek_bilgi     = |Gumruk Beyanname No: { iv_gcb }| ).

ENDFUNCTION.


*======================================================================
* 4. VERME BILDIRIMI
*======================================================================
FUNCTION zmdputs_verme_bildirimi_ekle.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IV_UNO) TYPE  CHAR23
*"     VALUE(IV_LNO) TYPE  CHAR20 OPTIONAL
*"     VALUE(IV_SNO) TYPE  CHAR20 OPTIONAL
*"     VALUE(IV_ADT) TYPE  I DEFAULT 1
*"     VALUE(IV_KUN) TYPE  NUMC10         " Verilen kurum
*"     VALUE(IV_BEN) TYPE  CHAR5 DEFAULT 'HAYIR'  " Bedelsiz numune
*"     VALUE(IV_BNO) TYPE  CHAR50         " Belge no (fatura/irsaliye)
*"     VALUE(IV_GIT) TYPE  DATS OPTIONAL  " Gercek islem tarihi
*"  EXPORTING
*"     VALUE(ES_CEVAP) TYPE  TY_UTS_CEVAP
*"----------------------------------------------------------------------

  es_cevap = zcl_zmdputs_mock=>get_instance( )->bildirim_kaydet(
    iv_bildirim_tip = gc_bildirim_tip-verme
    iv_uno          = iv_uno
    iv_lno          = iv_lno
    iv_sno          = iv_sno
    iv_adt          = iv_adt
    iv_bno          = iv_bno
    iv_kun          = iv_kun
    iv_ek_bilgi     = |Bedelsiz Numune: { iv_ben }; Gercek Islem Tarihi: { iv_git }| ).

ENDFUNCTION.


*======================================================================
* 5. KOZMETIK FIRMAYA VERME BILDIRIMI
*======================================================================
FUNCTION zmdputs_koz_firma_verme_ekle.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IV_UNO) TYPE  CHAR23
*"     VALUE(IV_LNO) TYPE  CHAR20 OPTIONAL
*"     VALUE(IV_ADT) TYPE  I DEFAULT 1
*"     VALUE(IV_KUN) TYPE  NUMC10         " Kozmetik firmanin kurum no
*"     VALUE(IV_BNO) TYPE  CHAR50
*"  EXPORTING
*"     VALUE(ES_CEVAP) TYPE  TY_UTS_CEVAP
*"----------------------------------------------------------------------

  es_cevap = zcl_zmdputs_mock=>get_instance( )->bildirim_kaydet(
    iv_bildirim_tip = gc_bildirim_tip-kozmetik_firma_ver
    iv_uno          = iv_uno
    iv_lno          = iv_lno
    iv_adt          = iv_adt
    iv_bno          = iv_bno
    iv_kun          = iv_kun ).

ENDFUNCTION.


*======================================================================
* 6. ALMA BILDIRIMI
*======================================================================
FUNCTION zmdputs_alma_bildirimi_ekle.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IV_UNO) TYPE  CHAR23
*"     VALUE(IV_LNO) TYPE  CHAR20 OPTIONAL
*"     VALUE(IV_SNO) TYPE  CHAR20 OPTIONAL
*"     VALUE(IV_ADT) TYPE  I DEFAULT 1
*"     VALUE(IV_KUN) TYPE  NUMC10         " Veren kurum no
*"     VALUE(IV_BNO) TYPE  CHAR50
*"     VALUE(IV_GIT) TYPE  DATS OPTIONAL
*"  EXPORTING
*"     VALUE(ES_CEVAP) TYPE  TY_UTS_CEVAP
*"----------------------------------------------------------------------

  es_cevap = zcl_zmdputs_mock=>get_instance( )->bildirim_kaydet(
    iv_bildirim_tip = gc_bildirim_tip-alma
    iv_uno          = iv_uno
    iv_lno          = iv_lno
    iv_sno          = iv_sno
    iv_adt          = iv_adt
    iv_bno          = iv_bno
    iv_kun          = iv_kun
    iv_ek_bilgi     = |Gercek Islem Tarihi: { iv_git }| ).

ENDFUNCTION.


*======================================================================
* 7. TANIMSIZ YERE VERME BILDIRIMI
*======================================================================
FUNCTION zmdputs_tny_verme_ekle.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IV_UNO) TYPE  CHAR23
*"     VALUE(IV_LNO) TYPE  CHAR20 OPTIONAL
*"     VALUE(IV_ADT) TYPE  I DEFAULT 1
*"     VALUE(IV_VKN_TCKN) TYPE  CHAR11     " Aliciya ait VKN veya TCKN
*"     VALUE(IV_UNVAN) TYPE  CHAR100
*"     VALUE(IV_BNO) TYPE  CHAR50
*"  EXPORTING
*"     VALUE(ES_CEVAP) TYPE  TY_UTS_CEVAP
*"----------------------------------------------------------------------

  es_cevap = zcl_zmdputs_mock=>get_instance( )->bildirim_kaydet(
    iv_bildirim_tip = gc_bildirim_tip-tny_verme
    iv_uno          = iv_uno
    iv_lno          = iv_lno
    iv_adt          = iv_adt
    iv_bno          = iv_bno
    iv_ek_bilgi     = |VKN/TCKN: { iv_vkn_tckn }; Unvan: { iv_unvan }| ).

ENDFUNCTION.


*======================================================================
* 8. TANIMSIZ YERDEN IADE ALMA BILDIRIMI
*======================================================================
FUNCTION zmdputs_tny_iade_alma_ekle.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IV_UNO) TYPE  CHAR23
*"     VALUE(IV_LNO) TYPE  CHAR20 OPTIONAL
*"     VALUE(IV_ADT) TYPE  I DEFAULT 1
*"     VALUE(IV_VKN_TCKN) TYPE  CHAR11
*"     VALUE(IV_UNVAN) TYPE  CHAR100
*"     VALUE(IV_BNO) TYPE  CHAR50
*"  EXPORTING
*"     VALUE(ES_CEVAP) TYPE  TY_UTS_CEVAP
*"----------------------------------------------------------------------

  es_cevap = zcl_zmdputs_mock=>get_instance( )->bildirim_kaydet(
    iv_bildirim_tip = gc_bildirim_tip-tny_iade_alma
    iv_uno          = iv_uno
    iv_lno          = iv_lno
    iv_adt          = iv_adt
    iv_bno          = iv_bno
    iv_ek_bilgi     = |VKN/TCKN: { iv_vkn_tckn }; Unvan: { iv_unvan }| ).

ENDFUNCTION.


*======================================================================
* 9. KULLANIM BILDIRIMI
*======================================================================
FUNCTION zmdputs_kullanim_bildirim_ekle.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IV_UNO) TYPE  CHAR23
*"     VALUE(IV_LNO) TYPE  CHAR20 OPTIONAL
*"     VALUE(IV_SNO) TYPE  CHAR20 OPTIONAL
*"     VALUE(IV_ADT) TYPE  I DEFAULT 1
*"     VALUE(IV_HASTA_TCKN) TYPE  CHAR11 OPTIONAL
*"     VALUE(IV_PROTOKOL_NO) TYPE  CHAR30 OPTIONAL
*"  EXPORTING
*"     VALUE(ES_CEVAP) TYPE  TY_UTS_CEVAP
*"----------------------------------------------------------------------

  es_cevap = zcl_zmdputs_mock=>get_instance( )->bildirim_kaydet(
    iv_bildirim_tip = gc_bildirim_tip-kullanim
    iv_uno          = iv_uno
    iv_lno          = iv_lno
    iv_sno          = iv_sno
    iv_adt          = iv_adt
    iv_ek_bilgi     = |Hasta TCKN: { iv_hasta_tckn }; Protokol No: { iv_protokol_no }| ).

ENDFUNCTION.


*======================================================================
* 10. TUKETICIYE VERME BILDIRIMI
*======================================================================
FUNCTION zmdputs_tuketiciye_verme_ekle.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IV_UNO) TYPE  CHAR23
*"     VALUE(IV_LNO) TYPE  CHAR20 OPTIONAL
*"     VALUE(IV_SNO) TYPE  CHAR20 OPTIONAL
*"     VALUE(IV_ADT) TYPE  I DEFAULT 1
*"     VALUE(IV_TUKETICI_TCKN) TYPE  CHAR11 OPTIONAL
*"     VALUE(IV_RECETE_NO) TYPE  CHAR30 OPTIONAL
*"     VALUE(IV_BNO) TYPE  CHAR50
*"  EXPORTING
*"     VALUE(ES_CEVAP) TYPE  TY_UTS_CEVAP
*"----------------------------------------------------------------------

  es_cevap = zcl_zmdputs_mock=>get_instance( )->bildirim_kaydet(
    iv_bildirim_tip = gc_bildirim_tip-tuketiciye_verme
    iv_uno          = iv_uno
    iv_lno          = iv_lno
    iv_sno          = iv_sno
    iv_adt          = iv_adt
    iv_bno          = iv_bno
    iv_ek_bilgi     = |Tuketici TCKN: { iv_tuketici_tckn }; Recete No: { iv_recete_no }| ).

ENDFUNCTION.


*======================================================================
* 11. HEK / ZAYIAT BILDIRIMI
*======================================================================
FUNCTION zmdputs_hek_zayiat_bild_ekle.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IV_UNO) TYPE  CHAR23
*"     VALUE(IV_LNO) TYPE  CHAR20 OPTIONAL
*"     VALUE(IV_SNO) TYPE  CHAR20 OPTIONAL
*"     VALUE(IV_ADT) TYPE  I DEFAULT 1
*"     VALUE(IV_NEDEN) TYPE  CHAR20         " HEK / ZAYIAT / BOZULMA
*"     VALUE(IV_ACIKLAMA) TYPE  STRING OPTIONAL
*"  EXPORTING
*"     VALUE(ES_CEVAP) TYPE  TY_UTS_CEVAP
*"----------------------------------------------------------------------

  es_cevap = zcl_zmdputs_mock=>get_instance( )->bildirim_kaydet(
    iv_bildirim_tip = gc_bildirim_tip-hek_zayiat
    iv_uno          = iv_uno
    iv_lno          = iv_lno
    iv_sno          = iv_sno
    iv_adt          = iv_adt
    iv_ek_bilgi     = |Neden: { iv_neden }; Aciklama: { iv_aciklama }| ).

ENDFUNCTION.


*======================================================================
* 12. ESSIZ KIMLIK BILGISI ALMA BILDIRIMI
*======================================================================
FUNCTION zmdputs_essiz_alma_bild_ekle.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IV_UDI) TYPE  STRING
*"     VALUE(IV_ADT) TYPE  I DEFAULT 1
*"     VALUE(IV_KUN) TYPE  NUMC10
*"     VALUE(IV_BNO) TYPE  CHAR50
*"  EXPORTING
*"     VALUE(ES_CEVAP) TYPE  TY_UTS_CEVAP
*"----------------------------------------------------------------------

  " UDI'den UNO parse et
  DATA: lv_uno TYPE char23.
  IF strlen( iv_udi ) >= 18.
    lv_uno = substring( val = iv_udi off = 4 len = 14 ).
  ENDIF.

  es_cevap = zcl_zmdputs_mock=>get_instance( )->bildirim_kaydet(
    iv_bildirim_tip = gc_bildirim_tip-essiz_alma
    iv_uno          = lv_uno
    iv_adt          = iv_adt
    iv_bno          = iv_bno
    iv_kun          = iv_kun
    iv_ek_bilgi     = |Essiz Kimlik: { iv_udi }| ).

ENDFUNCTION.


*======================================================================
* 13. ESSIZ KIMLIK BILGISI KULLANIM BILDIRIMI
*======================================================================
FUNCTION zmdputs_essiz_kullanim_ekle.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IV_UDI) TYPE  STRING
*"     VALUE(IV_ADT) TYPE  I DEFAULT 1
*"     VALUE(IV_HASTA_TCKN) TYPE  CHAR11 OPTIONAL
*"     VALUE(IV_PROTOKOL_NO) TYPE  CHAR30 OPTIONAL
*"  EXPORTING
*"     VALUE(ES_CEVAP) TYPE  TY_UTS_CEVAP
*"----------------------------------------------------------------------

  DATA: lv_uno TYPE char23.
  IF strlen( iv_udi ) >= 18.
    lv_uno = substring( val = iv_udi off = 4 len = 14 ).
  ENDIF.

  es_cevap = zcl_zmdputs_mock=>get_instance( )->bildirim_kaydet(
    iv_bildirim_tip = gc_bildirim_tip-essiz_kullanim
    iv_uno          = lv_uno
    iv_adt          = iv_adt
    iv_ek_bilgi     = |Essiz Kimlik: { iv_udi }; Hasta TCKN: { iv_hasta_tckn }; Protokol No: { iv_protokol_no }| ).

ENDFUNCTION.


*======================================================================
* 14. ESSIZ KIMLIK - TANIMSIZ YERDEN IADE ALMA BILDIRIMI
*======================================================================
FUNCTION zmdputs_essiz_tny_iade_ekle.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IV_UDI) TYPE  STRING
*"     VALUE(IV_ADT) TYPE  I DEFAULT 1
*"     VALUE(IV_VKN_TCKN) TYPE  CHAR11
*"     VALUE(IV_UNVAN) TYPE  CHAR100
*"     VALUE(IV_BNO) TYPE  CHAR50
*"  EXPORTING
*"     VALUE(ES_CEVAP) TYPE  TY_UTS_CEVAP
*"----------------------------------------------------------------------

  DATA: lv_uno TYPE char23.
  IF strlen( iv_udi ) >= 18.
    lv_uno = substring( val = iv_udi off = 4 len = 14 ).
  ENDIF.

  es_cevap = zcl_zmdputs_mock=>get_instance( )->bildirim_kaydet(
    iv_bildirim_tip = gc_bildirim_tip-essiz_tny_iade
    iv_uno          = lv_uno
    iv_adt          = iv_adt
    iv_bno          = iv_bno
    iv_ek_bilgi     = |Essiz Kimlik: { iv_udi }; VKN/TCKN: { iv_vkn_tckn }; Unvan: { iv_unvan }| ).

ENDFUNCTION.


*======================================================================
* 15. ESSIZ KIMLIK - TANIMSIZ YERE VERME BILDIRIMI
*======================================================================
FUNCTION zmdputs_essiz_tny_verme_ekle.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IV_UDI) TYPE  STRING
*"     VALUE(IV_ADT) TYPE  I DEFAULT 1
*"     VALUE(IV_VKN_TCKN) TYPE  CHAR11
*"     VALUE(IV_UNVAN) TYPE  CHAR100
*"     VALUE(IV_BNO) TYPE  CHAR50
*"  EXPORTING
*"     VALUE(ES_CEVAP) TYPE  TY_UTS_CEVAP
*"----------------------------------------------------------------------

  DATA: lv_uno TYPE char23.
  IF strlen( iv_udi ) >= 18.
    lv_uno = substring( val = iv_udi off = 4 len = 14 ).
  ENDIF.

  es_cevap = zcl_zmdputs_mock=>get_instance( )->bildirim_kaydet(
    iv_bildirim_tip = gc_bildirim_tip-essiz_tny_verme
    iv_uno          = lv_uno
    iv_adt          = iv_adt
    iv_bno          = iv_bno
    iv_ek_bilgi     = |Essiz Kimlik: { iv_udi }; VKN/TCKN: { iv_vkn_tckn }; Unvan: { iv_unvan }| ).

ENDFUNCTION.

*&---------------------------------------------------------------------*
*&  SORGULAMA FONKSIYON MODULLERI (3 adet)
*&---------------------------------------------------------------------*
*& Bu dosya SE37'de 3 ayri FM olarak olusturulur:
*&   ZMDPUTS_URUN_SORGULAMA
*&   ZMDPUTS_TEKIL_URUN_SORGULAMA
*&   ZMDPUTS_TEKIL_STOK_SORGULA
*&
*& Function Group: ZMDPUTS
*&---------------------------------------------------------------------*


*======================================================================
* FUNCTION ZMDPUTS_URUN_SORGULAMA
* Amac: UNO (GTIN) verilen urune ait katalog bilgisini doner
*======================================================================
FUNCTION zmdputs_urun_sorgulama.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IV_UNO) TYPE  CHAR23
*"  EXPORTING
*"     VALUE(ES_URUN) TYPE  TY_URUN_DETAY
*"     VALUE(EV_BULUNDU) TYPE  ABAP_BOOL
*"     VALUE(EV_MESAJ) TYPE  STRING
*"----------------------------------------------------------------------

  DATA(lo_mock) = zcl_zmdputs_mock=>get_instance( ).
  DATA(ls_urun) = lo_mock->get_urun_by_uno( iv_uno ).

  IF ls_urun-uno IS INITIAL.
    ev_bulundu = abap_false.
    ev_mesaj   = |UNO { iv_uno } UTS sisteminde bulunamadi.|.
    CLEAR es_urun.
    RETURN.
  ENDIF.

  ev_bulundu = abap_true.
  ev_mesaj   = |Urun bulundu: { ls_urun-urun_adi }|.

  es_urun = VALUE #(
    uno          = ls_urun-uno
    urun_adi     = ls_urun-urun_adi
    urun_tip     = ls_urun-urun_tip
    uretici_adi  = ls_urun-uretici_adi
    barkod_kur   = ls_urun-barkod_kur
    takip_tip    = ls_urun-takip_tip
    toplam_stok  = ls_urun-toplam_stok
    gtk          = ls_urun-gtk
    aciklama     = |Urun Takip Sisteminde kayitli, aktif durumda.| ).

ENDFUNCTION.


*======================================================================
* FUNCTION ZMDPUTS_TEKIL_URUN_SORGULAMA
* Amac: UNO + LNO (+ SNO) ile tekil urun detaylarini doner
*======================================================================
FUNCTION zmdputs_tekil_urun_sorgulama.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IV_UNO) TYPE  CHAR23
*"     VALUE(IV_LNO) TYPE  CHAR20 OPTIONAL
*"     VALUE(IV_SNO) TYPE  CHAR20 OPTIONAL
*"     VALUE(IV_UDI) TYPE  STRING OPTIONAL
*"  EXPORTING
*"     VALUE(ET_DETAY) TYPE  TT_TEKIL_URUN_DETAY
*"     VALUE(EV_BULUNDU) TYPE  ABAP_BOOL
*"     VALUE(EV_MESAJ) TYPE  STRING
*"----------------------------------------------------------------------

  DATA(lo_mock) = zcl_zmdputs_mock=>get_instance( ).

  " UDI verilmisse oradan git, yoksa UNO+LNO+SNO
  IF iv_udi IS NOT INITIAL.
    et_detay = lo_mock->get_by_udi( iv_udi ).
  ELSE.
    et_detay = lo_mock->get_tekil_urun_detay(
                  iv_uno = iv_uno
                  iv_lno = iv_lno
                  iv_sno = iv_sno ).
  ENDIF.

  IF et_detay IS INITIAL.
    ev_bulundu = abap_false.
    ev_mesaj   = |Tekil urun bulunamadi. UNO={ iv_uno }, LNO={ iv_lno }, SNO={ iv_sno }|.
  ELSE.
    ev_bulundu = abap_true.
    ev_mesaj   = |{ lines( et_detay ) } adet tekil urun kaydi bulundu.|.
  ENDIF.

ENDFUNCTION.


*======================================================================
* FUNCTION ZMDPUTS_TEKIL_STOK_SORGULA
* Amac: UNO (+ LNO) icin stok bilgisini doner
*======================================================================
FUNCTION zmdputs_tekil_stok_sorgula.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IV_UNO) TYPE  CHAR23
*"     VALUE(IV_LNO) TYPE  CHAR20 OPTIONAL
*"  EXPORTING
*"     VALUE(ET_STOK) TYPE  TT_STOK_DETAY
*"     VALUE(EV_TOPLAM_STOK) TYPE  I
*"     VALUE(EV_MESAJ) TYPE  STRING
*"----------------------------------------------------------------------

  DATA(lo_mock) = zcl_zmdputs_mock=>get_instance( ).
  et_stok = lo_mock->get_tekil_stok( iv_uno = iv_uno iv_lno = iv_lno ).

  ev_toplam_stok = 0.
  LOOP AT et_stok INTO DATA(ls_s).
    ev_toplam_stok = ev_toplam_stok + ls_s-stok_adedi.
  ENDLOOP.

  IF et_stok IS INITIAL.
    ev_mesaj = |UNO { iv_uno } icin stok bilgisi bulunamadi.|.
  ELSE.
    ev_mesaj = |Toplam { ev_toplam_stok } adet stok, { lines( et_stok ) } lot uzerinde dagilmis.|.
  ENDIF.

ENDFUNCTION.

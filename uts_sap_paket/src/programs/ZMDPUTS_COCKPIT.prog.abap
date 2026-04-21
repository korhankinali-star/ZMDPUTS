*&---------------------------------------------------------------------*
*& Report  ZMDPUTS_COCKPIT
*&---------------------------------------------------------------------*
*& UTS (Urun Takip Sistemi) Demo Cockpit
*&
*& Bu rapor ZMDPUTS transaction'i ile cagrilir. Ana ekranda 18 UTS
*& islemini listeler, kullanici secimine gore ilgili selection
*& screen'i acar. Tum cevaplar mock'tur - gercek UTS servisi
*& cagrilmaz. ZMDPUTS_BILD_LOG tablosunda her bildirim loglanir.
*&
*& Transaction Code: ZMDPUTS
*& Yazar           : MDP Group
*&---------------------------------------------------------------------*
REPORT zmdputs_cockpit.

INCLUDE zmdputs_common_types.   " Ortak type'lar

*----------------------------------------------------------------------*
* GLOBAL VERILER
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_menu_item,
    sira_no      TYPE i,
    islem_kodu   TYPE char30,
    kategori     TYPE char20,
    aciklama     TYPE char80,
    fm_adi       TYPE char30,
    icon         TYPE icon_d,
  END OF ty_menu_item,
  tt_menu_item TYPE STANDARD TABLE OF ty_menu_item WITH EMPTY KEY.

*-- ALV kolon etiketi yapisi (Turkce baslik atayan helper icin)
TYPES:
  BEGIN OF ty_col_label,
    col TYPE lvc_fname,
    s   TYPE scrtext_s,   " short (10)
    m   TYPE scrtext_m,   " medium (20)
    l   TYPE scrtext_l,   " long (40)
  END OF ty_col_label,
  tt_col_label TYPE STANDARD TABLE OF ty_col_label WITH EMPTY KEY.

*-- Log gosterimi icin genisletilmis log yapisi (Turkce bildirim tipi)
TYPES:
  BEGIN OF ty_log_display,
    log_id          TYPE numc20,
    bildirim_tip_tr TYPE char60,        " "Uretim Bildirimi" (UI'da gosterilen)
    ref_no          TYPE char20,
    uno             TYPE char23,
    lno             TYPE char20,
    sno             TYPE char20,
    adt             TYPE i,
    bno             TYPE char50,
    kun             TYPE numc10,
    kurum_adi       TYPE char60,        " KUN'un Turkce karsiligi
    ek_bilgi        TYPE char255,
    durum_tr        TYPE char20,        " "Basarili" / "Hatali"
    ersda           TYPE dats,
    erzet           TYPE uzeit,
    ernam           TYPE usnam,
  END OF ty_log_display,
  tt_log_display TYPE STANDARD TABLE OF ty_log_display WITH EMPTY KEY.

DATA: gt_menu TYPE tt_menu_item,
      go_alv  TYPE REF TO cl_salv_table,
      go_mock TYPE REF TO zcl_zmdputs_mock.

*----------------------------------------------------------------------*
* SELECTION SCREEN - URUN SORGULAMA (100)
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 100 TITLE t100.
  SELECTION-SCREEN BEGIN OF BLOCK bk100 WITH FRAME TITLE TEXT-s10.
    PARAMETERS: p100_uno TYPE char23 OBLIGATORY.
  SELECTION-SCREEN END OF BLOCK bk100.
SELECTION-SCREEN END OF SCREEN 100.

*----------------------------------------------------------------------*
* SELECTION SCREEN - TEKIL URUN SORGULAMA (101)
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 101 TITLE t101.
  SELECTION-SCREEN BEGIN OF BLOCK bk101 WITH FRAME TITLE TEXT-s11.
    PARAMETERS:
      p101_uno TYPE char23,
      p101_lno TYPE char20,
      p101_sno TYPE char20,
      p101_udi TYPE string LOWER CASE.
  SELECTION-SCREEN END OF BLOCK bk101.
SELECTION-SCREEN END OF SCREEN 101.

*----------------------------------------------------------------------*
* SELECTION SCREEN - TEKIL STOK SORGULA (102)
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 102 TITLE t102.
  SELECTION-SCREEN BEGIN OF BLOCK bk102 WITH FRAME TITLE TEXT-s12.
    PARAMETERS:
      p102_uno TYPE char23 OBLIGATORY,
      p102_lno TYPE char20.
  SELECTION-SCREEN END OF BLOCK bk102.
SELECTION-SCREEN END OF SCREEN 102.

*----------------------------------------------------------------------*
* SELECTION SCREEN - URETIM BILDIRIMI (200)
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 200 TITLE t200.
  SELECTION-SCREEN BEGIN OF BLOCK bk200 WITH FRAME TITLE TEXT-s20.
    PARAMETERS:
      p200_uno TYPE char23 OBLIGATORY,
      p200_lno TYPE char20,
      p200_sno TYPE char20,
      p200_urt TYPE dats OBLIGATORY DEFAULT sy-datum,
      p200_skt TYPE dats,
      p200_adt TYPE i DEFAULT 1,
      p200_udi TYPE string LOWER CASE.
  SELECTION-SCREEN END OF BLOCK bk200.
SELECTION-SCREEN END OF SCREEN 200.

*----------------------------------------------------------------------*
* SELECTION SCREEN - ITHALAT BILDIRIMI (201)
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 201 TITLE t201.
  SELECTION-SCREEN BEGIN OF BLOCK bk201 WITH FRAME TITLE TEXT-s21.
    PARAMETERS:
      p201_uno TYPE char23 OBLIGATORY,
      p201_lno TYPE char20,
      p201_sno TYPE char20,
      p201_urt TYPE dats OBLIGATORY DEFAULT sy-datum,
      p201_skt TYPE dats,
      p201_adt TYPE i DEFAULT 1,
      p201_gcb TYPE char20,
      p201_fno TYPE char50 OBLIGATORY.
  SELECTION-SCREEN END OF BLOCK bk201.
SELECTION-SCREEN END OF SCREEN 201.

*----------------------------------------------------------------------*
* SELECTION SCREEN - YETKILI BAYI ITHALAT (202)
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 202 TITLE t202.
  SELECTION-SCREEN BEGIN OF BLOCK bk202 WITH FRAME TITLE TEXT-s22.
    PARAMETERS:
      p202_uno TYPE char23 OBLIGATORY,
      p202_lno TYPE char20,
      p202_sno TYPE char20,
      p202_adt TYPE i DEFAULT 1,
      p202_gcb TYPE char20,
      p202_kun TYPE numc10 OBLIGATORY.
  SELECTION-SCREEN END OF BLOCK bk202.
SELECTION-SCREEN END OF SCREEN 202.

*----------------------------------------------------------------------*
* SELECTION SCREEN - VERME BILDIRIMI (203)
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 203 TITLE t203.
  SELECTION-SCREEN BEGIN OF BLOCK bk203 WITH FRAME TITLE TEXT-s23.
    PARAMETERS:
      p203_uno TYPE char23 OBLIGATORY,
      p203_lno TYPE char20,
      p203_sno TYPE char20,
      p203_adt TYPE i DEFAULT 1,
      p203_kun TYPE numc10 OBLIGATORY,
      p203_ben TYPE char5 DEFAULT 'HAYIR',
      p203_bno TYPE char50 OBLIGATORY,
      p203_git TYPE dats DEFAULT sy-datum.
  SELECTION-SCREEN END OF BLOCK bk203.
SELECTION-SCREEN END OF SCREEN 203.

*----------------------------------------------------------------------*
* SELECTION SCREEN - KOZMETIK FIRMAYA VERME (204)
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 204 TITLE t204.
  SELECTION-SCREEN BEGIN OF BLOCK bk204 WITH FRAME TITLE TEXT-s24.
    PARAMETERS:
      p204_uno TYPE char23 OBLIGATORY,
      p204_lno TYPE char20,
      p204_adt TYPE i DEFAULT 1,
      p204_kun TYPE numc10 OBLIGATORY,
      p204_bno TYPE char50 OBLIGATORY.
  SELECTION-SCREEN END OF BLOCK bk204.
SELECTION-SCREEN END OF SCREEN 204.

*----------------------------------------------------------------------*
* SELECTION SCREEN - ALMA BILDIRIMI (205)
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 205 TITLE t205.
  SELECTION-SCREEN BEGIN OF BLOCK bk205 WITH FRAME TITLE TEXT-s25.
    PARAMETERS:
      p205_uno TYPE char23 OBLIGATORY,
      p205_lno TYPE char20,
      p205_sno TYPE char20,
      p205_adt TYPE i DEFAULT 1,
      p205_kun TYPE numc10 OBLIGATORY,
      p205_bno TYPE char50 OBLIGATORY,
      p205_git TYPE dats DEFAULT sy-datum.
  SELECTION-SCREEN END OF BLOCK bk205.
SELECTION-SCREEN END OF SCREEN 205.

*----------------------------------------------------------------------*
* SELECTION SCREEN - TANIMSIZ YERE VERME (206)
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 206 TITLE t206.
  SELECTION-SCREEN BEGIN OF BLOCK bk206 WITH FRAME TITLE TEXT-s26.
    PARAMETERS:
      p206_uno TYPE char23 OBLIGATORY,
      p206_lno TYPE char20,
      p206_adt TYPE i DEFAULT 1,
      p206_vkn TYPE char11 OBLIGATORY,
      p206_unv TYPE char100 OBLIGATORY,
      p206_bno TYPE char50 OBLIGATORY.
  SELECTION-SCREEN END OF BLOCK bk206.
SELECTION-SCREEN END OF SCREEN 206.

*----------------------------------------------------------------------*
* SELECTION SCREEN - TANIMSIZ YERDEN IADE ALMA (207)
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 207 TITLE t207.
  SELECTION-SCREEN BEGIN OF BLOCK bk207 WITH FRAME TITLE TEXT-s27.
    PARAMETERS:
      p207_uno TYPE char23 OBLIGATORY,
      p207_lno TYPE char20,
      p207_adt TYPE i DEFAULT 1,
      p207_vkn TYPE char11 OBLIGATORY,
      p207_unv TYPE char100 OBLIGATORY,
      p207_bno TYPE char50 OBLIGATORY.
  SELECTION-SCREEN END OF BLOCK bk207.
SELECTION-SCREEN END OF SCREEN 207.

*----------------------------------------------------------------------*
* SELECTION SCREEN - KULLANIM BILDIRIMI (208)
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 208 TITLE t208.
  SELECTION-SCREEN BEGIN OF BLOCK bk208 WITH FRAME TITLE TEXT-s28.
    PARAMETERS:
      p208_uno TYPE char23 OBLIGATORY,
      p208_lno TYPE char20,
      p208_sno TYPE char20,
      p208_adt TYPE i DEFAULT 1,
      p208_tck TYPE char11,
      p208_pro TYPE char30.
  SELECTION-SCREEN END OF BLOCK bk208.
SELECTION-SCREEN END OF SCREEN 208.

*----------------------------------------------------------------------*
* SELECTION SCREEN - TUKETICIYE VERME (209)
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 209 TITLE t209.
  SELECTION-SCREEN BEGIN OF BLOCK bk209 WITH FRAME TITLE TEXT-s29.
    PARAMETERS:
      p209_uno TYPE char23 OBLIGATORY,
      p209_lno TYPE char20,
      p209_sno TYPE char20,
      p209_adt TYPE i DEFAULT 1,
      p209_tck TYPE char11,
      p209_rec TYPE char30,
      p209_bno TYPE char50 OBLIGATORY.
  SELECTION-SCREEN END OF BLOCK bk209.
SELECTION-SCREEN END OF SCREEN 209.

*----------------------------------------------------------------------*
* SELECTION SCREEN - HEK / ZAYIAT BILDIRIMI (210)
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 210 TITLE t210.
  SELECTION-SCREEN BEGIN OF BLOCK bk210 WITH FRAME TITLE TEXT-s30.
    PARAMETERS:
      p210_uno TYPE char23 OBLIGATORY,
      p210_lno TYPE char20,
      p210_sno TYPE char20,
      p210_adt TYPE i DEFAULT 1,
      p210_ned TYPE char20 DEFAULT 'HEK' AS LISTBOX,
      p210_ack TYPE string.
  SELECTION-SCREEN END OF BLOCK bk210.
SELECTION-SCREEN END OF SCREEN 210.

*----------------------------------------------------------------------*
* SELECTION SCREEN - ESSIZ KIMLIK ALMA (211)
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 211 TITLE t211.
  SELECTION-SCREEN BEGIN OF BLOCK bk211 WITH FRAME TITLE TEXT-s31.
    PARAMETERS:
      p211_udi TYPE string LOWER CASE OBLIGATORY,
      p211_adt TYPE i DEFAULT 1,
      p211_kun TYPE numc10 OBLIGATORY,
      p211_bno TYPE char50 OBLIGATORY.
  SELECTION-SCREEN END OF BLOCK bk211.
SELECTION-SCREEN END OF SCREEN 211.

*----------------------------------------------------------------------*
* SELECTION SCREEN - ESSIZ KIMLIK KULLANIM (212)
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 212 TITLE t212.
  SELECTION-SCREEN BEGIN OF BLOCK bk212 WITH FRAME TITLE TEXT-s32.
    PARAMETERS:
      p212_udi TYPE string LOWER CASE OBLIGATORY,
      p212_adt TYPE i DEFAULT 1,
      p212_tck TYPE char11,
      p212_pro TYPE char30.
  SELECTION-SCREEN END OF BLOCK bk212.
SELECTION-SCREEN END OF SCREEN 212.

*----------------------------------------------------------------------*
* SELECTION SCREEN - ESSIZ KIMLIK TANIMSIZ IADE (213)
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 213 TITLE t213.
  SELECTION-SCREEN BEGIN OF BLOCK bk213 WITH FRAME TITLE TEXT-s33.
    PARAMETERS:
      p213_udi TYPE string LOWER CASE OBLIGATORY,
      p213_adt TYPE i DEFAULT 1,
      p213_vkn TYPE char11 OBLIGATORY,
      p213_unv TYPE char100 OBLIGATORY,
      p213_bno TYPE char50 OBLIGATORY.
  SELECTION-SCREEN END OF BLOCK bk213.
SELECTION-SCREEN END OF SCREEN 213.

*----------------------------------------------------------------------*
* SELECTION SCREEN - ESSIZ KIMLIK TANIMSIZ VERME (214)
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 214 TITLE t214.
  SELECTION-SCREEN BEGIN OF BLOCK bk214 WITH FRAME TITLE TEXT-s34.
    PARAMETERS:
      p214_udi TYPE string LOWER CASE OBLIGATORY,
      p214_adt TYPE i DEFAULT 1,
      p214_vkn TYPE char11 OBLIGATORY,
      p214_unv TYPE char100 OBLIGATORY,
      p214_bno TYPE char50 OBLIGATORY.
  SELECTION-SCREEN END OF BLOCK bk214.
SELECTION-SCREEN END OF SCREEN 214.

*----------------------------------------------------------------------*
* EVENT HANDLER CLASS - ALV cift tiklama icin
*----------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS on_double_click
      FOR EVENT double_click OF cl_salv_events_table
      IMPORTING row column.
    METHODS on_user_command
      FOR EVENT added_function OF cl_salv_events
      IMPORTING e_salv_function.
ENDCLASS.

CLASS lcl_event_handler IMPLEMENTATION.
  METHOD on_double_click.
    DATA(ls_item) = gt_menu[ row ].
    PERFORM process_selection USING ls_item-islem_kodu.
  ENDMETHOD.

  METHOD on_user_command.
    CASE e_salv_function.
      WHEN 'LOG'.
        PERFORM show_log.
      WHEN 'URUN_KAT'.
        PERFORM show_urun_katalog.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.

DATA go_handler TYPE REF TO lcl_event_handler.

*======================================================================*
* INITIALIZATION - Baslik + Turkce etiketler (JSON kod adlari gorunmesin)
*======================================================================*
INITIALIZATION.
*-- Selection screen basliklari
  t100 = 'UTS: Urun Sorgulama'.
  t101 = 'UTS: Tekil Urun Sorgulama'.
  t102 = 'UTS: Tekil Stok Sorgulama'.
  t200 = 'UTS: Uretim Bildirimi Ekle'.
  t201 = 'UTS: Ithalat Bildirimi Ekle'.
  t202 = 'UTS: Yetkili Bayi Ithalat Ekle'.
  t203 = 'UTS: Verme Bildirimi Ekle'.
  t204 = 'UTS: Kozmetik Firmaya Verme Ekle'.
  t205 = 'UTS: Alma Bildirimi Ekle'.
  t206 = 'UTS: Tanimsiz Yere Verme Ekle'.
  t207 = 'UTS: Tanimsiz Yerden Iade Alma Ekle'.
  t208 = 'UTS: Kullanim Bildirimi Ekle'.
  t209 = 'UTS: Tuketiciye Verme Ekle'.
  t210 = 'UTS: HEK/Zayiat Bildirimi Ekle'.
  t211 = 'UTS: Essiz Kimlik Alma Ekle'.
  t212 = 'UTS: Essiz Kimlik Kullanim Ekle'.
  t213 = 'UTS: Essiz Kimlik Tanimsiz Iade Ekle'.
  t214 = 'UTS: Essiz Kimlik Tanimsiz Verme Ekle'.

*-- KRITIK: Parametreler icin selection text'leri runtime'da set et
*   Boylece kullanici UI'da "P100_UNO" yerine "Urun Numarasi" gorur.
*   JSON kodlari (UNO, LNO, SNO, ADT, URT, SKT, UDI, KUN, BNO, BEN, GIT)
*   asla UI'da gosterilmez.
*
*   NOT: Ayni zamanda SE38 -> Goto -> Text Elements -> Selection Texts
*        kisminda ayni etiketler statik olarak tanimlanmali (failsafe).
*        Tam liste icin docs/SELECTION_TEXTS.md dosyasina bakin.

*--- 100/101/102 SORGULAMA ekranlari
  %_p100_uno_%_app_%-text = 'Urun Numarasi'.
  %_p101_uno_%_app_%-text = 'Urun Numarasi'.
  %_p101_lno_%_app_%-text = 'Lot/Batch Numarasi'.
  %_p101_sno_%_app_%-text = 'Seri/Sira Numarasi'.
  %_p101_udi_%_app_%-text = 'Essiz Kimlik (UDI)'.
  %_p102_uno_%_app_%-text = 'Urun Numarasi'.
  %_p102_lno_%_app_%-text = 'Lot/Batch Numarasi'.

*--- 200 Uretim Bildirimi
  %_p200_uno_%_app_%-text = 'Urun Numarasi'.
  %_p200_lno_%_app_%-text = 'Lot/Batch Numarasi'.
  %_p200_sno_%_app_%-text = 'Seri/Sira Numarasi'.
  %_p200_urt_%_app_%-text = 'Uretim Tarihi'.
  %_p200_skt_%_app_%-text = 'Son Kullanma Tarihi'.
  %_p200_adt_%_app_%-text = 'Adet'.
  %_p200_udi_%_app_%-text = 'Essiz Kimlik (UDI)'.

*--- 201 Ithalat Bildirimi
  %_p201_uno_%_app_%-text = 'Urun Numarasi'.
  %_p201_lno_%_app_%-text = 'Lot/Batch Numarasi'.
  %_p201_sno_%_app_%-text = 'Seri/Sira Numarasi'.
  %_p201_urt_%_app_%-text = 'Uretim Tarihi'.
  %_p201_skt_%_app_%-text = 'Son Kullanma Tarihi'.
  %_p201_adt_%_app_%-text = 'Adet'.
  %_p201_gcb_%_app_%-text = 'Gumruk Beyanname No'.
  %_p201_fno_%_app_%-text = 'Fatura/Irsaliye Numarasi'.

*--- 202 Yetkili Bayi Ithalat
  %_p202_uno_%_app_%-text = 'Urun Numarasi'.
  %_p202_lno_%_app_%-text = 'Lot/Batch Numarasi'.
  %_p202_sno_%_app_%-text = 'Seri/Sira Numarasi'.
  %_p202_adt_%_app_%-text = 'Adet'.
  %_p202_gcb_%_app_%-text = 'Gumruk Beyanname No'.
  %_p202_kun_%_app_%-text = 'Yetkili Bayi Kurum No'.

*--- 203 Verme Bildirimi
  %_p203_uno_%_app_%-text = 'Urun Numarasi'.
  %_p203_lno_%_app_%-text = 'Lot/Batch Numarasi'.
  %_p203_sno_%_app_%-text = 'Seri/Sira Numarasi'.
  %_p203_adt_%_app_%-text = 'Adet'.
  %_p203_kun_%_app_%-text = 'Alici Kurum Numarasi'.
  %_p203_ben_%_app_%-text = 'Bedelsiz Numune mi? (EVET/HAYIR)'.
  %_p203_bno_%_app_%-text = 'Belge Numarasi (Fatura/Irsaliye)'.
  %_p203_git_%_app_%-text = 'Gercek Islem Tarihi'.

*--- 204 Kozmetik Firmaya Verme
  %_p204_uno_%_app_%-text = 'Urun Numarasi'.
  %_p204_lno_%_app_%-text = 'Lot/Batch Numarasi'.
  %_p204_adt_%_app_%-text = 'Adet'.
  %_p204_kun_%_app_%-text = 'Kozmetik Firma Kurum No'.
  %_p204_bno_%_app_%-text = 'Belge Numarasi (Fatura/Irsaliye)'.

*--- 205 Alma Bildirimi
  %_p205_uno_%_app_%-text = 'Urun Numarasi'.
  %_p205_lno_%_app_%-text = 'Lot/Batch Numarasi'.
  %_p205_sno_%_app_%-text = 'Seri/Sira Numarasi'.
  %_p205_adt_%_app_%-text = 'Adet'.
  %_p205_kun_%_app_%-text = 'Veren Kurum Numarasi'.
  %_p205_bno_%_app_%-text = 'Belge Numarasi (Fatura/Irsaliye)'.
  %_p205_git_%_app_%-text = 'Gercek Islem Tarihi'.

*--- 206 Tanimsiz Yere Verme
  %_p206_uno_%_app_%-text = 'Urun Numarasi'.
  %_p206_lno_%_app_%-text = 'Lot/Batch Numarasi'.
  %_p206_adt_%_app_%-text = 'Adet'.
  %_p206_vkn_%_app_%-text = 'VKN veya TCKN'.
  %_p206_unv_%_app_%-text = 'Firma/Kisi Unvani'.
  %_p206_bno_%_app_%-text = 'Belge Numarasi (Fatura/Irsaliye)'.

*--- 207 Tanimsiz Yerden Iade
  %_p207_uno_%_app_%-text = 'Urun Numarasi'.
  %_p207_lno_%_app_%-text = 'Lot/Batch Numarasi'.
  %_p207_adt_%_app_%-text = 'Adet'.
  %_p207_vkn_%_app_%-text = 'VKN veya TCKN'.
  %_p207_unv_%_app_%-text = 'Firma/Kisi Unvani'.
  %_p207_bno_%_app_%-text = 'Belge Numarasi (Fatura/Irsaliye)'.

*--- 208 Kullanim Bildirimi
  %_p208_uno_%_app_%-text = 'Urun Numarasi'.
  %_p208_lno_%_app_%-text = 'Lot/Batch Numarasi'.
  %_p208_sno_%_app_%-text = 'Seri/Sira Numarasi'.
  %_p208_adt_%_app_%-text = 'Adet'.
  %_p208_tck_%_app_%-text = 'Hasta TC Kimlik No'.
  %_p208_pro_%_app_%-text = 'Protokol Numarasi'.

*--- 209 Tuketiciye Verme
  %_p209_uno_%_app_%-text = 'Urun Numarasi'.
  %_p209_lno_%_app_%-text = 'Lot/Batch Numarasi'.
  %_p209_sno_%_app_%-text = 'Seri/Sira Numarasi'.
  %_p209_adt_%_app_%-text = 'Adet'.
  %_p209_tck_%_app_%-text = 'Tuketici TC Kimlik No'.
  %_p209_rec_%_app_%-text = 'Recete Numarasi'.
  %_p209_bno_%_app_%-text = 'Belge Numarasi (Fatura/Irsaliye)'.

*--- 210 HEK / Zayiat
  %_p210_uno_%_app_%-text = 'Urun Numarasi'.
  %_p210_lno_%_app_%-text = 'Lot/Batch Numarasi'.
  %_p210_sno_%_app_%-text = 'Seri/Sira Numarasi'.
  %_p210_adt_%_app_%-text = 'Adet'.
  %_p210_ned_%_app_%-text = 'Neden (HEK/ZAYIAT/BOZULMA)'.
  %_p210_ack_%_app_%-text = 'Aciklama'.

*--- 211 Essiz Kimlik Alma
  %_p211_udi_%_app_%-text = 'Essiz Kimlik (UDI barkod)'.
  %_p211_adt_%_app_%-text = 'Adet'.
  %_p211_kun_%_app_%-text = 'Veren Kurum Numarasi'.
  %_p211_bno_%_app_%-text = 'Belge Numarasi (Fatura/Irsaliye)'.

*--- 212 Essiz Kimlik Kullanim
  %_p212_udi_%_app_%-text = 'Essiz Kimlik (UDI barkod)'.
  %_p212_adt_%_app_%-text = 'Adet'.
  %_p212_tck_%_app_%-text = 'Hasta TC Kimlik No'.
  %_p212_pro_%_app_%-text = 'Protokol Numarasi'.

*--- 213 Essiz Kimlik Tanimsiz Iade
  %_p213_udi_%_app_%-text = 'Essiz Kimlik (UDI barkod)'.
  %_p213_adt_%_app_%-text = 'Adet'.
  %_p213_vkn_%_app_%-text = 'VKN veya TCKN'.
  %_p213_unv_%_app_%-text = 'Firma/Kisi Unvani'.
  %_p213_bno_%_app_%-text = 'Belge Numarasi (Fatura/Irsaliye)'.

*--- 214 Essiz Kimlik Tanimsiz Verme
  %_p214_udi_%_app_%-text = 'Essiz Kimlik (UDI barkod)'.
  %_p214_adt_%_app_%-text = 'Adet'.
  %_p214_vkn_%_app_%-text = 'VKN veya TCKN'.
  %_p214_unv_%_app_%-text = 'Firma/Kisi Unvani'.
  %_p214_bno_%_app_%-text = 'Belge Numarasi (Fatura/Irsaliye)'.

*======================================================================*
* START-OF-SELECTION
*======================================================================*
START-OF-SELECTION.
  go_mock = zcl_zmdputs_mock=>get_instance( ).
  PERFORM build_menu.
  PERFORM show_main_cockpit.

*&---------------------------------------------------------------------*
*&      Form  BUILD_MENU
*&---------------------------------------------------------------------*
FORM build_menu.
  gt_menu = VALUE #(
    ( sira_no = 1 islem_kodu = 'URUN_SORGULA'
      kategori = 'Sorgulama' icon = icon_biw_report
      aciklama = 'Urun Sorgulama - Urun kodu ile urun bilgilerini getir'
      fm_adi = 'ZMDPUTS_URUN_SORGULAMA' )
    ( sira_no = 2 islem_kodu = 'TEKIL_URUN_SORGULA'
      kategori = 'Sorgulama' icon = icon_biw_report
      aciklama = 'Tekil Urun Sorgulama - Urun numarasi + Lot/Seri ile detay'
      fm_adi = 'ZMDPUTS_TEKIL_URUN_SORGULAMA' )
    ( sira_no = 3 islem_kodu = 'TEKIL_STOK'
      kategori = 'Sorgulama' icon = icon_biw_report
      aciklama = 'Tekil Stok Sorgulama - Urun/Lot bazli stok bilgisi'
      fm_adi = 'ZMDPUTS_TEKIL_STOK_SORGULA' )
    ( sira_no = 4 islem_kodu = 'URETIM_BILD'
      kategori = 'Bildirim' icon = icon_create
      aciklama = 'Uretim Bildirimi - Uretilen urunleri UTS''ye bildir'
      fm_adi = 'ZMDPUTS_URETIM_BILDIRIMI_EKLE' )
    ( sira_no = 5 islem_kodu = 'ITHALAT_BILD'
      kategori = 'Bildirim' icon = icon_create
      aciklama = 'Ithalat Bildirimi - Ithal edilen urunleri UTS''ye bildir'
      fm_adi = 'ZMDPUTS_ITHALAT_BILDIRIMI_EKLE' )
    ( sira_no = 6 islem_kodu = 'YETK_ITHALAT'
      kategori = 'Bildirim' icon = icon_create
      aciklama = 'Yetkili Bayi Ile Ithalat Bildirimi'
      fm_adi = 'ZMDPUTS_YETKILI_ITHALAT_EKLE' )
    ( sira_no = 7 islem_kodu = 'VERME_BILD'
      kategori = 'Bildirim' icon = icon_create
      aciklama = 'Verme Bildirimi - Baska kurum veya firmaya verilen urunler'
      fm_adi = 'ZMDPUTS_VERME_BILDIRIMI_EKLE' )
    ( sira_no = 8 islem_kodu = 'KOZ_VERME'
      kategori = 'Bildirim' icon = icon_create
      aciklama = 'Kozmetik Firmaya Verme Bildirimi'
      fm_adi = 'ZMDPUTS_KOZ_FIRMA_VERME_EKLE' )
    ( sira_no = 9 islem_kodu = 'ALMA_BILD'
      kategori = 'Bildirim' icon = icon_create
      aciklama = 'Alma Bildirimi - Baska kurumdan alinan urunler'
      fm_adi = 'ZMDPUTS_ALMA_BILDIRIMI_EKLE' )
    ( sira_no = 10 islem_kodu = 'TNY_VERME'
      kategori = 'Bildirim' icon = icon_create
      aciklama = 'Tanimsiz Yere Verme - UTS kayitli olmayan bir yere verme'
      fm_adi = 'ZMDPUTS_TNY_VERME_EKLE' )
    ( sira_no = 11 islem_kodu = 'TNY_IADE'
      kategori = 'Bildirim' icon = icon_create
      aciklama = 'Tanimsiz Yerden Iade Alma - UTS kayitli olmayandan iade alma'
      fm_adi = 'ZMDPUTS_TNY_IADE_ALMA_EKLE' )
    ( sira_no = 12 islem_kodu = 'KULLANIM'
      kategori = 'Bildirim' icon = icon_create
      aciklama = 'Kullanim Bildirimi - Hasta icin kullanilan urunler'
      fm_adi = 'ZMDPUTS_KULLANIM_BILDIRIM_EKLE' )
    ( sira_no = 13 islem_kodu = 'TUK_VERME'
      kategori = 'Bildirim' icon = icon_create
      aciklama = 'Tuketiciye Verme - Son tuketiciye satis / verme'
      fm_adi = 'ZMDPUTS_TUKETICIYE_VERME_EKLE' )
    ( sira_no = 14 islem_kodu = 'HEK_ZAYIAT'
      kategori = 'Bildirim' icon = icon_delete
      aciklama = 'HEK / Zayiat Bildirimi - Kullanilamayacak hale gelen urunler'
      fm_adi = 'ZMDPUTS_HEK_ZAYIAT_BILD_EKLE' )
    ( sira_no = 15 islem_kodu = 'EK_ALMA'
      kategori = 'Essiz Kimlik' icon = icon_key
      aciklama = 'Essiz Kimlik Ile Alma Bildirimi'
      fm_adi = 'ZMDPUTS_ESSIZ_ALMA_BILD_EKLE' )
    ( sira_no = 16 islem_kodu = 'EK_KULLANIM'
      kategori = 'Essiz Kimlik' icon = icon_key
      aciklama = 'Essiz Kimlik Ile Kullanim Bildirimi'
      fm_adi = 'ZMDPUTS_ESSIZ_KULLANIM_EKLE' )
    ( sira_no = 17 islem_kodu = 'EK_TNY_IADE'
      kategori = 'Essiz Kimlik' icon = icon_key
      aciklama = 'Essiz Kimlik Tanimsiz Yerden Iade Alma'
      fm_adi = 'ZMDPUTS_ESSIZ_TNY_IADE_EKLE' )
    ( sira_no = 18 islem_kodu = 'EK_TNY_VERME'
      kategori = 'Essiz Kimlik' icon = icon_key
      aciklama = 'Essiz Kimlik Tanimsiz Yere Verme'
      fm_adi = 'ZMDPUTS_ESSIZ_TNY_VERME_EKLE' )
  ).
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SHOW_MAIN_COCKPIT
*&---------------------------------------------------------------------*
FORM show_main_cockpit.

  TRY.
      cl_salv_table=>factory(
        IMPORTING r_salv_table = go_alv
        CHANGING  t_table      = gt_menu ).

      " Kolon ayarlari (UI'da hep Turkce baslik, teknik ad gorunmez)
      DATA(lo_cols) = go_alv->get_columns( ).
      lo_cols->set_optimize( abap_true ).

      TRY.
          DATA(lo_col) = lo_cols->get_column( 'SIRA_NO' ).
          lo_col->set_short_text( 'Sira' ).
          lo_col->set_medium_text( 'Sira No' ).
          lo_col->set_long_text( 'Sira Numarasi' ).
        CATCH cx_salv_not_found.
      ENDTRY.

      TRY.
          lo_col = lo_cols->get_column( 'ISLEM_KODU' ).
          lo_col->set_visible( abap_false ).  " Teknik kod, asla gorunmez
        CATCH cx_salv_not_found.
      ENDTRY.

      TRY.
          lo_col = lo_cols->get_column( 'KATEGORI' ).
          lo_col->set_short_text( 'Kategori' ).
          lo_col->set_medium_text( 'Kategori' ).
          lo_col->set_long_text( 'Islem Kategorisi' ).
        CATCH cx_salv_not_found.
      ENDTRY.

      TRY.
          lo_col = lo_cols->get_column( 'ACIKLAMA' ).
          lo_col->set_short_text( 'Islem' ).
          lo_col->set_medium_text( 'UTS Islemi' ).
          lo_col->set_long_text( 'UTS Islem Aciklamasi' ).
          lo_col->set_output_length( 80 ).
        CATCH cx_salv_not_found.
      ENDTRY.

      TRY.
          lo_col = lo_cols->get_column( 'FM_ADI' ).
          lo_col->set_visible( abap_false ).  " Teknik FM adi, kullaniciya gosterilmez
        CATCH cx_salv_not_found.
      ENDTRY.

      TRY.
          lo_col = lo_cols->get_column( 'ICON' ).
          lo_col->set_long_text( '' ).
          lo_col->set_medium_text( '' ).
          lo_col->set_short_text( '' ).
          lo_col->set_output_length( 4 ).
        CATCH cx_salv_not_found.
      ENDTRY.

      " Zebra + display ayarlari
      go_alv->get_display_settings( )->set_striped_pattern( abap_true ).
      go_alv->get_display_settings( )->set_list_header(
        |UTS DEMO COCKPIT - Bir islem uzerine cift tiklayin| ).

      " Fonksiyonlari ac
      go_alv->get_functions( )->set_all( abap_true ).

      " Ekstra butonlar: Log goster, Urun Katalog goster
      DATA(lo_func) = go_alv->get_functions( ).
      TRY.
          lo_func->add_function(
            name     = 'LOG'
            icon     = CONV #( icon_protocol )
            text     = 'Bildirim Loglari'
            tooltip  = 'Yapilan bildirimlerin listesi'
            position = if_salv_c_function_position=>right_of_salv_functions ).
          lo_func->add_function(
            name     = 'URUN_KAT'
            icon     = CONV #( icon_ws_truck )
            text     = 'Urun Katalogu'
            tooltip  = '5 mock urunu goster'
            position = if_salv_c_function_position=>right_of_salv_functions ).
        CATCH cx_salv_existing cx_salv_wrong_call.
      ENDTRY.

      " Event handler'lari bagla
      CREATE OBJECT go_handler.
      SET HANDLER go_handler->on_double_click FOR go_alv->get_event( ).
      SET HANDLER go_handler->on_user_command FOR go_alv->get_event( ).

      go_alv->display( ).

    CATCH cx_salv_msg INTO DATA(lx_msg).
      MESSAGE lx_msg->get_text( ) TYPE 'E'.
  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PROCESS_SELECTION
*&---------------------------------------------------------------------*
FORM process_selection USING iv_islem_kodu TYPE char30.

  DATA: lv_ok_code TYPE sy-ucomm.

  CASE iv_islem_kodu.
    WHEN 'URUN_SORGULA'.
      CALL SELECTION-SCREEN 100 STARTING AT 10 3.
      IF sy-subrc = 0. PERFORM exec_urun_sorgula. ENDIF.

    WHEN 'TEKIL_URUN_SORGULA'.
      CALL SELECTION-SCREEN 101 STARTING AT 10 3.
      IF sy-subrc = 0. PERFORM exec_tekil_urun_sorgula. ENDIF.

    WHEN 'TEKIL_STOK'.
      CALL SELECTION-SCREEN 102 STARTING AT 10 3.
      IF sy-subrc = 0. PERFORM exec_tekil_stok. ENDIF.

    WHEN 'URETIM_BILD'.
      CALL SELECTION-SCREEN 200 STARTING AT 10 3.
      IF sy-subrc = 0. PERFORM exec_uretim. ENDIF.

    WHEN 'ITHALAT_BILD'.
      CALL SELECTION-SCREEN 201 STARTING AT 10 3.
      IF sy-subrc = 0. PERFORM exec_ithalat. ENDIF.

    WHEN 'YETK_ITHALAT'.
      CALL SELECTION-SCREEN 202 STARTING AT 10 3.
      IF sy-subrc = 0. PERFORM exec_yetk_ithalat. ENDIF.

    WHEN 'VERME_BILD'.
      CALL SELECTION-SCREEN 203 STARTING AT 10 3.
      IF sy-subrc = 0. PERFORM exec_verme. ENDIF.

    WHEN 'KOZ_VERME'.
      CALL SELECTION-SCREEN 204 STARTING AT 10 3.
      IF sy-subrc = 0. PERFORM exec_koz_verme. ENDIF.

    WHEN 'ALMA_BILD'.
      CALL SELECTION-SCREEN 205 STARTING AT 10 3.
      IF sy-subrc = 0. PERFORM exec_alma. ENDIF.

    WHEN 'TNY_VERME'.
      CALL SELECTION-SCREEN 206 STARTING AT 10 3.
      IF sy-subrc = 0. PERFORM exec_tny_verme. ENDIF.

    WHEN 'TNY_IADE'.
      CALL SELECTION-SCREEN 207 STARTING AT 10 3.
      IF sy-subrc = 0. PERFORM exec_tny_iade. ENDIF.

    WHEN 'KULLANIM'.
      CALL SELECTION-SCREEN 208 STARTING AT 10 3.
      IF sy-subrc = 0. PERFORM exec_kullanim. ENDIF.

    WHEN 'TUK_VERME'.
      CALL SELECTION-SCREEN 209 STARTING AT 10 3.
      IF sy-subrc = 0. PERFORM exec_tuk_verme. ENDIF.

    WHEN 'HEK_ZAYIAT'.
      CALL SELECTION-SCREEN 210 STARTING AT 10 3.
      IF sy-subrc = 0. PERFORM exec_hek_zayiat. ENDIF.

    WHEN 'EK_ALMA'.
      CALL SELECTION-SCREEN 211 STARTING AT 10 3.
      IF sy-subrc = 0. PERFORM exec_ek_alma. ENDIF.

    WHEN 'EK_KULLANIM'.
      CALL SELECTION-SCREEN 212 STARTING AT 10 3.
      IF sy-subrc = 0. PERFORM exec_ek_kullanim. ENDIF.

    WHEN 'EK_TNY_IADE'.
      CALL SELECTION-SCREEN 213 STARTING AT 10 3.
      IF sy-subrc = 0. PERFORM exec_ek_tny_iade. ENDIF.

    WHEN 'EK_TNY_VERME'.
      CALL SELECTION-SCREEN 214 STARTING AT 10 3.
      IF sy-subrc = 0. PERFORM exec_ek_tny_verme. ENDIF.
  ENDCASE.

ENDFORM.

*======================================================================*
* F4 HELP - UNO icin mock urun katalogu
*======================================================================*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p100_uno.  PERFORM f4_uno CHANGING p100_uno.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p101_uno.  PERFORM f4_uno CHANGING p101_uno.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p102_uno.  PERFORM f4_uno CHANGING p102_uno.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p200_uno.  PERFORM f4_uno CHANGING p200_uno.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p201_uno.  PERFORM f4_uno CHANGING p201_uno.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p202_uno.  PERFORM f4_uno CHANGING p202_uno.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p203_uno.  PERFORM f4_uno CHANGING p203_uno.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p204_uno.  PERFORM f4_uno CHANGING p204_uno.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p205_uno.  PERFORM f4_uno CHANGING p205_uno.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p206_uno.  PERFORM f4_uno CHANGING p206_uno.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p207_uno.  PERFORM f4_uno CHANGING p207_uno.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p208_uno.  PERFORM f4_uno CHANGING p208_uno.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p209_uno.  PERFORM f4_uno CHANGING p209_uno.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p210_uno.  PERFORM f4_uno CHANGING p210_uno.

*-- KUN F4 help (mock kurum listesi)
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p202_kun.  PERFORM f4_kun CHANGING p202_kun.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p203_kun.  PERFORM f4_kun CHANGING p203_kun.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p204_kun.  PERFORM f4_kun CHANGING p204_kun.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p205_kun.  PERFORM f4_kun CHANGING p205_kun.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p211_kun.  PERFORM f4_kun CHANGING p211_kun.

*&---------------------------------------------------------------------*
*&      Form  F4_UNO   (Urun katalog F4 help)
*& Popup'ta Turkce baslikli kolonlar - JSON kodlari gizli
*&---------------------------------------------------------------------*
FORM f4_uno CHANGING cv_uno TYPE char23.

  DATA: lt_katalog TYPE tt_urun_katalog,
        lt_return  TYPE STANDARD TABLE OF ddshretval,
        ls_return  TYPE ddshretval,
        lt_fields  TYPE STANDARD TABLE OF dfies,
        ls_field   TYPE dfies.

  lt_katalog = zcl_zmdputs_mock=>get_instance( )->get_urun_katalog( ).

  TYPES: BEGIN OF ty_f4,
           urun_no  TYPE char23,
           urun_adi TYPE char100,
           tip      TYPE char30,
           uretici  TYPE char60,
         END OF ty_f4.
  DATA lt_f4 TYPE STANDARD TABLE OF ty_f4.

  LOOP AT lt_katalog INTO DATA(ls_k).
    APPEND VALUE ty_f4(
      urun_no  = ls_k-uno
      urun_adi = ls_k-urun_adi
      tip      = zcl_zmdputs_mock=>get_instance( )->format_urun_tip( ls_k-urun_tip )
      uretici  = ls_k-uretici_adi ) TO lt_f4.
  ENDLOOP.

  " Kolon basliklarini Turkce yap (UI'da hic teknik kod gorunmez)
  CLEAR ls_field. ls_field-fieldname = 'URUN_NO'.
    ls_field-inttype = 'C'. ls_field-intlen = 23. ls_field-outputlen = 23.
    ls_field-scrtext_s = 'Urun No'.    ls_field-scrtext_m = 'Urun No'.
    ls_field-scrtext_l = 'Urun Numarasi'. APPEND ls_field TO lt_fields.
  CLEAR ls_field. ls_field-fieldname = 'URUN_ADI'.
    ls_field-inttype = 'C'. ls_field-intlen = 100. ls_field-outputlen = 50.
    ls_field-scrtext_s = 'Urun Adi'.   ls_field-scrtext_m = 'Urun Adi'.
    ls_field-scrtext_l = 'Urun Adi'.   APPEND ls_field TO lt_fields.
  CLEAR ls_field. ls_field-fieldname = 'TIP'.
    ls_field-inttype = 'C'. ls_field-intlen = 30. ls_field-outputlen = 15.
    ls_field-scrtext_s = 'Tip'.        ls_field-scrtext_m = 'Urun Tipi'.
    ls_field-scrtext_l = 'Urun Tipi'.  APPEND ls_field TO lt_fields.
  CLEAR ls_field. ls_field-fieldname = 'URETICI'.
    ls_field-inttype = 'C'. ls_field-intlen = 60. ls_field-outputlen = 35.
    ls_field-scrtext_s = 'Uretici'.    ls_field-scrtext_m = 'Uretici Firma'.
    ls_field-scrtext_l = 'Uretici Firma'. APPEND ls_field TO lt_fields.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield     = 'URUN_NO'
      dynpprog     = sy-repid
      dynpnr       = sy-dynnr
      dynprofield  = 'P100_UNO'
      value_org    = 'S'
      window_title = 'Urun Seciniz'
    TABLES
      value_tab    = lt_f4
      field_tab    = lt_fields
      return_tab   = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  READ TABLE lt_return INDEX 1 INTO ls_return.
  IF sy-subrc = 0.
    cv_uno = ls_return-fieldval.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F4_KUN   (Mock kurum listesi)
*&---------------------------------------------------------------------*
FORM f4_kun CHANGING cv_kun TYPE numc10.

  DATA: lt_kurum   TYPE STANDARD TABLE OF ty_urun_detay,
        lt_return  TYPE STANDARD TABLE OF ddshretval,
        ls_return  TYPE ddshretval,
        lt_fields  TYPE STANDARD TABLE OF dfies,
        ls_field   TYPE dfies.

  lt_kurum = zcl_zmdputs_mock=>get_instance( )->get_kurum_listesi( ).

  TYPES: BEGIN OF ty_f4_k,
           kurum_no  TYPE numc10,
           kurum_adi TYPE char100,
           tip       TYPE char30,
         END OF ty_f4_k.
  DATA lt_f4 TYPE STANDARD TABLE OF ty_f4_k.

  LOOP AT lt_kurum INTO DATA(ls_k).
    APPEND VALUE ty_f4_k(
      kurum_no  = ls_k-uno
      kurum_adi = ls_k-urun_adi
      tip       = ls_k-urun_tip ) TO lt_f4.
  ENDLOOP.

  " Kolon basliklarini Turkce yap
  CLEAR ls_field. ls_field-fieldname = 'KURUM_NO'.
    ls_field-inttype = 'N'. ls_field-intlen = 10. ls_field-outputlen = 10.
    ls_field-scrtext_s = 'Kurum No'.   ls_field-scrtext_m = 'Kurum No'.
    ls_field-scrtext_l = 'Kurum Numarasi'. APPEND ls_field TO lt_fields.
  CLEAR ls_field. ls_field-fieldname = 'KURUM_ADI'.
    ls_field-inttype = 'C'. ls_field-intlen = 100. ls_field-outputlen = 50.
    ls_field-scrtext_s = 'Kurum Adi'.  ls_field-scrtext_m = 'Kurum Adi'.
    ls_field-scrtext_l = 'Kurum / Firma Adi'. APPEND ls_field TO lt_fields.
  CLEAR ls_field. ls_field-fieldname = 'TIP'.
    ls_field-inttype = 'C'. ls_field-intlen = 30. ls_field-outputlen = 20.
    ls_field-scrtext_s = 'Tip'.        ls_field-scrtext_m = 'Kurum Tipi'.
    ls_field-scrtext_l = 'Kurum Tipi'. APPEND ls_field TO lt_fields.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield     = 'KURUM_NO'
      value_org    = 'S'
      window_title = 'Kurum / Firma Seciniz'
    TABLES
      value_tab    = lt_f4
      field_tab    = lt_fields
      return_tab   = lt_return
    EXCEPTIONS
      OTHERS = 3.

  READ TABLE lt_return INDEX 1 INTO ls_return.
  IF sy-subrc = 0.
    cv_kun = ls_return-fieldval.
  ENDIF.

ENDFORM.

*======================================================================*
*  ISLEM UYGULAMA (EXEC) FORMLARI - FM'leri cagiran sarmallayicilar
*======================================================================*

*&---------------------------------------------------------------------*
FORM exec_urun_sorgula.
  DATA: ls_urun TYPE ty_urun_detay,
        lv_bul  TYPE abap_bool,
        lv_msg  TYPE string.

  CALL FUNCTION 'ZMDPUTS_URUN_SORGULAMA'
    EXPORTING iv_uno     = p100_uno
    IMPORTING es_urun    = ls_urun
              ev_bulundu = lv_bul
              ev_mesaj   = lv_msg.

  IF lv_bul = abap_true.
    PERFORM show_urun_detay USING ls_urun lv_msg.
  ELSE.
    MESSAGE lv_msg TYPE 'I' DISPLAY LIKE 'W'.
  ENDIF.
ENDFORM.

FORM exec_tekil_urun_sorgula.
  DATA: lt_detay TYPE tt_tekil_urun_detay,
        lv_bul   TYPE abap_bool,
        lv_msg   TYPE string.

  CALL FUNCTION 'ZMDPUTS_TEKIL_URUN_SORGULAMA'
    EXPORTING iv_uno     = p101_uno
              iv_lno     = p101_lno
              iv_sno     = p101_sno
              iv_udi     = p101_udi
    IMPORTING et_detay   = lt_detay
              ev_bulundu = lv_bul
              ev_mesaj   = lv_msg.

  IF lv_bul = abap_true.
    PERFORM show_tekil_detay_alv USING lt_detay lv_msg.
  ELSE.
    MESSAGE lv_msg TYPE 'I' DISPLAY LIKE 'W'.
  ENDIF.
ENDFORM.

FORM exec_tekil_stok.
  DATA: lt_stok TYPE tt_stok_detay,
        lv_top  TYPE i,
        lv_msg  TYPE string.

  CALL FUNCTION 'ZMDPUTS_TEKIL_STOK_SORGULA'
    EXPORTING iv_uno         = p102_uno
              iv_lno         = p102_lno
    IMPORTING et_stok        = lt_stok
              ev_toplam_stok = lv_top
              ev_mesaj       = lv_msg.

  IF lt_stok IS NOT INITIAL.
    PERFORM show_stok_alv USING lt_stok lv_msg.
  ELSE.
    MESSAGE lv_msg TYPE 'I' DISPLAY LIKE 'W'.
  ENDIF.
ENDFORM.

FORM exec_uretim.
  DATA ls_cevap TYPE ty_uts_cevap.
  DATA: lv_urt TYPE char10, lv_skt TYPE char13.
  lv_urt = |{ p200_urt+0(4) }-{ p200_urt+4(2) }-{ p200_urt+6(2) }|.
  IF p200_skt IS NOT INITIAL.
    lv_skt = |{ p200_skt+0(4) }-{ p200_skt+4(2) }-{ p200_skt+6(2) }|.
  ENDIF.

  CALL FUNCTION 'ZMDPUTS_URETIM_BILDIRIMI_EKLE'
    EXPORTING iv_uno = p200_uno iv_lno = p200_lno iv_sno = p200_sno
              iv_urt = lv_urt iv_skt = lv_skt iv_adt = p200_adt iv_udi = p200_udi
    IMPORTING es_cevap = ls_cevap.
  PERFORM show_bildirim_sonuc USING ls_cevap.
ENDFORM.

FORM exec_ithalat.
  DATA ls_cevap TYPE ty_uts_cevap.
  DATA: lv_urt TYPE char10, lv_skt TYPE char13.
  lv_urt = |{ p201_urt+0(4) }-{ p201_urt+4(2) }-{ p201_urt+6(2) }|.
  IF p201_skt IS NOT INITIAL.
    lv_skt = |{ p201_skt+0(4) }-{ p201_skt+4(2) }-{ p201_skt+6(2) }|.
  ENDIF.

  CALL FUNCTION 'ZMDPUTS_ITHALAT_BILDIRIMI_EKLE'
    EXPORTING iv_uno = p201_uno iv_lno = p201_lno iv_sno = p201_sno
              iv_urt = lv_urt iv_skt = lv_skt iv_adt = p201_adt
              iv_gcb = p201_gcb iv_fatura_no = p201_fno
    IMPORTING es_cevap = ls_cevap.
  PERFORM show_bildirim_sonuc USING ls_cevap.
ENDFORM.

FORM exec_yetk_ithalat.
  DATA ls_cevap TYPE ty_uts_cevap.
  CALL FUNCTION 'ZMDPUTS_YETKILI_ITHALAT_EKLE'
    EXPORTING iv_uno = p202_uno iv_lno = p202_lno iv_sno = p202_sno
              iv_adt = p202_adt iv_gcb = p202_gcb iv_yetkili_kun = p202_kun
    IMPORTING es_cevap = ls_cevap.
  PERFORM show_bildirim_sonuc USING ls_cevap.
ENDFORM.

FORM exec_verme.
  DATA ls_cevap TYPE ty_uts_cevap.
  CALL FUNCTION 'ZMDPUTS_VERME_BILDIRIMI_EKLE'
    EXPORTING iv_uno = p203_uno iv_lno = p203_lno iv_sno = p203_sno
              iv_adt = p203_adt iv_kun = p203_kun iv_ben = p203_ben
              iv_bno = p203_bno iv_git = p203_git
    IMPORTING es_cevap = ls_cevap.
  PERFORM show_bildirim_sonuc USING ls_cevap.
ENDFORM.

FORM exec_koz_verme.
  DATA ls_cevap TYPE ty_uts_cevap.
  CALL FUNCTION 'ZMDPUTS_KOZ_FIRMA_VERME_EKLE'
    EXPORTING iv_uno = p204_uno iv_lno = p204_lno iv_adt = p204_adt
              iv_kun = p204_kun iv_bno = p204_bno
    IMPORTING es_cevap = ls_cevap.
  PERFORM show_bildirim_sonuc USING ls_cevap.
ENDFORM.

FORM exec_alma.
  DATA ls_cevap TYPE ty_uts_cevap.
  CALL FUNCTION 'ZMDPUTS_ALMA_BILDIRIMI_EKLE'
    EXPORTING iv_uno = p205_uno iv_lno = p205_lno iv_sno = p205_sno
              iv_adt = p205_adt iv_kun = p205_kun iv_bno = p205_bno iv_git = p205_git
    IMPORTING es_cevap = ls_cevap.
  PERFORM show_bildirim_sonuc USING ls_cevap.
ENDFORM.

FORM exec_tny_verme.
  DATA ls_cevap TYPE ty_uts_cevap.
  CALL FUNCTION 'ZMDPUTS_TNY_VERME_EKLE'
    EXPORTING iv_uno = p206_uno iv_lno = p206_lno iv_adt = p206_adt
              iv_vkn_tckn = p206_vkn iv_unvan = p206_unv iv_bno = p206_bno
    IMPORTING es_cevap = ls_cevap.
  PERFORM show_bildirim_sonuc USING ls_cevap.
ENDFORM.

FORM exec_tny_iade.
  DATA ls_cevap TYPE ty_uts_cevap.
  CALL FUNCTION 'ZMDPUTS_TNY_IADE_ALMA_EKLE'
    EXPORTING iv_uno = p207_uno iv_lno = p207_lno iv_adt = p207_adt
              iv_vkn_tckn = p207_vkn iv_unvan = p207_unv iv_bno = p207_bno
    IMPORTING es_cevap = ls_cevap.
  PERFORM show_bildirim_sonuc USING ls_cevap.
ENDFORM.

FORM exec_kullanim.
  DATA ls_cevap TYPE ty_uts_cevap.
  CALL FUNCTION 'ZMDPUTS_KULLANIM_BILDIRIM_EKLE'
    EXPORTING iv_uno = p208_uno iv_lno = p208_lno iv_sno = p208_sno
              iv_adt = p208_adt iv_hasta_tckn = p208_tck iv_protokol_no = p208_pro
    IMPORTING es_cevap = ls_cevap.
  PERFORM show_bildirim_sonuc USING ls_cevap.
ENDFORM.

FORM exec_tuk_verme.
  DATA ls_cevap TYPE ty_uts_cevap.
  CALL FUNCTION 'ZMDPUTS_TUKETICIYE_VERME_EKLE'
    EXPORTING iv_uno = p209_uno iv_lno = p209_lno iv_sno = p209_sno
              iv_adt = p209_adt iv_tuketici_tckn = p209_tck
              iv_recete_no = p209_rec iv_bno = p209_bno
    IMPORTING es_cevap = ls_cevap.
  PERFORM show_bildirim_sonuc USING ls_cevap.
ENDFORM.

FORM exec_hek_zayiat.
  DATA ls_cevap TYPE ty_uts_cevap.
  CALL FUNCTION 'ZMDPUTS_HEK_ZAYIAT_BILD_EKLE'
    EXPORTING iv_uno = p210_uno iv_lno = p210_lno iv_sno = p210_sno
              iv_adt = p210_adt iv_neden = p210_ned iv_aciklama = p210_ack
    IMPORTING es_cevap = ls_cevap.
  PERFORM show_bildirim_sonuc USING ls_cevap.
ENDFORM.

FORM exec_ek_alma.
  DATA ls_cevap TYPE ty_uts_cevap.
  CALL FUNCTION 'ZMDPUTS_ESSIZ_ALMA_BILD_EKLE'
    EXPORTING iv_udi = p211_udi iv_adt = p211_adt
              iv_kun = p211_kun iv_bno = p211_bno
    IMPORTING es_cevap = ls_cevap.
  PERFORM show_bildirim_sonuc USING ls_cevap.
ENDFORM.

FORM exec_ek_kullanim.
  DATA ls_cevap TYPE ty_uts_cevap.
  CALL FUNCTION 'ZMDPUTS_ESSIZ_KULLANIM_EKLE'
    EXPORTING iv_udi = p212_udi iv_adt = p212_adt
              iv_hasta_tckn = p212_tck iv_protokol_no = p212_pro
    IMPORTING es_cevap = ls_cevap.
  PERFORM show_bildirim_sonuc USING ls_cevap.
ENDFORM.

FORM exec_ek_tny_iade.
  DATA ls_cevap TYPE ty_uts_cevap.
  CALL FUNCTION 'ZMDPUTS_ESSIZ_TNY_IADE_EKLE'
    EXPORTING iv_udi = p213_udi iv_adt = p213_adt
              iv_vkn_tckn = p213_vkn iv_unvan = p213_unv iv_bno = p213_bno
    IMPORTING es_cevap = ls_cevap.
  PERFORM show_bildirim_sonuc USING ls_cevap.
ENDFORM.

FORM exec_ek_tny_verme.
  DATA ls_cevap TYPE ty_uts_cevap.
  CALL FUNCTION 'ZMDPUTS_ESSIZ_TNY_VERME_EKLE'
    EXPORTING iv_udi = p214_udi iv_adt = p214_adt
              iv_vkn_tckn = p214_vkn iv_unvan = p214_unv iv_bno = p214_bno
    IMPORTING es_cevap = ls_cevap.
  PERFORM show_bildirim_sonuc USING ls_cevap.
ENDFORM.

*======================================================================*
* GOSTERIM FORMLARI
*======================================================================*

*&---------------------------------------------------------------------*
FORM show_urun_detay USING ls_urun TYPE ty_urun_detay
                          iv_msg  TYPE string.
  DATA: lt_urun TYPE tt_urun_detay.
  APPEND ls_urun TO lt_urun.

  TRY.
      cl_salv_table=>factory(
        IMPORTING r_salv_table = DATA(lo_t)
        CHANGING  t_table      = lt_urun ).
      lo_t->get_display_settings( )->set_list_header( iv_msg ).
      lo_t->get_columns( )->set_optimize( abap_true ).
      lo_t->get_functions( )->set_all( abap_true ).

      " Turkce kolon basliklari (JSON kod adlari gorunmesin)
      DATA(lt_labels) = VALUE tt_col_label(
        ( col = 'UNO'          s = 'Urun No'        m = 'Urun Numarasi'      l = 'Urun Numarasi (GTIN)' )
        ( col = 'URUN_ADI'     s = 'Urun Adi'       m = 'Urun Adi'           l = 'Urun / Marka / Model Adi' )
        ( col = 'URUN_TIP'     s = 'Tip'            m = 'Urun Tipi'          l = 'Urun Tipi' )
        ( col = 'URETICI_ADI'  s = 'Uretici'        m = 'Uretici Firma'      l = 'Uretici Firma Adi' )
        ( col = 'BARKOD_KUR'   s = 'Barkod'         m = 'Barkod Kurulusu'    l = 'Barkod Kurulusu' )
        ( col = 'TAKIP_TIP'    s = 'Takip'          m = 'Takip Tipi'         l = 'Takip Tipi' )
        ( col = 'TOPLAM_STOK'  s = 'Stok'           m = 'Toplam Stok'        l = 'Toplam Stok Adedi' )
        ( col = 'GTK'          s = 'Gonullu'        m = 'Gonullu Takip'      l = 'Gonullu Takip Kapsami' )
        ( col = 'ACIKLAMA'     s = 'Aciklama'       m = 'Aciklama'           l = 'Aciklama' )
      ).
      PERFORM set_alv_labels USING lo_t lt_labels.

      lo_t->display( ).
    CATCH cx_salv_msg INTO DATA(lx). MESSAGE lx->get_text( ) TYPE 'E'.
  ENDTRY.
ENDFORM.

FORM show_tekil_detay_alv USING lt_detay TYPE tt_tekil_urun_detay
                               iv_msg   TYPE string.
  DATA(lt_d) = lt_detay.
  TRY.
      cl_salv_table=>factory(
        IMPORTING r_salv_table = DATA(lo_t)
        CHANGING  t_table      = lt_d ).
      lo_t->get_display_settings( )->set_list_header( iv_msg ).
      lo_t->get_columns( )->set_optimize( abap_true ).
      lo_t->get_functions( )->set_all( abap_true ).

      " Turkce kolon basliklari - UTS API JSON kodlari (UNO/LNO/SNO/ADT/URT/SKT/...)
      " asla kullaniciya gosterilmez
      DATA(lt_labels) = VALUE tt_col_label(
        ( col = 'UNO'            s = 'Urun No'     m = 'Urun Numarasi'       l = 'Urun Numarasi (GTIN)' )
        ( col = 'LNO'            s = 'Lot'         m = 'Lot/Batch No'        l = 'Lot/Batch Numarasi' )
        ( col = 'SNO'            s = 'Seri'        m = 'Seri No'             l = 'Seri/Sira Numarasi' )
        ( col = 'ADT'            s = 'Adet'        m = 'Adet'                l = 'Adet' )
        ( col = 'URT'            s = 'Uretim'      m = 'Uretim Tar.'         l = 'Uretim Tarihi' )
        ( col = 'SKT'            s = 'SKT'         m = 'Son Kull.Tar.'       l = 'Son Kullanma Tarihi' )
        ( col = 'MME'            s = 'Marka'       m = 'Marka/Model'         l = 'Marka / Model / Etiket' )
        ( col = 'UTP'            s = 'Tip'         m = 'Urun Tipi'           l = 'Urun Tipi' )
        ( col = 'UIK'            s = 'UTS Kod'     m = 'UTS Urun Ici Kod'    l = 'UTS Urun Ici Kod' )
        ( col = 'UAK'            s = 'Ayrim'       m = 'Ayrim Kodu'          l = 'Urun Ayrim Kodu' )
        ( col = 'KKG'            s = 'Gon.Bil.'    m = 'Gonderim Mumkun'     l = 'Kayitli Kullanima Gonderilebilir' )
        ( col = 'TKA'            s = 'Top.Kull.'   m = 'Top.Kullanilabilir'  l = 'Toplam Kullanilabilir Adet' )
        ( col = 'KKA'            s = 'Kalan'       m = 'Kalan Kullanilabil.' l = 'Kullanilabilir Kalan Adet' )
        ( col = 'IUS'            s = 'Iptal'       m = 'Iptal Sebebi'        l = 'Iptal Uretim Sebebi' )
        ( col = 'SON_HAREKET'    s = 'Son Hareket' m = 'Son Hareket'         l = 'Son Yapilan Hareket' )
        ( col = 'SON_SAHIP_KUN'  s = 'Son Sahip'   m = 'Son Sahip Kurum'     l = 'Son Sahip Kurum Adi' )
      ).
      PERFORM set_alv_labels USING lo_t lt_labels.

      lo_t->display( ).
    CATCH cx_salv_msg INTO DATA(lx). MESSAGE lx->get_text( ) TYPE 'E'.
  ENDTRY.
ENDFORM.

FORM show_stok_alv USING lt_stok TYPE tt_stok_detay
                        iv_msg  TYPE string.
  DATA(lt_s) = lt_stok.
  TRY.
      cl_salv_table=>factory(
        IMPORTING r_salv_table = DATA(lo_t)
        CHANGING  t_table      = lt_s ).
      lo_t->get_display_settings( )->set_list_header( iv_msg ).
      lo_t->get_columns( )->set_optimize( abap_true ).
      lo_t->get_functions( )->set_all( abap_true ).

      DATA(lt_labels) = VALUE tt_col_label(
        ( col = 'UNO'         s = 'Urun No'    m = 'Urun Numarasi'    l = 'Urun Numarasi (GTIN)' )
        ( col = 'LNO'         s = 'Lot'        m = 'Lot/Batch No'     l = 'Lot/Batch Numarasi' )
        ( col = 'SNO'         s = 'Seri'       m = 'Seri No'          l = 'Seri/Sira Numarasi' )
        ( col = 'URUN_ADI'    s = 'Urun Adi'   m = 'Urun Adi'         l = 'Urun Adi' )
        ( col = 'STOK_ADEDI'  s = 'Stok'       m = 'Stok Adedi'       l = 'Mevcut Stok Adedi' )
        ( col = 'URT'         s = 'Uretim'     m = 'Uretim Tar.'      l = 'Uretim Tarihi' )
        ( col = 'SKT'         s = 'SKT'        m = 'Son Kull.Tar.'    l = 'Son Kullanma Tarihi' )
        ( col = 'SAHIP_KUN'   s = 'Sahip'      m = 'Sahip Kurum'      l = 'Su An Sahip Olan Kurum' )
        ( col = 'DEPO_YERI'   s = 'Depo'       m = 'Depo Yeri'        l = 'Depo / Konum' )
      ).
      PERFORM set_alv_labels USING lo_t lt_labels.

      lo_t->display( ).
    CATCH cx_salv_msg INTO DATA(lx). MESSAGE lx->get_text( ) TYPE 'E'.
  ENDTRY.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SHOW_BILDIRIM_SONUC
*&---------------------------------------------------------------------*
FORM show_bildirim_sonuc USING is_cevap TYPE ty_uts_cevap.
  DATA lv_text TYPE string.

  IF is_cevap-basarili = abap_true.
    lv_text = |BILDIRIM BASARILI|
            && | |
            && |Referans No: { is_cevap-ref_no }|
            && | |
            && |Islem Tarihi: { is_cevap-islem_tar DATE = USER }|
            && | Saat: { is_cevap-islem_saat TIME = USER }|
            && | |
            && |{ is_cevap-mesaj }|.

    CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING titel = 'UTS Bildirim Sonucu'
                txt1  = 'Bildirim UTSye basariyla gonderildi.'
                txt2  = |Referans No: { is_cevap-ref_no }|
                txt3  = |Tarih: { is_cevap-islem_tar DATE = USER } { is_cevap-islem_saat TIME = USER }|
                txt4  = ''.
    MESSAGE |Bildirim basarili - Ref: { is_cevap-ref_no }| TYPE 'S'.
  ELSE.
    MESSAGE is_cevap-mesaj TYPE 'I' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SHOW_LOG  (Yapilan bildirimlerin gecmisi)
*& UI'da JSON kodlari (URETIM/ITHALAT/...) gosterilmez, tam Turkce
*& bildirim tipleri ("Uretim Bildirimi", "Ithalat Bildirimi") kullanilir.
*&---------------------------------------------------------------------*
FORM show_log.
  DATA: lt_log TYPE STANDARD TABLE OF zmdputs_bild_log,
        lt_dsp TYPE tt_log_display.
  lt_log = go_mock->get_bildirim_loglari( 200 ).

  IF lt_log IS INITIAL.
    MESSAGE 'Henuz bildirim logu yok. Bir bildirim girerek baslayin.' TYPE 'I'.
    RETURN.
  ENDIF.

  " Log kayitlarini ekran icin Turkce'ye cevir
  LOOP AT lt_log INTO DATA(ls_l).
    APPEND VALUE ty_log_display(
      log_id          = ls_l-log_id
      bildirim_tip_tr = go_mock->format_bildirim_tip( ls_l-bildirim_tip )
      ref_no          = ls_l-ref_no
      uno             = ls_l-uno
      lno             = ls_l-lno
      sno             = ls_l-sno
      adt             = ls_l-adt
      bno             = ls_l-bno
      kun             = ls_l-kun
      kurum_adi       = COND #( WHEN ls_l-kun IS NOT INITIAL
                                THEN go_mock->get_kurum_adi( ls_l-kun )
                                ELSE '' )
      ek_bilgi        = ls_l-ek_bilgi
      durum_tr        = COND #( WHEN ls_l-durum = 'S' THEN 'Basarili'
                                WHEN ls_l-durum = 'H' THEN 'Hatali'
                                ELSE ls_l-durum )
      ersda           = ls_l-ersda
      erzet           = ls_l-erzet
      ernam           = ls_l-ernam ) TO lt_dsp.
  ENDLOOP.

  TRY.
      cl_salv_table=>factory(
        IMPORTING r_salv_table = DATA(lo_t)
        CHANGING  t_table      = lt_dsp ).
      lo_t->get_display_settings( )->set_list_header(
        |UTS Bildirim Loglari - Son { lines( lt_dsp ) } kayit| ).
      lo_t->get_display_settings( )->set_striped_pattern( abap_true ).
      lo_t->get_columns( )->set_optimize( abap_true ).
      lo_t->get_functions( )->set_all( abap_true ).

      DATA(lt_labels) = VALUE tt_col_label(
        ( col = 'LOG_ID'          s = 'Log No'      m = 'Log Numarasi'        l = 'Log Kayit Numarasi' )
        ( col = 'BILDIRIM_TIP_TR' s = 'Islem'       m = 'Bildirim Tipi'       l = 'Bildirim Tipi' )
        ( col = 'REF_NO'          s = 'Ref No'      m = 'Referans No'         l = 'UTS Referans Numarasi' )
        ( col = 'UNO'             s = 'Urun No'     m = 'Urun Numarasi'       l = 'Urun Numarasi (GTIN)' )
        ( col = 'LNO'             s = 'Lot'         m = 'Lot/Batch No'        l = 'Lot/Batch Numarasi' )
        ( col = 'SNO'             s = 'Seri'        m = 'Seri No'             l = 'Seri/Sira Numarasi' )
        ( col = 'ADT'             s = 'Adet'        m = 'Adet'                l = 'Adet' )
        ( col = 'BNO'             s = 'Belge'       m = 'Belge No'            l = 'Belge Numarasi (Fatura/Irsaliye)' )
        ( col = 'KUN'             s = 'Kurum No'    m = 'Kurum Numarasi'      l = 'Kurum/Firma Numarasi' )
        ( col = 'KURUM_ADI'       s = 'Kurum Adi'   m = 'Kurum Adi'           l = 'Kurum/Firma Adi' )
        ( col = 'EK_BILGI'        s = 'Ek Bilgi'    m = 'Ek Bilgi'            l = 'Ek Bilgi / Detay' )
        ( col = 'DURUM_TR'        s = 'Durum'       m = 'Durum'               l = 'Bildirim Durumu' )
        ( col = 'ERSDA'           s = 'Tarih'       m = 'Kayit Tarihi'        l = 'Kayit Tarihi' )
        ( col = 'ERZET'           s = 'Saat'        m = 'Kayit Saati'         l = 'Kayit Saati' )
        ( col = 'ERNAM'           s = 'Kullanici'   m = 'Kullanici'           l = 'Kayit Yapan Kullanici' )
      ).
      PERFORM set_alv_labels USING lo_t lt_labels.

      lo_t->display( ).
    CATCH cx_salv_msg INTO DATA(lx). MESSAGE lx->get_text( ) TYPE 'E'.
  ENDTRY.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SHOW_URUN_KATALOG   (5 mock urun)
*& URUN_TIP ve TAKIP_TIP gibi teknik kodlar ekranda Turkce'ye donusturulur.
*&---------------------------------------------------------------------*
FORM show_urun_katalog.
  DATA(lt_katalog) = go_mock->get_urun_katalog( ).

  " Display struct: teknik kodlari Turkce'ye cevir
  TYPES: BEGIN OF ty_urun_dsp,
           uno         TYPE char23,
           urun_adi    TYPE char100,
           urun_tipi   TYPE char30,    " "Tibbi Cihaz" seklinde
           uretici     TYPE char60,
           barkod_kur  TYPE char10,
           takip_tipi  TYPE char30,    " "Lot Bazli" seklinde
           stok_adedi  TYPE i,
           gonullu     TYPE char5,
           aktif_mi    TYPE char5,
         END OF ty_urun_dsp.
  DATA lt_dsp TYPE STANDARD TABLE OF ty_urun_dsp.

  LOOP AT lt_katalog INTO DATA(ls_k).
    APPEND VALUE ty_urun_dsp(
      uno        = ls_k-uno
      urun_adi   = ls_k-urun_adi
      urun_tipi  = go_mock->format_urun_tip( ls_k-urun_tip )
      uretici    = ls_k-uretici_adi
      barkod_kur = ls_k-barkod_kur
      takip_tipi = go_mock->format_takip_tip( ls_k-takip_tip )
      stok_adedi = ls_k-toplam_stok
      gonullu    = COND #( WHEN ls_k-gtk = 'EVET' THEN 'Evet' ELSE 'Hayir' )
      aktif_mi   = COND #( WHEN ls_k-aktif = 'X' THEN 'Evet' ELSE 'Hayir' )
    ) TO lt_dsp.
  ENDLOOP.

  TRY.
      cl_salv_table=>factory(
        IMPORTING r_salv_table = DATA(lo_t)
        CHANGING  t_table      = lt_dsp ).
      lo_t->get_display_settings( )->set_list_header(
        'UTS Urun Katalogu' ).
      lo_t->get_display_settings( )->set_striped_pattern( abap_true ).
      lo_t->get_columns( )->set_optimize( abap_true ).
      lo_t->get_functions( )->set_all( abap_true ).

      DATA(lt_labels) = VALUE tt_col_label(
        ( col = 'UNO'         s = 'Urun No'     m = 'Urun Numarasi'   l = 'Urun Numarasi (GTIN)' )
        ( col = 'URUN_ADI'    s = 'Urun Adi'    m = 'Urun Adi'        l = 'Urun / Marka / Model Adi' )
        ( col = 'URUN_TIPI'   s = 'Tip'         m = 'Urun Tipi'       l = 'Urun Tipi' )
        ( col = 'URETICI'     s = 'Uretici'     m = 'Uretici Firma'   l = 'Uretici Firma Adi' )
        ( col = 'BARKOD_KUR'  s = 'Barkod'      m = 'Barkod Kurulusu' l = 'Barkod Kurulusu (GS1 / HIBCC)' )
        ( col = 'TAKIP_TIPI'  s = 'Takip'       m = 'Takip Tipi'      l = 'Takip Tipi' )
        ( col = 'STOK_ADEDI'  s = 'Stok'        m = 'Toplam Stok'     l = 'Toplam Stok Adedi' )
        ( col = 'GONULLU'     s = 'Gonullu'     m = 'Gonullu Takip'   l = 'Gonullu Takip Kapsaminda mi?' )
        ( col = 'AKTIF_MI'    s = 'Aktif'       m = 'Aktif mi?'       l = 'Urun Aktif Durumda mi?' )
      ).
      PERFORM set_alv_labels USING lo_t lt_labels.

      lo_t->display( ).
    CATCH cx_salv_msg INTO DATA(lx). MESSAGE lx->get_text( ) TYPE 'E'.
  ENDTRY.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_LABELS
*& SALV tablodaki her kolon icin Turkce etiketleri atar.
*& UI'da teknik alan adlari (UNO, LNO, SNO vb.) asla gorunmez.
*&---------------------------------------------------------------------*
FORM set_alv_labels USING io_alv    TYPE REF TO cl_salv_table
                          it_labels TYPE tt_col_label.
  DATA(lo_cols) = io_alv->get_columns( ).

  LOOP AT it_labels INTO DATA(ls_lbl).
    TRY.
        DATA(lo_c) = lo_cols->get_column( CONV lvc_fname( ls_lbl-col ) ).
        lo_c->set_short_text( ls_lbl-s ).
        lo_c->set_medium_text( ls_lbl-m ).
        lo_c->set_long_text( ls_lbl-l ).
      CATCH cx_salv_not_found.
        " Sutun yoksa sessizce atla
    ENDTRY.
  ENDLOOP.
ENDFORM.

*----------------------------------------------------------------------*
* TEXT SYMBOLS (SE38 -> Goto -> Text Elements)
*----------------------------------------------------------------------*
* S10  :  Urun Sorgulama Bilgileri
* S11  :  Tekil Urun Sorgulama (UNO+LNO+SNO veya UDI)
* S12  :  Tekil Stok Sorgulama
* S20  :  Uretim Bildirimi Alanlari
* S21  :  Ithalat Bildirimi Alanlari
* S22  :  Yetkili Bayi Ithalat Alanlari
* S23  :  Verme Bildirimi Alanlari
* S24  :  Kozmetik Firmaya Verme Alanlari
* S25  :  Alma Bildirimi Alanlari
* S26  :  Tanimsiz Yere Verme Alanlari
* S27  :  Tanimsiz Yerden Iade Alma Alanlari
* S28  :  Kullanim Bildirimi Alanlari
* S29  :  Tuketiciye Verme Alanlari
* S30  :  HEK / Zayiat Bildirimi Alanlari
* S31  :  Essiz Kimlik Alma Alanlari
* S32  :  Essiz Kimlik Kullanim Alanlari
* S33  :  Essiz Kimlik Tanimsiz Iade Alanlari
* S34  :  Essiz Kimlik Tanimsiz Verme Alanlari

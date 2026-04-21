*&---------------------------------------------------------------------*
*& Class          ZCL_ZMDPUTS_MOCK
*& Aciklama       UTS demo mock data saglayicisi ve simulasyon motoru
*&                Tum F_UTS_* function module'leri bu class'in metotlarini
*&                kullanir. Gercek UTS servisi cagrilmaz; veriler hardcoded.
*&
*& Kurulum: SE24 -> Create Class -> ZCL_ZMDPUTS_MOCK
*&          Asagidaki kodu Implementation tab'ina yapistir.
*&---------------------------------------------------------------------*

CLASS zcl_zmdputs_mock DEFINITION
  PUBLIC
  CREATE PRIVATE.  " Singleton pattern

  PUBLIC SECTION.

    INCLUDE zmdputs_common_types.   " Ortak type'lari includes'tan aliyoruz

    "! Singleton instance
    CLASS-METHODS get_instance
      RETURNING VALUE(ro_ref) TYPE REF TO zcl_zmdputs_mock.

    "! Tum mock urun katalogunu dondurur (5 urun)
    METHODS get_urun_katalog
      RETURNING VALUE(rt_urun) TYPE tt_urun_katalog.

    "! UNO'ya gore tek urun dondurur (katalog)
    METHODS get_urun_by_uno
      IMPORTING iv_uno          TYPE char23
      RETURNING VALUE(rs_urun)  TYPE ty_urun_katalog.

    "! UNO+LNO'ya gore tekil urun detay bilgisi (sorgulama cevabi)
    METHODS get_tekil_urun_detay
      IMPORTING iv_uno            TYPE char23
                iv_lno            TYPE char20 OPTIONAL
                iv_sno            TYPE char20 OPTIONAL
      RETURNING VALUE(rt_detay)   TYPE tt_tekil_urun_detay.

    "! Essiz kimlikten (UDI) tekil urun bulma
    METHODS get_by_udi
      IMPORTING iv_udi            TYPE string
      RETURNING VALUE(rt_detay)   TYPE tt_tekil_urun_detay.

    "! Tekil stok bilgisi (UNO+LNO bazinda stok ve depo)
    METHODS get_tekil_stok
      IMPORTING iv_uno            TYPE char23
                iv_lno            TYPE char20 OPTIONAL
      RETURNING VALUE(rt_stok)    TYPE tt_stok_detay.

    "! Bir bildirimi simule et: referans no uret, log'a yaz, cevap dondur
    METHODS bildirim_kaydet
      IMPORTING iv_bildirim_tip TYPE char30
                iv_uno          TYPE char23
                iv_lno          TYPE char20  OPTIONAL
                iv_sno          TYPE char20  OPTIONAL
                iv_adt          TYPE i        OPTIONAL
                iv_bno          TYPE char50  OPTIONAL
                iv_kun          TYPE numc10  OPTIONAL
                iv_ek_bilgi     TYPE string  OPTIONAL
      RETURNING VALUE(rs_cevap) TYPE ty_uts_cevap.

    "! Log tablosundan son N bildirimi getir (cockpit grid icin)
    METHODS get_bildirim_loglari
      IMPORTING iv_son_adet TYPE i DEFAULT 100
      RETURNING VALUE(rt_log) TYPE STANDARD TABLE OF zmdputs_bild_log.

    "! Kurum numarasindan firma adi (mock)
    METHODS get_kurum_adi
      IMPORTING iv_kun          TYPE numc10
      RETURNING VALUE(rv_ad)    TYPE char60.

    "! Kurum F4 listesi (demo icin 5-10 mock kurum)
    METHODS get_kurum_listesi
      RETURNING VALUE(rt_kurum) TYPE STANDARD TABLE OF ty_urun_detay.

    "! Bildirim tipi enum kodunu Turkce tam ada cevirir
    "!   Ornek: 'URETIM' -> 'Uretim Bildirimi'
    "!          'ITHALAT' -> 'Ithalat Bildirimi'
    "! UI'da asla teknik kod gosterilmez, hep tam ad kullanilir.
    METHODS format_bildirim_tip
      IMPORTING iv_tip        TYPE char30
      RETURNING VALUE(rv_ad)  TYPE char60.

    "! Urun tip kodunu Turkce tam ada cevirir
    "! Ornek: 'TIBBI_CIHAZ' -> 'Tibbi Cihaz', 'ILAC' -> 'Ilac'
    METHODS format_urun_tip
      IMPORTING iv_tip        TYPE char30
      RETURNING VALUE(rv_ad)  TYPE char30.

    "! Takip tip kodunu Turkce tam ada cevirir
    "! Ornek: 'LOT' -> 'Lot Bazli', 'SERI' -> 'Seri Bazli', 'TEKIL' -> 'Tekil Takip'
    METHODS format_takip_tip
      IMPORTING iv_tip        TYPE char10
      RETURNING VALUE(rv_ad)  TYPE char30.

  PRIVATE SECTION.

    CLASS-DATA go_instance TYPE REF TO zcl_zmdputs_mock.

    "! Simulasyon: 70ms random gecikme ekle (gercek servis hissi icin)
    METHODS _simule_network_delay.

    "! Referans no uret: YYYYMMDD-HHMMSS-NNNN
    METHODS _uret_referans_no
      RETURNING VALUE(rv_ref) TYPE char20.

ENDCLASS.


CLASS zcl_zmdputs_mock IMPLEMENTATION.

  METHOD get_instance.
    IF go_instance IS INITIAL.
      go_instance = NEW zcl_zmdputs_mock( ).
    ENDIF.
    ro_ref = go_instance.
  ENDMETHOD.


  METHOD get_urun_katalog.
*--- 5 mock urun. Demo'da degistirmek/eklemek icin buradan.
    rt_urun = VALUE #(
      ( uno         = '08680001234567'
        urun_tip    = 'TIBBI_CIHAZ'
        urun_adi    = 'OrtoFlex Kalca Protezi Model OF-250'
        uretici_adi = 'ACME Medikal Sanayi A.S.'
        barkod_kur  = 'GS1'
        takip_tip   = 'LOT'
        toplam_stok = 150
        gtk         = ''
        aktif       = 'X' )

      ( uno         = '08680002345678'
        urun_tip    = 'ILAC'
        urun_adi    = 'KardioMax 75mg 30 tablet'
        uretici_adi = 'PharmaTek Ilac A.S.'
        barkod_kur  = 'GS1'
        takip_tip   = 'LOT'
        toplam_stok = 8200
        gtk         = ''
        aktif       = 'X' )

      ( uno         = '08680003456789'
        urun_tip    = 'TIBBI_CIHAZ'
        urun_adi    = 'NeuroStim Pacemaker NS-500'
        uretici_adi = 'ACME Medikal Sanayi A.S.'
        barkod_kur  = 'HIBCC'
        takip_tip   = 'SERI'
        toplam_stok = 42
        gtk         = ''
        aktif       = 'X' )

      ( uno         = '08680004567890'
        urun_tip    = 'KOZMETIK'
        urun_adi    = 'DermaCare Nemlendirici Krem 50ml'
        uretici_adi = 'BeautyLab Kozmetik Ltd.'
        barkod_kur  = 'GS1'
        takip_tip   = 'LOT'
        toplam_stok = 3450
        gtk         = 'EVET'
        aktif       = 'X' )

      ( uno         = '08680005678901'
        urun_tip    = 'TIBBI_CIHAZ'
        urun_adi    = 'InsuPump Pro 3 Insulin Pompasi'
        uretici_adi = 'MedicTech Global Inc.'
        barkod_kur  = 'GS1'
        takip_tip   = 'TEKIL'
        toplam_stok = 18
        gtk         = ''
        aktif       = 'X' )
    ).
  ENDMETHOD.


  METHOD get_urun_by_uno.
    DATA(lt_urun) = get_urun_katalog( ).
    READ TABLE lt_urun WITH KEY uno = iv_uno INTO rs_urun.
  ENDMETHOD.


  METHOD get_tekil_urun_detay.
    _simule_network_delay( ).

    DATA: ls_detay TYPE ty_tekil_urun_detay.
    DATA(ls_urun) = get_urun_by_uno( iv_uno ).

    IF ls_urun-uno IS INITIAL.
      RETURN.  " Urun bulunamadi
    ENDIF.

    " Her urun icin mock LOT/seri kombinasyonlari
    " Kullanici LNO girmisse sadece o LNO, girmemisse tum LNO'lar
    DATA(lv_bugun) = sy-datum.

    CASE iv_uno.
      WHEN '08680001234567'.
        " OrtoFlex - 3 LOT mock
        APPEND VALUE #(
          uno = iv_uno lno = 'LOT2025A001' sno = '' adt = 100
          urt = '2025-01-15' skt = '2028-01-15'
          mme = ls_urun-urun_adi utp = ls_urun-urun_tip
          uik = 1234567890 uak = 'LOT' kkg = abap_true
          tka = 100 kka = 95 ius = 0
          son_hareket = 'ITHALAT BILDIRIMI' son_sahip_kun = 'ACME Medikal A.S.' )
          TO rt_detay.
        APPEND VALUE #(
          uno = iv_uno lno = 'LOT2025A002' sno = '' adt = 50
          urt = '2025-03-10' skt = '2028-03-10'
          mme = ls_urun-urun_adi utp = ls_urun-urun_tip
          uik = 1234567891 uak = 'LOT' kkg = abap_true
          tka = 50 kka = 48 ius = 0
          son_hareket = 'VERME BILDIRIMI' son_sahip_kun = 'Ankara Egitim ve Arastirma Hastanesi' )
          TO rt_detay.

      WHEN '08680002345678'.
        " KardioMax - 2 LOT
        APPEND VALUE #(
          uno = iv_uno lno = 'KM25B15' sno = '' adt = 8000
          urt = '2025-02-01' skt = '2027-02-01'
          mme = ls_urun-urun_adi utp = ls_urun-urun_tip
          uik = 2345678901 uak = 'LOT' kkg = abap_true
          tka = 8000 kka = 7800 ius = 0
          son_hareket = 'VERME BILDIRIMI' son_sahip_kun = 'Ecza Deposu Merkez A.S.' )
          TO rt_detay.
        APPEND VALUE #(
          uno = iv_uno lno = 'KM25C22' sno = '' adt = 200
          urt = '2025-03-15' skt = '2027-03-15'
          mme = ls_urun-urun_adi utp = ls_urun-urun_tip
          uik = 2345678902 uak = 'LOT' kkg = abap_true
          tka = 200 kka = 200 ius = 0
          son_hareket = 'URETIM BILDIRIMI' son_sahip_kun = 'PharmaTek Ilac A.S.' )
          TO rt_detay.

      WHEN '08680003456789'.
        " NeuroStim - seri bazinda 3 cihaz
        APPEND VALUE #(
          uno = iv_uno lno = '' sno = 'NS500-2025-0001' adt = 1
          urt = '2025-01-20' skt = '2030-01-20'
          mme = ls_urun-urun_adi utp = ls_urun-urun_tip
          uik = 3456789001 uak = 'SERI' kkg = abap_true
          tka = 1 kka = 1 ius = 0
          son_hareket = 'URETIM BILDIRIMI' son_sahip_kun = 'ACME Medikal A.S.' )
          TO rt_detay.
        APPEND VALUE #(
          uno = iv_uno lno = '' sno = 'NS500-2025-0002' adt = 1
          urt = '2025-01-20' skt = '2030-01-20'
          mme = ls_urun-urun_adi utp = ls_urun-urun_tip
          uik = 3456789002 uak = 'SERI' kkg = abap_true
          tka = 1 kka = 0 ius = 0
          son_hareket = 'KULLANIM BILDIRIMI' son_sahip_kun = 'Istanbul Tip Fakultesi Hastanesi' )
          TO rt_detay.

      WHEN '08680004567890'.
        " DermaCare - 2 LOT
        APPEND VALUE #(
          uno = iv_uno lno = 'DC2025-01' sno = '' adt = 2000
          urt = '2025-02-10' skt = '2028-02-10'
          mme = ls_urun-urun_adi utp = ls_urun-urun_tip
          uik = 4567890001 uak = 'LOT' kkg = abap_true
          tka = 2000 kka = 1950 ius = 0
          son_hareket = 'VERME BILDIRIMI' son_sahip_kun = 'Watsons Magazacilik A.S.' )
          TO rt_detay.
        APPEND VALUE #(
          uno = iv_uno lno = 'DC2025-02' sno = '' adt = 1500
          urt = '2025-03-01' skt = '2028-03-01'
          mme = ls_urun-urun_adi utp = ls_urun-urun_tip
          uik = 4567890002 uak = 'LOT' kkg = abap_true
          tka = 1500 kka = 1500 ius = 0
          son_hareket = 'URETIM BILDIRIMI' son_sahip_kun = 'BeautyLab Kozmetik Ltd.' )
          TO rt_detay.

      WHEN '08680005678901'.
        " InsuPump Pro - tekil (UDI) 3 cihaz
        APPEND VALUE #(
          uno = iv_uno lno = 'IP2025-A' sno = 'IPP-A-25-00001' adt = 1
          urt = '2025-02-15' skt = '2030-02-15'
          mme = ls_urun-urun_adi utp = ls_urun-urun_tip
          uik = 5678901001 uak = 'SERI' kkg = abap_true
          tka = 1 kka = 1 ius = 0
          son_hareket = 'ITHALAT BILDIRIMI' son_sahip_kun = 'MedicTech Turkey Ltd.' )
          TO rt_detay.
        APPEND VALUE #(
          uno = iv_uno lno = 'IP2025-A' sno = 'IPP-A-25-00002' adt = 1
          urt = '2025-02-15' skt = '2030-02-15'
          mme = ls_urun-urun_adi utp = ls_urun-urun_tip
          uik = 5678901002 uak = 'SERI' kkg = abap_true
          tka = 1 kka = 0 ius = 0
          son_hareket = 'TUKETICIYE VERME' son_sahip_kun = 'AYSE YILMAZ (TC: 123****6789)' )
          TO rt_detay.
    ENDCASE.

    " Filtreleme: iv_lno ve iv_sno doldurulmussa sadece eslenenleri don
    IF iv_lno IS NOT INITIAL.
      DELETE rt_detay WHERE lno <> iv_lno.
    ENDIF.
    IF iv_sno IS NOT INITIAL.
      DELETE rt_detay WHERE sno <> iv_sno.
    ENDIF.
  ENDMETHOD.


  METHOD get_by_udi.
    _simule_network_delay( ).
    " UDI formati demo: ilk 14 karakter UNO, sonra parse et
    " Gercek UDI: (01)08680001234567(17)250115(10)LOT2025A001(21)SN00001

    " Basit mock: UDI icindeki 14 haneli UNO'yu cek
    IF strlen( iv_udi ) >= 14.
      DATA(lv_uno) = substring( val = iv_udi off = 4 len = 14 ).
      rt_detay = get_tekil_urun_detay( iv_uno = CONV #( lv_uno ) ).
    ENDIF.
  ENDMETHOD.


  METHOD get_tekil_stok.
    _simule_network_delay( ).
    DATA(lt_detay) = get_tekil_urun_detay( iv_uno = iv_uno iv_lno = iv_lno ).

    LOOP AT lt_detay INTO DATA(ls_d).
      APPEND VALUE ty_stok_detay(
        uno        = ls_d-uno
        lno        = ls_d-lno
        sno        = ls_d-sno
        urun_adi   = ls_d-mme
        stok_adedi = ls_d-kka
        urt        = ls_d-urt
        skt        = ls_d-skt
        sahip_kun  = ls_d-son_sahip_kun
        depo_yeri  = 'ANA DEPO - Istanbul' ) TO rt_stok.
    ENDLOOP.
  ENDMETHOD.


  METHOD bildirim_kaydet.
    _simule_network_delay( ).

    DATA: ls_log TYPE zmdputs_bild_log.

    " Log ID uret
    DATA lv_next_id TYPE numc20.
    TRY.
        SELECT MAX( log_id ) FROM zmdputs_bild_log INTO @DATA(lv_max).
        lv_next_id = lv_max + 1.
      CATCH cx_sy_open_sql_db.
        lv_next_id = '00000000000000000001'.
    ENDTRY.

    rs_cevap-ref_no     = _uret_referans_no( ).
    rs_cevap-basarili   = abap_true.
    rs_cevap-islem_tar  = sy-datum.
    rs_cevap-islem_saat = sy-uzeit.
    rs_cevap-mesaj      = |Bildirim UTS'ye basariyla gonderildi. Referans No: { rs_cevap-ref_no }|.

    " Log yaz
    ls_log = VALUE #(
      log_id       = lv_next_id
      bildirim_tip = iv_bildirim_tip
      ref_no       = rs_cevap-ref_no
      uno          = iv_uno
      lno          = iv_lno
      sno          = iv_sno
      adt          = iv_adt
      bno          = iv_bno
      kun          = iv_kun
      ek_bilgi     = CONV #( iv_ek_bilgi )
      durum        = gc_durum-basarili
      ersda        = sy-datum
      erzet        = sy-uzeit
      ernam        = sy-uname ).

    INSERT zmdputs_bild_log FROM ls_log.
    IF sy-subrc = 0.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
      rs_cevap-basarili = abap_false.
      rs_cevap-mesaj    = |Log kaydinda hata olustu. Lutfen yonetici ile iletisime gecin.|.
    ENDIF.

  ENDMETHOD.


  METHOD get_bildirim_loglari.
    SELECT * FROM zmdputs_bild_log
      INTO TABLE @rt_log
      UP TO @iv_son_adet ROWS
      ORDER BY log_id DESCENDING.
  ENDMETHOD.


  METHOD get_kurum_adi.
    CASE iv_kun.
      WHEN '0000000007'. rv_ad = 'Ecza Deposu Merkez A.S.'.
      WHEN '0000000015'. rv_ad = 'Ankara Egitim ve Arastirma Hastanesi'.
      WHEN '0000000023'. rv_ad = 'Istanbul Tip Fakultesi Hastanesi'.
      WHEN '0000000042'. rv_ad = 'Watsons Magazacilik A.S.'.
      WHEN '0000000077'. rv_ad = 'Gulhane Askeri Tip Akademisi'.
      WHEN '0000000088'. rv_ad = 'Ozel Medicana Saglik Grubu'.
      WHEN OTHERS.       rv_ad = |KURUM NO { iv_kun }|.
    ENDCASE.
  ENDMETHOD.


  METHOD get_kurum_listesi.
    " F4 help icin mock kurum listesi (urun_detay type'i reuse edildi)
    APPEND VALUE #( uno = '0000000007' urun_adi = 'Ecza Deposu Merkez A.S.'
                    urun_tip = 'ECZA_DEPOSU' ) TO rt_kurum.
    APPEND VALUE #( uno = '0000000015' urun_adi = 'Ankara Egitim ve Arastirma Hastanesi'
                    urun_tip = 'HASTANE' ) TO rt_kurum.
    APPEND VALUE #( uno = '0000000023' urun_adi = 'Istanbul Tip Fakultesi Hastanesi'
                    urun_tip = 'HASTANE' ) TO rt_kurum.
    APPEND VALUE #( uno = '0000000042' urun_adi = 'Watsons Magazacilik A.S.'
                    urun_tip = 'PERAKENDE' ) TO rt_kurum.
    APPEND VALUE #( uno = '0000000077' urun_adi = 'Gulhane Askeri Tip Akademisi'
                    urun_tip = 'HASTANE' ) TO rt_kurum.
    APPEND VALUE #( uno = '0000000088' urun_adi = 'Ozel Medicana Saglik Grubu'
                    urun_tip = 'OZEL_HASTANE' ) TO rt_kurum.
  ENDMETHOD.


  METHOD format_bildirim_tip.
*--- UI'da asla teknik kod gosterilmez. Log tablosundaki 'URETIM',
*    'ITHALAT' gibi kisaltilmis kodlari kullaniciya "Uretim Bildirimi",
*    "Ithalat Bildirimi" olarak goster.
    CASE iv_tip.
      WHEN gc_bildirim_tip-uretim.
        rv_ad = 'Uretim Bildirimi'.
      WHEN gc_bildirim_tip-ithalat.
        rv_ad = 'Ithalat Bildirimi'.
      WHEN gc_bildirim_tip-yetkili_ithalat.
        rv_ad = 'Yetkili Bayi ile Ithalat Bildirimi'.
      WHEN gc_bildirim_tip-verme.
        rv_ad = 'Verme Bildirimi'.
      WHEN gc_bildirim_tip-kozmetik_firma_ver.
        rv_ad = 'Kozmetik Firmaya Verme Bildirimi'.
      WHEN gc_bildirim_tip-alma.
        rv_ad = 'Alma Bildirimi'.
      WHEN gc_bildirim_tip-tny_verme.
        rv_ad = 'Tanimsiz Yere Verme Bildirimi'.
      WHEN gc_bildirim_tip-tny_iade_alma.
        rv_ad = 'Tanimsiz Yerden Iade Alma Bildirimi'.
      WHEN gc_bildirim_tip-kullanim.
        rv_ad = 'Kullanim Bildirimi'.
      WHEN gc_bildirim_tip-tuketiciye_verme.
        rv_ad = 'Tuketiciye Verme Bildirimi'.
      WHEN gc_bildirim_tip-hek_zayiat.
        rv_ad = 'HEK / Zayiat Bildirimi'.
      WHEN gc_bildirim_tip-essiz_alma.
        rv_ad = 'Essiz Kimlik ile Alma Bildirimi'.
      WHEN gc_bildirim_tip-essiz_kullanim.
        rv_ad = 'Essiz Kimlik ile Kullanim Bildirimi'.
      WHEN gc_bildirim_tip-essiz_tny_iade.
        rv_ad = 'Essiz Kimlik Tanimsiz Yerden Iade Bildirimi'.
      WHEN gc_bildirim_tip-essiz_tny_verme.
        rv_ad = 'Essiz Kimlik Tanimsiz Yere Verme Bildirimi'.
      WHEN OTHERS.
        rv_ad = iv_tip.  " Fallback
    ENDCASE.
  ENDMETHOD.


  METHOD format_urun_tip.
*--- UI'da asla 'TIBBI_CIHAZ' gibi teknik kod gosterilmez.
    CASE iv_tip.
      WHEN 'TIBBI_CIHAZ'. rv_ad = 'Tibbi Cihaz'.
      WHEN 'ILAC'.        rv_ad = 'Ilac'.
      WHEN 'KOZMETIK'.    rv_ad = 'Kozmetik'.
      WHEN OTHERS.        rv_ad = iv_tip.
    ENDCASE.
  ENDMETHOD.


  METHOD format_takip_tip.
*--- UI'da asla 'LOT' / 'SERI' teknik kodu yalniz basina gorunmez.
    CASE iv_tip.
      WHEN 'LOT'.   rv_ad = 'Lot Bazli'.
      WHEN 'SERI'.  rv_ad = 'Seri Bazli'.
      WHEN 'TEKIL'. rv_ad = 'Tekil (UDI) Takip'.
      WHEN OTHERS.  rv_ad = iv_tip.
    ENDCASE.
  ENDMETHOD.


  METHOD _simule_network_delay.
    " Demo'da "servis cagiriyoruz" hissi icin 200-400ms gecikme
    WAIT UP TO '0.3' SECONDS.
  ENDMETHOD.


  METHOD _uret_referans_no.
    DATA: lv_rnd TYPE i.
    CALL FUNCTION 'QF05_RANDOM_INTEGER'
      EXPORTING
        ran_int_max = 9999
        ran_int_min = 1000
      IMPORTING
        ran_int     = lv_rnd.

    rv_ref = |{ sy-datum }{ sy-uzeit }-{ lv_rnd WIDTH = 4 PAD = '0' ALIGN = RIGHT }|.
  ENDMETHOD.

ENDCLASS.

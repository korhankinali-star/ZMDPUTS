*&---------------------------------------------------------------------*
*& Report  ZMDPUTS_DATA_INIT
*&---------------------------------------------------------------------*
*& UTS Demo - 5 mock urunu ZMDPUTS_URUN tablosuna yukler.
*& Bu rapor sadece KURULUM sirasinda 1 kez calistirilir.
*& ZMDPUTS_BILD_LOG tablosunu da temizler (istege bagli).
*&---------------------------------------------------------------------*
REPORT zmdputs_data_init.

PARAMETERS:
  p_logclr AS CHECKBOX DEFAULT abap_false,   " Bildirim loglarini da temizle
  p_confir AS CHECKBOX DEFAULT abap_false.   " Onayla (guvenlik)

INITIALIZATION.
  WRITE: / '=== UTS DEMO DATA INIT ==='.

START-OF-SELECTION.

  IF p_confir = abap_false.
    MESSAGE 'Devam etmek icin "Onayla" kutusunu isaretleyin.' TYPE 'E'.
  ENDIF.

  WRITE: / 'Baslandi...'.

  " 1) Urun katalogu sil (tazele)
  DELETE FROM zmdputs_urun.
  COMMIT WORK.
  WRITE: / 'ZMDPUTS_URUN tablosu temizlendi.'.

  " 2) 5 mock urunu yaz
  DATA: lt_urun TYPE STANDARD TABLE OF zmdputs_urun.

  lt_urun = VALUE #(
    ( mandt = sy-mandt uno = '08680001234567' urun_tip = 'TIBBI_CIHAZ'
      urun_adi = 'OrtoFlex Kalca Protezi Model OF-250'
      uretici_adi = 'ACME Medikal Sanayi A.S.'
      barkod_kur = 'GS1' takip_tip = 'LOT' toplam_stok = 150 aktif = 'X' )

    ( mandt = sy-mandt uno = '08680002345678' urun_tip = 'ILAC'
      urun_adi = 'KardioMax 75mg 30 tablet'
      uretici_adi = 'PharmaTek Ilac A.S.'
      barkod_kur = 'GS1' takip_tip = 'LOT' toplam_stok = 8200 aktif = 'X' )

    ( mandt = sy-mandt uno = '08680003456789' urun_tip = 'TIBBI_CIHAZ'
      urun_adi = 'NeuroStim Pacemaker NS-500'
      uretici_adi = 'ACME Medikal Sanayi A.S.'
      barkod_kur = 'HIBCC' takip_tip = 'SERI' toplam_stok = 42 aktif = 'X' )

    ( mandt = sy-mandt uno = '08680004567890' urun_tip = 'KOZMETIK'
      urun_adi = 'DermaCare Nemlendirici Krem 50ml'
      uretici_adi = 'BeautyLab Kozmetik Ltd.'
      barkod_kur = 'GS1' takip_tip = 'LOT' toplam_stok = 3450 gtk = 'EVET' aktif = 'X' )

    ( mandt = sy-mandt uno = '08680005678901' urun_tip = 'TIBBI_CIHAZ'
      urun_adi = 'InsuPump Pro 3 Insulin Pompasi'
      uretici_adi = 'MedicTech Global Inc.'
      barkod_kur = 'GS1' takip_tip = 'TEKIL' toplam_stok = 18 aktif = 'X' )
  ).

  INSERT zmdputs_urun FROM TABLE lt_urun.
  COMMIT WORK.

  WRITE: / |{ sy-dbcnt } adet urun ZMDPUTS_URUN tablosuna yuklendi.|.

  " 3) Bildirim loglari (opsiyonel)
  IF p_logclr = abap_true.
    DELETE FROM zmdputs_bild_log.
    COMMIT WORK.
    WRITE: / 'ZMDPUTS_BILD_LOG tablosu temizlendi.'.
  ENDIF.

  WRITE: /, / '=== KURULUM TAMAMLANDI ==='.
  WRITE: / 'Artik ZMDPUTS transaction kodunu calistirabilirsiniz.'.

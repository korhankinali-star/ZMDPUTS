*&---------------------------------------------------------------------*
*& Include          ZMDPUTS_COMMON_TYPES
*& Aciklama         UTS Demo icin ortak type/struct tanimlari
*&                  Bu include ZMDPUTS_COCKPIT ve ZMDPUTS function
*&                  group'unun TOP include'una eklenir.
*&---------------------------------------------------------------------*
*& Kurulum: SE38 -> Include -> Z  prefix ile olustur
*&---------------------------------------------------------------------*

*-- 1. Temel veri yapisi: Tekil urun request bilgisi (tum bildirimlerde ortak)
TYPES:
  BEGIN OF ty_uts_urun_key,
    uno TYPE char23,                  " Urun Numarasi (GTIN)
    lno TYPE char20,                  " Lot Numarasi
    sno TYPE char20,                  " Seri Numarasi
    adt TYPE i,                       " Adet
    udi TYPE string,                  " Essiz Kimlik (tum yapi)
  END OF ty_uts_urun_key,

  tt_uts_urun_key TYPE STANDARD TABLE OF ty_uts_urun_key WITH EMPTY KEY.

*-- 2. Urun katalog satiri (mock)
TYPES:
  BEGIN OF ty_urun_katalog,
    uno          TYPE char23,
    urun_tip     TYPE char30,
    urun_adi     TYPE char100,
    uretici_adi  TYPE char60,
    barkod_kur   TYPE char10,
    takip_tip    TYPE char10,
    toplam_stok  TYPE i,
    gtk          TYPE char5,
    aktif        TYPE char1,
  END OF ty_urun_katalog,
  tt_urun_katalog TYPE STANDARD TABLE OF ty_urun_katalog WITH EMPTY KEY.

*-- 3. UTS standart servis cevap yapisi (tum bildirimler icin ortak)
TYPES:
  BEGIN OF ty_uts_cevap,
    basarili   TYPE abap_bool,        " X = basarili
    ref_no     TYPE char20,           " UTS referans numarasi
    mesaj      TYPE string,           " Kullaniciya gosterilecek mesaj
    islem_tar  TYPE dats,             " Islem tarihi
    islem_saat TYPE uzeit,            " Islem saati
  END OF ty_uts_cevap.

*-- 4. Tekil Urun Sorgulama cevap yapisi (UTS API'deki SNC entry'sine benzer)
TYPES:
  BEGIN OF ty_tekil_urun_detay,
    uno             TYPE char23,
    lno             TYPE char20,
    sno             TYPE char20,
    adt             TYPE i,
    urt             TYPE char10,      " Uretim tarihi (YYYY-AA-GG)
    skt             TYPE char13,      " Son kullanma (YYYY-AA-GG SS)
    mme             TYPE char100,     " Marka/Model/Etiket
    utp             TYPE char30,      " Urun tipi
    uik             TYPE int8,        " Urun ici kod (UTS)
    uak             TYPE char10,      " Urun ayrim kodu (LOT/SERI)
    kkg             TYPE abap_bool,   " Kayitli kullanima gonderilebilir
    tka             TYPE i,           " Toplam kullanilabilir adet
    kka             TYPE i,           " Kullanilabilir kalan adet
    ius             TYPE i,           " Iptal uretim sebebi
    son_hareket     TYPE char50,      " Son hareket aciklamasi (demo)
    son_sahip_kun   TYPE char60,      " Son sahip kurum adi
  END OF ty_tekil_urun_detay,
  tt_tekil_urun_detay TYPE STANDARD TABLE OF ty_tekil_urun_detay WITH EMPTY KEY.

*-- 5. Urun Sorgulama cevap yapisi (katalog bilgisi)
TYPES:
  BEGIN OF ty_urun_detay,
    uno          TYPE char23,
    urun_adi     TYPE char100,
    urun_tip     TYPE char30,
    uretici_adi  TYPE char60,
    barkod_kur   TYPE char10,
    takip_tip    TYPE char10,
    toplam_stok  TYPE i,
    gtk          TYPE char5,
    aciklama     TYPE string,
  END OF ty_urun_detay,
  tt_urun_detay TYPE STANDARD TABLE OF ty_urun_detay WITH EMPTY KEY.

*-- 6. Tekil Stok Sorgulama cevap yapisi
TYPES:
  BEGIN OF ty_stok_detay,
    uno           TYPE char23,
    lno           TYPE char20,
    sno           TYPE char20,
    urun_adi      TYPE char100,
    stok_adedi    TYPE i,
    urt           TYPE char10,
    skt           TYPE char13,
    sahip_kun     TYPE char60,
    depo_yeri     TYPE char30,
  END OF ty_stok_detay,
  tt_stok_detay TYPE STANDARD TABLE OF ty_stok_detay WITH EMPTY KEY.

*-- 7. Bildirim log tablosu
TYPES: ty_bild_log TYPE zmdputs_bild_log.

*-- 8. Sabitler (bildirim tipleri icin)
CONSTANTS:
  BEGIN OF gc_bildirim_tip,
    uretim              TYPE char30 VALUE 'URETIM',
    ithalat             TYPE char30 VALUE 'ITHALAT',
    yetkili_ithalat     TYPE char30 VALUE 'YETKILI_BAYI_ITHALAT',
    verme               TYPE char30 VALUE 'VERME',
    kozmetik_firma_ver  TYPE char30 VALUE 'KOZMETIK_FIRMA_VERME',
    alma                TYPE char30 VALUE 'ALMA',
    tny_verme           TYPE char30 VALUE 'TANIMSIZ_YERE_VERME',
    tny_iade_alma       TYPE char30 VALUE 'TANIMSIZ_YERDEN_IADE',
    kullanim            TYPE char30 VALUE 'KULLANIM',
    tuketiciye_verme    TYPE char30 VALUE 'TUKETICIYE_VERME',
    hek_zayiat          TYPE char30 VALUE 'HEK_ZAYIAT',
    essiz_alma          TYPE char30 VALUE 'ESSIZ_ALMA',
    essiz_kullanim      TYPE char30 VALUE 'ESSIZ_KULLANIM',
    essiz_tny_iade      TYPE char30 VALUE 'ESSIZ_TNY_IADE',
    essiz_tny_verme     TYPE char30 VALUE 'ESSIZ_TNY_VERME',
  END OF gc_bildirim_tip,

  BEGIN OF gc_durum,
    basarili TYPE char1 VALUE 'S',
    hata     TYPE char1 VALUE 'H',
  END OF gc_durum,

  BEGIN OF gc_takip_tip,
    lot   TYPE char10 VALUE 'LOT',
    seri  TYPE char10 VALUE 'SERI',
    tekil TYPE char10 VALUE 'TEKIL',
  END OF gc_takip_tip.

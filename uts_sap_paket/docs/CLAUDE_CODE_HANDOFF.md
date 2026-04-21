# UTS SAP ABAP Demo Paketi — Claude Code Devir Dosyası

> **Bu dosya ne için var?**
> Bu proje başka bir geliştiricinin Claude Code'una devredilecek. Bu dosya, o Claude Code instance'ının projenin tüm tarihini, kararlarını ve kurallarını **tek bir yerden** öğrenebilmesi için hazırlandı. Conversation geçmişinin yerini tutar.
>
> **İlk yapacağın iş:** Bu dosyayı baştan sona okuduktan sonra, paket içindeki `src/` ağacını tara ve `README.md` ile `docs/KURULUM_REHBERI.md` dosyalarını da oku.

---

## İçindekiler

1. [Proje Özeti & Hedef](#1-proje-özeti--hedef)
2. [Paydaş Bağlamı](#2-paydaş-bağlamı)
3. [Kaynak Referanslar](#3-kaynak-referanslar)
4. [Mimari Özet](#4-mimari-özet)
5. [Kritik Tasarım Kararları](#5-kritik-tasarım-kararları)
6. [**MUTLAK KURAL: JSON Kodları UI'da Yok**](#6-mutlak-kural-json-kodları-uıda-yok)
7. [Paket İçeriği — Dosya Dosya](#7-paket-içeriği--dosya-dosya)
8. [18 Function Module — İsim Kısaltma Mantığı](#8-18-function-module--isim-kısaltma-mantığı)
9. [Mock Veri Seti](#9-mock-veri-seti)
10. [Veri Akışı — Bir Bildirim Nasıl Gerçekleşiyor?](#10-veri-akışı--bir-bildirim-nasıl-gerçekleşiyor)
11. [UI Katmanı — Nasıl Türkçeleştirildi](#11-ui-katmanı--nasıl-türkçeleştirildi)
12. [Kurulum Adımları Özeti](#12-kurulum-adımları-özeti)
13. [Bilinen Eksikler & TODO Listesi](#13-bilinen-eksikler--todo-listesi)
14. [Genişletme Rehberi](#14-genişletme-rehberi)
15. [Üretime Geçiş Yol Haritası](#15-üretime-geçiş-yol-haritası)
16. [Sunum Günü Akışı](#16-sunum-günü-akışı)
17. [Claude Code için İlk Prompt Örnekleri](#17-claude-code-için-ilk-prompt-örnekleri)
18. [SSS — Geliştirici Perspektifi](#18-sss--geliştirici-perspektifi)

---

## 1. Proje Özeti & Hedef

### 1.1 Nedir?

SAP ABAP ortamında çalışan, **T.C. Sağlık Bakanlığı UTS (Ürün Takip Sistemi)** için hazırlanmış **tam mock bir demo uygulaması**. Transaction kodu: `ZMDPUTS`.

### 1.2 Hangi Amaç?

**Canlı müşteri sunumu için.** Gerçek UTS web servisine hiçbir HTTP çağrısı yapmaz; tüm veriler ABAP kodunda sabit (hardcoded). Amaç müşteriye "sistemimiz SAP içinde bu şekilde çalışacak" hissini vermek — yani UX örneği, mimari değil.

### 1.3 Kapsam

SAP Entegrasyon Platformu (MIP veya SAP Process Orchestration / Integration Suite) üzerinden gerçek UTS servisine bağlanacak mimarinin SAP ABAP tarafındaki **görünen yüzü**. UTS'nin PDF dokümanında tanımlanan **18 iş akışı** (3 sorgulama + 15 bildirim) kapsanır.

### 1.4 Ne Değil?

- Gerçek UTS entegrasyonu DEĞİL (HTTP yok, token yok, sertifika yok)
- Üretime hazır DEĞİL (authorization check yok, retry/resilience yok, audit yetersiz)
- Business logic DEĞİL (stok yönetimi SAP tarafında; demo sadece UX)
- Fiori/UI5 DEĞİL (klasik SAP GUI + SALV, REPORT transaction)

---

## 2. Paydaş Bağlamı

### 2.1 Hasan (Proje Sahibi)

- Pozisyon: Yazılım geliştirici + entegrasyon grup yöneticisi, **MDP GROUP**, İstanbul Kozyatağı
- Ekip: 25 kişilik entegrasyon ekibi
- Uzmanlık: **MIP** (şirketin kendi Integration Suite ürünü), SAP Process Orchestration, SAP Integration Suite
- Dil: Türkçe
- İletişim tarzı: Samimi, doğrudan, detay ve kod örneği tercih eder, madde madde listeler sever

### 2.2 MDP GROUP — İşveren

- Türkiye'nin entegrasyon odaklı yazılım firması
- Ana ürün: **MIP** (Message Integration Platform) — SAP PI/PO/CPI alternatifi
- Büyük kurumsal müşterilerle çalışır: bankalar, üreticiler, sağlık kuruluşları, perakende zincirleri
- UTS entegrasyonunda pazarlama konumu: "SAP'nizden çıkmadan UTS'ye bağlanın, token / retry / logging bizim MIP'te merkezi"

### 2.3 Müşteri (Demo Hedefi)

Henüz tanımlanmadı; tipik profil: SAP ERP / S/4HANA kullanan bir ilaç / tıbbi cihaz / kozmetik üreticisi veya distribütörü. UTS yasal yükümlülüğü olan her firma aday.

### 2.4 Arkadaş (Bu Dosyayı Okuyan)

- Hasan'ın projeyi devrettiği kişi
- Kendi Claude Code instance'ını kullanarak paketi kuracak, test edecek, belki genişletecek
- **Bu dosya o Claude Code için ilk context'tir.**

---

## 3. Kaynak Referanslar

### 3.1 Birincil Spec Dokümanı

**`UTS-PRJ-TakipVeIzlemeWebServisTanimlariDokumani.pdf`**

- Yayınlayan: **TÜBİTAK BİLGEM**
- Sahibi: **T.C. Sağlık Bakanlığı** — Ürün Takip Sistemi
- Uzunluk: ~233 sayfa
- İçerik: 18 SOAP/REST metodunun tam parametre listesi (UNO, LNO, SNO, ADT, URT, SKT, MME, UTP, UIK, UAK, KKG, TKA, KKA, IUS, KUN, BNO, BEN, GIT, UDI, VKN/TCKN)
- Bu paketin request/response struct'ları bu PDF'e **birebir uyumlu** hazırlandı

### 3.2 Referans Uyarlama (C# / Logo ERP)

**`github.com/dogukankosan/UTSLogoEntegrasyon`**

- Logo ERP (Türkiye'nin SAP rakibi ERP sistemi) için yapılmış UTS entegrasyonu
- Teknoloji: C# / .NET, Windows servis
- Bu repo Faz 0'da analiz edildi → **"UTS SAP ABAP Uyarlama Raporu"** üretildi
- Rapor Seçenek A (saf ABAP HTTP client) ve Seçenek B (MIP ara katman üzerinden) mimari karşılaştırması içerir
- **Hasan Seçenek B'yi (MIP) üretim için seçti** — demo paketi ise iki mimariye de uyumlu (ZCL_ZMDPUTS_MOCK → ZCL_UTS_CLIENT swap tek noktadan yapılır)

### 3.3 Önceki Çıktı Dosyaları

- `UTS_SAP_ABAP_Uyarlama_Raporu.md` — Logo repo analizi + SAP mimari önerisi + 10 haftalık sprint planı
- `UTS_SAP_DEMO_PAKET.zip` — bu paketin kendisi
- `UTS_SUNUM_SENARYOSU.md` — müşteri sunumu için 5 perdelik senaryo (bu paketin `docs/` klasöründe de var)

---

## 4. Mimari Özet

### 4.1 Katman Modeli

```
┌──────────────────────────────────────────────────────┐
│  UI Katmanı (ZMDPUTS_COCKPIT)                          │
│  - Transaction ZMDPUTS                                  │
│  - 18 SELECTION-SCREEN (100,101,102, 200-214)        │
│  - SALV grid cockpit + 5 ayrı SALV result screen     │
│  - F4 help (ürün / kurum picker)                     │
│  - Selection texts runtime-assigned (Türkçe)         │
│  - tt_col_label pattern ile ALV kolon Türkçeleri     │
└──────────────────────────────────────────────────────┘
                         ▼ CALL FUNCTION
┌──────────────────────────────────────────────────────┐
│  API Katmanı (Function Group ZMDPUTS)                │
│  - LZMDPUTSTOP include (TYPES + constants)           │
│  - 18 Function Module (F_UTS_*)                      │
│  - Her FM: importing params → mock call → export     │
│  - Hepsi global / senkron / Pass Value               │
└──────────────────────────────────────────────────────┘
                         ▼ CREATE OBJECT / method call
┌──────────────────────────────────────────────────────┐
│  İş Mantığı Katmanı (ZCL_ZMDPUTS_MOCK — singleton)       │
│  - get_urun_katalog( ) — 5 sabit ürün                │
│  - get_tekil_urun( ) — LOT/seri bazlı simüle         │
│  - get_stok( ) — stok simüle                         │
│  - bildirim_ekle_*( ) — ref no üret, log yaz         │
│  - _simule_network_delay( ) — 0.3s WAIT              │
│  - format_bildirim_tip( ) — kod → Türkçe ad          │
│  - format_urun_tip( ) — 'TIBBI_CIHAZ' → 'Tibbi Cihaz'│
│  - format_takip_tip( ) — 'LOT' → 'Lot Bazli'         │
│  - get_kurum_adi( ) — KUN → kurum adı                │
└──────────────────────────────────────────────────────┘
                         ▼ DB
┌──────────────────────────────────────────────────────┐
│  Persistans Katmanı                                  │
│  - ZMDPUTS_URUN      (5 mock ürün — ZMDPUTS_DATA_INIT)   │
│  - ZMDPUTS_BILD_LOG  (her bildirim audit trail)        │
└──────────────────────────────────────────────────────┘
```

### 4.2 Bileşen Sorumluları

| Dosya | Sorumluluğu |
|---|---|
| `ZMDPUTS_COCKPIT` | UI — müşterinin gördüğü tek transaction |
| `ZMDPUTS_DATA_INIT` | Kurulum sırasında mock veriyi DB'ye yükler |
| `ZCL_ZMDPUTS_MOCK` | Tüm iş mantığı + format helpers (upstream tarafı swap edilir) |
| `ZMDPUTS / F_UTS_*` | Müşterinin görüp doğrulayabileceği RFC arayüzü |
| `ZMDPUTS_COMMON_TYPES` | FM'ler ve cockpit arasında paylaşılan tipler |
| `ZMDPUTS_URUN` | Mock ürün mastervera |
| `ZMDPUTS_BILD_LOG` | Yapılan bildirimlerin audit log'u (denetim için) |

### 4.3 Üretime Geçiş Noktası

**Tek değişim noktası: `ZCL_ZMDPUTS_MOCK`.**

Bu class'ın iki alternatifi olacak:
- `ZCL_ZMDPUTS_MOCK` (mevcut) — demo, mock
- `ZCL_UTS_CLIENT_MIP` (gelecek) — MIP entegrasyonu
- `ZCL_UTS_CLIENT_DIRECT` (opsiyonel) — doğrudan UTS servise

Factory metodu üzerinden switch edilir. Diğer katmanlar (UI, API, types, DB tabloları) aynı kalır.

---

## 5. Kritik Tasarım Kararları

### 5.1 Neden Function Module? Neden Global Class Değil?

UTS dokümanındaki web servis metotlarının SAP tarafında doğrudan karşılığı olsun diye. Müşteri dokümanı karşılaştırdığında `UrunSorgulama` → `ZMDPUTS_URUN_SORGULAMA` olarak birebir eşleşme görür. Bu sunumda güven verir.

Ayrıca FM'ler **remote-enabled (RFC) yapılabilir** — başka bir SAP sisteminden veya dış sistemden çağrılabilir. Bu opsiyon açık kalsın.

### 5.2 Neden Singleton Mock?

Tüm FM'lerin aynı veri havuzuna bakması için. Her FM yeni instance yaratsaydı, bir FM'de yapılan bildirim log'u başka FM'den görünmeyecekti. Singleton ile tek state.

```abap
go_mock = zcl_zmdputs_mock=>get_instance( ).
```

### 5.3 Neden `CREATE PRIVATE`?

Singleton pattern'in ABAP'te doğru uygulanması için. `CREATE OBJECT zcl_zmdputs_mock` dışarıdan çağrılabilse, 2. instance oluşur ve state kirlenir.

### 5.4 Neden 0.3 Saniye Gecikme?

`WAIT UP TO '0.3' SECONDS.`

Demo'da kullanıcıya "sistem gerçekten UTS'ye gidiyor, bekle" hissi vermek için. Gerçek UTS yanıt süresi ~200-400ms. Bu olmasaydı bildirim anında döner, sahte görünürdü. Yüksek-konsept: "network delay simulation".

### 5.5 Neden SAP'nin FM Adı 30 Karakter Sınırı Var?

ABAP tarihi bir kısıt. 1990'lardan kalma, değişmedi. UTS PDF'te `F_UTS_YETKILI_BAYI_ITHALAT_BILDIRIMI_EKLE` (44 karakter) gibi uzun isimler var. Bunları kısaltmak zorunda kaldık. Kısaltma tablosu Bölüm 8'de.

**Öneri müşteriye:** "SAP'nin sistem kısıtı nedeniyle teknik isimler kısaltıldı, mantık aynı. İsterseniz kendi Z-namespace'inize (`/ZMUSTERI/F_UTS_*`) alıp adlandırabiliriz."

### 5.6 Neden `F_` Prefix (Z_F_ Değil)?

`F_` teknik olarak SAP customer namespace değildir. Ama proje demo'da "UTS metodları gibi görünsün" diye seçildi. Gerçek müşteri kurulumunda bu önek `Z_F_UTS_*` veya `/MUSTERI/F_UTS_*` olarak değişmeli. README'de bu not var.

### 5.7 Neden SALV (Classical ALV Değil)?

- Daha temiz OO API
- Built-in Excel/mail export
- Event handler pattern kolay
- Legacy classical ALV (REUSE_ALV_GRID_DISPLAY) deprecated sayılır

### 5.8 Neden Tek Transaction + 18 Selection Screen (18 Ayrı Transaction Değil)?

- Kullanıcı için tek giriş noktası (`/nZUTS`)
- Cockpit'ten cross-navigation kolay
- 18 transaction müşteriye "kullanıcı dostu değil" hissi verirdi
- Bildirim log'u merkezi bir yerde görülebiliyor

### 5.9 Neden ZMDPUTS_BILD_LOG Tablosu?

- **Denetim için kritik**: Sağlık Bakanlığı denetlemesinde "kim, ne zaman, hangi bildirimi atmış" sorusuna cevap
- Demo'da kullanıcının "baktık, işte 3 bildirim de atılmış" demesini sağlar
- Üretime de taşınacak (orada da kalmalı)

### 5.10 Neden Türkçe Karakter Yok (Kodda)?

ABAP programlarının non-Unicode sistemlerde de çalışması için ASCII karakter kullanıldı. Unicode sistemlerde (S/4HANA) Türkçe karakter kullanılabilirdi, ama paketin her yerde çalışması için ASCII seçildi. Kullanıcıya görünen text element'ler zaten SE38 UI'ında Türkçe karakter kabul eder.

---

## 6. MUTLAK KURAL: JSON Kodları UI'da Yok

### 6.1 Kuralın Metni

**Kullanıcı hiçbir ekranda UTS teknik kodlarını (UNO, LNO, SNO, ADT, URT, SKT, BNO, KUN, GIT, BEN, UDI, MME, UTP, UIK, UAK, KKG, TKA, KKA, IUS, VKN/TCKN) GÖRMEYECEK.** Bunun yerine tam Türkçe ad görecek: "Ürün Numarası", "Lot/Batch Numarası", "Seri/Sıra Numarası", "Adet", "Üretim Tarihi" vs.

Bu kural **hem istek alanlarında, hem dönüş ekranlarında, hem F4 help popup'larında, hem mesaj/popup metinlerinde** geçerli.

### 6.2 Hasan'ın Bu Kural Hakkındaki Yaklaşımı

Hasan sunumda müşterinin teknik karmaşadan uzak, "bu sistem bana yakın" hissi alması istiyor. UNO/LNO gibi 3 harfli enum kodları UTS dokümanının teknik dili — dış dünyaya pazarlanmaz.

**Kural 2. iterasyonda eklendi.** İlk paket teslim edildiğinde Hasan bu kuralı söyledi ve kod buna göre güncellendi. **Sonra 3. iterasyonda bir kez daha pekiştirildi** — devir kararı alınırken kural netleştirildi.

### 6.3 Kural Nasıl Uygulandı?

4 farklı mekanizma:

**(a) Selection screen labels (girdi alanları)**

`INITIALIZATION` bloğunda 97 adet runtime atama:

```abap
%_p200_uno_%_app_%-text = 'Urun Numarasi'.
%_p200_lno_%_app_%-text = 'Lot/Batch Numarasi'.
%_p200_urt_%_app_%-text = 'Uretim Tarihi'.
...
```

Bu ABAP'in **text element**'lerini runtime'da set etmenin resmi yolu. SE38 → Goto → Text Elements → Selection Texts'te boş olsa bile, bu kod INITIALIZATION anında label'ları set eder.

**(b) ALV kolon başlıkları (çıktı tabloları)**

`tt_col_label` type ve `set_alv_labels` FORM pattern'i:

```abap
TYPES: BEGIN OF ty_col_label,
  col TYPE lvc_fname,
  s TYPE scrtext_s, m TYPE scrtext_m, l TYPE scrtext_l,
END OF ty_col_label.

FORM set_alv_labels USING io_alv TYPE REF TO cl_salv_table
                          it_labels TYPE tt_col_label.
  LOOP AT it_labels INTO DATA(ls).
    TRY.
        io_alv->get_columns( )->get_column( ls-col )
          ->set_short_text( ls-s )->set_medium_text( ls-m )->set_long_text( ls-l ).
    CATCH cx_salv_not_found.  " sutun yoksa atla
    ENDTRY.
  ENDLOOP.
ENDFORM.
```

Her `show_*` form'u kendi kolon etiketleri listesi ile bu helper'ı çağırır. 5 farklı ALV için tam etiket seti tanımlandı.

**(c) Enum değeri → Türkçe ad çevirisi**

`ZCL_ZMDPUTS_MOCK` içinde 3 format helper:

```abap
format_bildirim_tip( 'URETIM' )  →  'Uretim Bildirimi'
format_urun_tip( 'TIBBI_CIHAZ' ) →  'Tibbi Cihaz'
format_takip_tip( 'LOT' )        →  'Lot Bazli'
```

Log ekranında ve ürün kataloğu ekranında bu çağrılarak teknik kodlar ekrana hiç yazılmaz — display-only struct'a çevrilmiş hali yazılır.

**(d) F4 help popup kolon başlıkları**

`F4IF_INT_TABLE_VALUE_REQUEST` FM'ine `FIELD_TAB` parametresi (DFIES tipli tablo) verilerek kolon başlıkları kontrol edildi:

```abap
ls_field-fieldname = 'URUN_NO'.
ls_field-scrtext_l = 'Urun Numarasi'.   " popup'ta bu görünür
```

### 6.4 Kontrol Listesi (Review İçin)

Kod review yaparken şu noktaları kontrol et — JSON kodu sızmış mı:

- [ ] Selection screen'de hiçbir parametrenin label'ı boş (SE38 default "P200_UNO" gelir) olmasın
- [ ] `show_*` form'larında ALV'den önce `set_alv_labels` çağrılmış olmalı
- [ ] Enum sahalarını (bildirim_tip, urun_tip, takip_tip, durum) `format_*` helper'ına geçirilmeden doğrudan ekrana yazılmasın
- [ ] `F4IF_INT_TABLE_VALUE_REQUEST` çağrılarında `FIELD_TAB` parametresi dolu olmalı
- [ ] Mesaj ve popup metinlerinde "UNO", "LNO" vb. hiç geçmesin
- [ ] Status bar mesajlarında: "Ref: { ref_no }" tamam ama "UNO: { uno }" olmaz

---

## 7. Paket İçeriği — Dosya Dosya

```
uts_sap_paket/
│
├── README.md                            Paketin genel tanıtımı + FM listesi
│
├── src/
│   ├── ddic/
│   │   ├── 01_ZMDPUTS_URUN.tabl.txt       Mock ürün katalog tablosu tanımı
│   │   └── 02_ZMDPUTS_BILD_LOG.tabl.txt   Bildirim audit log tablosu tanımı
│   │
│   ├── includes/
│   │   └── ZMDPUTS_COMMON_TYPES.abap       Ortak types + gc_bildirim_tip constants
│   │                                    tt_urun_katalog, tt_tekil_urun_detay,
│   │                                    tt_stok_detay, ty_uts_cevap vb.
│   │
│   ├── classes/
│   │   └── ZCL_ZMDPUTS_MOCK.clas.abap       Singleton mock data provider
│   │                                    - 5 ürün katalog (hardcoded)
│   │                                    - LOT/seri simulation
│   │                                    - Stok simulation
│   │                                    - Bildirim ekleme + log
│   │                                    - Referans no generator
│   │                                    - Format helpers (Türkçe çeviri)
│   │
│   ├── fugr/
│   │   ├── LZMDPUTSTOP.abap             Function group TOP include
│   │   │                                (global değişkenler, types import)
│   │   ├── 01_SORGULAMA_FMs.abap        3 sorgulama FM'i
│   │   │                                (kullanıcı SE37'de her birini ayrı yaratır)
│   │   └── 02_BILDIRIM_FMs.abap         15 bildirim FM'i
│   │                                    (her biri import params → mock call → export)
│   │
│   ├── programs/
│   │   ├── ZMDPUTS_COCKPIT.prog.abap      Ana cockpit programı — 1450+ satır
│   │   │                                - 18 SELECTION-SCREEN (100-214)
│   │   │                                - INITIALIZATION: 97 runtime label atama
│   │   │                                - Cockpit SALV + event handler
│   │   │                                - 18 exec_* form (FM çağrısı)
│   │   │                                - show_* form'lar (sonuç gösterim)
│   │   │                                - F4 help custom popup (FIELD_TAB ile)
│   │   │                                - set_alv_labels helper form
│   │   │
│   │   └── ZMDPUTS_DATA_INIT.prog.abap    Mock veriyi DB'ye yükler
│   │                                    (kurulum sırasında 1 kez çalıştırılır)
│   │
│   └── transactions/
│       └── ZMDPUTS.tran.txt                Transaction tanımı (SE93'te manuel)
│
└── docs/
    ├── KURULUM_REHBERI.md               SE11 → SE24 → SE37 → SE38 → SE93 adım adım
    ├── KULLANIM_KILAVUZU.md             Son kullanıcı için 18 işlem açıklaması
    ├── SUNUM_SENARYOSU.md               Müşteri demo 5 perdelik akış + replikler
    ├── SELECTION_TEXTS.md               Tüm selection text'lerin statik listesi (fail-safe)
    └── CLAUDE_CODE_HANDOFF.md           (BU DOSYA)
```

### 7.1 Dosya Boyut ve Satır Özeti

| Dosya | Yaklaşık Satır | Açıklama |
|---|---:|---|
| ZMDPUTS_COCKPIT.prog.abap | 1450 | En büyük dosya — UI mantığı |
| 02_BILDIRIM_FMs.abap | 630 | 15 FM gövdesi |
| ZCL_ZMDPUTS_MOCK.clas.abap | 500 | Mock data + helpers |
| ZMDPUTS_COMMON_TYPES.abap | 170 | Types + constants |
| 01_SORGULAMA_FMs.abap | 160 | 3 FM gövdesi |
| ZMDPUTS_DATA_INIT.prog.abap | 65 | Veri yükleme |
| LZMDPUTSTOP.abap | 20 | FG top include |

**Toplam ABAP kodu: ~3000 satır.**

---

## 8. 18 Function Module — İsim Kısaltma Mantığı

SAP'nin 30 karakter kısıtı nedeniyle PDF'teki uzun isimler kısaltıldı. Müşteriye gösterilirken bu tablo referans olsun:

### 8.1 Sorgulama (3 FM)

| FM (SAP) | Karakter | PDF Orijinali |
|---|---:|---|
| `ZMDPUTS_URUN_SORGULAMA` | 20 | ZMDPUTS_URUN_SORGULAMA ✓ |
| `ZMDPUTS_TEKIL_URUN_SORGULAMA` | 26 | ZMDPUTS_TEKIL_URUN_SORGULAMA ✓ |
| `ZMDPUTS_TEKIL_STOK_SORGULA` | 24 | ZMDPUTS_TEKIL_STOK_SORGULAMA (birini kısaltıldı) |

### 8.2 Bildirim (15 FM) — Kısaltma Tablosu

| FM (SAP) | Karakter | PDF Orijinali | Kısaltma Sebebi |
|---|---:|---|---|
| `ZMDPUTS_URETIM_BILDIRIMI_EKLE` | 27 | ZMDPUTS_URETIM_BILDIRIMI_EKLE ✓ | — |
| `ZMDPUTS_ITHALAT_BILDIRIMI_EKLE` | 28 | ZMDPUTS_ITHALAT_BILDIRIMI_EKLE ✓ | — |
| `ZMDPUTS_YETKILI_ITHALAT_EKLE` | 26 | F_UTS_YETKILI_BAYI_ITHALAT_BILDIRIMI_EKLE | "BAYI" ve "BILDIRIMI" atıldı |
| `ZMDPUTS_VERME_BILDIRIMI_EKLE` | 26 | ZMDPUTS_VERME_BILDIRIMI_EKLE ✓ | — |
| `ZMDPUTS_KOZ_FIRMA_VERME_EKLE` | 26 | F_UTS_KOZMETIK_FIRMA_VERME_BILDIRIMI_EKLE | "KOZMETIK"→"KOZ", "BILDIRIMI" atıldı |
| `ZMDPUTS_ALMA_BILDIRIMI_EKLE` | 25 | ZMDPUTS_ALMA_BILDIRIMI_EKLE ✓ | — |
| `ZMDPUTS_TNY_VERME_EKLE` | 20 | F_UTS_TANIMSIZ_YERE_VERME_BILDIRIMI_EKLE | "TANIMSIZ_YERE"→"TNY" |
| `ZMDPUTS_TNY_IADE_ALMA_EKLE` | 24 | F_UTS_TANIMSIZ_YERDEN_IADE_ALMA_BILDIRIMI_EKLE | "TANIMSIZ_YERDEN"→"TNY" |
| `ZMDPUTS_KULLANIM_BILDIRIM_EKLE` | 28 | F_UTS_KULLANIM_BILDIRIMI_EKLE | "BILDIRIMI"→"BILDIRIM" |
| `ZMDPUTS_TUKETICIYE_VERME_EKLE` | 27 | F_UTS_TUKETICIYE_VERME_BILDIRIMI_EKLE | "BILDIRIMI" atıldı |
| `ZMDPUTS_HEK_ZAYIAT_BILD_EKLE` | 26 | F_UTS_HEK_ZAYIAT_BILDIRIM_EKLE | "BILDIRIM"→"BILD" |
| `ZMDPUTS_ESSIZ_ALMA_BILD_EKLE` | 26 | F_UTS_ESSIZ_KIMLIK_BILGISI_ALMA_BILDIRIMI_EKLE | "KIMLIK_BILGISI_" atıldı |
| `ZMDPUTS_ESSIZ_KULLANIM_EKLE` | 25 | F_UTS_ESSIZ_KIMLIK_BILGISI_KULLANIM_BILDIRIMI_EKLE | agresif kısaltma |
| `ZMDPUTS_ESSIZ_TNY_IADE_EKLE` | 25 | F_UTS_ESSIZ_KIMLIK_BILGISI_TANIMSIZ_YERDEN_IADE_ALMA_BILDIRIMI_EKLE | agresif kısaltma |
| `ZMDPUTS_ESSIZ_TNY_VERME_EKLE` | 26 | F_UTS_ESSIZ_KIMLIK_BILGISI_TANIMSIZ_YERE_VERME_BILDIRIMI_EKLE | agresif kısaltma |

Hiçbir FM 30 karakteri aşmıyor — aktivasyon sorun çıkarmaz.

### 8.3 FM Parametreleri Değişmedi

İsimler kısaldı ama parametre seti UTS PDF'ine birebir uyumlu. Müşteri doğrulayabilir.

---

## 9. Mock Veri Seti

### 9.1 5 Sabit Ürün

`ZCL_ZMDPUTS_MOCK->get_urun_katalog( )` içinde hardcoded:

| UNO (GTIN) | Ad | Tip | Takip | Stok | Özellik |
|---|---|---|---|---:|---|
| 08680001234567 | OrtoFlex Kalça Protezi OF-250 | TIBBI_CIHAZ | LOT | 150 | 2 LOT varyantı (LOT2025A001, LOT2025A002) |
| 08680002345678 | KardioMax 75mg 30 tablet | ILAC | LOT | 8200 | 2 LOT (KM25B15, KM25B16) |
| 08680003456789 | NeuroStim Pacemaker NS-500 | TIBBI_CIHAZ | SERI | 42 | 2 seri varyantı |
| 08680004567890 | DermaCare Krem 50ml | KOZMETIK | LOT | 3450 | GTK=EVET (gönüllü takip) |
| 08680005678901 | InsuPump Pro 3 | TIBBI_CIHAZ | TEKIL | 18 | UDI takipli |

5 ürün **bilinçli olarak farklı** seçildi — müşteriye her ürün tipi + takip yöntemi kombinasyonu gösterilsin.

### 9.2 Mock Kurum Listesi

`ZCL_ZMDPUTS_MOCK->get_kurum_listesi( )`:

- Ankara Eğitim Hastanesi
- İstanbul Üniversitesi Tıp Fakültesi
- Ecza Deposu Merkez A.Ş.
- Sağlık Ecz. Koop.
- BeautyLab Kozmetik Ltd.

Verme/alma bildirimlerinde F4 help'ten seçilir.

### 9.3 Network Delay

Tüm mock çağrılarda:

```abap
CALL METHOD me->_simule_network_delay.  " WAIT UP TO '0.3' SECONDS
```

Demo için kritik — anında dönerse sahte görünür.

### 9.4 Referans No Formatı

```
20260420143521-7842
│        │      │
YYYY     HHMMSS  random 4 hane
MMDD
```

Her başarılı bildirimde yeni ref no üretilir. Duplicate olma ihtimali teorik olarak var (aynı saniyede aynı random), ama demo için sorun değil.

---

## 10. Veri Akışı — Bir Bildirim Nasıl Gerçekleşiyor?

**Senaryo: Kullanıcı "Üretim Bildirimi Ekle" yapıyor.**

```
1. Kullanıcı /nZUTS yazar
   → ZMDPUTS_COCKPIT program START-OF-SELECTION tetiklenir
   → go_mock = zcl_zmdputs_mock=>get_instance( )
   → build_menu( ) gt_menu tablosunu doldurur (18 satır)
   → show_main_cockpit( ) SALV'i gösterir

2. Kullanıcı "Üretim Bildirimi Ekle" üzerine çift tıklar
   → lcl_event_handler->on_double_click tetiklenir
   → row = 4, gt_menu[4]-islem_kodu = 'URETIM_BILD'
   → PERFORM process_selection USING 'URETIM_BILD'

3. process_selection formu
   → CASE iv_islem_kodu = 'URETIM_BILD'
   → CALL SELECTION-SCREEN 200 STARTING AT 10 3
   → Ekranda Türkçe label'lı selection screen açılır:
     * Ürün Numarası  (P200_UNO)
     * Lot/Batch Numarası (P200_LNO)
     * Seri/Sıra Numarası (P200_SNO)
     * Üretim Tarihi (P200_URT)
     * Son Kullanma Tarihi (P200_SKT)
     * Adet (P200_ADT)
     * Eşsiz Kimlik (UDI) (P200_UDI)

4. Kullanıcı P200_UNO'da F4 basar
   → AT SELECTION-SCREEN ON VALUE-REQUEST FOR p200_uno tetiklenir
   → PERFORM f4_uno CHANGING p200_uno
   → 5 ürün FIELD_TAB ile Türkçe kolon başlıklı popup'ta
   → Kullanıcı OrtoFlex seçer → p200_uno = '08680001234567'

5. Kullanıcı alanları doldurup F8 basar
   → CALL SELECTION-SCREEN sy-subrc = 0 döner
   → PERFORM exec_uretim

6. exec_uretim formu
   → CALL FUNCTION 'ZMDPUTS_URETIM_BILDIRIMI_EKLE' ...
     EXPORTING iv_uno = p200_uno iv_lno = p200_lno ...

7. FM ZMDPUTS_URETIM_BILDIRIMI_EKLE
   → ZCL_ZMDPUTS_MOCK=>get_instance( )->bildirim_ekle_uretim( ... )

8. ZCL_ZMDPUTS_MOCK->bildirim_ekle_uretim
   → _simule_network_delay( )  ← 0.3 saniye bekleme
   → _uret_referans_no( )      ← 20260420143521-7842 üretilir
   → INSERT ZMDPUTS_BILD_LOG      ← log kaydı atılır
   → COMMIT WORK
   → RETURN ty_uts_cevap (başarılı, ref_no, zaman)

9. FM importing params döner → exec_uretim formu
   → PERFORM show_bildirim_sonuc USING ls_cevap

10. show_bildirim_sonuc
    → CALL FUNCTION 'POPUP_TO_INFORM'
    → "BILDIRIM BAŞARILI — Referans No: 20260420143521-7842" popup
    → MESSAGE S tipi status bar mesajı

11. Kullanıcı OK'e basar → tekrar cockpit'te

12. Kullanıcı "Bildirim Loglari" butonuna basar
    → on_user_command FOR e_salv_function = 'LOG'
    → PERFORM show_log
    → ZCL_ZMDPUTS_MOCK->get_bildirim_loglari( 200 )
    → SELECT ZMDPUTS_BILD_LOG, son 200 kayıt
    → display_struct'a çevir (format_bildirim_tip, format_durum, kurum_adi çöz)
    → SALV'de Türkçeleştirilmiş kolonlarla göster
```

Bu akış demo'nun omurgası. Her bildirim FM'i benzer şekilde çalışır.

---

## 11. UI Katmanı — Nasıl Türkçeleştirildi

### 11.1 Selection Screen Runtime Labels

ABAP'te bir parametrenin label'ı 3 şekilde set edilir:

1. **Static (SE38 → Goto → Text Elements → Selection Texts)** — manuel UI'dan girilir, text pool'a kaydolur
2. **Runtime** — `%_<param>_%_app_%-text = '...'.` INITIALIZATION'da
3. **Hiç set edilmezse** → SAP default olarak parametre tech adını büyük harfle gösterir (`P200_UNO` → "P200 UNO")

Bu paket **runtime atamayı kullanıyor**. Sebep: Text pool transport ile taşınmazsa kaybolur; runtime kod transport ile garanti. `docs/SELECTION_TEXTS.md` dosyasında aynı label'lar statik backup olarak listelendi.

**Syntax detayı:**
```abap
%_<parameter_name>_%_app_%-text = 'Yeni Label'.
```

Bu özel değişken adı SAP'nin kendi internal text pool erişimi. Başka hiçbir yerde dokümante edilmez ama çalışır (SDN'de yıllar öncesi forum post'larında geçer).

### 11.2 SALV Kolon Başlıkları

`cl_salv_table` her kolonun 3 farklı uzunluk label'ını destekler:

- `set_short_text( )` — genelde 10 karakter, küçük ekranda
- `set_medium_text( )` — 20 karakter
- `set_long_text( )` — 40 karakter, wide layout

Kullanıcı ekran genişliğine göre SAP otomatik en uygun olanı seçer. 3'ünü de Türkçe set ettik.

### 11.3 ALV'de Teknik Kolon Gizleme

Cockpit ana ekranda `ISLEM_KODU` ('URETIM_BILD') ve `FM_ADI` ('ZMDPUTS_URETIM_BILDIRIMI_EKLE') kolonları gizlendi:

```abap
lo_col = lo_cols->get_column( 'ISLEM_KODU' ).
lo_col->set_visible( abap_false ).
```

Kullanıcı sadece sıra no, ikon, kategori, açıklama görür. Event handler'da `row` değerini `gt_menu[row]-islem_kodu` ile internal olarak okur.

### 11.4 Enum Değeri → Türkçe Ad

Log tablosunda `BILDIRIM_TIP` sahası 'URETIM', 'ITHALAT' gibi kodlar tutuyor. Ekrana yazarken:

```abap
bildirim_tip_tr = go_mock->format_bildirim_tip( ls_l-bildirim_tip ).
" 'URETIM' → 'Uretim Bildirimi'
```

`ty_log_display` struct'ında `bildirim_tip_tr` adında ayrı bir saha var — asıl tabloyu kirletmeden sadece ekran için. Aynı pattern `durum` ('S'/'H' → 'Basarili'/'Hatali') ve `kurum_adi` (KUN → adı çöz) için de kullanılıyor.

Ürün kataloğunda aynı pattern: `ty_urun_dsp` display-struct'ı kullanılıyor, `URUN_TIP` ve `TAKIP_TIP` sahaları `format_*` helper'larından geçiyor.

### 11.5 F4 Help FIELD_TAB Tekniği

`F4IF_INT_TABLE_VALUE_REQUEST` FM'ine normalde sadece `VALUE_TAB` ve `RETFIELD` verilir. Ama `FIELD_TAB` parametresi de destekleniyor — `DFIES` kayıtları (DDIC alan meta data) ile kolon başlıklarını override eder:

```abap
ls_field-fieldname = 'URUN_NO'.     " struct alan adı
ls_field-inttype   = 'C'.
ls_field-intlen    = 23.
ls_field-outputlen = 23.
ls_field-scrtext_l = 'Urun Numarasi'.  ← popup'ta bu görünür
APPEND ls_field TO lt_fields.
```

Bu sayede popup'ta "URUN_NO" yerine "Urun Numarasi" etiketi görünür. DDIC data element yaratmak zorunda kalmadık.

---

## 12. Kurulum Adımları Özeti

Detaylar `docs/KURULUM_REHBERI.md`'de. Özet:

1. **SE80** — Package `ZPCK_ZMDPUTS` yarat (veya `$TMP` local)
2. **SE11** — 2 tablo yarat: `ZMDPUTS_URUN`, `ZMDPUTS_BILD_LOG`
3. **SE38** — Include yarat: `ZMDPUTS_COMMON_TYPES`
4. **SE24** — Global class yarat: `ZCL_ZMDPUTS_MOCK`
5. **SE80** — Function group yarat: `ZMDPUTS`
6. **SE37** — 18 FM yarat (`F_UTS_*`)
7. **SE38** — 2 rapor yarat: `ZMDPUTS_COCKPIT`, `ZMDPUTS_DATA_INIT`
8. **SE93** — Transaction yarat: `ZMDPUTS`
9. `ZMDPUTS_DATA_INIT`'i tick'lerle çalıştır
10. `/nZUTS` → demo hazır

**Tahmini kurulum süresi: 30-45 dakika** (çoğu SE37'de 18 FM'i manuel yaratmada geçiyor; copy-paste ile hızlandırılabilir).

### 12.1 Kurulum Sırasında Dikkat

- **Aktivasyon sırası önemli:** önce types → sonra class → sonra FG → sonra FM → sonra report
- **Hata:** "TY_URUN_DETAY is unknown" → ZMDPUTS_COMMON_TYPES aktif değil
- **Hata:** "ZCL_ZMDPUTS_MOCK has no public method FORMAT_URUN_TIP" → class son değişikliklerden sonra yeniden aktive edilmedi
- **Hata:** `F_UTS_*` FM'inde "TY_UTS_CEVAP unknown" → FG include types import etmedi → LZMDPUTSTOP'ta `INCLUDE ZMDPUTS_COMMON_TYPES.` var mı kontrol et
- **Hata:** Cockpit programında "%_p200_uno_%_app_%-text not assignable" → eski ABAP sürümü (7.02 öncesi) olabilir; bu syntax 7.4+ ile çalışır. Alternatif: SE38 → Text Elements → Selection Texts ile statik gir

---

## 13. Bilinen Eksikler & TODO Listesi

### 13.1 Demo Kapsamı Dışı (Bilinçli)

- ❌ Gerçek UTS servis çağrısı (amaç mock)
- ❌ SSL sertifika / token yönetimi (MIP'in sorumluluğu)
- ❌ Retry / exception handling detaylı (demo için 2-3 basit case)
- ❌ Authorization check (S_TCODE + S_DEVELOP dışında özel obje yok)
- ❌ Fiori / UI5 versiyonu (klasik SAP GUI)
- ❌ Değişim yönetimi / approval workflow
- ❌ Multi-currency / multi-language (tek dil TR)
- ❌ BAdI / enhancement point — entegrasyona kapalı

### 13.2 Üretim Öncesi Yapılmalı

- [ ] **`ZCL_UTS_CLIENT_MIP` yazılması** — HTTP client + MIP endpoint
- [ ] **Error handling genişletilmesi** — timeout, 401/403/429/5xx senaryoları
- [ ] **Retry mekanizması** — exponential backoff
- [ ] **Idempotency** — aynı bildirim tekrar gönderilirse duplicate oluşturmamalı
- [ ] **Transport request management** — SAP Change & Transport System entegrasyonu
- [ ] **Authorization object** yaratılması: `ZMDPUTS_OPER` (ACTVT 02=ekle, 03=göster; BILD_TIP filtreleme)
- [ ] **VF03 / VL03N enhancement** — fatura/irsaliye kaydı sonrası otomatik bildirim
- [ ] **MIP tarafında Credential Store entegrasyonu** — her BUKRS için ayrı token
- [ ] **SAP WebClient / Fiori varyantı** (opsiyonel, pazar ihtiyacına göre)

### 13.3 Hemen Yapılabilecek İyileştirmeler

- [ ] `ZMDPUTS_IPTAL_BILDIRIMI` FM'i eklenebilir (UTS PDF bölüm 3.2)
- [ ] Daha çok mock ürün (10-20 ürün)
- [ ] Log ekranına tarih filtresi (select-options)
- [ ] Log ekranından bildirim detay drill-down (double-click → detay popup)
- [ ] Excel export için `cl_salv_table->get_functions( )->set_all( abap_true )` zaten açık — test edilmeli
- [ ] FM'leri `REMOTE-ENABLED` yapmak — başka SAP'den çağrılabilir
- [ ] Classical TOP-OF-PAGE ile başlık branding (MDP Group logo ASCII art)

### 13.4 Sunum Öncesi Dikkat Edilmesi

- [ ] `ZMDPUTS_DATA_INIT` bir kere çalıştırılmış mı?
- [ ] `ZMDPUTS_BILD_LOG` temiz mi? (eski sunumlardan kalan kayıt olmasın — `P_LOGCLR` tick'li çalıştır)
- [ ] SAP GUI dili Türkçe set mi?
- [ ] Popup'lar açık mı? (SAP GUI Customizing → Interaction Design)

---

## 14. Genişletme Rehberi

### 14.1 Yeni Bildirim FM'i Ekleme

UTS PDF'te ek bildirim türü var ve müşteri istiyorsa (örn. "Tüketiciden İade Alma"):

**Adımlar:**

1. `ZMDPUTS_COMMON_TYPES` içinde yeni constant ekle:
   ```abap
   gc_bildirim_tip-tuketiciden_iade = 'TUKETICIDEN_IADE'.
   ```

2. `ZCL_ZMDPUTS_MOCK` içinde yeni metot:
   ```abap
   METHODS bildirim_ekle_tuk_iade IMPORTING ... RETURNING ...
   ```
   Gövde mevcut `bildirim_ekle_*` pattern'lerinden birinden kopyala.

3. `ZCL_ZMDPUTS_MOCK->format_bildirim_tip` CASE'ine ekle:
   ```abap
   WHEN gc_bildirim_tip-tuketiciden_iade.
     rv_ad = 'Tuketiciden Iade Alma Bildirimi'.
   ```

4. Yeni FM yarat: `F_UTS_TUK_IADE_EKLE`. Import/export parameters + gövde = mock class çağrısı.

5. Cockpit'e:
   - `gt_menu`'ye yeni satır (kategori = 'Bildirim')
   - Yeni SELECTION-SCREEN (örn. 215)
   - Yeni `t215` title
   - INITIALIZATION'da Türkçe label atamaları **(MUTLAK KURAL: UNO/LNO gibi kod görünmesin)**
   - `process_selection` CASE'ine `WHEN 'TUK_IADE'`
   - Yeni `exec_*` form
   - F4 help gerekiyorsa AT SELECTION-SCREEN ON VALUE-REQUEST tanımla

6. Test ve aktive et.

Bir bildirim ekleme: ~2-3 saat (ilk sefer), sonradan 1 saat.

### 14.2 Yeni Mock Ürün Ekleme

**En kolay yol:**

`ZCL_ZMDPUTS_MOCK->get_urun_katalog( )` içine yeni satır:

```abap
APPEND VALUE ty_urun_detay(
  uno = '08680006789012' urun_tip = 'TIBBI_CIHAZ'
  urun_adi = 'Yeni Ürün Adı'
  uretici_adi = 'Firma'
  barkod_kur = 'GS1' takip_tip = 'LOT'
  toplam_stok = 100 aktif = 'X'
) TO rt_katalog.
```

Opsiyonel: `ZMDPUTS_DATA_INIT` programını da güncelle ki ZMDPUTS_URUN tablosuna da ürün yazılsın.

LOT/seri varyantı eklemek için `get_tekil_urun` metodunu güncelle.

### 14.3 Gerçek UTS Client'a Geçiş

**Tek class swap:**

```abap
" Mevcut (mock):
go_service = zcl_zmdputs_mock=>get_instance( ).

" Üretim (gerçek):
go_service = zcl_uts_client_mip=>get_instance( ).
```

Interface pattern kullanılarak daha temiz yapılabilir:

```abap
INTERFACE zif_uts_service.
  METHODS get_urun_katalog ...
  METHODS bildirim_ekle_uretim ...
  " etc.
ENDINTERFACE.

CLASS zcl_zmdputs_mock IMPLEMENTATION zif_uts_service.
CLASS zcl_uts_client_mip IMPLEMENTATION zif_uts_service.
```

FM'ler `zif_uts_service` tipini referans eder, factory method hangi implementasyonun döneceğini belirler (config tablosundan).

---

## 15. Üretime Geçiş Yol Haritası

Bu paket demo. Üretime geçmek için 3 faz öneriliyor:

### 15.1 Faz 3A: Mock → MIP Client (2-3 hafta)

- `ZCL_UTS_CLIENT_MIP` class'ı yaz
- HTTP client: `cl_http_client=>create_by_destination` veya `cl_rest_http_client`
- SM59 RFC destination: `ZMIP_UTS` (HTTP type G)
- MIP endpoint: `POST /api/uts/uretim-bildirimi` vs.
- Auth: MIP'in Authorization header'ını SM59 destination'da tanımla
- Request serialization: JSON (via `/ui2/cl_json`)
- Response deserialization: ref_no parse et
- Error handling: timeout, 4xx, 5xx, idempotency check
- Unit tests: ABAP Unit ile mock responses

### 15.2 Faz 3B: Fatura/İrsaliye Entegrasyonu (3-4 hafta)

- VF01 sonrası BAdI: `SD_SALES_DOCUMENT_SAVE_CHECK` veya order-to-cash workflow
- VL02N sonrası: delivery_save BAdI
- Otomatik bildirim tetikleme: başarılı kayıttan sonra ZMDPUTS_VERME_BILDIRIMI_EKLE
- Retry queue: SAP tRFC bgRFC ile asenkron
- İstatistik dashboard'u: ST22 / SM21 üzerinden audit

### 15.3 Faz 3C: Operasyonel Dashboard (2-3 hafta)

- `ZMDPUTS_DASHBOARD` transaction: başarı/başarısız oranları, trend, uyarılar
- Fiori Launchpad tile (opsiyonel)
- E-posta alert: başarısız bildirim > X / gün
- MIP monitoring entegrasyonu

**Toplam: 7-10 hafta tam entegrasyon.**

---

## 16. Sunum Günü Akışı

Hasan'ın müşteri karşısında kullanacağı akış. Detay: `docs/SUNUM_SENARYOSU.md`.

### 16.1 Kısa Versiyon (10-15 dk)

1. `/nZUTS` → Cockpit → "Sistemimiz SAP içinde 18 iş akışı sunuyor"
2. **Ürün Kataloğu** butonuna bas → 5 ürün → "3 farklı ürün tipi, farklı takip metotları"
3. **Ürün Sorgulama** → F4 ile OrtoFlex seç → F8 → Ürün detayı
4. **Üretim Bildirimi Ekle** → F4 ile OrtoFlex → LOT, URT, ADT doldur → F8 → **"Başarılı Ref: XXX" popup**
5. **Verme Bildirimi Ekle** → benzer → başka ref no popup
6. **HEK/Zayiat** → senaryo: 5 kutu soğuk zincir kırıldı, bildir
7. **Bildirim Logları** butonuna bas → 3 bildirim listede, zaman damgalı, Türkçeleştirilmiş
8. **Eşsiz Kimlik (UDI) Bildirimi** → tekil cihaz ile → başka ref no
9. Kapanış: "MIP ara katmanı token, retry, monitoring merkezi — SAP tarafında sadece iş mantığı"

### 16.2 Kritik Vurgular

- "SAP dışına çıkmadan bildirimler yapılıyor"
- "Audit trail otomatik, denetime hazır"
- "UDI destekli cihazlar için hazır"
- "Yetkili bayi, kozmetik firma gibi özel akışlar da kapsandı"
- "Gerçek UTS bağlantısı MIP ile 4-6 haftada canlıya alınır"

### 16.3 Beklenebilecek Sorular

**"Gerçek bağlantı nasıl olacak?"**
→ MIP endpoint SM59'da tanımlanır, bu class swap edilir, UI hiç değişmez.

**"Fatura kesince otomatik bildirim olacak mı?"**
→ VF01 BAdI ile tetikleme ikinci fazda. Bu paket manuel işleme odaklı.

**"Hata olursa ne olur?"**
→ Şu an popup ile uyarı. Üretimde: tRFC retry queue + operatör dashboard'u.

**"Çoklu firma için token?"**
→ MIP Credential Store'da BUKRS bazlı token saklanır. SAP tarafı değişmez.

**"Ne kadar sürer?"**
→ Pilot (1 bildirim tipi): 3-4 hafta. Tam kapsam: 10-12 hafta.

---

## 17. Claude Code için İlk Prompt Örnekleri

Arkadaşın projeyi kendi Claude Code'una yüklediğinde şu prompt'larla başlayabilir:

### 17.1 Context Onboarding Prompt

```
Bu repo'yu incelemeni istiyorum. İçinde SAP ABAP ile yazılmış bir UTS
(Ürün Takip Sistemi) demo paketi var. Önce docs/CLAUDE_CODE_HANDOFF.md
dosyasını baştan sona oku, sonra src/ ağacını gez.

Projenin:
1. Ne yaptığını
2. Kimin için olduğunu
3. 18 FM'nin neler olduğunu
4. Hangi kuralların "mutlak" olduğunu

bana kendi sözcüklerinle özetle.
```

### 17.2 Ekleme Prompt'u

```
docs/CLAUDE_CODE_HANDOFF.md'de Bölüm 14.1'deki "Yeni Bildirim FM'i
Ekleme" rehberini uygula. Eklenecek bildirim: "Tüketiciden İade Alma"
— hasta ürünü iade etti, eczane UTS'ye bildirimde bulunuyor.

Gerekli alanlar: Ürün Numarası, Lot/Seri No, Adet, Tüketici TCKN
(opsiyonel), İade Sebebi, Fatura No, Tarih.

MUTLAK KURAL: JSON kodları UI'da gözükmesin (Bölüm 6).
Tüm gerekli dosya değişikliklerini yap, sonra bana özet ver.
```

### 17.3 Üretime Geçiş Başlangıç Prompt'u

```
docs/CLAUDE_CODE_HANDOFF.md'nin Bölüm 15.1 "Faz 3A: Mock → MIP Client"
planına göre, ZCL_UTS_CLIENT_MIP class'ının iskeletini yaz.

HTTP client CL_REST_HTTP_CLIENT kullansın. SM59 destination adı ZMIP_UTS.
JSON serialization için /ui2/cl_json. Mevcut ZCL_ZMDPUTS_MOCK'un interface
metotlarının aynısını implement etsin ki cockpit kod değişmesin.

Error handling: 401 → yeniden authentication, 429 → 2 saniye bekle
retry, 5xx → 3 kez retry exponential backoff, diğer → exception fırlat.

Sadece iskelet, tüm metotları detaylı doldurmaya gerek yok. TODO
yorumlarıyla yerler belirt.
```

### 17.4 Sorun Giderme Prompt'u

```
SE37'de ZMDPUTS_URETIM_BILDIRIMI_EKLE aktive ederken hata alıyorum:
"TY_UTS_CEVAP is unknown. It is neither in one of the specified tables
nor defined by a "TABLES" statement."

docs/CLAUDE_CODE_HANDOFF.md'nin Bölüm 12.1 "Kurulum Sırasında Dikkat"
kısmına bak ve çözümü söyle. Sonra düzeltmemi nasıl yapacağımı adım
adım anlat.
```

### 17.5 Review Prompt'u

```
Bölüm 6.4'teki "JSON Kodları UI'da Yok" kontrol listesi ile kodu
gözden geçir. Şu noktaları taradım:
- ZMDPUTS_COCKPIT.prog.abap'ın her yerinde "UNO", "LNO", "SNO" gibi
  teknik 3-harfli kod string literal olarak UI'a sızmış mı?
- set_alv_labels çağırmayan bir show_* formu var mı?

Bulduklarını raporla. Hiçbir şey bulamazsan da o raporu ver —
clean bill of health.
```

---

## 18. SSS — Geliştirici Perspektifi

### S: Bu paketi doğrudan müşteri sistemine transport edebilir miyim?

**C:** Teorik olarak evet ama **ZPCK_ZMDPUTS package'ı bir development package olduğundan** doğru transport layer'a bağlamak gerek. Müşterinin TMS sistemine bağlı değilsen, Local object ($TMP) olarak geliştir, sonra "Copy to Package" ile customer package'a taşı. Basis ekibiyle koordine et.

### S: UTS'de GS1 dışındaki barkod kuruluşları (HIBCC) desteklenmiyor mu?

**C:** ZMDPUTS_URUN-BARKOD_KUR sahası text — 'GS1' veya 'HIBCC' girilebilir. NeuroStim ürünü HIBCC örneği olarak var. Validation zayıf çünkü demo. Üretimde domain check values ile kısıtlanmalı.

### S: Gerçek UDI parsing nasıl olacak?

**C:** UDI stringi (örn. `010868000567890117250215100IP2025A21IPP-A-25-00003`) GS1 Application Identifier formatında. Parse için `CL_BARCODE_GTIN_PARSER` gibi custom helper gerekir. Demo'da parse yok — UDI string'i gönderdiğin gibi mock tarafında kabul ediyoruz.

### S: "IV_UDI" parametresi neden her FM'de yok?

**C:** UDI sadece tekil takipli ürünler için anlamlı. Üretim/İthalat/Verme/Alma gibi "normal" FM'lerde opsiyonel. Eşsiz Kimlik bildirimleri (F_UTS_ESSIZ_*) özellikle UDI odaklı, orada UNO/LNO/SNO yerine UDI zorunlu.

### S: Client handling — MANDT sahası neden her tabloda var?

**C:** SAP standard — multi-client sistem mimarisi için. Her sorguda otomatik sy-mandt eklenir. ABAP geliştirirken manuel MANDT yazmak yanlış (framework hallediyor), ama tablo tanımında zorunlu.

### S: Gerçek UTS servisi hangi protokolü kullanıyor?

**C:** TÜBİTAK BİLGEM dokümanı SOAP/REST ikisini de destekliyor ama modern entegrasyon için REST önerilir. MIP üzerinden giderken protokol soyutlanır — uygulama JSON görür, MIP UTS'ye hangi protokol lazımsa çevirir.

### S: Bu paket S/4HANA Cloud'da çalışır mı?

**C:** Hayır. S/4HANA Cloud restricted ABAP environment kullanıyor — global class'ta CL_HTTP_CLIENT açık değil, custom tablolar için farklı framework (CDS + RAP) lazım. Bu paket on-premise S/4HANA veya ECC için. Cloud için **BTP ABAP Environment (Steampunk)** veya **CAP/Node.js microservice** önerilir.

### S: ABAP test framework (ABAP Unit) entegrasyonu var mı?

**C:** Yok — demo paket, test yazılmadı. Üretim versiyonunda `zcl_zmdputs_mock` zaten hazır bir mock → test double olarak kullanılabilir. Unit test: `zcl_uts_client_mip` → HTTP mock → response doğrulama.

### S: Paketi abapGit ile export/import yapabilir miyim?

**C:** Evet, **tercih edilen yol**. Tüm objeler Z-namespace olduğu için compatible. Repo URL'i müşteri sistemi ile paylaşılır, abapGit clone + pull ile kurulum 5 dakikaya iner. Kurulum rehberindeki manuel adımlar abapGit olmayan sistemler için.

### S: Dosyalardaki `%_p200_uno_%_app_%-text` syntax'ı garip, bu resmi mi?

**C:** SAP resmi dokümante etmiyor, ama SDN ve ABAP community forumlarında (Horst Keller'in post'larında) 2005'ten beri paylaşılıyor. 7.02+ sürümlerde stable çalışıyor. Daha güvenli yol: SE38 → Goto → Text Elements'te statik selection texts de doldur. `SELECTION_TEXTS.md` bu listeyi içeriyor — runtime + static çift güvenlik.

### S: NEP 'BILDIRIM' (GP 1980'ler tarihçeliği) üzerine 'Bildirim' olsa olmaz mıydı?

**C:** ABAP'in ID'leri ALL CAPS tutar (konvansiyon). Alan isimleri her zaman upper case. Ama kullanıcı-görünür metinler (scrtext_l, title, list_header) Türkçe yazılır: "Bildirim Tipi". Bu paket bu konvansiyona uyar.

---

## Kapanış Notu

Bu paket **pazarlama + mimari örnek** amaçlıdır. Kod production-grade değil ama production-inspired — üretime geçerken %70 yapı korunur, %30 (mock class, authorization, error handling, retry) yeniden yazılır.

**Hasan'ın kilit mesajı:** "Sunumda müşteriyi ikna etmek için, teknik karmaşayı arka plana at, kullanıcı ergonomisi ön planda tut. SAP'ciler 'bu bizim dilimiz' desin."

**JSON Kodu Kuralı özeti:** UNO/LNO/SNO/... asla UI'da görünmez. Bölüm 6'ya sık sık geri dön.

İyi çalışmalar!

---

**Paket Versiyonu:** 1.1 (JSON→Türkçe UI kuralı 3. iterasyonda tamamen uygulandı)
**Tarih:** 2026-04-20
**Hazırlayan:** MDP Group / Hasan (+ Claude asistanlık)
**Dosya yaklaşık:** 1100 satır handoff + 3000 satır ABAP kodu

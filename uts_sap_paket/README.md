# UTS (Ürün Takip Sistemi) Demo — SAP ABAP Paketi

> **Proje türü:** Canlı müşteri sunumu için mock/demo uygulaması
> **Hedef sistem:** SAP ERP / S/4HANA (NW 7.40+ veya 7.5+)
> **Servis bağımlılığı:** YOK — tüm veriler ABAP tarafında sabit kodlu
> **Transaction Code:** `ZMDPUTS`

> ⚠️ **MUTLAK KURAL — BU PAKETTE GÜÇLÜ GEÇERLİ:**
> Kullanıcı hiçbir ekranda UTS teknik kodlarını (UNO, LNO, SNO, ADT, URT, SKT, BNO, KUN, GIT, BEN, UDI, MME, UTP, UIK, UAK, KKG, TKA, KKA, IUS) GÖRMEZ. Her zaman tam Türkçe adlar ("Ürün Numarası", "Lot/Batch Numarası", "Adet", "Üretim Tarihi" vs.) gösterilir. Detay: `docs/CLAUDE_CODE_HANDOFF.md` § 6.

---

## 👉 BAŞKA BİR CLAUDE CODE'A DEVİR?

Bu projeyi başka bir geliştiricinin Claude Code'una yüklüyorsan:

1. **`docs/CLAUDE_CODE_HANDOFF.md`** dosyasını ilk önce o Claude'a okut (~1100 satır, 18 bölüm — projenin tüm hikayesi, kararları, kuralları)
2. Sonra bu README'yi ve `docs/KURULUM_REHBERI.md`'yi okut
3. Kaynak ağacını `src/` altından tara
4. Hazır. O Claude, projenin tüm context'ine sahip.

---

## 1. Paket İçeriği

```
uts_sap_paket/
├── src/
│   ├── ddic/
│   │   ├── 01_ZMDPUTS_URUN.tabl.txt         Mock ürün kataloğu tablosu
│   │   └── 02_ZMDPUTS_BILD_LOG.tabl.txt     Bildirim audit log tablosu
│   │
│   ├── includes/
│   │   └── ZMDPUTS_COMMON_TYPES.abap         Ortak type/struct tanımları
│   │
│   ├── classes/
│   │   └── ZCL_ZMDPUTS_MOCK.clas.abap         Mock data provider (5 ürün)
│   │
│   ├── fugr/
│   │   ├── LZMDPUTSTOP.abap               Function group TOP include
│   │   ├── 01_SORGULAMA_FMs.abap          3 sorgulama FM'i
│   │   └── 02_BILDIRIM_FMs.abap           15 bildirim FM'i
│   │
│   ├── programs/
│   │   ├── ZMDPUTS_COCKPIT.prog.abap        Ana cockpit programı
│   │   └── ZMDPUTS_DATA_INIT.prog.abap      Mock veri yükleme
│   │
│   └── transactions/
│       └── ZMDPUTS.tran.txt                  Transaction tanımı
│
└── docs/
    ├── KURULUM_REHBERI.md                 Adım adım kurulum
    ├── KULLANIM_KILAVUZU.md               Son kullanıcı kılavuzu
    └── SUNUM_SENARYOSU.md                 Müşteri demo akışı
```

---

## 2. 18 Fonksiyon Modülü — Tam Liste

### Sorgulama (3)

| Sıra | FM Adı | Açıklama |
|---|---|---|
| 1 | `ZMDPUTS_URUN_SORGULAMA` | UNO/GTIN ile ürün katalog bilgisi |
| 2 | `ZMDPUTS_TEKIL_URUN_SORGULAMA` | UNO+LNO+SNO veya UDI ile tekil detay |
| 3 | `ZMDPUTS_TEKIL_STOK_SORGULA` | Ürün+Lot bazlı stok bilgisi |

### Bildirim Ekleme (15)

> **Not:** SAP function module isim limiti 30 karakter olduğu için orijinal PDF'teki bazı uzun isimler kısaltıldı. Aşağıdaki tabloda her ikisi de gösterildi.

| Sıra | FM Adı (SAP) | Orijinal İsim (PDF) |
|---|---|---|
| 4 | `ZMDPUTS_URETIM_BILDIRIMI_EKLE` | ZMDPUTS_URETIM_BILDIRIMI_EKLE |
| 5 | `ZMDPUTS_ITHALAT_BILDIRIMI_EKLE` | ZMDPUTS_ITHALAT_BILDIRIMI_EKLE |
| 6 | `ZMDPUTS_YETKILI_ITHALAT_EKLE` | F_UTS_YETKILI_BAYI_ITHALAT_BILDIRIMI_EKLE |
| 7 | `ZMDPUTS_VERME_BILDIRIMI_EKLE` | ZMDPUTS_VERME_BILDIRIMI_EKLE |
| 8 | `ZMDPUTS_KOZ_FIRMA_VERME_EKLE` | F_UTS_KOZMETIK_FIRMA_VERME_BILDIRIMI_EKLE |
| 9 | `ZMDPUTS_ALMA_BILDIRIMI_EKLE` | ZMDPUTS_ALMA_BILDIRIMI_EKLE |
| 10 | `ZMDPUTS_TNY_VERME_EKLE` | F_UTS_TANIMSIZ_YERE_VERME_BILDIRIMI_EKLE |
| 11 | `ZMDPUTS_TNY_IADE_ALMA_EKLE` | F_UTS_TANIMSIZ_YERDEN_IADE_ALMA_BILDIRIMI_EKLE |
| 12 | `ZMDPUTS_KULLANIM_BILDIRIM_EKLE` | F_UTS_KULLANIM_BILDIRIMI_EKLE |
| 13 | `ZMDPUTS_TUKETICIYE_VERME_EKLE` | F_UTS_TUKETICIYE_VERME_BILDIRIMI_EKLE |
| 14 | `ZMDPUTS_HEK_ZAYIAT_BILD_EKLE` | F_UTS_HEK_ZAYIAT_BILDIRIM_EKLE |
| 15 | `ZMDPUTS_ESSIZ_ALMA_BILD_EKLE` | F_UTS_ESSIZ_KIMLIK_BILGISI_ALMA_BILDIRIMI_EKLE |
| 16 | `ZMDPUTS_ESSIZ_KULLANIM_EKLE` | F_UTS_ESSIZ_KIMLIK_BILGISI_KULLANIM_BILDIRIMI_EKLE |
| 17 | `ZMDPUTS_ESSIZ_TNY_IADE_EKLE` | F_UTS_ESSIZ_KIMLIK_BILGISI_TANIMSIZ_YERDEN_IADE_ALMA_BILDIRIMI_EKLE |
| 18 | `ZMDPUTS_ESSIZ_TNY_VERME_EKLE` | F_UTS_ESSIZ_KIMLIK_BILGISI_TANIMSIZ_YERE_VERME_BILDIRIMI_EKLE |

---

## 3. Mock Ürün Kataloğu (5 Ürün)

| UNO (GTIN) | Ürün Adı | Tip | Takip | Stok |
|---|---|---|---|---|
| 08680001234567 | OrtoFlex Kalça Protezi Model OF-250 | TIBBI_CIHAZ | LOT | 150 |
| 08680002345678 | KardioMax 75mg 30 tablet | ILAC | LOT | 8.200 |
| 08680003456789 | NeuroStim Pacemaker NS-500 | TIBBI_CIHAZ | SERI | 42 |
| 08680004567890 | DermaCare Nemlendirici Krem 50ml | KOZMETIK | LOT | 3.450 |
| 08680005678901 | InsuPump Pro 3 İnsülin Pompası | TIBBI_CIHAZ | TEKIL | 18 |

Her ürünün 2-3 mock LOT/seri numarası hazır — tekil ürün sorgulamasında gerçek hareket simüle edilir (ör. "Son hareket: KULLANIM BILDIRIMI, Son sahip: Ankara Eğitim Hastanesi").

---

## 4. Hızlı Kurulum (Özet)

Detaylı adımlar için `docs/KURULUM_REHBERI.md`'ye bakın.

1. **SE11** — 2 tablo oluştur: `ZMDPUTS_URUN`, `ZMDPUTS_BILD_LOG`
2. **SE38** — Include oluştur: `ZMDPUTS_COMMON_TYPES`
3. **SE24** — Global class oluştur: `ZCL_ZMDPUTS_MOCK`
4. **SE80** — Function group oluştur: `ZMDPUTS`
5. **SE37** — 18 function module oluştur (`ZMDPUTS_*`)
6. **SE38** — 2 rapor oluştur: `ZMDPUTS_COCKPIT`, `ZMDPUTS_DATA_INIT`
7. **SE93** — Transaction oluştur: `ZMDPUTS` → `ZMDPUTS_COCKPIT`
8. **ZMDPUTS_DATA_INIT** bir kere çalıştır (checkbox'ları tikle → F8)
9. **ZMDPUTS** yaz → demo hazır!

---

## 5. Müşteri Sunumu İpuçları

- Kullanıcı cockpit açtığında 18 işlem ikonlu liste görür → sunumu demo etkisi için **Urun Katalogu** butonuna basarak başlayın
- **Urun Sorgulama** → UNO için F4 help basın, 5 ürün popup'ta görünür, birini seçin → katalog detayı ALV'de döner
- **Uretim Bildirimi Ekle** → seçin → UNO+LNO+URT girin → F8 → **popup "Bildirim başarılı - Ref: 20260420120345-4827"**
- **Bildirim Loglari** butonuna basın → az önce atılan bildirim listede görünür (gerçek servis hissi)
- Ekrandaki 0.3 saniye gecikme mock class'ta `WAIT UP TO '0.3' SECONDS` olarak simüle edildi

---

## 6. Tasarım Kararları / Notlar

### 🔴 KRİTİK UI KURALI — JSON Kodları Asla UI'da Görünmez

UTS API dokümanındaki teknik JSON alan kodları (**UNO, LNO, SNO, ADT, URT, SKT, UDI, KUN, BNO, BEN, GIT, MME, UTP, UIK, UAK, KKG, TKA, KKA, IUS, SNC, MSJ**) kullanıcı arayüzünde **hiçbir yerde görünmemelidir**. Hep tam Türkçe isim kullanılır:

| JSON Kodu | UI'da Görünen Tam İsim |
|---|---|
| UNO | Ürün Numarası |
| LNO | Lot/Batch Numarası |
| SNO | Seri/Sıra Numarası |
| ADT | Adet |
| URT | Üretim Tarihi |
| SKT | Son Kullanma Tarihi |
| UDI | Eşsiz Kimlik |
| KUN | Kurum Numarası |
| BNO | Belge Numarası (Fatura/İrsaliye) |
| BEN | Bedelsiz Numune |
| GIT | Gerçek İşlem Tarihi |
| MME | Marka/Model/Etiket |

Bu kural; selection screen parametre etiketlerinde, ALV sonuç ekranı kolon başlıklarında, log tablosu gösterimlerinde (bildirim tipleri dahil), F4 help popup'larında ve ek bilgi metinlerinde uygulanır. Detaylı tablolar için `docs/SELECTION_TEXTS.md`.

### Diğer Kararlar

- Tüm FM'ler **senkron** (asenkron bgRFC kullanılmadı) — canlı demoda yanıt beklemek gerekmiyor
- `ZCL_ZMDPUTS_MOCK` **singleton** — tek instance, tüm FM'ler aynı mock kataloğa bakar
- Referans numarası formatı: `YYYYMMDDHHMMSS-NNNN` (4 haneli random suffix)
- **Network gecikme simülasyonu:** `_simule_network_delay` → 0.3 saniye bekler
- Bildirimler gerçek tabloya yazılır (`ZMDPUTS_BILD_LOG`) → demo sonunda "baktık şu şu bildirimler atıldı" diye gösterebilirsiniz
- Log tablosunda DB'de "URETIM" kısa kod saklanır, ekranda `format_bildirim_tip( )` ile "Üretim Bildirimi" olarak gösterilir
- `ZMDPUTS_DATA_INIT` programı ürün kataloğunu refresh eder — demo öncesi her seferinde çalıştırılabilir

---

## 7. Üretime Geçiş Notu

Bu paket **sunum için** tasarlandı. Gerçek UTS entegrasyonuna geçişte:

1. `ZCL_ZMDPUTS_MOCK`'u `ZCL_UTS_CLIENT` ile değiştirin (CL_HTTP_CLIENT kullanarak gerçek UTS API çağrısı)
2. Token yönetimi: MIP veya SECSTORE üzerinden
3. Error handling: 401/403/429/5xx senaryolarını ekleyin
4. SSL: STRUST'a saglik.gov.tr sertifika zincirini ekleyin
5. `ZMDPUTS_BILD_LOG` üretimde de kalsın — audit trail için kritik

Detaylar için daha önce hazırlanan **"UTS SAP ABAP Uyarlama Raporu"** dokümanına bakın (repo analizi + mimari öneri).

---

**Versiyon:** 1.0
**Tarih:** 2026-04-20
**Hazırlayan:** MDP Group (demo paket)

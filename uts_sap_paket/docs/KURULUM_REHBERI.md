# Kurulum Rehberi — UTS Demo Paketi

Bu rehber, SAP GUI üzerinden sırayla yapılacak adımları anlatır. Yaklaşık süre: **45 dakika - 1 saat**.

---

## ⚠️ Başlamadan Önce — KRİTİK UI KURALI

UTS API dokümanındaki JSON alan kodları (**UNO, LNO, SNO, ADT, URT, SKT, UDI, KUN, BNO, BEN, GIT** vb.) **kullanıcı arayüzünde hiçbir zaman görünmemelidir**. Tüm etiketler tam Türkçe isim olarak kullanılır ("Ürün Numarası", "Lot/Batch Numarası", "Üretim Tarihi", ...).

Bu kural özellikle şu yerlerde kritik:
- **Selection screen parametre etiketleri** → `P200_UNO` altında "Ürün Numarası" görünmeli
- **ALV sonuç kolonları** → "UNO" değil "Ürün Numarası"
- **Log tablosu gösterimi** → "URETIM" değil "Üretim Bildirimi"
- **F4 help popup'ları** → "KUN" değil "Kurum No"
- **Ek bilgi metinleri** → `"URT=..., SKT=..."` değil `"Üretim Tarihi: ...; Son Kullanma: ..."`

Kod bu kurala göre hazırlandı, **ancak Adım 6.1 (Text Elements ayarları) doğru yapılmazsa UI'da teknik kodlar sızar.** Mutlaka `docs/SELECTION_TEXTS.md` dosyasındaki tam listeyi SE38 → Text Elements'te tanımlayın.

---

## Adım 0 — Paket Oluşturma (Opsiyonel ama Önerilen)

Tüm objeleri tek bir paket altında toplamak için:

1. **SE80** aç → Package → `ZPCK_ZMDPUTS` → Create
2. Short text: `UTS Demo - Mock Uygulaması`
3. Software component: `HOME` (veya müşterinin Z-bileşeni)
4. Application component: `CA` (Cross-Application)
5. Transport Layer: Development class'ınıza göre seçin, veya **Local Object** (`$TMP`) seçerek geliştirin

> **Not:** Eğer geliştirmeyi kendi sisteminizde yapıp müşteriye transport olarak taşıyacaksanız, `ZPCK_ZMDPUTS` paketini kullanın ve tüm objeleri bu pakette tutun. Transport oluşturma tarafını basis ekibinizle koordine edin.

---

## Adım 1 — Data Dictionary Objeleri (SE11)

### 1.1 Data Element/Domain Kontrolü

Kodda kullanılan bazı standard data elementler:
- `MANDT` (client)
- `USNAM`, `DATS`, `TIMS`, `UZEIT` (SAP standart)
- `CHAR1, CHAR5, CHAR10, CHAR20, CHAR23, CHAR30, CHAR50, CHAR60, CHAR100, CHAR255`
- `INT4, NUMC10, NUMC20`

**Bunların hepsi SAP standart** — yeni bir data element yaratmaya gerek yok.

### 1.2 ZMDPUTS_URUN Tablosunu Oluştur

1. SE11 → Database Table → `ZMDPUTS_URUN` → Create
2. Short text: `UTS Demo - Mock Urun Katalogu`
3. Delivery and Maintenance tab:
   - Delivery class: **A** (Application table, master data)
   - Maintenance: **Display/Maintenance Allowed**
4. Fields tab (`src/ddic/01_ZMDPUTS_URUN.tabl.txt` dosyasına da bak):

| Field | Key | Initial | DE | Type | Length |
|---|---|---|---|---|---|
| MANDT | ✓ | ✓ | MANDT | CLNT | 3 |
| UNO | ✓ | ✓ | CHAR23 | CHAR | 23 |
| URUN_TIP | | | CHAR30 | CHAR | 30 |
| URUN_ADI | | | CHAR100 | CHAR | 100 |
| URETICI_ADI | | | CHAR60 | CHAR | 60 |
| BARKOD_KUR | | | CHAR10 | CHAR | 10 |
| TAKIP_TIP | | | CHAR10 | CHAR | 10 |
| TOPLAM_STOK | | | INT4 | INT4 | 10 |
| GTK | | | CHAR5 | CHAR | 5 |
| AKTIF | | | CHAR1 | CHAR | 1 |

5. Technical Settings:
   - Data class: **APPL1**
   - Size category: **0**
6. **Activate** (F8 / Ctrl+F3)

### 1.3 ZMDPUTS_BILD_LOG Tablosunu Oluştur

Aynı yöntemle, `src/ddic/02_ZMDPUTS_BILD_LOG.tabl.txt` dosyasındaki alanları gir:

| Field | Key | Type | Length |
|---|---|---|---|
| MANDT | ✓ | CLNT | 3 |
| LOG_ID | ✓ | NUMC | 20 |
| BILDIRIM_TIP | | CHAR | 30 |
| REF_NO | | CHAR | 20 |
| UNO | | CHAR | 23 |
| LNO | | CHAR | 20 |
| SNO | | CHAR | 20 |
| ADT | | INT4 | 10 |
| BNO | | CHAR | 50 |
| KUN | | NUMC | 10 |
| EK_BILGI | | CHAR | 255 |
| DURUM | | CHAR | 1 |
| ERSDA | | DATS | 8 |
| ERZET | | TIMS | 6 |
| ERNAM | | CHAR | 12 |

Technical Settings: Data class **APPL1**, Size category **1**. Aktive et.

---

## Adım 2 — Include Oluşturma

1. **SE38** → Program name: `ZMDPUTS_COMMON_TYPES` → Create
2. Type: **Include program**
3. `src/includes/ZMDPUTS_COMMON_TYPES.abap` dosyasının tüm içeriğini copy-paste et
4. Save (Ctrl+S) → Package: `ZPCK_ZMDPUTS` (veya `$TMP`)
5. Activate

---

## Adım 3 — Global Class (SE24)

1. **SE24** → Class/Interface: `ZCL_ZMDPUTS_MOCK` → Create
2. Type: **Usual ABAP Class**
3. Description: `UTS Demo Mock Data Provider`
4. Instantiation: **Private** (singleton)
5. Save → Package: `ZPCK_ZMDPUTS`
6. **Source code** tab'ına geç (ABAP Editor açılır)
7. `src/classes/ZCL_ZMDPUTS_MOCK.clas.abap` dosyasındaki **CLASS zcl_zmdputs_mock DEFINITION ... ENDCLASS.** bloklarının hepsini copy-paste et
8. Activate (Ctrl+F3)

> **Dikkat:** Include `zmdputs_common_types`'ın DEFINITION içindeki referansı çözümleyebilmesi için Include'un önce aktive edilmiş olması gerekir.

---

## Adım 4 — Function Group (SE80)

1. **SE80** → Function Group: `ZMDPUTS` → Create
2. Short text: `UTS Demo Function Group`
3. Save → Package: `ZPCK_ZMDPUTS`
4. Function group açıldığında sol ağaç görünümünde:
   - **Includes** → `LZMDPUTSTOP` otomatik oluşturuldu
   - Çift tıkla → üst kısma `src/fugr/LZMDPUTSTOP.abap` içeriğini yerleştir
   - Activate

---

## Adım 5 — 18 Function Module (SE37)

Her FM için aşağıdaki adımları tekrarla. **Toplam 18 FM** — zamanı var ama mekanik iş.

### 5.1 İlk FM örneği: `ZMDPUTS_URUN_SORGULAMA`

1. **SE37** → Function Module: `ZMDPUTS_URUN_SORGULAMA` → Create
2. Function group: `ZMDPUTS`
3. Short text: `UTS Urun Sorgulama (Mock)`
4. **Attributes** tab: Processing Type: **Normal Function Module**
5. **Import** tab:
   - Parameter name: `IV_UNO`, Typing: `TYPE`, Associated Type: `CHAR23`, Pass Value: ✓
6. **Export** tab:
   - `ES_URUN` — Typing TYPE — Associated Type `TY_URUN_DETAY` — Pass Value ✓
   - `EV_BULUNDU` — Typing TYPE — Type `ABAP_BOOL` — Pass Value ✓
   - `EV_MESAJ` — Typing TYPE — Type `STRING` — Pass Value ✓
7. **Source code** tab: `src/fugr/01_SORGULAMA_FMs.abap` dosyasından ilk FM'nin gövdesini (FUNCTION ile ENDFUNCTION arası) kopyala
8. Activate

### 5.2 Kalan 17 FM

`src/fugr/01_SORGULAMA_FMs.abap` ve `src/fugr/02_BILDIRIM_FMs.abap` dosyalarındaki her FM için aynı adımları izle. **Her FM'nin interface parametreleri dosyaların içinde yorum satırlarında açıkça belirtildi** (`*"IMPORTING ...` `*"EXPORTING ...` bloklarında).

### 5.3 Hızlı Kopyalama İpucu

Bir FM'yi oluşturduktan sonra "Copy" butonu ile klonlayıp sadece isim + parametreleri değiştirmek çok hızlı olur. 18 FM'yi 45 dakikada bitirebilirsin.

---

## Adım 6 — Raporları Oluştur (SE38)

### 6.1 ZMDPUTS_COCKPIT

1. SE38 → `ZMDPUTS_COCKPIT` → Create
2. Title: `UTS Demo Cockpit`
3. Type: **Executable program**
4. Status: **Test Program**
5. Application: **Cross-application**
6. `src/programs/ZMDPUTS_COCKPIT.prog.abap` içeriğini yapıştır
7. **Text Elements** ayarları — **KRİTİK ADIM**:

   **SE38 → Goto → Text Elements** menüsünden aşağıdakileri tanımla:

   - **Text Symbols sekmesinde** — S10'dan S34'e kadar 18 adet selection screen başlığı. Tam liste için `docs/SELECTION_TEXTS.md` Bölüm 1'e bak.

   - **Selection Texts sekmesinde** — Tüm `P100_UNO`, `P101_LNO`, `P200_URT` vb. parametre etiketleri. **Dictionary Reference kutucuğu işaretsiz olmalı** (kendi metnimiz kullanılsın, SAP'nin standard data element metni değil). Tam liste için `docs/SELECTION_TEXTS.md` Bölüm 2'ye bak.

   > ⚠️ **Kritik:** Bu adım atlanırsa kullanıcı UI'da "P200_URT", "P200_UNO" gibi teknik parametre isimlerini görür — müşteri sunumunda çok kötü görünür. Kodda `INITIALIZATION`'da programatik set mevcut (yeni sürümlerde çalışır) ama failsafe olarak SE38'de de mutlaka tanımlanmalı.

8. Activate

### 6.2 ZMDPUTS_DATA_INIT

1. SE38 → `ZMDPUTS_DATA_INIT` → Create
2. Type: **Executable program**
3. `src/programs/ZMDPUTS_DATA_INIT.prog.abap` içeriğini yapıştır
4. Activate

---

## Adım 7 — Transaction Kodu (SE93)

1. **SE93** → Transaction Code: `ZMDPUTS` → Create
2. Short text: `UTS Demo Cockpit`
3. Start Object: **Program and selection screen (report transaction)**
4. Program: `ZMDPUTS_COCKPIT`
5. Screen number: `1000`
6. GUI support:
   - ✓ SAP GUI for HTML
   - ✓ SAP GUI for Windows
   - ✓ SAP GUI for Java
7. Save → Package: `ZPCK_ZMDPUTS`

---

## Adım 8 — Mock Veri Yükleme

1. Komut kutusuna `/nSE38` yaz → `ZMDPUTS_DATA_INIT` → F8
2. Açılan ekranda:
   - ☑ Onayla (P_CONFIR) → tikle
   - ☐ Bildirim loglarini da temizle (P_LOGCLR) → **ilk yüklemede tikle**
3. F8 (Execute)
4. Mesaj: "5 adet urun ZMDPUTS_URUN tablosuna yuklendi."

**Not:** Kodda mock ürünler zaten `ZCL_ZMDPUTS_MOCK=>get_urun_katalog( )` içinde sabit tanımlı, bu yüzden `ZMDPUTS_DATA_INIT` zorunlu değil — ancak SE11 → ZMDPUTS_URUN'ı müşteriye açıp "ürünlerimiz burada" demek istiyorsan yüklemek şık olur.

---

## Adım 9 — Demo Testi

1. `/nZUTS` → Enter
2. Cockpit açılmalı, 18 satır görünmeli
3. **Urun Katalogu** butonuna (sağ üst) bas → 5 ürün listelenmeli
4. 1. satır (Urun Sorgulama) üzerine **çift tıkla**
5. UNO alanında **F4** bas → mock ürün listesi popup → birini seç → OK → F8
6. Ürün detayı ALV'de gelmeli
7. Ana cockpit'e dön → **Uretim Bildirimi Ekle** üzerine çift tıkla
8. UNO gir, URT bugün, F8 → **"Bildirim başarılı - Ref: XXXXX" popup**
9. Ana cockpit'e dön → **Bildirim Loglari** butonuna bas → az önce yaptığın bildirim görünmeli

Eğer bu akış çalışıyorsa kurulum tamamdır.

---

## Karşılaşılabilecek Hatalar

### "Type ABAP_BOOL not known"
→ ABAP sürüm 7.02'den eski ise `abap_bool` yerine `boolean` kullan, veya data element olarak `ABAP_BOOL_D` tercih et.

### "String templates not supported"
→ 7.02 öncesi için `|{ x }|` string templates yerine `CONCATENATE` kullan. Projede minimal etki var.

### "F_UTS_XXX not found at runtime"
→ Aktif değil. SE80 → ZMDPUTS → Function Modules → activate all.

### "ZMDPUTS_URUN has no data"
→ ZMDPUTS_DATA_INIT'i çalıştırmayı unuttun.

### Popup görünmüyor
→ GUI ayarlarından popup'ları aç (SAP GUI Customizing).

---

## Özet Kurulum Kontrol Listesi

- [ ] ZPCK_ZMDPUTS package oluşturuldu
- [ ] ZMDPUTS_URUN, ZMDPUTS_BILD_LOG tablolari aktive edildi
- [ ] ZMDPUTS_COMMON_TYPES include aktive edildi
- [ ] ZCL_ZMDPUTS_MOCK class aktive edildi
- [ ] ZMDPUTS function group oluşturuldu
- [ ] 18 adet F_UTS_* function module aktive edildi
- [ ] ZMDPUTS_COCKPIT report aktive edildi
- [ ] ZMDPUTS_DATA_INIT report aktive edildi
- [ ] ZMDPUTS transaction code kaydedildi
- [ ] ZMDPUTS_DATA_INIT bir kere çalıştırıldı
- [ ] /nZUTS ile test edildi, bir bildirim başarıyla atıldı

**Hepsi tikli ise demo sunuma hazırsınız.**

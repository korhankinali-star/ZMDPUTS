# Selection Texts ve Text Symbols Referansı

> Bu belge, `ZMDPUTS_COCKPIT` program'ındaki text element'lerin tam listesidir. JSON kodları (UNO, LNO, vs.) UI'da asla görünmemeli — tüm etiketler Türkçe tam isim olarak tanımlanmalıdır.

Program kodu içinde `INITIALIZATION` bloğunda runtime'da selection text'ler set edildi, **ek olarak** SE38 → Goto → Text Elements'te de statik olarak tanımlanması tavsiye edilir (failsafe). Aşağıdaki tablo her iki yerde de kullanılabilir.

---

## 1. Text Symbols (SE38 → Goto → Text Elements → Text Symbols)

Program başlığı ve selection screen block frame başlıkları için:

| Symbol | Text |
|---|---|
| S10 | Ürün Sorgulama Bilgileri |
| S11 | Tekil Ürün Sorgulama (UNO+LNO+SNO veya UDI) |
| S12 | Tekil Stok Sorgulama |
| S20 | Üretim Bildirimi Alanları |
| S21 | İthalat Bildirimi Alanları |
| S22 | Yetkili Bayi İthalat Alanları |
| S23 | Verme Bildirimi Alanları |
| S24 | Kozmetik Firmaya Verme Alanları |
| S25 | Alma Bildirimi Alanları |
| S26 | Tanımsız Yere Verme Alanları |
| S27 | Tanımsız Yerden İade Alma Alanları |
| S28 | Kullanım Bildirimi Alanları |
| S29 | Tüketiciye Verme Alanları |
| S30 | HEK / Zayiat Bildirimi Alanları |
| S31 | Eşsiz Kimlik Alma Alanları |
| S32 | Eşsiz Kimlik Kullanım Alanları |
| S33 | Eşsiz Kimlik Tanımsız İade Alanları |
| S34 | Eşsiz Kimlik Tanımsız Verme Alanları |

---

## 2. Selection Texts (SE38 → Goto → Text Elements → Selection Texts)

Tüm parametreler için. Sağ sütundaki **Dictionary Reference** kutucuğu **işaretsiz** olmalı (Türkçe kendi metnimiz geçerli olsun).

### Sorgulama ekranları (100, 101, 102)

| Parameter | Text |
|---|---|
| P100_UNO | Ürün Numarası |
| P101_UNO | Ürün Numarası |
| P101_LNO | Lot/Batch Numarası |
| P101_SNO | Seri/Sıra Numarası |
| P101_UDI | Eşsiz Kimlik (UDI) |
| P102_UNO | Ürün Numarası |
| P102_LNO | Lot/Batch Numarası |

### Üretim Bildirimi (200)

| Parameter | Text |
|---|---|
| P200_UNO | Ürün Numarası |
| P200_LNO | Lot/Batch Numarası |
| P200_SNO | Seri/Sıra Numarası |
| P200_URT | Üretim Tarihi |
| P200_SKT | Son Kullanma Tarihi |
| P200_ADT | Adet |
| P200_UDI | Eşsiz Kimlik (UDI) |

### İthalat Bildirimi (201)

| Parameter | Text |
|---|---|
| P201_UNO | Ürün Numarası |
| P201_LNO | Lot/Batch Numarası |
| P201_SNO | Seri/Sıra Numarası |
| P201_URT | Üretim Tarihi |
| P201_SKT | Son Kullanma Tarihi |
| P201_ADT | Adet |
| P201_GCB | Gümrük Beyanname No |
| P201_FNO | Fatura/İrsaliye Numarası |

### Yetkili Bayi İthalat (202)

| Parameter | Text |
|---|---|
| P202_UNO | Ürün Numarası |
| P202_LNO | Lot/Batch Numarası |
| P202_SNO | Seri/Sıra Numarası |
| P202_ADT | Adet |
| P202_GCB | Gümrük Beyanname No |
| P202_KUN | Yetkili Bayi Kurum No |

### Verme Bildirimi (203)

| Parameter | Text |
|---|---|
| P203_UNO | Ürün Numarası |
| P203_LNO | Lot/Batch Numarası |
| P203_SNO | Seri/Sıra Numarası |
| P203_ADT | Adet |
| P203_KUN | Alıcı Kurum Numarası |
| P203_BEN | Bedelsiz Numune mi? (EVET/HAYIR) |
| P203_BNO | Belge Numarası (Fatura/İrsaliye) |
| P203_GIT | Gerçek İşlem Tarihi |

### Kozmetik Firmaya Verme (204)

| Parameter | Text |
|---|---|
| P204_UNO | Ürün Numarası |
| P204_LNO | Lot/Batch Numarası |
| P204_ADT | Adet |
| P204_KUN | Kozmetik Firma Kurum No |
| P204_BNO | Belge Numarası (Fatura/İrsaliye) |

### Alma Bildirimi (205)

| Parameter | Text |
|---|---|
| P205_UNO | Ürün Numarası |
| P205_LNO | Lot/Batch Numarası |
| P205_SNO | Seri/Sıra Numarası |
| P205_ADT | Adet |
| P205_KUN | Veren Kurum Numarası |
| P205_BNO | Belge Numarası (Fatura/İrsaliye) |
| P205_GIT | Gerçek İşlem Tarihi |

### Tanımsız Yere Verme (206)

| Parameter | Text |
|---|---|
| P206_UNO | Ürün Numarası |
| P206_LNO | Lot/Batch Numarası |
| P206_ADT | Adet |
| P206_VKN | VKN veya TCKN |
| P206_UNV | Firma/Kişi Unvanı |
| P206_BNO | Belge Numarası (Fatura/İrsaliye) |

### Tanımsız Yerden İade Alma (207)

| Parameter | Text |
|---|---|
| P207_UNO | Ürün Numarası |
| P207_LNO | Lot/Batch Numarası |
| P207_ADT | Adet |
| P207_VKN | VKN veya TCKN |
| P207_UNV | Firma/Kişi Unvanı |
| P207_BNO | Belge Numarası (Fatura/İrsaliye) |

### Kullanım Bildirimi (208)

| Parameter | Text |
|---|---|
| P208_UNO | Ürün Numarası |
| P208_LNO | Lot/Batch Numarası |
| P208_SNO | Seri/Sıra Numarası |
| P208_ADT | Adet |
| P208_TCK | Hasta TC Kimlik No |
| P208_PRO | Protokol Numarası |

### Tüketiciye Verme (209)

| Parameter | Text |
|---|---|
| P209_UNO | Ürün Numarası |
| P209_LNO | Lot/Batch Numarası |
| P209_SNO | Seri/Sıra Numarası |
| P209_ADT | Adet |
| P209_TCK | Tüketici TC Kimlik No |
| P209_REC | Reçete Numarası |
| P209_BNO | Belge Numarası (Fatura/İrsaliye) |

### HEK / Zayiat Bildirimi (210)

| Parameter | Text |
|---|---|
| P210_UNO | Ürün Numarası |
| P210_LNO | Lot/Batch Numarası |
| P210_SNO | Seri/Sıra Numarası |
| P210_ADT | Adet |
| P210_NED | Neden (HEK/ZAYIAT/BOZULMA) |
| P210_ACK | Açıklama |

### Eşsiz Kimlik Alma (211)

| Parameter | Text |
|---|---|
| P211_UDI | Eşsiz Kimlik (UDI barkod) |
| P211_ADT | Adet |
| P211_KUN | Veren Kurum Numarası |
| P211_BNO | Belge Numarası (Fatura/İrsaliye) |

### Eşsiz Kimlik Kullanım (212)

| Parameter | Text |
|---|---|
| P212_UDI | Eşsiz Kimlik (UDI barkod) |
| P212_ADT | Adet |
| P212_TCK | Hasta TC Kimlik No |
| P212_PRO | Protokol Numarası |

### Eşsiz Kimlik Tanımsız İade (213)

| Parameter | Text |
|---|---|
| P213_UDI | Eşsiz Kimlik (UDI barkod) |
| P213_ADT | Adet |
| P213_VKN | VKN veya TCKN |
| P213_UNV | Firma/Kişi Unvanı |
| P213_BNO | Belge Numarası (Fatura/İrsaliye) |

### Eşsiz Kimlik Tanımsız Verme (214)

| Parameter | Text |
|---|---|
| P214_UDI | Eşsiz Kimlik (UDI barkod) |
| P214_ADT | Adet |
| P214_VKN | VKN veya TCKN |
| P214_UNV | Firma/Kişi Unvanı |
| P214_BNO | Belge Numarası (Fatura/İrsaliye) |

---

## 3. Türkçe Karakter Notu

Eğer SAP sisteminiz Türkçe karakterleri (ç, ğ, ı, ö, ş, ü) desteklemiyorsa (çok eski Unicode olmayan sistemler), yukarıdaki metinlerde ASCII karşılıklar kullanın:
- ç → c, Ç → C
- ğ → g, Ğ → G
- ı → i, İ → I
- ö → o, Ö → O
- ş → s, Ş → S
- ü → u, Ü → U

Modern S/4HANA ve NW 7.40+ Unicode sistemlerinde Türkçe karakter sorunsuz çalışır.

---

## 4. Doğrulama

Text elements tanımladıktan sonra:

1. `ZMDPUTS_COCKPIT` programını aktive edin
2. `/nZUTS` çalıştırın
3. Herhangi bir bildirim işlemine çift tıklayın
4. Selection screen'de alan etiketleri **"Ürün Numarası"**, **"Lot/Batch Numarası"** gibi görünmeli
5. Ana cockpit'teki kolonlar **"UTS İşlemi"**, **"İşlem Kategorisi"** gibi olmalı
6. Bildirim sonrası log'a bakınca "Bildirim Tipi" kolonunda **"Üretim Bildirimi"**, **"İthalat Bildirimi"** gibi tam Türkçe isimler yer almalı

**Kullanıcı asla UNO, LNO, SNO, URT, SKT, KUN, BNO gibi kısaltmaları görmemeli.** Görüyorsa selection text veya ALV kolon etiketi eksik demektir.

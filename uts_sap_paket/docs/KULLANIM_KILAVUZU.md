# UTS Demo — Kullanıcı Kılavuzu

> Bu kılavuz SAP kullanıcısı için hazırlandı. Teknik detay minimum.

---

## Başlangıç

1. SAP GUI'ye giriş yapın
2. Komut kutusuna `ZMDPUTS` yazın → Enter
3. UTS Demo Cockpit açılır

---

## Ana Ekran

Ekranda 18 iş akışı görürsünüz:

### Sorgulama (3 işlem) — Mavi ikonlu

UTS sisteminde mevcut bir ürünü veya stoğu öğrenmek istediğinizde kullanın.

### Bildirim Ekleme (15 işlem) — Yeşil ikonlu

UTS'ye yeni bir hareket (üretim, ithalat, verme, alma vs.) bildirmek için kullanın.

---

## Bir İşlem Nasıl Çalıştırılır

### Adım 1: İşlemi Seç
İstediğiniz satır üzerinde **çift tıklayın**.

### Adım 2: Alanları Doldur
Açılan form ekranında gerekli alanları doldurun.

**Zorunlu alanlar** sarı arka planlıdır.

**Ürün Numarası (UNO):** F4 (Possible Values) ile mevcut ürünler listesinden seçebilirsiniz.

**Kurum Numarası (KUN):** F4 ile kurum listesinden seçim yapabilirsiniz.

**Tarih alanları:** Doğrudan yazabilir veya takvim ikonuyla seçebilirsiniz.

### Adım 3: Çalıştır
**F8** tuşuna basın veya araç çubuğundaki yeşil saat ikonuna tıklayın (Execute).

### Adım 4: Sonuç

**Sorgulama işlemlerinde:** Sonuç grid'i açılır, bulunan kayıtları görürsünüz.

**Bildirim işlemlerinde:** Başarılı olursa popup açılır — "Bildirim Başarılı" ve referans numarası görürsünüz. Bu referans numarası UTS sistemindeki kaydınızın tanımlayıcısıdır.

### Adım 5: Ana Ekrana Dön
**Esc** tuşu veya ekrandaki geri ok ile ana cockpit'e dönün.

---

## İşlem Açıklamaları

### 1. Ürün Sorgulama
Bir ürünün genel katalog bilgilerini (üretici, takip tipi, toplam stok) öğrenmek için.
**Gerekli:** UNO

### 2. Tekil Ürün Sorgulama
Belirli bir LOT veya seri numaralı ürünün detaylı geçmişini görmek için.
**Gerekli:** UNO (veya UDI)
**Opsiyonel:** LNO, SNO

### 3. Tekil Stok Sorgulama
Ürünün belirli bir LOT'undaki stok miktarını görmek için.
**Gerekli:** UNO
**Opsiyonel:** LNO

### 4. Üretim Bildirimi
Fabrikada yeni üretilen ürünleri UTS'ye bildirmek için.
**Gerekli:** UNO, LNO veya SNO, URT (üretim tarihi)
**Opsiyonel:** SKT (son kullanma), ADT (adet)

### 5. İthalat Bildirimi
Yurtdışından ithal edilen ürünler için.
**Gerekli:** UNO, LNO/SNO, URT, GCB (gümrük beyanname no), Fatura No

### 6. Yetkili Bayi Ithalat
Yetkili bayi aracılığıyla yapılan ithalatlar için.
**Gerekli:** UNO, LNO/SNO, GCB, KUN (yetkili bayi kurum no)

### 7. Verme Bildirimi
Bir kuruma/firmaya ürün satışı, hibesi, sevki için.
**Gerekli:** UNO, LNO/SNO, KUN (alıcı kurum), BNO (fatura/irsaliye no)
**Opsiyonel:** ADT, BEN (bedelsiz numune EVET/HAYIR), GIT (gerçek işlem tarihi)

### 8. Kozmetik Firmaya Verme
Yalnızca kozmetik ürünler için, kozmetik firmasına verildiğinde.
**Gerekli:** UNO, LNO, KUN, BNO

### 9. Alma Bildirimi
Başka bir kurumdan ürün alındığında.
**Gerekli:** UNO, LNO/SNO, KUN (veren kurum), BNO
**Opsiyonel:** ADT, GIT

### 10. Tanımsız Yere Verme
UTS'ye kayıtlı olmayan bir kişiye/kuruluşa verme.
**Gerekli:** UNO, LNO, VKN/TCKN, Ünvan, BNO

### 11. Tanımsız Yerden İade Alma
UTS'ye kayıtlı olmayandan iade alma.
**Gerekli:** UNO, LNO, VKN/TCKN, Ünvan, BNO

### 12. Kullanım Bildirimi
Tıbbi cihaz / ilaç hasta için kullanıldığında.
**Gerekli:** UNO, LNO/SNO
**Opsiyonel:** Hasta TCKN, Protokol No

### 13. Tüketiciye Verme
Son tüketiciye satış (eczane/market/magaza → tüketici).
**Gerekli:** UNO, LNO/SNO, BNO
**Opsiyonel:** Tüketici TCKN, Reçete No

### 14. HEK / Zayiat Bildirimi
Kullanılamaz hale gelen, kaybolan, bozulan ürünler için.
**Gerekli:** UNO, LNO/SNO, Neden (HEK/ZAYIAT/BOZULMA)
**Opsiyonel:** Açıklama

### 15-18. Eşsiz Kimlik (UDI) Bildirimleri
UDI barkodu olan ürünler için alternatif giriş. UNO/LNO/SNO yerine tek bir UDI stringi girilir, sistem ayrıştırır.

---

## Ekstra Butonlar (Sağ Üstte)

### Ürün Kataloğu
5 mock ürünün detaylarını gösterir. Hangi ürünlere bildirim yapabileceğinizi buradan görün.

### Bildirim Logları
Şimdiye kadar yapmış olduğunuz tüm bildirimlerin listesi. Tarih, referans no, kullanıcı, durum — tüm audit bilgisi burada.

---

## Sık Karşılaşılan Sorular

**S: Bir işlemi yanlış parametre ile çalıştırdım, geri alabilir miyim?**
C: Bu bir demo sistemidir, tüm işlemler mock'tur — gerçekten UTS'ye gitmez. Ancak log tablosunda kayıt kalır. Gerçek sistemde "iptal bildirimi" (PDF'teki 3.2 bölümü) ile düzeltilir.

**S: F4 help'te ürün gelmiyor, ne yapmalıyım?**
C: Yöneticiye başvurun — `ZMDPUTS_DATA_INIT` programı çalıştırılması gerekir. Bir kere çalıştırıldıktan sonra sorun çözülür.

**S: Üretim tarihini neden "2025-01-15" değil de "15.01.2025" olarak yazıyorum?**
C: SAP varsayılan tarih formatını kullanır (kullanıcı ayarınıza göre). Sistem içinde otomatik olarak YYYY-AA-GG formatına çevirilir ve UTS'ye öyle gider.

**S: Referans numarası ne işime yarar?**
C: UTS sistemindeki bildiriminizin tanımlayıcısıdır. Denetimde, iptal işleminde veya sorgu yaparken bu numara istenir. Ekran kaydını almak veya not almak iyi olur.

**S: Toplu bildirim yapabilir miyim?**
C: Bu demo sürümünde tek tek yapılır. Gerçek sürümde fatura/irsaliye üzerinden toplu bildirim akışı tasarlanıyor (VF03'ten otomatik).

---

## Klavye Kısayolları

| Tuş | İşlev |
|---|---|
| F1 | Alan yardımı |
| F4 | Possible values / dropdown |
| F8 | Execute (işlemi başlat) |
| F3 | Bir adım geri |
| F15 | Exit (Shift+F3) |
| Ctrl+F1 | Transaction kodu göster |

---

**Sorularınız için:** MDP Group destek ekibi

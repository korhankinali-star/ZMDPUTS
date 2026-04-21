# Müşteri Sunumu — Demo Akış Senaryosu

> **Hedef:** Canlı SAP ekranından UTS sistemimizin nasıl çalıştığını müşteriye göstermek.
> **Süre:** 15-20 dakika
> **Gereken:** SAP GUI açık, ZMDPUTS transaction hazır, mock veri yüklü

---

## Açılış (1 dk)

> *"Bugün size Ürün Takip Sistemi entegrasyonumuzu SAP üzerinde göstereceğim. Şu an sizin simüle ettiğimiz SAP sisteminde, sistemimizle UTS'ye yapılan tüm bildirimleri ve sorgulamaları gerçek zamanlı görebileceksiniz."*

- `/nZUTS` yaz → cockpit açılır
- *"İşte UTS Cockpit'imiz. Burada 18 farklı iş akışı var — sorgulamalar ve bildirimler. Hepsi Sağlık Bakanlığı'nın UTS web servis dokümanına birebir uyumlu."*

---

## Akt 1: Ürün Kataloğunu Göster (2 dk)

**Amaç:** SAP'de ürün mastervera mantığını göstermek.

1. Cockpit sağ üstteki **"Ürün Kataloğu"** butonuna bas
2. 5 ürünlük liste açılır:
   - OrtoFlex Kalça Protezi (tıbbi cihaz, LOT takipli)
   - KardioMax tablet (ilaç, LOT takipli)
   - NeuroStim Pacemaker (tıbbi cihaz, SERİ takipli)
   - DermaCare krem (kozmetik, gönüllü takip)
   - InsuPump insülin pompası (tekil/UDI takipli)

> *"Görüyorsunuz — 3 farklı ürün tipimiz var: tıbbi cihaz, ilaç, kozmetik. Her biri farklı takip metoduyla UTS'de izleniyor. LOT bazlı, seri bazlı, hatta UDI (eşsiz kimlik) bazlı."*

Esc ile kapat → cockpit'e dön.

---

## Akt 2: Sorgulama Akışı (3 dk)

**Amaç:** "SAP'den UTS'ye sorgu atabiliyoruz" demek.

### 2.1 Ürün Sorgulama

1. Cockpit'te **1. satır** (Ürün Sorgulama) üzerine çift tıkla
2. UNO alanında **F4** bas → mock katalog popup
3. **OrtoFlex** satırını seç → OK
4. F8 (Execute)

> *"F4 ile ürünü seçtik, şimdi UTS servise gidiyor... (0.3 saniye bekleme) ... ve bakın, ürün detayı geldi. Ürün adı, üretici, barkod kuruluşu, takip tipi, mevcut toplam stok."*

Esc ile kapat.

### 2.2 Tekil Ürün Sorgulama

1. **2. satır** (Tekil Ürün Sorgulama) üzerine çift tıkla
2. UNO: F4 → OrtoFlex seç
3. LNO alanı boş bırak (tüm LOT'ları getirsin)
4. F8

> *"Bu sefer daha detaylı bir sorgu. Sistem OrtoFlex ürününün her bir LOT'unu ayrı ayrı gösterdi — LOT2025A001, LOT2025A002. Her biri için üretim tarihi, son kullanma tarihi, toplam kullanılabilir adet, son hareketi ve son sahibi ayrıca listelendi."*

> *"Bu şekilde SAP içinden çıkmadan UTS sistemindeki ürünün tam geçmişini görebiliyoruz. Son sahibi kim, son hangi hareket yapılmış — hepsi tek ekranda."*

Esc.

### 2.3 Stok Sorgulama

1. **3. satır** (Tekil Stok Sorgulama) üzerine çift tıkla
2. UNO: F4 → KardioMax seç
3. F8

> *"KardioMax için stok durumu: 2 LOT, toplam 8000 adet. Her LOT'un nerede olduğu, son kullanma tarihi ne zaman — hepsi burada. Depocudan veri istememize gerek yok."*

Esc.

---

## Akt 3: Bildirim Akışı — Kritik Kısım (5 dk)

**Amaç:** "SAP'den tek tıkla UTS'ye bildirim gönderebiliyoruz."

### 3.1 Üretim Bildirimi

1. **4. satır** (Üretim Bildirimi Ekle) üzerine çift tıkla
2. Alanları doldur:
   - UNO: F4 → OrtoFlex seç
   - LNO: `LOT2025X999` (yeni bir LOT)
   - URT: Bugün (varsayılan)
   - SKT: Bugün + 3 yıl (2029-04-20)
   - ADT: `50`
3. F8

> *"Fabrikamızda 50 adet yeni kalça protezi ürettik. SAP'den tek tıkla UTS'ye bildirim gönderiyoruz... işte."*

**Popup açılır:**
> **BILDIRIM BAŞARILI**
> Referans No: 20260420143521-7842
> Tarih: 20.04.2026 14:35:21
> Mesaj: Bildirim UTS'ye başarıyla gönderildi.

> *"Tamamdır. UTS sistemi bildirim numaramızı verdi: 20260420143521-7842. Artık bu 50 ürün Sağlık Bakanlığı'nın sisteminde kayıtlı."*

OK → cockpit'e dön.

### 3.2 Verme Bildirimi (satış)

1. **7. satır** (Verme Bildirimi Ekle)
2. Alanlar:
   - UNO: F4 → KardioMax
   - LNO: `KM25B15` (mevcut bir LOT)
   - ADT: `100`
   - KUN: F4 → "Ecza Deposu Merkez A.S." seç
   - BNO: `FAT-2026-00421`
3. F8

> *"Eczaya 100 kutu KardioMax sattık. Fatura numarası 00421. SAP'den doğrudan UTS'ye verme bildirimi yapıyoruz."*

**Popup:** Referans no döner.

### 3.3 HEK/Zayiat Bildirimi

1. **14. satır** (HEK/Zayiat)
2. Alanlar:
   - UNO: F4 → DermaCare
   - LNO: `DC2025-02`
   - ADT: `5`
   - NEDEN: `ZAYIAT` (dropdown'dan seç)
   - AÇIKLAMA: "Soğuk zincir kırıldı, ürün bozuldu"
3. F8 → popup.

> *"Kozmetik ürünümüzün 5 adeti depoda bozulmuş. Anında UTS'ye zayiat bildirimi gönderdik — yasal yükümlülüğü saniyeler içinde yerine getirdik."*

---

## Akt 4: Audit / Log Tablosunu Göster (2 dk)

**Amaç:** "Yaptığımız her şey sistemde kayıtlı, denetlenebilir."

1. Cockpit sağ üstteki **"Bildirim Logları"** butonuna bas
2. ALV açılır, az önce yapılan 3 bildirim listede görünür:
   - LOG_ID, BILDIRIM_TIP, REF_NO, UNO, LNO, ADT, BNO, KUN, DURUM, ERSDA, ERZET, ERNAM

> *"Burası audit trail'imiz. Yaptığımız her bildirim zaman damgasıyla, kim yaptı, referans numarasıyla birlikte kaydediliyor. Bakanlık denetimine hazır."*

> *"Mesela şu bakın — sayın X kullanıcısı, bugün saat 14:35'te Üretim Bildirimi yaptı, ref no 7842, başarılı. İsterseniz bu tabloyu raporlayabilir, Excel'e aktarabilir, SAP'nin tüm sorgu olanaklarıyla filtreleyebilirsiniz."*

Esc.

---

## Akt 5: Gelişmiş Senaryo — Eşsiz Kimlik (UDI) (2 dk)

**Amaç:** "UDI destekli cihazlar için de hazırız."

1. **15. satır** (Eşsiz Kimlik Alma Bildirimi)
2. Alanlar:
   - UDI: `010868000567890117250215100IP2025A21IPP-A-25-00003` (UDI barkod formatı)
   - ADT: `1`
   - KUN: F4 → hastane seç
   - BNO: `IRS-2026-005`
3. F8 → popup.

> *"InsuPump Pro tek tek seri numarasıyla takip ediliyor. Barkodu tarayınca UDI stringi geliyor, sistem içinden ürün numarası, LOT, seri hepsini ayrıştırıp UTS'ye gönderiyor. İş akışı kullanıcı için tek tıklama."*

---

## Kapanış (1 dk)

> *"Özetle: SAP Cockpit'imiz üzerinden UTS'nin tüm 18 iş akışına doğrudan erişiminiz var. Sorgulama, bildirim ekleme, eşsiz kimlikli hareketler, audit trail — hepsi SAP içinde. Kullanıcı başka bir ekrana geçmiyor, token yönetmiyor, teknik detayla uğraşmıyor. Ürünü F4 ile seç, alanı doldur, F8'e bas — gerisi bizim altyapımızda (MIP / SAP Integration Suite) yönetiliyor."*

**Kapanış soruları için hazır ol:**

- **"Gerçek servis bağlantısı nasıl olacak?"**
  → *"MIP ara katmanımız devreye girecek. Token yönetimi, retry, rate limiting MIP tarafında merkezi. SAP tarafında kod değişmiyor — URL ve auth MIP üzerinden."*

- **"Fatura/irsaliye entegrasyonu?"**
  → *"VF01/VL01N gibi standart transaction'lara USEREXIT/BAdI koyarak fatura kaydı sonrası otomatik UTS bildirimi tetiklenebilir. Bu ikinci faz."*

- **"Çoklu firma için token yönetimi?"**
  → *"MIP Credential Store'da her BUKRS için ayrı token saklanır. SAP tarafında değişiklik gerekmez."*

- **"Ne kadar sürede hayata geçer?"**
  → *"Pilot: 4-6 hafta. Tam kapsam (VF01/VL01N entegrasyonu + PTSNOTICE gönderim dahil): 10-12 hafta."*

---

## Kurtarma Planı — Beklenmedik Durumlar

| Senaryo | Aksiyon |
|---|---|
| Ekran donuyor | Ctrl+F11 → force kill → yeniden /nZUTS |
| F4 boş geliyor | ZMDPUTS_DATA_INIT'i çalıştırmayı unutmuşsun — hemen arka planda yap |
| Popup gözükmüyor | GUI settings → Options → Interaction Design → "Allow all pop-ups" açık mı? |
| Kimse bilmeden log temizleniyor | Demo öncesi ZMDPUTS_DATA_INIT'te **P_LOGCLR tick'ini kaldır** |

---

## Sunum Öncesi Son Kontrol (5 dk önce)

- [ ] SAP GUI açık, doğru sisteme bağlı
- [ ] `/nZUTS` çalışıyor, cockpit geliyor
- [ ] "Ürün Kataloğu" butonu 5 ürün gösteriyor
- [ ] 1 test bildirimi başarılı, popup geliyor
- [ ] "Bildirim Loglari" butonu çalışıyor
- [ ] Proje ekranları, SAP'nin Türkçe dili aktif
- [ ] Log tablosunda **çok eski kayıtlar yoksa** demo temiz olur — gerekirse `ZMDPUTS_DATA_INIT` ile P_LOGCLR tick'li çalıştır

**Hazırsın. İyi sunumlar!**

# ErenWAF - Otomatik Sunucu Güvenlik Duvarı 🔥

ErenWAF, Linux tabanlı sunucular için gelişmiş bir güvenlik duvarı yönetim aracıdır. Debian tabanlı sistemlerde **UFW**, RHEL tabanlı sistemlerde ise **Firewalld** kullanarak güvenlik duvarı yapılandırmasını otomatik hale getirir.

🚀 **Özellikler:**
- 📌 **Tam otomatik güvenlik duvarı kurulumu** (Debian için UFW, RHEL için Firewalld)
- 🔐 **SSH brute-force saldırılarını tespit edip saldırgan IP'leri otomatik engelleme**
- 🌍 **Dinamik port yönetimi** (Açılacak portları kullanıcı belirler)
- 📡 **Canlı ağ trafiği izleme**
- 👀 **SSH giriş denemelerini takip etme**
- 🛠️ **Kolay yönetim için kullanıcı dostu bir arayüz**
- ⚡ **`erenwaf` komutu ile kolayca tekrar çalıştırılabilir**

---

## 📥 Kurulum

ErenWAF'ı sisteminize kurmak ve çalıştırmak için aşağıdaki adımları takip edin:

### 1️⃣ Scripti İndirin
```bash
wget https://github.com/erenakkus/erenwaf/blob/7ac68809362dec64451b795ebc47a64251e0f34f/erenwaf.sh -O erenwaf.sh
```

### 2️⃣ Çalıştırma İzni Verin
```bash
chmod +x erenwaf.sh
```

### 3️⃣ Scripti Çalıştırın
```bash
./erenwaf.sh
```

### 4️⃣ `erenwaf` Komutuyla Kolay Kullanım İçin Kurulum Yapın
Script ilk çalıştırıldığında, **erenwaf** komutuyla tekrar çalıştırılabilmesi için `/usr/local/bin` içine kopyalanacaktır.
Eğer bu işlem tamamlandıysa aşağıdaki komutla her zaman scripti çalıştırabilirsiniz:
```bash
erenwaf
```

---

## 🔧 Kullanım
Script çalıştırıldığında aşağıdaki menü karşınıza gelecektir:

```
=====================================
       🔥 Sunucu Güvenlik Duvarı 🔥
=====================================
1) Firewall Yapılandırma ve Kurulum
2) IP Engelleme ve Yönetim
3) Fail2Ban ile SSH Koruması
4) Canlı Ağ Trafiği İzleme
5) Otomatik IP Kara Listeleme
6) SSH Bağlantı Denemelerini İzleme
7) Çıkış
=====================================
```

**Ana fonksiyonlar:**

### 🛡️ 1) Firewall Yapılandırma ve Kurulum
- İşletim sistemini otomatik tespit eder.
- Gerekli güvenlik duvarı yazılımını yükler.
- Tüm trafiği engelleyip sadece kullanıcı tarafından belirlenen portları açar.

### 🚫 2) IP Engelleme ve Yönetim
- Kullanıcı dilediği IP adreslerini manuel olarak engelleyebilir veya kaldırabilir.

### 🔄 3) Fail2Ban ile SSH Koruması
- SSH brute-force saldırılarını tespit edip IP'yi otomatik olarak kara listeye ekler.

### 📊 4) Canlı Ağ Trafiği İzleme
- Gerçek zamanlı olarak sunucuya gelen trafiği takip etmenizi sağlar.

### ⚠️ 5) Otomatik IP Kara Listeleme
- Belirli sayıda başarısız giriş denemesinden sonra saldırgan IP'leri otomatik olarak engeller.

### 👀 6) SSH Bağlantı Denemelerini İzleme
- `auth.log` üzerinden başarısız giriş denemelerini canlı olarak gösterir.

### ❌ 7) Çıkış
- Scripti kapatır.

---

## ⚡ Örnek Kullanım
**Firewall kurulumunu tamamladıktan sonra 80, 443 ve 22 numaralı portları açalım:**
```bash
erenwaf
```
**Seçim ekranında `1` girin ve ardından portları şu şekilde yazın:**
```
80,443,22
```
Bu işlem tamamlandıktan sonra yalnızca belirtilen portlar açık kalacaktır.

---

## 🔥 Katkıda Bulunma
Projeye katkıda bulunmak isterseniz **Pull Request** gönderebilir veya **Issue** açabilirsiniz. Her türlü geri bildirim değerlidir! 😊

---

## 📜 Lisans
Bu proje MIT lisansı ile lisanslanmıştır. Daha fazla bilgi için **LICENSE** dosyasına göz atabilirsiniz.

---

🚀 **Sunucunuzu korumak için ErenWAF kullanın ve güvende kalın!** 🔥



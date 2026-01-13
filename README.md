# flutter-event-planner

Bu proje, **Mobil Programlama** dersi **6. Ödev** kapsamında geliştirilmiş, kullanıcıların etkinlik oluşturup yönetebileceği, konum ve görsel destekli bir **Flutter** uygulamasıdır. Veri saklama işlemleri için yerel veritabanı (SQLite) kullanılmıştır.

## 🚀 Özellikler

Uygulama aşağıdaki temel fonksiyonları içermektedir:

### 1. Kullanıcı İşlemleri (Authentication)
* **Kayıt Ol:** Kullanıcı adı ve parola ile yeni kayıt oluşturma. (Veriler SQLite `users` tablosuna kaydedilir.)
* **Giriş Yap:** Kayıtlı kullanıcı bilgileriyle sisteme giriş.
* **Profil Güncelleme:** Giriş yapmış kullanıcının kullanıcı adı ve şifresini güncelleyebilmesi.
* **Çıkış:** Oturumu sonlandırma ve giriş ekranına dönüş.

### 2. Etkinlik Yönetimi
* **Etkinlik Ekleme:**
    * Etkinlik Adı ve İçeriği (Metin girişi)
    * Etkinlik Görseli (Galeriden veya Kameradan seçim)
    * Tarih Seçimi (Date Time Picker)
    * Konum Seçimi (Google Maps üzerinden işaretleme)
* **Listeleme:** Eklenen etkinliklerin Ana Sayfada listelenmesi. Uygulama kapatılıp açılsa dahi veriler `sqflite` sayesinde korunur.
* **Detay Görüntüleme & Animasyon:** Listeden bir etkinliğin görseline tıklandığında, **özel bir animasyon** (Hero veya PageRouteBuilder) ile detay sayfasına geçiş yapılır.

## 🛠️ Kullanılan Teknolojiler ve Paketler

* **Flutter & Dart**
* **sqflite:** Yerel veritabanı yönetimi (CRUD işlemleri için).
* **path:** Veritabanı dosya yollarını yönetmek için.
* **google_maps_flutter:** Harita entegrasyonu ve konum seçimi için.
* **image_picker:** Cihaz galerisinden görsel seçmek için.
* **intl:** Tarih formatlama işlemleri için.

## 📸 Ekran Görüntüleri

| Giriş Ekranı | Anasayfa | Etkinlik Ekleme | Detay & Harita |
| :---: | :---: | :---: | :---: |
| ![Giriş](gorseller/giris_screenshot.png) | ![Anasayfa](gorseller/home_screenshot.png) | ![Ekleme](gorseller/add_event_screenshot.png) | ![Detay](gorseller/detail_screenshot.png) |

*(Not: Ekran görüntülerinizi projenizin içine bir klasöre atıp buradaki yolları güncelleyiniz.)*

## 📂 Veritabanı Yapısı

Uygulama `app_database.db` adında bir SQLite veritabanı kullanır ve iki ana tablo içerir:

1.  **users**
    * `id` (INTEGER, Primary Key)
    * `username` (TEXT)
    * `password` (TEXT)

2.  **events**
    * `id` (INTEGER, Primary Key)
    * `title` (TEXT)
    * `description` (TEXT)
    * `imagePath` (TEXT)
    * `date` (TEXT)
    * `latitude` (REAL)
    * `longitude` (REAL)

## ⚙️ Kurulum ve Çalıştırma

Projeyi kendi bilgisayarınızda çalıştırmak için şu adımları izleyin:

1.  Projeyi klonlayın:
    ```bash
    git clone [https://github.com/KULLANICI_ADINIZ/REPO_ADINIZ.git](https://github.com/KULLANICI_ADINIZ/REPO_ADINIZ.git)
    ```
2.  Proje dizinine gidin ve paketleri yükleyin:
    ```bash
    cd proje_klasoru
    flutter pub get
    ```
3.  **ÖNEMLİ:** Google Maps'in çalışması için `android/app/src/main/AndroidManifest.xml` ve `ios/Runner/AppDelegate.swift` dosyalarına kendi **Google Maps API Key**'inizi eklemeniz gerekmektedir.
4.  Uygulamayı başlatın:
    ```bash
    flutter run
    ```

## 📝 Notlar

* Etkinlik görselleri cihazın yerel depolama alanına kaydedilen dosya yolları (path) üzerinden yönetilmektedir.
* Detay sayfasına geçiş animasyonu "Ödev 4" gereksinimlerine uygun olarak kurgulanmıştır.

---
**Geliştirici:** [Adınız Soyadınız]

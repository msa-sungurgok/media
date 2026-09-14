# Digital Media Streaming Platform

Online ve offline çalışabilen kapsamlı sosyal etkileşimli dijital yayın platformu Flutter ile geliştirilmiştir.

## Özellikler

### 📺 TV Sekmesi
- TV kanalları listeleme
- Dinamik kalite seçimi (Auto, 360p, 480p, 720p, 1080p, 1440p, 2160p, 4320p)
- EPG (Elektronik Program Rehberi) desteği
- Kanal raporlama sistemi
- Favori kanallar
- Kanal listesi özelleştirmesi

### 📻 Radyo Sekmesi
- Radyo kanalları listeleme ve oynatma
- Arka planda müzik oynatma
- Kanal raporlama
- Arama işlevi

### 🎬 Film Sekmesi
- Film ve dizi kategorileri
- Filtre ve sıralama seçenekleri
- Filmler için yorum ve puanlama sistemi
- Bölüm oynatma (diziler için)
- Film raporlama

### 💬 Sohbet Sekmesi
- Global sohbet odası
- Moderasyon ve yönetim özellikleri
- Kullanıcı susturma/engelleme sistemi
- Yavaş mod (slow mode)

### ⚙️ Ayarlar
- Kullanıcı profili yönetimi
- Tema ayarları (Aydınlık/Karanlık)
- Player ayarları
- Bildirim tercihleri
- Yönetim paneli (Yöneticiler için)

## Teknik Stack

- **Framework**: Flutter
- **Backend**: Supabase (PostgreSQL)
- **State Management**: GetX / Provider
- **Yerel Veri**: SQLite + SharedPreferences
- **Video Player**: video_player + chewie
- **Ses Oynatıcı**: just_audio

## Kurulum

### Gereksinimler
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android SDK (Android için)
- Xcode (iOS için)
- Supabase hesabı

### Adımlar

1. Repository'yi klonla:
```bash
git clone https://github.com/msa-sungurgok/media.git
cd media
```

2. Bağımlılıkları yükle:
```bash
flutter pub get
```

3. Supabase konfigürasyonunu ayarla:
   - `config/supabase_config.dart` dosyasını açı
   - Supabase URL ve Anon Key'i gir

4. Veritabanını oluştur:
   - Supabase Dashboard'a git
   - `DATABASE_SCHEMA.md` dosyasındaki SQL komutlarını çalıştır

5. Uygulamayı çalıştır:
```bash
flutter run
```

## Proje Yapısı

Detaylı proje yapısı için `PROJECT_STRUCTURE.md` dosyasına bakın.

## Veritabanı Şeması

Detaylı veritabanı şeması için `DATABASE_SCHEMA.md` dosyasına bakın.

## Geliştirme

### Branch Stratejisi
- `main`: Üretim kodları (stable)
- `development`: Geliştirme kodları
- `feature/*`: Yeni özellikler
- `bugfix/*`: Hata düzeltmeleri

### Kod Standartları
- MVC + OOP mimarisi
- Detaylı yorum ve açıklamalar
- 80 karakter satır uzunluğu
- Dart linting kurallarına uyum

## Versiyon Kontrol

Uygulama başlangıcında `system_version` tablosundan versiyon kontrol yapılır.
Yeni versiyon varsa kullanıcıya bildirim gösterilir.

## Lisans

MIT License

## Yazar

- **msa-sungurgok** - İlk versiyonun oluşturulması

## İletişim

Sorular ve öneriler için lütfen GitHub Issues'i kullanın.

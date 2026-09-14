# Digital Media Streaming Platform

Online ve offline çalışabilen kapsamlı sosyal etkileşimli dijital yayın platformu Flutter ile geliştirilmiştir.

## Özellikler

### 📺 TV Sekmesi
- TV kanalları listeleme
- Dinamik kalite seçimi (Auto, 360p, 480p, 720p, 1080p, 1440p, 2160p, 4320p)
- EPG desteği
- Kanal raporlama sistemi
- Favori kanallar

### 📻 Radyo Sekmesi
- Radyo kanalları listeleme ve oynatma
- Arka planda müzik oynatma
- Kanal raporlama
- Arama işlevi

### 🎬 Film Sekmesi
- Film ve dizi kategorileri
- Filtre ve sıralama seçenekleri
- Filmler için yorum ve puanlama sistemi

### 💬 Sohbet Sekmesi
- Global sohbet odası
- Moderasyon ve yönetim özellikleri

### ⚙️ Ayarlar
- Kullanıcı profili yönetimi
- Tema ayarları (Aydınlık/Karanlık)
- Player ayarları
- Bildirim tercihleri

## Teknoloji Stack

- **Framework**: Flutter
- **Backend**: Supabase (PostgreSQL)
- **State Management**: GetX
- **Yerel Veri**: SQLite

## Kurulum

```bash
git clone https://github.com/msa-sungurgok/media.git
cd media
flutter pub get
```

### Supabase Konfigürasyonu

1. `lib/config/supabase_config.dart` dosyasını açın
2. Supabase URL ve Anon Key'i girin

```bash
flutter run
```

## Proje Yapısı

```
lib/
├── config/          # Konfigürasyon dosyaları
├── models/          # Veri modelleri
├── services/        # API ve Supabase servisleri
├── repositories/    # Veri erişim katmanı
├── controllers/     # Business logic ve state management
├── views/          # Kullanıcı arayüzü
├── utils/          # Yardımcı fonksiyonlar
└── main.dart       # Uygulama giriş noktası
```

## Lisans

MIT License

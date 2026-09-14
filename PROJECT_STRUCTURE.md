# Digital Media Streaming Platform - Flutter Projesi

## Proje Özeti
Online ve offline çalışabilen kapsamlı sosyal etkileşimli dijital yayın platformu
- **Platform**: Flutter (Android, Tablet, Smart TV)
- **Backend**: Supabase (PostgreSQL)
- **Yapı**: MVC + OOP Architecture
- **Veri Depolama**: SQLite (yerel ayarlar) + Supabase (bulut)

## Proje Yapısı

```
media/
├── config/                    # Konfigürasyon dosyaları
│   ├── supabase_config.dart  # Supabase API ayarları (dinamik)
│   ├── app_constants.dart    # Sabit değerler
│   └── version_config.dart   # Versiyon bilgileri
│
├── lib/
│   ├── main.dart             # Uygulama giriş noktası
│   │
│   ├── models/               # Veri modelleri (OOP)
│   │   ├── user/
│   │   ├── tv/
│   │   ├── radio/
│   │   ├── movie/
│   │   ├── chat/
│   │   └── admin/
│   │
│   ├── controllers/          # İş mantığı (MVC - Controller)
│   │   ├── auth_controller.dart
│   │   ├── tv_controller.dart
│   │   ├── radio_controller.dart
│   │   ├── movie_controller.dart
│   │   ├── chat_controller.dart
│   │   ├── admin_controller.dart
│   │   └── version_controller.dart
│   │
│   ├── views/               # Arayüz katmanı (MVC - View)
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── splash_screen.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── main_navigation.dart
│   │   ├── tv/
│   │   │   ├── tv_list_screen.dart
│   │   │   ├── tv_player_screen.dart
│   │   │   └── tv_report_screen.dart
│   │   ├── radio/
│   │   │   ├── radio_list_screen.dart
│   │   │   └── radio_player_screen.dart
│   │   ├── movie/
│   │   │   ├── movie_list_screen.dart
│   │   │   ├── movie_detail_screen.dart
│   │   │   └── movie_player_screen.dart
│   │   ├── chat/
│   │   │   ├── chat_screen.dart
│   │   │   └── chat_manage_screen.dart
│   │   ├── settings/
│   │   │   ├── settings_screen.dart
│   │   │   ├── user_settings_screen.dart
│   │   │   ├── app_settings_screen.dart
│   │   │   ├── theme_settings_screen.dart
│   │   │   └── admin_panel_screen.dart
│   │   └── common/
│   │       ├── widgets/
│   │       └── dialogs/
│   │
│   ├── services/            # Dış hizmetler ve API çağrıları
│   │   ├── supabase_service.dart
│   │   ├── auth_service.dart
│   │   ├── tv_service.dart
│   │   ├── radio_service.dart
│   │   ├── movie_service.dart
│   │   ├── chat_service.dart
│   │   ├── local_storage_service.dart
│   │   └── notification_service.dart
│   │
│   ├── repositories/        # Veri erişim katmanı
│   │   ├── user_repository.dart
│   │   ├── tv_repository.dart
│   │   ├── radio_repository.dart
│   │   ├── movie_repository.dart
│   │   ├── chat_repository.dart
│   │   └── admin_repository.dart
│   │
│   ├── utils/              # Yardımcı fonksiyonlar
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   ├── logger.dart
│   │   └── exceptions.dart
│   │
│   ├── widgets/            # Tekrar kullanılabilir arayüz bileşenleri
│   │   ├── custom_player.dart
│   │   ├── custom_button.dart
│   │   ├── loading_widget.dart
│   │   └── error_widget.dart
│   │
│   └── providers/          # State management (GetX, Provider vb.)
│       └── app_state.dart
│
├── assets/
│   ├── images/
│   │   ├── tv/
│   │   │   └── logos/
│   │   ├── radio/
│   │   │   └── logos/
│   │   ├── icons/
│   │   └── backgrounds/
│   ├── fonts/
│   └── translations/
│
├── database/               # Lokal database şemaları
│   ├── migrations/
│   └── schemas.dart
│
├── pubspec.yaml           # Proje bağımlılıkları
└── README.md             # Proje dokümantasyonu
```

## Veritabanı Tabloları (Supabase)

### 1. Kullanıcı Yönetimi
- **users**: Temel kullanıcı bilgileri
- **user_groups**: Kullanıcı grupları ve seviyeleri
- **admin_permissions**: Yönetici yetkiler
- **user_restrictions**: Kullanıcı kısıtlamaları

### 2. TV Yönetimi
- **tv_channels**: TV kanalı bilgileri
- **tv_streams**: Yayın kaliteleri ve URLleri
- **tv_epg**: TV rehberi verileri
- **tv_reports**: Kullanıcı raporları

### 3. Radyo Yönetimi
- **radio_channels**: Radyo kanalı bilgileri
- **radio_reports**: Radyo raporları

### 4. Film Yönetimi
- **movies**: Film bilgileri
- **movie_categories**: Film ana kategorileri
- **movie_genres**: Film türleri
- **movie_seasons**: Dizi sezonları
- **movie_episodes**: Dizi bölümleri
- **movie_comments**: Film yorumları
- **movie_reports**: Film raporları

### 5. Sosyal Etkileşim
- **chat_messages**: Sohbet mesajları
- **chat_moderation**: Sohbet moderasyon ayarları
- **user_mutes**: Susturulan kullanıcılar
- **user_blocks**: Engellenen kullanıcılar

### 6. Sistem Yönetimi
- **system_version**: Versiyon kontrol
- **notifications**: Bildirimler
- **admin_logs**: Yönetici işlem logları
- **user_logs**: Kullanıcı işlem logları
- **points_config**: Puan sistemi konfigürasyonu
- **app_settings**: Uygulama genel ayarları

## Teknoloji Stack

### Bağımlılıklar (pubspec.yaml)
- **flutter**: Framework
- **supabase_flutter**: Backend ve gerçek zamanlı veri senkronizasyonu
- **video_player**: Video oynatıcı
- **just_audio**: Müzik/radyo oynatıcı
- **sqflite**: Lokal SQLite veritabanı
- **shared_preferences**: Basit yerel veri depolama
- **get**: State management ve navigasyon
- **provider**: State management
- **http**: API istekleri
- **json_serializable**: JSON serileştirme
- **logger**: Loglama sistemi

## Mimari Açıklamalar

### MVC (Model-View-Controller) Yapısı
- **Model**: `models/` - Veri yapıları
- **View**: `views/` - Kullanıcı arayüzü
- **Controller**: `controllers/` - İş mantığı ve veri akışı

### OOP Prensipler
- **Encapsulation**: Veri gizleme ve erişim kontrolü
- **Inheritance**: Ortak fonksiyonların kalıtımı
- **Polymorphism**: Aynı interface ile farklı uygulamalar
- **Abstraction**: Kompleks yapıları soyutlama

### Versiyon Kontrol Sistemi
- Uygulama başlangıcında `system_version` tablosundan mevcut versiyon kontrol
- Yeni versiyon varsa kullanıcıya bildirim göster
- Güncelleme linkini Telegram veya hosting adresinden sağla
- Güncelleme sonrası "Yenilikler" sayfası göster (sadece ilk açılışta)

## Detaylı Başlangıç Adımları

1. **Konfigürasyon**: Supabase API bilgilerini `config/` dizininde tanımla
2. **Veritabanı**: Supabase'de tüm tabloları oluştur
3. **Modeller**: Veri modellerini tanımla ve JSON serileştirmesini ayarla
4. **Servisler**: API çağrılarını ve veri erişimini sağla
5. **Repository**: Veri erişim slojasını oluştur
6. **Controller**: İş mantığını yazıp testler yap
7. **Views**: Kullanıcı arayüzünü geliştir
8. **Integration**: Tüm bileşenleri entegre et

---

*Bu proje yapısı, ileride yapılacak ekleme ve değişiklikleri kolaylaştırmak için modüler ve genişletilebilir olacak şekilde tasarlanmıştır.*

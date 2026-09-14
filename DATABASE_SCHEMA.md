# Supabase Veritabanı Şeması

## 1. KULLANICI YÖNETİMİ

### users Tablosu
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username VARCHAR(100) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  profile_picture_url VARCHAR(500),
  user_group_id UUID NOT NULL REFERENCES user_groups(id),
  is_approved BOOLEAN DEFAULT FALSE,
  is_banned BOOLEAN DEFAULT FALSE,
  ban_reason VARCHAR(500),
  ban_end_date TIMESTAMP,
  total_points INT DEFAULT 0,
  remember_me_token VARCHAR(255),
  last_login TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Sistemin temel kullanıcı tablosu
  -- is_approved: Admin tarafından onay bekleniyor mu
  -- is_banned: Kullanıcı banlandı mı (süreli/süresiz)
  -- total_points: Kullanıcının toplam puanı
  -- remember_me_token: Otomatik giriş tokeni
);
```

### user_groups Tablosu
```sql
CREATE TABLE user_groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) UNIQUE NOT NULL, -- Yeni Üye, Bronz Üye, Normal Üye, Platin Üye, Gold Üye, Vip Üye, Onursal Üye
  description VARCHAR(500),
  min_points INT, -- Otomatik terfi için minimum puan
  icon_url VARCHAR(500),
  color_code VARCHAR(7), -- Renk kodu (#XXXXXX)
  is_system BOOLEAN DEFAULT TRUE, -- Sistem tarafından oluşturulan gruplar değiştirilemez
  created_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Kullanıcı seviyeleri ve gruplar
  -- Her kullanıcı bir gruba aittir ve puanları artıkça otomatik terfi olur
);
```

### admin_users Tablosu
```sql
CREATE TABLE admin_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  role VARCHAR(50) NOT NULL, -- Root, Admin, Editör, Moderatör
  created_by UUID REFERENCES admin_users(id),
  is_ghost_mode BOOLEAN DEFAULT FALSE, -- Hayalet mod: işlemler loglanmaz
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Yönetici tanımları ve rolleri
  -- is_ghost_mode: Sadece root bu modu kullanabilir
);
```

### admin_permissions Tablosu
```sql
CREATE TABLE admin_permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id UUID NOT NULL REFERENCES admin_users(id) ON DELETE CASCADE,
  permission_code VARCHAR(100) NOT NULL, -- TV_ADD, TV_EDIT, TV_DELETE, TV_ENCRYPT vs.
  is_granted BOOLEAN DEFAULT TRUE,
  granted_by UUID REFERENCES admin_users(id),
  granted_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Yönetici yetkilerinin detaylı kontrolü
  -- permission_code: İşlem kodları (TV_ADD, RADIO_EDIT vb.)
  -- Rollere göre otomatik permissions atanır ama root istersek manuel değiştirilebilir
  UNIQUE(admin_id, permission_code)
);
```

### user_restrictions Tablosu
```sql
CREATE TABLE user_restrictions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  restriction_type VARCHAR(50) NOT NULL, -- MUTE, MUTE_COMMENTS, BLOCK_TV, BLOCK_RADIO, BLOCK_MOVIES, BLOCK_CHAT
  reason VARCHAR(500),
  duration_minutes INT, -- NULL = süresi yok
  restricted_by UUID NOT NULL REFERENCES admin_users(id),
  restriction_end TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE,
  appealed BOOLEAN DEFAULT FALSE,
  appeal_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Kullanıcı kısıtlama ve cezaları
  -- restriction_type: Mutelenme, bölüm kapatması, banlanma vb.
  -- duration_minutes: Süre (NULL ise sonsuza kadar)
);
```

### user_appeal Tablosu
```sql
CREATE TABLE user_appeal (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  restriction_id UUID NOT NULL REFERENCES user_restrictions(id),
  appeal_reason TEXT NOT NULL,
  status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED
  decided_by UUID REFERENCES admin_users(id),
  decision_reason VARCHAR(500),
  created_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Kullanıcıların kısıtlamalara itiraz etmesi
);
```

---

## 2. TV YÖNETİMİ

### tv_channels Tablosu
```sql
CREATE TABLE tv_channels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) UNIQUE NOT NULL,
  description VARCHAR(500),
  logo_url VARCHAR(500), -- images/tv/logo klasöründe
  epg_url VARCHAR(500), -- EPG verisi URL'si (JSON/XML)
  is_encrypted BOOLEAN DEFAULT FALSE, -- Şifreli kanal
  encrypted_for_groups UUID[], -- Erişebilecek gruplar (ARRAY)
  is_blocked_for_groups UUID[], -- Erişemeyecek gruplar
  is_active BOOLEAN DEFAULT TRUE,
  created_by UUID NOT NULL REFERENCES admin_users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: TV kanallarının ana bilgileri
  -- is_encrypted: Şifreli kanallar sadece izin verilen gruplara açık
  -- encrypted_for_groups: Hangi gruplar izleyebilir (NULL = herkes)
  -- is_blocked_for_groups: Hangi gruplar izleyemez
);
```

### tv_streams Tablosu
```sql
CREATE TABLE tv_streams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tv_channel_id UUID NOT NULL REFERENCES tv_channels(id) ON DELETE CASCADE,
  quality VARCHAR(50) NOT NULL, -- Auto, SD-360p, SD-480p, HD-720p, FHD-1080p, 2K-1440p, 4K-2160p, 8K-4320p
  stream_url VARCHAR(500) NOT NULL,
  platform VARCHAR(100), -- Yayın kaynağı (TRT, Digiturk vb.)
  bitrate INT, -- Bitrate (kbps)
  is_working BOOLEAN DEFAULT TRUE,
  added_by UUID NOT NULL REFERENCES admin_users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Kanal yayın akışları ve kaliteleri
  -- Bir kanalın birden fazla kalitede yayını olabilir
  -- quality: Yayın kalitesi
  -- stream_url: Yayın URL'si (m3u8, mp4 vb.)
  UNIQUE(tv_channel_id, quality)
);
```

### tv_epg Tablosu
```sql
CREATE TABLE tv_epg (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tv_channel_id UUID NOT NULL REFERENCES tv_channels(id) ON DELETE CASCADE,
  program_name VARCHAR(200) NOT NULL,
  description VARCHAR(500),
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP NOT NULL,
  program_image_url VARCHAR(500),
  category VARCHAR(100),
  -- Açıklama: TV programı rehberi (EPG) verileri
  -- Web kaynaklarından JSON/XML olarak çekilen veriler
  created_at TIMESTAMP DEFAULT NOW()
);
```

### tv_reports Tablosu
```sql
CREATE TABLE tv_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tv_channel_id UUID NOT NULL REFERENCES tv_channels(id) ON DELETE CASCADE,
  reported_by UUID NOT NULL REFERENCES users(id),
  issue_description TEXT,
  stream_quality VARCHAR(50), -- Sorunun olduğu kalite
  status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, INVESTIGATING, RESOLVED, WONT_FIX
  resolved_description VARCHAR(500),
  resolved_by UUID REFERENCES admin_users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Kullanıcılar tarafından raporlanan kanal sorunları
  -- status: Sorunun durumu (Çalışılıyor, Çözüldü vb.)
);
```

---

## 3. RADYO YÖNETİMİ

### radio_channels Tablosu
```sql
CREATE TABLE radio_channels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) UNIQUE NOT NULL,
  description VARCHAR(500),
  logo_url VARCHAR(500),
  stream_url VARCHAR(500) NOT NULL,
  bitrate INT, -- Bitrate (kbps)
  language VARCHAR(50),
  genre VARCHAR(100),
  is_active BOOLEAN DEFAULT TRUE,
  created_by UUID NOT NULL REFERENCES admin_users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Radyo kanallarının tüm bilgileri
  -- Radyo genellikle tek bir stream URL'sine sahiptir
);
```

### radio_reports Tablosu
```sql
CREATE TABLE radio_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  radio_channel_id UUID NOT NULL REFERENCES radio_channels(id) ON DELETE CASCADE,
  reported_by UUID NOT NULL REFERENCES users(id),
  issue_description TEXT,
  status VARCHAR(20) DEFAULT 'PENDING',
  resolved_description VARCHAR(500),
  resolved_by UUID REFERENCES admin_users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Radyo kanalı raporları
);
```

---

## 4. FİLM YÖNETİMİ

### movie_categories Tablosu
```sql
CREATE TABLE movie_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) UNIQUE NOT NULL, -- Sinema, Dizi
  description VARCHAR(500),
  is_system BOOLEAN DEFAULT TRUE,
  -- Açıklama: Ana film kategorileri (Sinema ve Dizi)
);
```

### movie_genres Tablosu
```sql
CREATE TABLE movie_genres (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) UNIQUE NOT NULL, -- Fantastik, Bilim Kurgu, Romantizm, Komedi vb.
  description VARCHAR(500),
  icon_url VARCHAR(500),
  -- Açıklama: Film türleri - dinamik olarak eklenebilir/düzenlenebilir
);
```

### movies Tablosu
```sql
CREATE TABLE movies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(200) NOT NULL,
  description TEXT,
  cover_image_url VARCHAR(500),
  category_id UUID NOT NULL REFERENCES movie_categories(id),
  genre_id UUID NOT NULL REFERENCES movie_genres(id),
  director VARCHAR(200),
  cast VARCHAR(500),
  release_date DATE,
  duration_minutes INT,
  rating FLOAT, -- IMDb vb. puanı
  total_comments INT DEFAULT 0,
  average_rating FLOAT DEFAULT 0,
  is_encrypted BOOLEAN DEFAULT FALSE,
  encrypted_for_groups UUID[], -- Erişebilecek gruplar
  is_blocked_for_groups UUID[], -- Erişemeyecek gruplar
  is_active BOOLEAN DEFAULT TRUE,
  created_by UUID NOT NULL REFERENCES admin_users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Film ana bilgileri
  -- Sinema için video URL'si doğrudan movies tablosunda
  -- Dizi için seasons ve episodes tablolarında
  -- total_comments: Toplam yorum sayısı
  -- average_rating: Kullanıcıların verdiği ortalama puanı
);
```

### movie_streams Tablosu (Sinema için video URL'leri)
```sql
CREATE TABLE movie_streams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  movie_id UUID NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
  stream_url VARCHAR(500) NOT NULL,
  quality VARCHAR(50), -- Auto, 720p, 1080p vb.
  platform VARCHAR(100), -- YouTube, Vimeo, Ok.ru vb.
  is_working BOOLEAN DEFAULT TRUE,
  added_by UUID NOT NULL REFERENCES admin_users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Sinema filmlerinin video URL'leri
  -- Dizi bölümleri episode_streams tablosunda
);
```

### movie_seasons Tablosu (Dizi sezonları)
```sql
CREATE TABLE movie_seasons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  movie_id UUID NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
  season_number INT NOT NULL,
  season_name VARCHAR(200),
  cover_image_url VARCHAR(500),
  description TEXT,
  episode_count INT,
  created_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Dizi sezonları
  UNIQUE(movie_id, season_number)
);
```

### movie_episodes Tablosu (Dizi bölümleri)
```sql
CREATE TABLE movie_episodes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  season_id UUID NOT NULL REFERENCES movie_seasons(id) ON DELETE CASCADE,
  episode_number INT NOT NULL,
  episode_name VARCHAR(200),
  description TEXT,
  thumbnail_url VARCHAR(500),
  duration_minutes INT,
  air_date DATE,
  created_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Her sezonun bölümleri
  UNIQUE(season_id, episode_number)
);
```

### episode_streams Tablosu (Bölüm video URL'leri)
```sql
CREATE TABLE episode_streams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  episode_id UUID NOT NULL REFERENCES movie_episodes(id) ON DELETE CASCADE,
  stream_url VARCHAR(500) NOT NULL,
  quality VARCHAR(50),
  platform VARCHAR(100),
  is_working BOOLEAN DEFAULT TRUE,
  added_by UUID NOT NULL REFERENCES admin_users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Bölüm video URL'leri
);
```

### movie_comments Tablosu
```sql
CREATE TABLE movie_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  movie_id UUID NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  comment_text TEXT NOT NULL,
  rating INT, -- 1-10 puan
  likes_count INT DEFAULT 0,
  dislikes_count INT DEFAULT 0,
  is_edited BOOLEAN DEFAULT FALSE,
  edited_at TIMESTAMP,
  is_deleted BOOLEAN DEFAULT FALSE,
  deleted_at TIMESTAMP,
  deleted_by UUID REFERENCES admin_users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Film yorumları
  -- Kullanıcılar yorum yapabilir ve puanlandırabilir
  -- Yöneticiler yorum silebilir/düzenleyebilir
);
```

### comment_reactions Tablosu
```sql
CREATE TABLE comment_reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  comment_id UUID NOT NULL REFERENCES movie_comments(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  reaction_type VARCHAR(20) NOT NULL, -- LIKE, DISLIKE
  created_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Yorumlara yapılan beğeni/beğenmeme işlemleri
  UNIQUE(comment_id, user_id, reaction_type)
);
```

### movie_reports Tablosu
```sql
CREATE TABLE movie_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  movie_id UUID NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
  reported_by UUID NOT NULL REFERENCES users(id),
  issue_description TEXT,
  status VARCHAR(20) DEFAULT 'PENDING',
  resolved_description VARCHAR(500),
  resolved_by UUID REFERENCES admin_users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Film/dizi raporları (sorunlu linkler vb.)
);
```

---

## 5. SOSYAL ETKİLEŞİM (SOHBET)

### chat_messages Tablosu
```sql
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  message_text TEXT NOT NULL,
  is_edited BOOLEAN DEFAULT FALSE,
  edited_at TIMESTAMP,
  is_deleted BOOLEAN DEFAULT FALSE,
  deleted_at TIMESTAMP,
  deleted_by UUID REFERENCES admin_users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Sohbet mesajları
  -- Tüm mesajlar global bir sohbet kanalında
  -- Yöneticiler mesaj silebilir
);
```

### user_mutes Tablosu
```sql
CREATE TABLE user_mutes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  mute_count INT DEFAULT 1,
  last_mute_date TIMESTAMP,
  last_unmute_date TIMESTAMP,
  is_currently_muted BOOLEAN DEFAULT TRUE,
  mute_end_date TIMESTAMP,
  mute_reason VARCHAR(500),
  muted_by UUID NOT NULL REFERENCES admin_users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Susturulan kullanıcılar
  -- is_currently_muted: Şu an susturulmuş mı
  -- mute_count: 1 ay içinde susturulma sayısı
  -- 5 defa susturulup affedilirse 6.sinde tam ban
);
```

### user_blocks Tablosu
```sql
CREATE TABLE user_blocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  block_count INT DEFAULT 1,
  last_block_date TIMESTAMP,
  last_unblock_date TIMESTAMP,
  is_currently_blocked BOOLEAN DEFAULT TRUE,
  block_end_date TIMESTAMP,
  block_reason VARCHAR(500),
  blocked_by UUID NOT NULL REFERENCES admin_users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Engellenen kullanıcılar (sohbetten)
  -- is_currently_blocked: Şu an engellenmiş mi
  -- block_count: 1 ay içinde engelleme sayısı
  -- 5 defa engellenip affedilirse 6.sinde root tarafından affedilebilir
);
```

### chat_settings Tablosu
```sql
CREATE TABLE chat_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  is_chat_open BOOLEAN DEFAULT TRUE,
  is_slow_mode_enabled BOOLEAN DEFAULT FALSE,
  slow_mode_duration_seconds INT DEFAULT 60, -- 1dk, 2dk, 5dk, 10dk, 60dk
  slow_mode_exempt_groups UUID[], -- Slow moddan muaf gruplar
  last_modified_by UUID REFERENCES admin_users(id),
  last_modified_at TIMESTAMP,
  -- Açıklama: Global sohbet ayarları
  -- Sohbet açılabilir/kapatılabilir
  -- Slow mode aktif edilebilir
);
```

---

## 6. SİSTEM YÖNETİMİ

### system_version Tablosu
```sql
CREATE TABLE system_version (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  version_number VARCHAR(20) NOT NULL UNIQUE, -- 1.0.0, 1.0.1 vb.
  version_code INT NOT NULL UNIQUE, -- 1, 2, 3... (numerik sürüm)
  description TEXT,
  minimum_required_version VARCHAR(20), -- Minimum uyumlu eski versiyon
  release_notes TEXT, -- Yenilikler (kullanıcıya gösterilecek)
  download_url VARCHAR(500), -- Hosting adı veya Telegram link
  is_force_update BOOLEAN DEFAULT FALSE, -- Zorunlu güncelleme
  is_active BOOLEAN DEFAULT TRUE,
  release_date TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Uygulama versiyonları ve güncelleme bilgileri
  -- Uygulama başlangıcında en son aktif versiyona bakılır
  -- Kullanıcı versiyonu bundan düşükse güncelleme bildirimi gösterilir
);
```

### notifications Tablosu
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(200) NOT NULL,
  message TEXT NOT NULL,
  notification_type VARCHAR(50), -- SYSTEM, USER_UPDATE, CHAT_MUTE vb.
  target_users UUID[], -- Null = tüm kullanıcılara
  target_groups UUID[], -- Null = tüm gruplara
  send_once BOOLEAN DEFAULT FALSE, -- True ise tek sefer gönderilir
  repeat_type VARCHAR(50), -- ONCE, HOURLY_6, HOURLY_12, DAILY_3, DAILY_7, WEEKLY, MONTHLY
  repeat_limit INT, -- Kaç defa tekrarlanacak (NULL = sonsuz)
  repeat_count INT DEFAULT 0,
  next_send_time TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE,
  created_by UUID NOT NULL REFERENCES admin_users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Sistem ve kullanıcı bildirimleri
  -- Belirli aralıklarla otomatik gönderilebilir
  -- Root ve adminler günde sadece 1 bildirim gönderebilir (repeat_type=ONCE)
);
```

### points_config Tablosu
```sql
CREATE TABLE points_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  action_code VARCHAR(100) UNIQUE NOT NULL, -- TV_FIRST_WATCH, TV_HOUR_WATCH, COMMENT_LIKE vb.
  action_description VARCHAR(200),
  points_earned INT NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Dinamik puan sistemi
  -- Her işlem için kaç puan kazanıldığını tanımlar
  -- Örnek: TV_FIRST_WATCH = +5 puan
  -- Örnek: TV_HOUR_WATCH = +60 puan
);
```

### user_points_log Tablosu
```sql
CREATE TABLE user_points_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  action_code VARCHAR(100) NOT NULL REFERENCES points_config(action_code),
  points_earned INT NOT NULL,
  related_id VARCHAR(100), -- TV/Film/Radyo ID'si vb.
  created_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Kullanıcı puan kazanım logu
  -- Her puan kazanımı kayıt edilir
);
```

### admin_logs Tablosu
```sql
CREATE TABLE admin_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id UUID NOT NULL REFERENCES admin_users(id),
  action_type VARCHAR(100), -- USER_APPROVED, TV_ADDED, CHANNEL_BANNED vb.
  action_description TEXT,
  related_user_id UUID REFERENCES users(id),
  related_resource_id VARCHAR(100), -- TV/Film/Radyo ID'si
  related_resource_type VARCHAR(50), -- USER, TV, RADIO, MOVIE, CHAT
  ip_address VARCHAR(45),
  user_agent VARCHAR(500),
  status VARCHAR(20), -- SUCCESS, FAILED
  created_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Yönetici işlemlerinin logu
  -- Hayalet mod olmadığında tüm işlemler loglanır
  -- Root isterse bir logu silebilir (bu silme işlemi loglanmaz)
);
```

### user_activity_logs Tablosu
```sql
CREATE TABLE user_activity_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  activity_type VARCHAR(100), -- TV_WATCH, RADIO_LISTEN, MOVIE_WATCH, COMMENT, LIKE vb.
  activity_description TEXT,
  related_resource_id VARCHAR(100),
  related_resource_type VARCHAR(50),
  duration_seconds INT, -- İzleme/dinleme süresi
  ip_address VARCHAR(45),
  device_info VARCHAR(200),
  created_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Kullanıcı aktivite logu
  -- Yapılan her işlem loglanır
);
```

### app_settings Tablosu
```sql
CREATE TABLE app_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  setting_key VARCHAR(100) UNIQUE NOT NULL,
  setting_value TEXT,
  setting_type VARCHAR(50), -- STRING, INT, BOOLEAN, JSON
  description VARCHAR(500),
  updated_by UUID REFERENCES admin_users(id),
  updated_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Genel uygulama ayarları
  -- website_url, telegram_channel, app_logo vb.
  -- sadece root ve admin düzenleyebilir
);
```

### user_preferences Tablosu (Lokal)
```sql
CREATE TABLE user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  theme_mode VARCHAR(20) DEFAULT 'DARK', -- LIGHT, DARK, CUSTOM
  language VARCHAR(10) DEFAULT 'tr',
  enable_notifications BOOLEAN DEFAULT TRUE,
  tv_player_fullscreen BOOLEAN DEFAULT TRUE,
  tv_channel_list_position VARCHAR(20) DEFAULT 'RIGHT', -- LEFT, RIGHT, TOP, BOTTOM
  tv_channel_list_transparency VARCHAR(20) DEFAULT 'TRANSPARENT', -- TRANSPARENT, OPAQUE
  startup_tab VARCHAR(50) DEFAULT 'TV', -- TV, RADIO, MOVIE, CHAT
  volume_level INT DEFAULT 50,
  updated_at TIMESTAMP DEFAULT NOW(),
  -- Açıklama: Kullanıcı yerel ayarları (SQLite'te saklanabilir)
  -- Uygulamadan çıkıp girdiğinde hatırlanmalı
);
```

---

## İNDEKSLER (Performans)

```sql
-- Sık sorgulanan alanlar için indexler
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_is_approved ON users(is_approved);
CREATE INDEX idx_users_is_banned ON users(is_banned);
CREATE INDEX idx_users_user_group_id ON users(user_group_id);

CREATE INDEX idx_admin_users_user_id ON admin_users(user_id);
CREATE INDEX idx_admin_users_role ON admin_users(role);

CREATE INDEX idx_tv_channels_is_active ON tv_channels(is_active);
CREATE INDEX idx_tv_streams_tv_channel_id ON tv_streams(tv_channel_id);

CREATE INDEX idx_radio_channels_is_active ON radio_channels(is_active);

CREATE INDEX idx_movies_category_id ON movies(category_id);
CREATE INDEX idx_movies_genre_id ON movies(genre_id);
CREATE INDEX idx_movies_is_active ON movies(is_active);

CREATE INDEX idx_chat_messages_created_at ON chat_messages(created_at);
CREATE INDEX idx_chat_messages_user_id ON chat_messages(user_id);

CREATE INDEX idx_admin_logs_admin_id ON admin_logs(admin_id);
CREATE INDEX idx_admin_logs_created_at ON admin_logs(created_at);

CREATE INDEX idx_user_activity_logs_user_id ON user_activity_logs(user_id);
CREATE INDEX idx_user_activity_logs_created_at ON user_activity_logs(created_at);
```

---

## ROW LEVEL SECURITY (RLS) POLİSİLERİ

Tüm tablolar için temel RLS policy'leri tanımlanmalı:
- Kullanıcılar sadece kendilerine ait verileri görebilir
- Admin'ler yetkileri doğrultusunda işlem yapabilir
- Paylaşılan veriler (TV, Radyo, Film) herkes tarafından okunabilir
- Raporlar ve loglar yetki doğrultusunda görüntülenebilir


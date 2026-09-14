// Versiyon Kontrol Konfigürasyonu
// Açıklama: Uygulama versiyonu kontrol ve yönetim için kullanılır
// Bu dosya system_version tablosundan verileri okur ve kontrol sağlar

class VersionConfig {
  /// Güncellemeleri otomatik kontrol et
  /// Açıklama: Uygulama başlangıcında versiyonları kontrol eder
  static const bool autoCheckUpdates = true;

  /// Zorunlu güncelleme için seçenek gösterme süresi (saniye)
  /// Açıklama: Zorunlu güncellemelerde çıkış seçeneği bu kadar süre sonra görünür
  static const int forceUpdateWaitTime = 5;

  /// Yenilikler sayfasını göster (ilk açılışta)
  /// Açıklama: Güncelleme sonrası ilk açılışta "Yenilikler" sayfası gösterilir
  static const bool showWhatsNewOnFirstLaunch = true;

  /// Versiyonu yerel olarak kaydet
  /// Açıklama: İndirilen versiyonu SharedPreferences'e kaydeder
  /// Key: 'current_app_version'
  static const String versionStorageKey = 'current_app_version';

  /// Son versiyon kontrol tarihi
  /// Açıklama: Son kez versiyonun kontrol edildiği zamanı saklar
  /// Key: 'last_version_check_time'
  static const String lastVersionCheckKey = 'last_version_check_time';

  /// Yenilikler görüldü mü?
  /// Açıklama: Kullanıcı yenilikler sayfasını gördü mü?
  /// Key: 'whats_new_seen_for_version'
  static const String whatsNewSeenKey = 'whats_new_seen_for_version';

  /// Versiyon kontrol aralığı (saat)
  /// Açıklama: Versiyon kontrolü bu kadar saat arasında bir kere yapılır
  /// 0 = Her zaman kontrol et
  static const int versionCheckIntervalHours = 0;

  /// Minimum versiyon uyumluluğu kontrol edilsin mi?
  /// Açıklama: Eski versiyonlar desteklenip desteklenmediği kontrol edilir
  static const bool checkMinimumVersion = true;
}

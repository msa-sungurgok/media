// Supabase API Konfigürasyonu
// Bu dosya Supabase bağlantısı için gerekli bilgileri tutar
// Dinamik olarak değiştirilmesi gerektiğinde bu dosya güncellenmelidir

class SupabaseConfig {
  /// Supabase URL - Supabase Dashboard'dan alınır
  /// Format: https://xxxxxxxxxxxxx.supabase.co
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';

  /// Supabase Anon Key - Supabase Dashboard'dan alınır
  /// Public key olarak kullanılır
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// Database Connection Pool Size
  /// Supabase ile yapılacak maksimum eşzamanlı bağlantı sayısı
  static const int maxConnections = 10;

  /// API Request Timeout (saniye cinsinden)
  /// API isteği bu süre içinde tamamlanmazsa timeout oluşur
  static const int requestTimeout = 30;

  /// Real-time subscriptions etkin mi?
  /// True = Real-time veri güncellemeleri aktif
  static const bool enableRealtimeSubscriptions = true;

  /// Supabase Konfigürasyonunun geçerli olup olmadığını kontrol eder
  /// Açıklama: Üretim ortamında bu fonksiyon çalıştırılmalıdır
  static bool isConfigValid() {
    return supabaseUrl != 'YOUR_SUPABASE_URL' &&
        supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY' &&
        supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty;
  }

  /// Dinamik konfigürasyon yükleme
  /// Açıklama: JSON dosya veya API'den konfigürasyon yüklemek için
  /// Bu metod ileri aşamalarda kullanılabilir
  static Future<Map<String, dynamic>> loadDynamicConfig() async {
    // TODO: İleride JSON dosya veya API'den konfigürasyon yükleme
    return {
      'supabaseUrl': supabaseUrl,
      'supabaseAnonKey': supabaseAnonKey,
      'maxConnections': maxConnections,
      'requestTimeout': requestTimeout,
    };
  }
}

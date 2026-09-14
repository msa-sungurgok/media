// Supabase Servis
// Açıklama: Supabase ile tüm veritabanı işlemlerini yöneten merkezi servis
// Bağlantı kurma, veri çekme, güncelleme, silme işlemlerini burada yaparız

import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/logger.dart';

/// Supabase Servis Sınıfı
/// Açıklama: Supabase ile tüm iletişimi yönetir
/// Singleton pattern kullanılır (uygulama boyunca tek instance)
class SupabaseService {
  /// Singleton instance
  static final SupabaseService _instance = SupabaseService._internal();

  /// Supabase client
  late final SupabaseClient _client;

  /// Supabase başlatıldı mı?
  bool _isInitialized = false;

  /// Private constructor
  SupabaseService._internal();

  /// Singleton instance getter
  /// Açıklama: Uygulama boyunca her yerden SupabaseService().instance şeklinde erişilebilir
  factory SupabaseService() {
    return _instance;
  }

  /// Supabase client getter
  SupabaseClient get client => _client;

  /// Başlatılma durumu getter
  bool get isInitialized => _isInitialized;

  /// Supabase'i başlat
  /// Açıklama: Uygulama başlangıcında bir kez çağrılmalıdır
  /// main.dart içinde _initializeApp() fonksiyonunda çağrılması gerekir
  Future<void> initialize() async {
    try {
      AppLogger.info('Supabase başlatılıyor...');

      // Konfigürasyon geçerli mi kontrol et
      if (!SupabaseConfig.isConfigValid()) {
        throw Exception(
          'Supabase konfigürasyonu geçersiz!\n'
          'config/supabase_config.dart dosyasını güncelleyin.',
        );
      }

      // Supabase'i başlat
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );

      _client = Supabase.instance.client;
      _isInitialized = true;

      AppLogger.success('Supabase başarıyla başlatıldı!');
    } catch (e) {
      AppLogger.error('Supabase başlatılırken hata: $e');
      rethrow;
    }
  }

  /// Bağlantı durumu kontrol et
  /// Açıklama: Supabase'e bağlı mı kontrol eder
  bool get isConnected => _isInitialized;

  /// Veritabanı sorgusu çalıştır
  /// Açıklama: Genel amaçlı sorgu fonksiyonu
  /// table: Tablo adı
  /// query: Sorguda yapılacak filtre/sıralama işlemleri
  Future<List<Map<String, dynamic>>> query(
    String table, {
    PostgrestFilterBuilder Function(PostgrestQueryBuilder)? queryBuilder,
  }) async {
    try {
      var query = _client.from(table).select();
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.error('Sorgu hatası ($table): $e');
      rethrow;
    }
  }

  /// Tek bir kaydı getir
  /// Açıklama: Sorguya uyan ilk kaydı döndürür
  Future<Map<String, dynamic>?> queryOne(
    String table, {
    required PostgrestFilterBuilder Function(PostgrestQueryBuilder) queryBuilder,
  }) async {
    try {
      final response = await queryBuilder(_client.from(table).select()).limit(1);
      return response.isNotEmpty ? response.first : null;
    } catch (e) {
      AppLogger.error('Tek kayıt sorgusu hatası ($table): $e');
      rethrow;
    }
  }

  /// Veri ekle
  /// Açıklama: Tabloya yeni kayıt ekler
  Future<Map<String, dynamic>?> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.from(table).insert(data).select();
      return response.isNotEmpty ? response.first : null;
    } catch (e) {
      AppLogger.error('Ekleme hatası ($table): $e');
      rethrow;
    }
  }

  /// Veri güncelle
  /// Açıklama: Mevcut kaydı günceller
  Future<List<Map<String, dynamic>>> update(
    String table,
    Map<String, dynamic> data, {
    required PostgrestFilterBuilder Function(PostgrestQueryBuilder) whereBuilder,
  }) async {
    try {
      final response = await whereBuilder(_client.from(table).update(data)).select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.error('Güncelleme hatası ($table): $e');
      rethrow;
    }
  }

  /// Veri sil
  /// Açıklama: Sorguya uyan kaydı siler
  Future<void> delete(
    String table, {
    required PostgrestFilterBuilder Function(PostgrestQueryBuilder) whereBuilder,
  }) async {
    try {
      await whereBuilder(_client.from(table).delete());
      AppLogger.info('Silme işlemi başarılı ($table)');
    } catch (e) {
      AppLogger.error('Silme hatası ($table): $e');
      rethrow;
    }
  }

  /// Sayıyı getir
  /// Açıklama: Belirli koşula uyan kayıt sayısını döndürür
  Future<int> count(
    String table, {
    PostgrestFilterBuilder Function(PostgrestQueryBuilder)? queryBuilder,
  }) async {
    try {
      var query = _client.from(table).select('*', const FetchOptions(count: CountOption.exact));
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      final response = await query;
      return response.length;
    } catch (e) {
      AppLogger.error('Sayı sorgusu hatası ($table): $e');
      return 0;
    }
  }
}

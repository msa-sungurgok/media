// Supabase Servis
// Açıklama: Supabase ile tüm veritabanı işlemlerini yönetir

import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Servis Sınıfı
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient _client;
  bool _isInitialized = false;

  SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseClient get client => _client;
  bool get isInitialized => _isInitialized;

  Future<void> initialize(String url, String anonKey) async {
    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
      print('Supabase başlatıldı');
    } catch (e) {
      print('Supabase başlatma hatası: $e');
      rethrow;
    }
  }

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
      print('Sorgu hatası ($table): $e');
      rethrow;
    }
  }
}

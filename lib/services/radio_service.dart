// Radyo Servis
// Açıklama: Radyo kanalları ile ilgili tüm Supabase işlemlerini yönetir
// Veri çekme, filtreleme, raporlama vb.

import '../models/radio/radio_channel_model.dart';
import '../utils/logger.dart';
import 'supabase_service.dart';

/// Radyo Servis Sınıfı
/// Açıklama: Radyo kanalları ile ilgili tüm işlemleri yönetir
/// - Kanalları listele
/// - Kanal detaylarını getir
/// - Kanal ara
/// - Kanal raporla
class RadioService {
  /// Supabase servis instance
  final SupabaseService _supabaseService = SupabaseService();

  /// Tüm radyo kanallarını getir
  /// Açıklama: Aktif olan tüm radyo kanallarını döndürür
  /// Returns: RadioChannelModel listesi
  Future<List<RadioChannelModel>> getAllChannels() async {
    try {
      AppLogger.info('Radyo kanalları yükleniyor...');

      final response = await _supabaseService.query(
        'radio_channels',
        queryBuilder: (query) => query.eq('is_active', true).order('name'),
      );

      final channels =
          response.map((json) => RadioChannelModel.fromJson(json)).toList();

      AppLogger.success('${channels.length} radyo kanalı yüklendi');
      return channels;
    } catch (e) {
      AppLogger.error('Kanalları yüklerken hata: $e');
      return [];
    }
  }

  /// Kanal ID'sine göre kanal getir
  /// Açıklama: Tek bir kanal detaylarını getir
  /// channelId: Radyo kanal ID'si
  /// Returns: RadioChannelModel veya null
  Future<RadioChannelModel?> getChannelById(String channelId) async {
    try {
      final response = await _supabaseService.queryOne(
        'radio_channels',
        queryBuilder: (query) => query.eq('id', channelId),
      );

      return response != null ? RadioChannelModel.fromJson(response) : null;
    } catch (e) {
      AppLogger.error('Kanal getirme hatası: $e');
      return null;
    }
  }

  /// Kanal adına göre ara
  /// Açıklama: Kanal adında arama yapıp eşleşenleri döndürür
  /// searchQuery: Aranacak metin
  /// Returns: Eşleşen RadioChannelModel listesi
  Future<List<RadioChannelModel>> searchChannels(String searchQuery) async {
    try {
      final query = searchQuery.toLowerCase();
      final channels = await getAllChannels();

      return channels
          .where((channel) => channel.name.toLowerCase().contains(query))
          .toList();
    } catch (e) {
      AppLogger.error('Kanal araması hatası: $e');
      return [];
    }
  }

  /// Kanalları türe göre filtrele
  /// Açıklama: Belirli müzik türündeki radyo kanallarını döndürür
  /// genre: Müzik türü (Pop, Rock, Klasik vb.)
  /// Returns: Filtrelenmiş RadioChannelModel listesi
  Future<List<RadioChannelModel>> getChannelsByGenre(String genre) async {
    try {
      final response = await _supabaseService.query(
        'radio_channels',
        queryBuilder: (query) => query.eq('is_active', true).eq('genre', genre),
      );

      return response.map((json) => RadioChannelModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Tür filtreleme hatası: $e');
      return [];
    }
  }

  /// Kanalları dile göre filtrele
  /// Açıklama: Belirli dildeki radyo kanallarını döndürür
  /// language: Dil kodu (tr, en, de vb.)
  /// Returns: Filtrelenmiş RadioChannelModel listesi
  Future<List<RadioChannelModel>> getChannelsByLanguage(
    String language,
  ) async {
    try {
      final response = await _supabaseService.query(
        'radio_channels',
        queryBuilder: (query) =>
            query.eq('is_active', true).eq('language', language),
      );

      return response.map((json) => RadioChannelModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Dil filtreleme hatası: $e');
      return [];
    }
  }

  /// Kanal raporla
  /// Açıklama: Kullanıcı bir kanalda sorun yaşıyorsa bunu rapor eder
  /// channelId: Radyo kanal ID'si
  /// userId: Raporu gönderen kullanıcı ID'si
  /// issueDescription: Sorun açıklaması
  /// Returns: Başarılı mı?
  Future<bool> reportChannel({
    required String channelId,
    required String userId,
    required String issueDescription,
  }) async {
    try {
      AppLogger.info('Kanal rapor ediliyor: $channelId - $userId');

      await _supabaseService.insert('radio_reports', {
        'radio_channel_id': channelId,
        'reported_by': userId,
        'issue_description': issueDescription,
        'status': 'PENDING',
        'created_at': DateTime.now().toIso8601String(),
      });

      AppLogger.success('Kanal raporu başarıyla gönderildi');
      return true;
    } catch (e) {
      AppLogger.error('Kanal rapor gönderme hatası: $e');
      return false;
    }
  }

  /// Tüm türleri getir
  /// Açıklama: Veritabanında bulunan tüm müzik türlerini döndürür
  /// Returns: Tür listesi
  Future<List<String>> getAllGenres() async {
    try {
      final channels = await getAllChannels();
      final genres = <String>{};

      for (final channel in channels) {
        if (channel.genre != null && channel.genre!.isNotEmpty) {
          genres.add(channel.genre!);
        }
      }

      return genres.toList();
    } catch (e) {
      AppLogger.error('Türler getirme hatası: $e');
      return [];
    }
  }

  /// Tüm dilleri getir
  /// Açıklama: Veritabanında bulunan tüm dilleri döndürür
  /// Returns: Dil listesi
  Future<List<String>> getAllLanguages() async {
    try {
      final channels = await getAllChannels();
      final languages = <String>{};

      for (final channel in channels) {
        if (channel.language != null && channel.language!.isNotEmpty) {
          languages.add(channel.language!);
        }
      }

      return languages.toList();
    } catch (e) {
      AppLogger.error('Diller getirme hatası: $e');
      return [];
    }
  }

  /// En popüler kanalları getir
  /// Açıklama: En çok raporlanan/takip edilen kanalları döndürür
  /// limit: Kaç kanal döndürülsün
  /// Returns: PopülerRadioChannelModel listesi
  Future<List<RadioChannelModel>> getPopularChannels({
    int limit = 10,
  }) async {
    try {
      // Bu işlem için advanced query yapılması gerekir
      // Şimdilik tüm kanalları döndürelim
      final channels = await getAllChannels();
      return channels.take(limit).toList();
    } catch (e) {
      AppLogger.error('Popüler kanallar getirme hatası: $e');
      return [];
    }
  }
}

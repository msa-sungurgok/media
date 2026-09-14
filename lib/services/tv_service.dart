// TV Servis
// Açıklama: TV kanalları ve yayın akışları ile ilgili tüm Supabase işlemlerini yönetir
// Veri çekme, filtreleme, raporlama vb.

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tv/tv_channel_model.dart';
import '../models/tv/tv_stream_model.dart';
import '../utils/logger.dart';
import 'supabase_service.dart';

/// TV Servis Sınıfı
/// Açıklama: TV kanalları ile ilgili tüm işlemleri yönetir
/// - Kanalları listele
/// - Kanal detaylarını getir
/// - Yayın kalitelerini getir
/// - Kanalı raporla
class TVService {
  /// Supabase servis instance
  final SupabaseService _supabaseService = SupabaseService();

  /// Tüm TV kanallarını getir
  /// Açıklama: Aktif olan tüm TV kanallarını döndürür
  /// userGroupId: Kullanıcı grup ID'si (şifreleme kontrolü için)
  /// Returns: TVChannelModel listesi
  Future<List<TVChannelModel>> getAllChannels({String? userGroupId}) async {
    try {
      AppLogger.info('TV kanalları yükleniyor...');

      final response = await _supabaseService.query(
        'tv_channels',
        queryBuilder: (query) => query.eq('is_active', true).order('name'),
      );

      final channels =
          response.map((json) => TVChannelModel.fromJson(json)).toList();

      // Kullanıcı grubu ID'si varsa, erişebileceği kanalları filtrele
      if (userGroupId != null) {
        return channels
            .where((channel) => channel.canUserWatch(userGroupId))
            .toList();
      }

      return channels;
    } catch (e) {
      AppLogger.error('Kanalları yüklerken hata: $e');
      return [];
    }
  }

  /// Kanal ID'sine göre kanal getir
  /// Açıklama: Tek bir kanal detaylarını getir
  /// channelId: TV kanal ID'si
  /// Returns: TVChannelModel veya null
  Future<TVChannelModel?> getChannelById(String channelId) async {
    try {
      final response = await _supabaseService.queryOne(
        'tv_channels',
        queryBuilder: (query) => query.eq('id', channelId),
      );

      return response != null ? TVChannelModel.fromJson(response) : null;
    } catch (e) {
      AppLogger.error('Kanal getirme hatası: $e');
      return null;
    }
  }

  /// Kanal adına göre ara
  /// Açıklama: Kanal adında arama yapıp eşleşenleri döndürür
  /// searchQuery: Aranacak metin
  /// userGroupId: Kullanıcı grup ID'si
  /// Returns: Eşleşen TVChannelModel listesi
  Future<List<TVChannelModel>> searchChannels(
    String searchQuery, {
    String? userGroupId,
  }) async {
    try {
      final query = searchQuery.toLowerCase();
      final channels = await getAllChannels(userGroupId: userGroupId);

      return channels
          .where((channel) => channel.name.toLowerCase().contains(query))
          .toList();
    } catch (e) {
      AppLogger.error('Kanal araması hatası: $e');
      return [];
    }
  }

  /// Kanal için yayın akışlarını getir
  /// Açıklama: Bir kanalın tüm kalitelerdeki yayın linklerini döndürür
  /// channelId: TV kanal ID'si
  /// Returns: TVStreamModel listesi
  Future<List<TVStreamModel>> getChannelStreams(String channelId) async {
    try {
      AppLogger.info('Kanal yayın akışları yükleniyor: $channelId');

      final response = await _supabaseService.query(
        'tv_streams',
        queryBuilder: (query) =>
            query.eq('tv_channel_id', channelId).eq('is_working', true).order('quality'),
      );

      return response.map((json) => TVStreamModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Yayın akışları yüklerken hata: $e');
      return [];
    }
  }

  /// Belirli kalitedeki yayın akışını getir
  /// Açıklama: Kanal ve kalite kombinasyonuna göre yayın linkini döndürür
  /// channelId: TV kanal ID'si
  /// quality: İstenen kalite (Auto, 720p, 1080p vb.)
  /// Returns: TVStreamModel veya null
  Future<TVStreamModel?> getStreamByQuality(
    String channelId,
    String quality,
  ) async {
    try {
      final response = await _supabaseService.queryOne(
        'tv_streams',
        queryBuilder: (query) => query
            .eq('tv_channel_id', channelId)
            .eq('quality', quality)
            .eq('is_working', true),
      );

      return response != null ? TVStreamModel.fromJson(response) : null;
    } catch (e) {
      AppLogger.error('Yayın akışı getirme hatası: $e');
      return null;
    }
  }

  /// Kanal raporla
  /// Açıklama: Kullanıcı bir kanalda sorun yaşıyorsa bunu rapor eder
  /// channelId: TV kanal ID'si
  /// userId: Raporu gönderen kullanıcı ID'si
  /// issueDescription: Sorun açıklaması
  /// streamQuality: Sorunun olduğu kalite
  /// Returns: Başarılı mı?
  Future<bool> reportChannel({
    required String channelId,
    required String userId,
    required String issueDescription,
    String? streamQuality,
  }) async {
    try {
      AppLogger.info('Kanal rapor ediliyor: $channelId - $userId');

      await _supabaseService.insert('tv_reports', {
        'tv_channel_id': channelId,
        'reported_by': userId,
        'issue_description': issueDescription,
        'stream_quality': streamQuality,
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

  /// Kanal için EPG verisi getir
  /// Açıklama: Kanal için TV rehberi verilerini getir
  /// channelId: TV kanal ID'si
  /// Returns: EPG verileri
  Future<List<Map<String, dynamic>>> getChannelEPG(String channelId) async {
    try {
      AppLogger.info('EPG verileri yükleniyor: $channelId');

      final response = await _supabaseService.query(
        'tv_epg',
        queryBuilder: (query) => query
            .eq('tv_channel_id', channelId)
            .gte('end_time', DateTime.now().toIso8601String())
            .order('start_time'),
      );

      return response;
    } catch (e) {
      AppLogger.error('EPG verisi yüklerken hata: $e');
      return [];
    }
  }

  /// Çalışan kanalları getir
  /// Açıklama: Tüm yayın akışları çalışan kanalları döndürür
  /// Returns: Çalışan TVChannelModel listesi
  Future<List<TVChannelModel>> getWorkingChannels({
    String? userGroupId,
  }) async {
    try {
      final channels = await getAllChannels(userGroupId: userGroupId);

      // Her kanal için çalışan akış var mı kontrol et
      final workingChannels = <TVChannelModel>[];

      for (final channel in channels) {
        final streams = await getChannelStreams(channel.id);
        if (streams.isNotEmpty) {
          workingChannels.add(channel);
        }
      }

      return workingChannels;
    } catch (e) {
      AppLogger.error('Çalışan kanalları yüklerken hata: $e');
      return [];
    }
  }

  /// Aranan kaliteleri sırasıyla getir
  /// Açıklama: Kalite tercihine göre uygun akışı bul
  /// channelId: TV kanal ID'si
  /// preferredQualities: Tercih sırası (örn: ['720p', '1080p', 'Auto'])
  /// Returns: Bulunmuş TVStreamModel veya null
  Future<TVStreamModel?> getPreferredStream(
    String channelId,
    List<String> preferredQualities,
  ) async {
    try {
      for (final quality in preferredQualities) {
        final stream = await getStreamByQuality(channelId, quality);
        if (stream != null) {
          return stream;
        }
      }
      return null;
    } catch (e) {
      AppLogger.error('Tercih edilen akış getirme hatası: $e');
      return null;
    }
  }
}

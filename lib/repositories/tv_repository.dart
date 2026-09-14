// TV Repository
// Açıklama: TV ile ilgili veri erişim katmanı
// Service ve Controller arasında veri akışını yönetir
// Caching, filtreleme ve sıralama işlemlerini burada yaparız

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tv/tv_channel_model.dart';
import '../models/tv/tv_stream_model.dart';
import '../services/tv_service.dart';
import '../utils/logger.dart';

/// TV Repository Sınıfı
/// Açıklama: TV ile ilgili veri erişim işlemlerini yönetir
/// Service'ten veri alır, işler ve Controller'a sunar
class TVRepository {
  /// TV Servis instance
  final TVService _tvService = TVService();

  /// Kanallar cache'i
  /// Açıklama: Son alınan kanallar hafızada tutulur
  /// Gereksiz API çağrılarını azaltır
  List<TVChannelModel>? _channelsCache;

  /// Cache güncelleme zamanı
  DateTime? _cacheUpdateTime;

  /// Cache geçerlilik süresi (dakika)
  static const int cacheValidityMinutes = 30;

  /// Tüm TV kanallarını getir (caching ile)
  /// Açıklama: Cache varsa ondan döndürür, yoksa API'den çeker
  /// userGroupId: Kullanıcı grup ID'si
  /// forceRefresh: Cache'i es geç ve API'den çek
  /// Returns: TVChannelModel listesi
  Future<List<TVChannelModel>> getAllChannels({
    String? userGroupId,
    bool forceRefresh = false,
  }) async {
    try {
      // Cache geçerli mi kontrol et
      if (!forceRefresh &&
          _channelsCache != null &&
          _cacheUpdateTime != null &&
          DateTime.now().difference(_cacheUpdateTime!).inMinutes <
              cacheValidityMinutes) {
        AppLogger.debug('Kanallar cache'ten yükleniyor');
        return _channelsCache!;
      }

      // API'den yükle
      final channels = await _tvService.getAllChannels(
        userGroupId: userGroupId,
      );

      // Cache'e kaydet
      _channelsCache = channels;
      _cacheUpdateTime = DateTime.now();

      return channels;
    } catch (e) {
      AppLogger.error('Kanalları yüklerken hata: $e');
      return _channelsCache ?? [];
    }
  }

  /// Kanal detaylarını getir
  /// Açıklama: Kanal ID'sine göre detaylı bilgileri döndürür
  /// channelId: TV kanal ID'si
  /// Returns: TVChannelModel veya null
  Future<TVChannelModel?> getChannelDetails(String channelId) async {
    try {
      // Cache'de varsa oradan döndür
      if (_channelsCache != null) {
        try {
          return _channelsCache!
              .firstWhere((channel) => channel.id == channelId);
        } catch (e) {
          // Cache'de yoksa API'den çek
        }
      }

      return await _tvService.getChannelById(channelId);
    } catch (e) {
      AppLogger.error('Kanal detaylarını yüklerken hata: $e');
      return null;
    }
  }

  /// Kanalları ara
  /// Açıklama: Kanal adında arama yapıp eşleşenleri döndürür
  /// searchQuery: Aranacak metin
  /// userGroupId: Kullanıcı grup ID'si
  /// Returns: Eşleşen TVChannelModel listesi
  Future<List<TVChannelModel>> searchChannels(
    String searchQuery, {
    String? userGroupId,
  }) async {
    try {
      if (searchQuery.isEmpty) {
        return await getAllChannels(userGroupId: userGroupId);
      }

      return await _tvService.searchChannels(
        searchQuery,
        userGroupId: userGroupId,
      );
    } catch (e) {
      AppLogger.error('Kanal araması hatası: $e');
      return [];
    }
  }

  /// Kanal için yayın akışlarını getir
  /// Açıklama: Bir kanalın tüm kalitelerdeki yayın linklerini döndürür
  /// channelId: TV kanal ID'si
  /// Returns: TVStreamModel listesi (quality'ye göre sıralı)
  Future<List<TVStreamModel>> getChannelStreams(String channelId) async {
    try {
      final streams = await _tvService.getChannelStreams(channelId);

      // Kaliteleri sırasıyla sırala
      // Auto en başta gelsin diye
      streams.sort((a, b) {
        const qualityOrder = [
          'Auto',
          'SD-360p',
          'SD-480p',
          'HD-720p',
          'FHD-1080p',
          '2K-1440p',
          '4K-2160p',
          '8K-4320p',
        ];
        final aIndex = qualityOrder.indexOf(a.quality);
        final bIndex = qualityOrder.indexOf(b.quality);
        return aIndex.compareTo(bIndex);
      });

      return streams;
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
      return await _tvService.getStreamByQuality(channelId, quality);
    } catch (e) {
      AppLogger.error('Yayın akışı getirme hatası: $e');
      return null;
    }
  }

  /// Tercih edilen kalitedeki yayın akışını getir
  /// Açıklama: Kalite tercihine göre uygun akışı bulur
  /// channelId: TV kanal ID'si
  /// preferences: Tercih sırası (örn: ['720p', '1080p', 'Auto'])
  /// Returns: Bulunmuş TVStreamModel veya null
  Future<TVStreamModel?> getPreferredStream(
    String channelId,
    List<String> preferences,
  ) async {
    try {
      return await _tvService.getPreferredStream(channelId, preferences);
    } catch (e) {
      AppLogger.error('Tercih edilen akış getirme hatası: $e');
      return null;
    }
  }

  /// Kanal raporla
  /// Açıklama: Kullanıcı bir kanalda sorun yaşıyorsa bunu rapor eder
  /// channelId: TV kanal ID'si
  /// userId: Raporu gönderen kullanıcı ID'si
  /// issueDescription: Sorun açıklaması
  /// streamQuality: Sorunun olduğu kalite (opsiyonel)
  /// Returns: Başarılı mı?
  Future<bool> reportChannel({
    required String channelId,
    required String userId,
    required String issueDescription,
    String? streamQuality,
  }) async {
    try {
      if (issueDescription.isEmpty) {
        AppLogger.warning('Rapor açıklaması boş olamaz');
        return false;
      }

      return await _tvService.reportChannel(
        channelId: channelId,
        userId: userId,
        issueDescription: issueDescription,
        streamQuality: streamQuality,
      );
    } catch (e) {
      AppLogger.error('Kanal rapor gönderme hatası: $e');
      return false;
    }
  }

  /// EPG verisi getir
  /// Açıklama: Kanal için TV rehberi verilerini getir
  /// channelId: TV kanal ID'si
  /// Returns: EPG verileri
  Future<List<Map<String, dynamic>>> getChannelEPG(String channelId) async {
    try {
      return await _tvService.getChannelEPG(channelId);
    } catch (e) {
      AppLogger.error('EPG verisi yüklerken hata: $e');
      return [];
    }
  }

  /// Çalışan kanalları getir
  /// Açıklama: Tüm yayın akışları çalışan kanalları döndürür
  /// userGroupId: Kullanıcı grup ID'si
  /// Returns: Çalışan TVChannelModel listesi
  Future<List<TVChannelModel>> getWorkingChannels({
    String? userGroupId,
  }) async {
    try {
      return await _tvService.getWorkingChannels(
        userGroupId: userGroupId,
      );
    } catch (e) {
      AppLogger.error('Çalışan kanalları yüklerken hata: $e');
      return [];
    }
  }

  /// Cache'i temizle
  /// Açıklama: Tüm cache'i siler, yeni veri çekmek için
  void clearCache() {
    _channelsCache = null;
    _cacheUpdateTime = null;
    AppLogger.info('TV cache temizlendi');
  }
}

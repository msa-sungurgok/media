// Radyo Repository
// Açıklama: Radyo ile ilgili veri erişim katmanı
// Service ve Controller arasında veri akışını yönetir
// Caching, filtreleme ve sıralama işlemlerini burada yaparız

import '../models/radio/radio_channel_model.dart';
import '../services/radio_service.dart';
import '../utils/logger.dart';

/// Radyo Repository Sınıfı
/// Açıklama: Radyo ile ilgili veri erişim işlemlerini yönetir
/// Service'ten veri alır, işler ve Controller'a sunar
class RadioRepository {
  /// Radyo Servis instance
  final RadioService _radioService = RadioService();

  /// Kanallar cache'i
  /// Açıklama: Son alınan kanallar hafızada tutulur
  /// Gereksiz API çağrılarını azaltır
  List<RadioChannelModel>? _channelsCache;

  /// Cache güncelleme zamanı
  DateTime? _cacheUpdateTime;

  /// Türler cache'i
  List<String>? _genresCache;

  /// Diller cache'i
  List<String>? _languagesCache;

  /// Cache geçerlilik süresi (dakika)
  static const int cacheValidityMinutes = 30;

  /// Tüm radyo kanallarını getir (caching ile)
  /// Açıklama: Cache varsa ondan döndürür, yoksa API'den çeker
  /// forceRefresh: Cache'i es geç ve API'den çek
  /// Returns: RadioChannelModel listesi
  Future<List<RadioChannelModel>> getAllChannels({
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
      final channels = await _radioService.getAllChannels();

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
  /// channelId: Radyo kanal ID'si
  /// Returns: RadioChannelModel veya null
  Future<RadioChannelModel?> getChannelDetails(String channelId) async {
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

      return await _radioService.getChannelById(channelId);
    } catch (e) {
      AppLogger.error('Kanal detaylarını yüklerken hata: $e');
      return null;
    }
  }

  /// Kanalları ara
  /// Açıklama: Kanal adında arama yapıp eşleşenleri döndürür
  /// searchQuery: Aranacak metin
  /// Returns: Eşleşen RadioChannelModel listesi
  Future<List<RadioChannelModel>> searchChannels(String searchQuery) async {
    try {
      if (searchQuery.isEmpty) {
        return await getAllChannels();
      }

      return await _radioService.searchChannels(searchQuery);
    } catch (e) {
      AppLogger.error('Kanal araması hatası: $e');
      return [];
    }
  }

  /// Kanalları türe göre filtrele
  /// Açıklama: Belirli müzik türündeki radyo kanallarını döndürür
  /// genre: Müzik türü
  /// Returns: Filtrelenmiş RadioChannelModel listesi
  Future<List<RadioChannelModel>> getChannelsByGenre(String genre) async {
    try {
      if (genre.isEmpty) {
        return await getAllChannels();
      }

      return await _radioService.getChannelsByGenre(genre);
    } catch (e) {
      AppLogger.error('Tür filtreleme hatası: $e');
      return [];
    }
  }

  /// Kanalları dile göre filtrele
  /// Açıklama: Belirli dildeki radyo kanallarını döndürür
  /// language: Dil kodu
  /// Returns: Filtrelenmiş RadioChannelModel listesi
  Future<List<RadioChannelModel>> getChannelsByLanguage(
    String language,
  ) async {
    try {
      if (language.isEmpty) {
        return await getAllChannels();
      }

      return await _radioService.getChannelsByLanguage(language);
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
      if (issueDescription.isEmpty) {
        AppLogger.warning('Rapor açıklaması boş olamaz');
        return false;
      }

      return await _radioService.reportChannel(
        channelId: channelId,
        userId: userId,
        issueDescription: issueDescription,
      );
    } catch (e) {
      AppLogger.error('Kanal rapor gönderme hatası: $e');
      return false;
    }
  }

  /// Tüm türleri getir (caching ile)
  /// Açıklama: Veritabanında bulunan tüm müzik türlerini döndürür
  /// forceRefresh: Cache'i es geç
  /// Returns: Tür listesi
  Future<List<String>> getAllGenres({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _genresCache != null) {
        return _genresCache!;
      }

      final genres = await _radioService.getAllGenres();
      _genresCache = genres;
      return genres;
    } catch (e) {
      AppLogger.error('Türler getirme hatası: $e');
      return _genresCache ?? [];
    }
  }

  /// Tüm dilleri getir (caching ile)
  /// Açıklama: Veritabanında bulunan tüm dilleri döndürür
  /// forceRefresh: Cache'i es geç
  /// Returns: Dil listesi
  Future<List<String>> getAllLanguages({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _languagesCache != null) {
        return _languagesCache!;
      }

      final languages = await _radioService.getAllLanguages();
      _languagesCache = languages;
      return languages;
    } catch (e) {
      AppLogger.error('Diller getirme hatası: $e');
      return _languagesCache ?? [];
    }
  }

  /// En popüler kanalları getir
  /// Açıklama: En çok izlenen kanalları döndürür
  /// limit: Kaç kanal döndürülsün
  /// Returns: PopülerRadioChannelModel listesi
  Future<List<RadioChannelModel>> getPopularChannels({
    int limit = 10,
  }) async {
    try {
      return await _radioService.getPopularChannels(limit: limit);
    } catch (e) {
      AppLogger.error('Popüler kanallar getirme hatası: $e');
      return [];
    }
  }

  /// Cache'i temizle
  /// Açıklama: Tüm cache'i siler, yeni veri çekmek için
  void clearCache() {
    _channelsCache = null;
    _cacheUpdateTime = null;
    _genresCache = null;
    _languagesCache = null;
    AppLogger.info('Radyo cache temizlendi');
  }
}

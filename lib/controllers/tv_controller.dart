// TV Controller
// Açıklama: TV ile ilgili iş mantığını yönetir
// View'den gelen istekleri işler ve Repository'ye yönlendirir
// State management ve business logic burada yapılır

import 'package:get/get.dart';
import '../models/tv/tv_channel_model.dart';
import '../models/tv/tv_stream_model.dart';
import '../repositories/tv_repository.dart';
import '../utils/logger.dart';

/// TV Controller Sınıfı
/// Açıklama: GetX kullanarak TV ile ilgili state management yapar
/// Kanalları yönetir, oynatma durumunu takip eder, filtreleme yapar
class TVController extends GetxController {
  /// TV Repository instance
  final TVRepository _repository = TVRepository();

  /// Tüm TV kanalları
  /// Açıklama: Supabase'den çekilen TV kanalları
  final RxList<TVChannelModel> channels = <TVChannelModel>[].obs;

  /// Seçili kanal
  /// Açıklama: Kullanıcının şu an izlemekte olduğu kanal
  final Rx<TVChannelModel?> selectedChannel = Rx<TVChannelModel?>(null);

  /// Seçili kanal için yayın akışları
  /// Açıklama: Seçili kanalın tüm kalitelerdeki yayın linkları
  final RxList<TVStreamModel> selectedChannelStreams = <TVStreamModel>[].obs;

  /// Seçili yayın akışı
  /// Açıklama: Oynatılacak yayın akışı (kalite + link)
  final Rx<TVStreamModel?> selectedStream = Rx<TVStreamModel?>(null);

  /// Arama sorgusu
  /// Açıklama: Kanal araması için sorgu metni
  final RxString searchQuery = ''.obs;

  /// Arama sonuçları
  /// Açıklama: Aranan kanalların listesi
  final RxList<TVChannelModel> searchResults = <TVChannelModel>[].obs;

  /// Yükleniyor mu?
  /// Açıklama: Verilerin yüklenmesi sırasında true olur
  final RxBool isLoading = false.obs;

  /// Hata mesajı
  /// Açıklama: Hata durumunda hata mesajı
  final RxString errorMessage = ''.obs;

  /// Kullanıcı grup ID'si
  /// Açıklama: Kanalların şifreleme kontrolü için
  String? _userGroupId;

  /// Seçili kalite tercihi
  /// Açıklama: Oynatma sırasında tercih edilen kalite
  final RxString preferredQuality = 'Auto'.obs;

  /// Favori kanallar
  /// Açıklama: Kullanıcının favorilere eklediği kanallar
  final RxList<String> favoriteChannelIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('TV Controller başlatıldı');
  }

  /// Tüm kanalları yükle
  /// Açıklama: Supabase'den tüm TV kanallarını çeker
  /// userGroupId: Kullanıcı grup ID'si (opsiyonel)
  /// forceRefresh: Cache'i es geç
  Future<void> loadChannels({
    String? userGroupId,
    bool forceRefresh = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _userGroupId = userGroupId;

      final loadedChannels = await _repository.getAllChannels(
        userGroupId: userGroupId,
        forceRefresh: forceRefresh,
      );

      channels.value = loadedChannels;
      searchResults.value = loadedChannels;

      AppLogger.success(
        'TV kanalları yüklendi: ${channels.length} kanal',
      );
    } catch (e) {
      errorMessage.value = 'Kanalları yüklerken hata: $e';
      AppLogger.error('Kanalları yüklerken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Kanal seç
  /// Açıklama: Kanal listesinden bir kanal seçer ve yayın akışlarını yükler
  /// channelId: Seçilecek kanal ID'si
  Future<void> selectChannel(String channelId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Kanal detaylarını getir
      final channel = await _repository.getChannelDetails(channelId);

      if (channel == null) {
        errorMessage.value = 'Kanal bulunamadı';
        return;
      }

      selectedChannel.value = channel;

      // Kanal için yayın akışlarını yükle
      final streams = await _repository.getChannelStreams(channelId);
      selectedChannelStreams.value = streams;

      // En uygun kaliteyi seç (tercih sırası)
      await _selectOptimalStream();

      AppLogger.success('Kanal seçildi: ${channel.name}');
    } catch (e) {
      errorMessage.value = 'Kanal seçerken hata: $e';
      AppLogger.error('Kanal seçerken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// En uygun yayın akışını seç
  /// Açıklama: Kullanıcının tercihine göre uygun kaliteyi seçer
  Future<void> _selectOptimalStream() async {
    if (selectedChannel.value == null) return;

    try {
      // Tercih sırası: tercih edilen kalite > 720p > Auto
      final preferences = [
        preferredQuality.value,
        'HD-720p',
        'FHD-1080p',
        'Auto',
      ].toSet().toList();

      final stream = await _repository.getPreferredStream(
        selectedChannel.value!.id,
        preferences,
      );

      selectedStream.value = stream;
    } catch (e) {
      AppLogger.error('Yayın akışı seçerken hata: $e');
    }
  }

  /// Kanalları ara
  /// Açıklama: Kanal adında arama yapıp filtrelenmiş listeyi gösterir
  /// query: Aranacak metin
  Future<void> searchChannels(String query) async {
    try {
      searchQuery.value = query;
      isLoading.value = true;

      if (query.isEmpty) {
        searchResults.value = channels;
      } else {
        final results = await _repository.searchChannels(
          query,
          userGroupId: _userGroupId,
        );
        searchResults.value = results;
      }

      AppLogger.info(
        'Kanal araması yapıldı: "$query" - ${searchResults.length} sonuç',
      );
    } catch (e) {
      errorMessage.value = 'Kanal araması hatası: $e';
      AppLogger.error('Kanal araması hatası: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Kaliteyi değiştir
  /// Açıklama: Oynatma sırasında yayın kalitesini değiştirir
  /// quality: Yeni kalite (Auto, 720p, 1080p vb.)
  Future<void> changeQuality(String quality) async {
    try {
      if (selectedChannel.value == null) return;

      isLoading.value = true;
      errorMessage.value = '';

      preferredQuality.value = quality;

      // İstenen kaliteyi getir
      final stream = await _repository.getStreamByQuality(
        selectedChannel.value!.id,
        quality,
      );

      if (stream != null) {
        selectedStream.value = stream;
        AppLogger.success('Kalite değiştirildi: $quality');
      } else {
        // Yoksa en uygununu seç
        await _selectOptimalStream();
        errorMessage.value = 'İstenen kalite mevcut değil';
      }
    } catch (e) {
      errorMessage.value = 'Kalite değiştirilirken hata: $e';
      AppLogger.error('Kalite değiştirilirken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Kanal raporla
  /// Açıklama: Sorunlu kanalı yöneticilere rapor eder
  /// issueDescription: Sorun açıklaması
  /// userId: Raporu gönderen kullanıcı ID'si
  Future<bool> reportChannel({
    required String issueDescription,
    required String userId,
  }) async {
    try {
      if (selectedChannel.value == null) {
        errorMessage.value = 'Kanal seçili değil';
        return false;
      }

      isLoading.value = true;

      final success = await _repository.reportChannel(
        channelId: selectedChannel.value!.id,
        userId: userId,
        issueDescription: issueDescription,
        streamQuality: selectedStream.value?.quality,
      );

      if (success) {
        AppLogger.success('Kanal başarıyla rapor edildi');
      } else {
        errorMessage.value = 'Rapor gönderilemedi';
      }

      return success;
    } catch (e) {
      errorMessage.value = 'Rapor gönderme hatası: $e';
      AppLogger.error('Rapor gönderme hatası: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Kanalı favorilere ekle/çıkar
  /// Açıklama: Kanal favori listesine eklenir/çıkarılır
  /// channelId: Kanal ID'si
  void toggleFavorite(String channelId) {
    if (favoriteChannelIds.contains(channelId)) {
      favoriteChannelIds.remove(channelId);
      AppLogger.info('Kanal favorilerden çıkarıldı');
    } else {
      favoriteChannelIds.add(channelId);
      AppLogger.info('Kanal favorilere eklendi');
    }
    // TODO: Favorileri cihazda kaydet (SharedPreferences)
  }

  /// Kanal favori mi?
  /// Açıklama: Kanal favori listesinde mi?
  /// channelId: Kanal ID'si
  /// Returns: true = favori, false = favori değil
  bool isFavorite(String channelId) {
    return favoriteChannelIds.contains(channelId);
  }

  /// Cache'i temizle
  /// Açıklama: Tüm cache'i siler, yeni veri çekmek için
  void clearCache() {
    _repository.clearCache();
    AppLogger.info('TV cache temizlendi');
  }
}

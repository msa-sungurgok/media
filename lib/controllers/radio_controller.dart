// Radyo Controller
// Açıklama: Radyo ile ilgili işi mantığını yönetir
// View'den gelen istekleri işler ve Repository'ye yönlendirir
// State management ve business logic burada yapılır

import 'package:get/get.dart';
import '../models/radio/radio_channel_model.dart';
import '../repositories/radio_repository.dart';
import '../utils/logger.dart';

/// Radyo Controller Sınıfı
/// Açıklama: GetX kullanarak Radyo ile ilgili state management yapar
/// Kanalları yönetir, oynatma durumunu takip eder, filtreleme yapar
class RadioController extends GetxController {
  /// Radyo Repository instance
  final RadioRepository _repository = RadioRepository();

  /// Tüm radyo kanalları
  /// Açıklama: Supabase'den çekilen radyo kanalları
  final RxList<RadioChannelModel> channels = <RadioChannelModel>[].obs;

  /// Seçili kanal
  /// Açıklama: Kullanıcının şu an dinlemekte olduğu kanal
  final Rx<RadioChannelModel?> selectedChannel = Rx<RadioChannelModel?>(null);

  /// Arama sorgusu
  /// Açıklama: Kanal araması için sorgu metni
  final RxString searchQuery = ''.obs;

  /// Arama sonuçları
  /// Açıklama: Aranan kanalların listesi
  final RxList<RadioChannelModel> searchResults = <RadioChannelModel>[].obs;

  /// Yükleniyormez?
  /// Açıklama: Verilerin yüklenmesi sırasında true olur
  final RxBool isLoading = false.obs;

  /// Hata mesajı
  /// Açıklama: Hata durumunda hata mesajı
  final RxString errorMessage = ''.obs;

  /// Seçili tür filtresi
  /// Açıklama: Türe göre filtreleme için
  final RxString selectedGenre = ''.obs;

  /// Seçili dil filtresi
  /// Açıklama: Dile göre filtreleme için
  final RxString selectedLanguage = ''.obs;

  /// Tüm türler
  /// Açıklama: Filtreleme için mevcut tüm türler
  final RxList<String> genres = <String>[].obs;

  /// Tüm diller
  /// Açıklama: Filtreleme için mevcut tüm diller
  final RxList<String> languages = <String>[].obs;

  /// Favori kanallar
  /// Açıklama: Kullanıcının favorilere eklediği kanallar
  final RxList<String> favoriteChannelIds = <String>[].obs;

  /// Oynatma durumu
  /// Açıklama: Radyo şu an oynatılıyor mu?
  final RxBool isPlaying = false.obs;

  /// Ses seviyesi
  /// Açıklama: Ses seviyesi (0-100)
  final RxInt volume = 50.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('Radyo Controller başlatıldı');
  }

  /// Tüm kanalları yükle
  /// Açıklama: Supabase'den tüm radyo kanallarını çeker
  /// forceRefresh: Cache'i es geç
  Future<void> loadChannels({bool forceRefresh = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final loadedChannels = await _repository.getAllChannels(
        forceRefresh: forceRefresh,
      );

      channels.value = loadedChannels;
      searchResults.value = loadedChannels;

      AppLogger.success(
        'Radyo kanalları yüklendi: ${channels.length} kanal',
      );
    } catch (e) {
      errorMessage.value = 'Kanalları yüklerken hata: $e';
      AppLogger.error('Kanalları yüklerken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Filtre seçeneklerini yükle (türler ve diller)
  /// Açıklama: Filtreleme dropdown'ları için seçenekleri yükler
  Future<void> loadFilterOptions() async {
    try {
      isLoading.value = true;

      final loadedGenres = await _repository.getAllGenres();
      final loadedLanguages = await _repository.getAllLanguages();

      genres.value = loadedGenres;
      languages.value = loadedLanguages;

      AppLogger.success(
        'Filtre seçenekleri yüklendi: ${genres.length} tür, ${languages.length} dil',
      );
    } catch (e) {
      AppLogger.error('Filtre seçenekleri yüklerken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Kanal seç
  /// Açıklama: Kanal listesinden bir kanal seçer ve oynatmaya hazırlar
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
      AppLogger.success('Kanal seçildi: ${channel.name}');
    } catch (e) {
      errorMessage.value = 'Kanal seçerken hata: $e';
      AppLogger.error('Kanal seçerken hata: $e');
    } finally {
      isLoading.value = false;
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
        final results = await _repository.searchChannels(query);
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

  /// Türe göre filtrele
  /// Açıklama: Belirli müzik türündeki kanalları gösterir
  /// genre: Müzik türü
  Future<void> filterByGenre(String genre) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      selectedGenre.value = genre;

      final filtered = await _repository.getChannelsByGenre(genre);
      searchResults.value = filtered;

      AppLogger.info(
        'Türe göre filtrelendi: "$genre" - ${searchResults.length} kanal',
      );
    } catch (e) {
      errorMessage.value = 'Filtreleme hatası: $e';
      AppLogger.error('Filtreleme hatası: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Dile göre filtrele
  /// Açıklama: Belirli dildeki kanalları gösterir
  /// language: Dil kodu
  Future<void> filterByLanguage(String language) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      selectedLanguage.value = language;

      final filtered = await _repository.getChannelsByLanguage(language);
      searchResults.value = filtered;

      AppLogger.info(
        'Dile göre filtrelendi: "$language" - ${searchResults.length} kanal',
      );
    } catch (e) {
      errorMessage.value = 'Filtreleme hatası: $e';
      AppLogger.error('Filtreleme hatası: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Filtreleri sıfırla
  /// Açıklama: Tüm filtreleri kaldırıp tüm kanalları gösterir
  Future<void> clearFilters() async {
    try {
      selectedGenre.value = '';
      selectedLanguage.value = '';
      searchQuery.value = '';
      searchResults.value = channels;
      AppLogger.info('Filtreler sıfırlandı');
    } catch (e) {
      AppLogger.error('Filtreleri sıfırlarken hata: $e');
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

  /// Oynatma durumunu değiştir
  /// Açıklama: Radyoyu oynatır/durdurur
  void togglePlayPause() {
    isPlaying.value = !isPlaying.value;
    AppLogger.info(isPlaying.value ? 'Radyo oynatılıyor' : 'Radyo durduruldu');
    // TODO: Just Audio ile gerçek oynatma işlemi
  }

  /// Ses seviyesini ayarla
  /// Açıklama: Radyo ses seviyesini değiştirir
  /// level: Ses seviyesi (0-100)
  void setVolume(int level) {
    volume.value = level.clamp(0, 100);
    AppLogger.debug('Ses seviyesi ayarlandı: ${volume.value}%');
    // TODO: Just Audio ile gerçek ses ayarı
  }

  /// Cache'i temizle
  /// Açıklama: Tüm cache'i siler, yeni veri çekmek için
  void clearCache() {
    _repository.clearCache();
    AppLogger.info('Radyo cache temizlendi');
  }
}

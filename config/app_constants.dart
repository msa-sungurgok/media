// Uygulama Sabit Değerleri
// Açıklama: Tüm uygulama içinde kullanılacak sabit değerler buraya tanımlanır
// Bu değerleri değiştirerek uygulamanın davranışı özelleştirilebilir

class AppConstants {
  // ==================== VERSİYON BİLGİLERİ ====================
  /// Uygulama versiyonu (Semantic Versioning: major.minor.patch)
  static const String appVersion = '1.0.0';

  /// Uygulama versiyonu kodu (numerik)
  /// Açıklama: Versiyonları karşılaştırmak için kullanılır
  static const int appVersionCode = 1;

  // ==================== ZAMAN AYARLARI ====================
  /// API isteğinin timeout süresi (saniye)
  static const int apiTimeoutSeconds = 30;

  /// Otomatik giriş tokeni geçerlilik süresi (gün)
  static const int rememberMeTokenDays = 30;

  /// Sohbet yavaş modu varsayılan süresi (saniye)
  /// Açıklama: Slow mode aktif edildiğinde mesaj gönderme gecikmeleri
  static const Map<String, int> slowModeOptions = {
    '1 dakika': 60,
    '2 dakika': 120,
    '5 dakika': 300,
    '10 dakika': 600,
    '1 saat': 3600,
  };

  // ==================== PUAN SİSTEMİ ====================
  /// TV kanalı ilk kez izledikten sonra kazanılan puan
  static const int pointsTVFirstWatch = 5;

  /// TV kanalını 1 saat izledikten sonra kazanılan puan
  static const int pointsTVOneHourWatch = 60;

  /// Radyo kanalını 1 saat dinledikten sonra kazanılan puan
  static const int pointsRadioOneHourListen = 50;

  /// Film izledikten sonra kazanılan puan
  static const int pointsMovieWatch = 100;

  /// Yorum yapıldığında kazanılan puan
  static const int pointsCommentCreated = 10;

  /// Yorum beğenildiğinde kazanılan puan
  static const int pointsCommentLiked = 5;

  // ==================== KULLANICI GRUBU PUAN LİMİTLERİ ====================
  /// Yeni Üye: 0 puan
  static const int pointsForNewMember = 0;

  /// Bronz Üye: 3.000 puan
  static const int pointsForBronzeMember = 3000;

  /// Normal Üye: 1.000 puan (geçici, Gold Üyeye terfiler)
  static const int pointsForNormalMember = 1000;

  /// Platin Üye: 5.000 puan
  static const int pointsForPlatinumMember = 5000;

  /// Gold Üye: 10.000 puan
  static const int pointsForGoldMember = 10000;

  /// VIP Üye: 50.000 puan
  static const int pointsForVIPMember = 50000;

  // ==================== CEZA SİSTEMİ ====================
  /// 1 ay içinde maksimum kaç defa susturulabilir
  /// Açıklama: 5. kez susturulduktan sonra ıkinci kez affedilmezse tam ban
  static const int maxMutesBeforePermanentBan = 5;

  /// 1 ay içinde maksimum kaç defa engellenebilir
  /// Açıklama: 5. kez engellenip affedildikten sonra sadece root affedebilir
  static const int maxBlocksBeforeRootUnblock = 5;

  /// Ceza sayısını sıfırlamak için geçecek gün sayısı
  static const int daysToResetPenalties = 30;

  // ==================== LİST GÖRÜNTÜLEME ====================
  /// Listeleme sayfasında gösterilecek maksimum film/tv sayısı
  static const int maxItemsPerPage = 10;

  /// "Daha fazla göster" butonuyla eklenecek item sayısı
  static const int loadMoreItemsCount = 10;

  // ==================== DOSYA BOYUT LİMİTLERİ ====================
  /// Logo dosyası maksimum boyutu (MB)
  static const int maxLogoSizeMB = 5;

  /// Kapak resmi maksimum boyutu (MB)
  static const int maxCoverImageSizeMB = 10;

  /// Avatar maksimum boyutu (MB)
  static const int maxAvatarSizeMB = 3;

  // ==================== PLAYER AYARLARI ====================
  /// TV player varsayılan başlama modu
  /// Açıklama: true = tam ekran, false = küçük ekran
  static const bool defaultTVPlayerFullscreen = true;

  /// Kanal listesi varsayılan konumu
  /// Açıklama: 'LEFT', 'RIGHT', 'TOP', 'BOTTOM'
  static const String defaultChannelListPosition = 'RIGHT';

  /// Kanal listesi varsayılan şeffaflığı
  /// Açıklama: 'TRANSPARENT', 'OPAQUE'
  static const String defaultChannelListTransparency = 'TRANSPARENT';

  // ==================== UYGULAMANIN BAŞLANGIÇ AYARLARI ====================
  /// Uygulama başladığında gösterilecek sekmesi
  /// Açıklama: 'TV', 'RADIO', 'MOVIE', 'CHAT'
  static const String defaultStartupTab = 'TV';

  /// Bildirimler varsayılan olarak açık mı?
  static const bool defaultNotificationsEnabled = true;

  /// Tema varsayılan modu
  /// Açıklama: 'LIGHT', 'DARK'
  static const String defaultThemeMode = 'DARK';

  // ==================== SOSYAL BAĞLANTILAR ====================
  /// Uygulamanın web sitesi URL'si (boş bırakılabilir)
  static const String websiteUrl = '';

  /// Uygulamanın Telegram kanalı URL'si (boş bırakılabilir)
  static const String telegramChannelUrl = '';

  /// Uygulamanın YouTube kanalı URL'si (boş bırakılabilir)
  static const String youtubeChannelUrl = '';

  /// Uygulamanın Instagram sayfası URL'si (boş bırakılabilir)
  static const String instagramUrl = '';

  /// Uygulamanın Twitter sayfası URL'si (boş bırakılabilir)
  static const String twitterUrl = '';

  // ==================== LOGLAMA ====================
  /// Loglama sistemi aktif mi?
  static const bool enableLogging = true;

  /// Debug modu etkin mi?
  static const bool debugMode = true;

  /// Console'a çıktı verilsin mi?
  static const bool printLogs = true;

  // ==================== YÖNETİCİ ROLLERI ====================
  /// Yönetici rol seçenekleri
  /// Açıklama: Root > Admin > Editör > Moderatör
  static const List<String> adminRoles = ['Root', 'Admin', 'Editör', 'Moderatör'];

  // ==================== KULLANICI GRUBU SEÇENEKLERI ====================
  /// Kullanıcı grubu seçenekleri
  static const List<String> userGroupNames = [
    'Yeni Üye',
    'Normal Üye',
    'Bronz Üye',
    'Platin Üye',
    'Gold Üye',
    'VIP Üye',
    'Onursal Üye',
  ];
}

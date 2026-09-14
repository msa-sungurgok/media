// TV Yayın Akışı Model Sınıfı
// Açıklama: TV kanalının farklı kalitelerdeki yayın URL'lerini temsil eder
// Örnek: Auto, 360p, 480p, 720p, 1080p vb.

import 'package:json_annotation/json_annotation.dart';

part 'tv_stream_model.g.dart';

/// Yayın Kalitesi Enum
/// Açıklama: Desteklenen yayın kaliteleri
enum StreamQuality {
  /// Otomatik kalite seçimi
  /// Açıklama: Sistem bağlantı hızına göre kaliteyi seçer
  @JsonValue('Auto')
  auto('Auto'),
  
  /// 360p (SD kalite)
  @JsonValue('SD-360p')
  sd360('SD-360p'),
  
  /// 480p (SD kalite)
  @JsonValue('SD-480p')
  sd480('SD-480p'),
  
  /// 720p (HD kalite)
  @JsonValue('HD-720p')
  hd720('HD-720p'),
  
  /// 1080p (Full HD kalite)
  @JsonValue('FHD-1080p')
  fhd1080('FHD-1080p'),
  
  /// 1440p (2K kalite)
  @JsonValue('2K-1440p')
  k2_1440('2K-1440p'),
  
  /// 2160p (4K UHD kalite)
  @JsonValue('4K-2160p')
  k4_2160('4K-2160p'),
  
  /// 4320p (8K UHD kalite)
  @JsonValue('8K-4320p')
  k8_4320('8K-4320p');

  final String value;
  const StreamQuality(this.value);
}

/// TV Yayın Akışı Model Sınıfı
/// Açıklama: Supabase'deki tv_streams tablosundan gelen veriyi temsil eder
/// TV kanalının farklı kalitelerdeki yayın linklerini içerir
@JsonSerializable()
class TVStreamModel {
  /// Yayın Akışı UUID
  /// Açıklama: Supabase tarafından otomatik oluşturulan unique ID
  @JsonKey(name: 'id')
  final String id;

  /// TV Kanal ID
  /// Açıklama: tv_channels tablosundaki kanal ID'si
  /// Bu yayın akışı hangi kanalın?
  @JsonKey(name: 'tv_channel_id')
  final String tvChannelId;

  /// Yayın kalitesi
  /// Açıklama: Bu linkinin kalitesi nedir?
  /// Örnek: Auto, 720p, 1080p vb.
  @JsonKey(name: 'quality')
  final String quality;

  /// Yayın URL'si
  /// Açıklama: M3U8, MP4 veya diğer video akış formatının URL'si
  /// Bu URL'den video verisi çekilir ve player'da oynatılır
  @JsonKey(name: 'stream_url')
  final String streamUrl;

  /// Platform/Kaynak
  /// Açıklama: Yayın nerenin platformu? (örnek: TRT, Digiturk vb.)
  /// Yönetim için referans bilgisi
  @JsonKey(name: 'platform')
  final String? platform;

  /// Bitrate (kbps)
  /// Açıklama: Yayın hızı kilobit/saniye cinsinden
  /// Kalite tahmini için kullanılabilir
  @JsonKey(name: 'bitrate')
  final int? bitrate;

  /// Çalışıyor mu?
  /// Açıklama: Yayın akışı şu an çalışıyor mu?
  /// true = Çalışıyor (izlenebilir)
  /// false = Bozuk veya erişilemiyor
  /// İşten sonra yönetici tarafından güncellenir
  @JsonKey(name: 'is_working')
  final bool isWorking;

  /// Ekleyen yönetici ID
  /// Açıklama: Bu yayın akışını hangi yönetici ekledi?
  @JsonKey(name: 'added_by')
  final String addedBy;

  /// Oluşturulma tarihi
  /// Açıklama: Yayın akışı ne zaman sisteme eklendi?
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Güncellenme tarihi
  /// Açıklama: Yayın akışı bilgileri en son ne zaman güncellendi?
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  /// Constructor
  TVStreamModel({
    required this.id,
    required this.tvChannelId,
    required this.quality,
    required this.streamUrl,
    this.platform,
    this.bitrate,
    required this.isWorking,
    required this.addedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON'dan Model'e dönüştürme
  factory TVStreamModel.fromJson(Map<String, dynamic> json) =>
      _$TVStreamModelFromJson(json);

  /// Model'den JSON'a dönüştürme
  Map<String, dynamic> toJson() => _$TVStreamModelToJson(this);
}

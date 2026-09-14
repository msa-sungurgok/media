// Radyo Kanalı Model Sınıfı
// Açıklama: Radyo kanalı bilgilerini temsil eder
// Radyo adı, logosu, yayın akışı vb.

import 'package:json_annotation/json_annotation.dart';

part 'radio_channel_model.g.dart';

/// Radyo Kanalı Model Sınıfı
/// Açıklama: Supabase'deki radio_channels tablosundan gelen veriyi temsil eder
/// Radyo kanalının temel bilgilerini içerir
@JsonSerializable()
class RadioChannelModel {
  /// Kanal UUID
  /// Açıklama: Supabase tarafından otomatik oluşturulan unique ID
  @JsonKey(name: 'id')
  final String id;

  /// Kanal adı
  /// Açıklama: Radyo kanalının adı (örnek: Metro FM, Radyo Türk vb.)
  /// Unique (benzersiz) olmalı
  @JsonKey(name: 'name')
  final String name;

  /// Kanal açıklaması
  /// Açıklama: Radyo kanalı hakkında kısa bilgi
  @JsonKey(name: 'description')
  final String? description;

  /// Logo URL'si
  /// Açıklama: Radyo kanalının logosunun URL'si
  /// Lokal veya web kaynaklarından olabilir
  @JsonKey(name: 'logo_url')
  final String logoUrl;

  /// Yayın URL'si
  /// Açıklama: Radyo yayın akışının URL'si
  /// Genellikle tek bir URL (Auto kalitesi)
  /// Format: M3U8 veya MP3
  @JsonKey(name: 'stream_url')
  final String streamUrl;

  /// Bitrate (kbps)
  /// Açıklama: Radyo yayın hızı kilobit/saniye cinsinden
  /// Örnek: 128, 192, 320 kbps
  @JsonKey(name: 'bitrate')
  final int? bitrate;

  /// Dil
  /// Açıklama: Radyo yayınının dili (örnek: tr, en, de vb.)
  @JsonKey(name: 'language')
  final String? language;

  /// Tür/Müzik Türü
  /// Açıklama: Radyonun tür kategorisi (örnek: Pop, Rock, Klasik vb.)
  @JsonKey(name: 'genre')
  final String? genre;

  /// Aktif mi?
  /// Açıklama: Radyo kanalı sisteme aktif mi?
  /// true = Aktif (kullanıcılar dinleyebilir)
  /// false = Deaktif (listede görünmez)
  @JsonKey(name: 'is_active')
  final bool isActive;

  /// Oluşturan yönetici ID
  /// Açıklama: Radyoyu hangi yönetici ekledi?
  @JsonKey(name: 'created_by')
  final String createdBy;

  /// Oluşturulma tarihi
  /// Açıklama: Radyo ne zaman sisteme eklendi?
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Güncellenme tarihi
  /// Açıklama: Radyo bilgileri en son ne zaman güncellendi?
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  /// Constructor
  RadioChannelModel({
    required this.id,
    required this.name,
    this.description,
    required this.logoUrl,
    required this.streamUrl,
    this.bitrate,
    this.language,
    this.genre,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON'dan Model'e dönüştürme
  factory RadioChannelModel.fromJson(Map<String, dynamic> json) =>
      _$RadioChannelModelFromJson(json);

  /// Model'den JSON'a dönüştürme
  Map<String, dynamic> toJson() => _$RadioChannelModelToJson(this);
}

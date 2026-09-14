// TV Kanalı Model Sınıfı
// Açıklama: TV kanalı bilgilerini temsil eder
// Kanal adı, logosu, EPG URL'si, şifreleme durumu vb.

import 'package:json_annotation/json_annotation.dart';

part 'tv_channel_model.g.dart';

/// TV Kanalı Model Sınıfı
/// Açıklama: Supabase'deki tv_channels tablosundan gelen veriyi temsil eder
/// TV kanalının temel bilgilerini (ad, logo, EPG vb.) içerir
@JsonSerializable()
class TVChannelModel {
  /// Kanal UUID
  /// Açıklama: Supabase tarafından otomatik oluşturulan unique ID
  @JsonKey(name: 'id')
  final String id;

  /// Kanal adı
  /// Açıklama: TV kanalının adı (örnek: TRT 1, Kanal D vb.)
  /// Unique (benzersiz) olmalı
  @JsonKey(name: 'name')
  final String name;

  /// Kanal açıklaması
  /// Açıklama: Kanal hakkında kısa bilgi
  @JsonKey(name: 'description')
  final String? description;

  /// Logo URL'si
  /// Açıklama: Kanal logosunun URL'si
  /// Lokal: images/tv/logo klasöründe saklanabilir
  /// Web: CDN veya direct link
  @JsonKey(name: 'logo_url')
  final String logoUrl;

  /// EPG URL'si
  /// Açıklama: Elektronik Program Rehberi (TV rehberi) verisi URL'si
  /// Format: JSON veya XML
  /// Yönetici tarafından eklenebilir/düzenlenebilir
  @JsonKey(name: 'epg_url')
  final String? epgUrl;

  /// Şifreli kanal mı?
  /// Açıklama: Kanal yalnızca belirli kullanıcı gruplarına açık mı?
  /// true = Şifreli (encrypted_for_groups'ta belirtilen gruplara açık)
  /// false = Herkesin erişebileceği açık kanal
  @JsonKey(name: 'is_encrypted')
  final bool isEncrypted;

  /// Erişebilecek grup ID'leri (Şifreli kanal için)
  /// Açıklama: Bu kanal hangi kullanıcı grupları tarafından izlenebilir?
  /// null veya boş array = Şifreli değilse herkes izleyebilir
  /// dolu array = Sadece bu gruplardaki kullanıcılar izleyebilir
  @JsonKey(name: 'encrypted_for_groups')
  final List<String>? encryptedForGroups;

  /// Erişemeyen grup ID'leri
  /// Açıklama: Kanal hangi gruplara kapatılmış?
  /// Örnek: Yeni üyelere kanalı kapatmak gibi
  @JsonKey(name: 'is_blocked_for_groups')
  final List<String>? blockedForGroups;

  /// Aktif mi?
  /// Açıklama: Kanal sistemde aktif mi?
  /// true = Aktif (kullanıcılara gösterilir)
  /// false = Deaktif (listede görünmez, silişi bekliyor)
  @JsonKey(name: 'is_active')
  final bool isActive;

  /// Oluşturan yönetici ID
  /// Açıklama: Kanalı hangi yönetici ekledi?
  @JsonKey(name: 'created_by')
  final String createdBy;

  /// Oluşturulma tarihi
  /// Açıklama: Kanal ne zaman sisteme eklendi?
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Güncellenme tarihi
  /// Açıklama: Kanal bilgileri en son ne zaman güncellendi?
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  /// Constructor
  TVChannelModel({
    required this.id,
    required this.name,
    this.description,
    required this.logoUrl,
    this.epgUrl,
    required this.isEncrypted,
    this.encryptedForGroups,
    this.blockedForGroups,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON'dan Model'e dönüştürme
  factory TVChannelModel.fromJson(Map<String, dynamic> json) =>
      _$TVChannelModelFromJson(json);

  /// Model'den JSON'a dönüştürme
  Map<String, dynamic> toJson() => _$TVChannelModelToJson(this);

  /// Kullanıcı bu kanalı izleyebilir mi?
  /// Açıklama: Kullanıcının grup ID'sine göre izleme yetkisi kontrol eder
  /// Returns: true = İzleyebilir, false = İzleyemez
  bool canUserWatch(String userGroupId) {
    // Kanal deaktif ise hiç kimse izleyemez
    if (!isActive) return false;

    // Kanal şifreli ise encrypted_for_groups kontrol edilir
    if (isEncrypted) {
      // Şifreli ama izin verilen grup boş = hiç kimse izleyemez
      if (encryptedForGroups == null || encryptedForGroups!.isEmpty) {
        return false;
      }
      // Kullanıcı izin verilen gruplardan biri ise izleyebilir
      return encryptedForGroups!.contains(userGroupId);
    }

    // Kanal bloke edilen gruplara kapalı mı?
    if (blockedForGroups != null && blockedForGroups!.contains(userGroupId)) {
      return false;
    }

    // Şifreli değilse herkes izleyebilir
    return true;
  }
}

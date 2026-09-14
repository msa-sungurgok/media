// Kullanıcı Grubu Model Sınıfı
// Açıklama: Kullanıcı seviyeleri ve gruplarını temsil eder
// Örnek: Yeni Üye, Bronz Üye, Gold Üye, VIP Üye vb.

import 'package:json_annotation/json_annotation.dart';

part 'user_group_model.g.dart';

/// Kullanıcı Grubu Model Sınıfı
/// Açıklama: Sistemin kullanıcı seviyelerini ve özelliklerini tanımlar
/// Kullanıcılar puanlarına göre otomatik olarak grup seviyesine terfi olurlar
@JsonSerializable()
class UserGroupModel {
  /// Grup UUID
  /// Açıklama: Supabase tarafından otomatik oluşturulan unique ID
  @JsonKey(name: 'id')
  final String id;

  /// Grup adı
  /// Açıklama: Grup adı (örnek: Yeni Üye, Bronz Üye, VIP Üye)
  /// Sistem tarafından oluşturulan gruplar değiştirilemez
  @JsonKey(name: 'name')
  final String name;

  /// Grup açıklaması
  /// Açıklama: Grup hakkında kısa bilgi
  @JsonKey(name: 'description')
  final String? description;

  /// Minimum puan
  /// Açıklama: Bu gruba dahil olmak için gereken minimum puan
  /// Örnek: Gold Üye için 10.000 puan gerekli
  /// null = Sistem grubu, manuel olarak tanımlanmış
  @JsonKey(name: 'min_points')
  final int? minPoints;

  /// Grup ikonu URL'si
  /// Açıklama: Grup seviyesini gösteren icon
  @JsonKey(name: 'icon_url')
  final String? iconUrl;

  /// Renk kodu
  /// Açıklama: Grup seviyesini göstermek için kullanılan renk
  /// Format: #XXXXXX (Hex color code)
  /// Örnek: #FFD700 (Altın rengi - Gold Üye)
  @JsonKey(name: 'color_code')
  final String? colorCode;

  /// Sistem grubu mu?
  /// Açıklama: Sistem tarafından oluşturulan grup mu?
  /// true = Sistem grubu (silinip değiştirilmez)
  /// false = Kullanıcı tanımlı grup (admin tarafından yönetilebilir)
  @JsonKey(name: 'is_system')
  final bool isSystem;

  /// Oluşturulma tarihi
  /// Açıklama: Grup ne zaman sisteme eklendi?
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Constructor
  UserGroupModel({
    required this.id,
    required this.name,
    this.description,
    this.minPoints,
    this.iconUrl,
    this.colorCode,
    required this.isSystem,
    required this.createdAt,
  });

  /// JSON'dan Model'e dönüştürme
  factory UserGroupModel.fromJson(Map<String, dynamic> json) =>
      _$UserGroupModelFromJson(json);

  /// Model'den JSON'a dönüştürme
  Map<String, dynamic> toJson() => _$UserGroupModelToJson(this);

  /// Sistem grubu adları
  /// Açıklama: Sistemde önceden tanımlanmış grup adları
  static const List<String> systemGroupNames = [
    'Yeni Üye',
    'Normal Üye',
    'Bronz Üye',
    'Platin Üye',
    'Gold Üye',
    'VIP Üye',
    'Onursal Üye',
  ];
}

// Kullanıcı Model Sınıfı
// Açıklama: Supabase'deki users tablosundan gelen veriyi temsil eder
// Bu model kullanıcı bilgilerini saklar ve JSON serileştirme destekler

import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart'; // JSON serialization için gerekli

/// Kullanıcı Model Sınıfı
/// Açıklama: Sistemin temel kullanıcı sınıfı
/// - Kullanıcı bilgileri (username, email, telefon)
/// - Kullanıcı durumu (onaylı, banlandı)
/// - Puan ve grup bilgileri
@JsonSerializable()
class UserModel {
  /// Kullanıcı UUID
  /// Açıklama: Supabase tarafından otomatik oluşturulan unique ID
  @JsonKey(name: 'id')
  final String id;

  /// Kullanıcı adı
  /// Açıklama: Giriş yapılırken veya aramada kullanılan ad
  /// Kurallar: Minimum 3, maksimum 100 karakter
  /// Unique (benzersiz) olmalı
  @JsonKey(name: 'username')
  final String username;

  /// Email adresi
  /// Açıklama: Giriş ve iletişim için kullanılan email
  /// Unique (benzersiz) olmalı
  /// Geçerli format kontrolü yapılmalı
  @JsonKey(name: 'email')
  final String email;

  /// Şifre hash
  /// Açıklama: Şifre Supabase tarafından otomatik hash'lenir
  /// Asla plain text olarak saklanmaz
  @JsonKey(name: 'password_hash')
  final String? passwordHash;

  /// Telefon numarası
  /// Açıklama: İsteğe bağlı, kullanıcı profili için
  @JsonKey(name: 'phone')
  final String? phone;

  /// Profil resmi URL'si
  /// Açıklama: Kullanıcının avatarı/profil resmi
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;

  /// Kullanıcı grubu ID
  /// Açıklama: user_groups tablosundaki grup ID'si
  /// Örnek: Yeni Üye, Bronz Üye, VIP Üye vb.
  @JsonKey(name: 'user_group_id')
  final String userGroupId;

  /// Onaylı mı?
  /// Açıklama: Admin tarafından onaylanmış kullanıcı mı?
  /// false = Onay bekleniyor, gerçek üyelere giriş kapalı
  /// true = Onaylanmış, sisteme tam erişim
  @JsonKey(name: 'is_approved')
  final bool isApproved;

  /// Banlandı mı?
  /// Açıklama: Kullanıcı sistemi yasaklanmış mı?
  /// true = Banlandı (giriş yapamaz)
  /// false = Normal durum
  @JsonKey(name: 'is_banned')
  final bool isBanned;

  /// Ban sebebi
  /// Açıklama: Kullanıcı neden banlandı?
  @JsonKey(name: 'ban_reason')
  final String? banReason;

  /// Ban bitiş tarihi
  /// Açıklama: Süreli ban için bitiş tarihi
  /// null = Süresiz ban
  @JsonKey(name: 'ban_end_date')
  final DateTime? banEndDate;

  /// Toplam puan
  /// Açıklama: Kullanıcının topladığı toplam puanlar
  /// TV izlemek, yorum yapmak, beğenmek gibi işlemlerden puan kazanır
  /// Puanlar arttıkça kullanıcı grup seviyesi otomatik olarak yükselir
  @JsonKey(name: 'total_points')
  final int totalPoints;

  /// Beni hatırla tokeni
  /// Açıklama: Otomatik giriş için kullanılan token
  /// Kullanıcı "Beni Hatırla" seçerse bu token saklanır
  @JsonKey(name: 'remember_me_token')
  final String? rememberMeToken;

  /// Son giriş tarihi
  /// Açıklama: Kullanıcının en son sisteme girişi
  @JsonKey(name: 'last_login')
  final DateTime? lastLogin;

  /// Oluşturulma tarihi
  /// Açıklama: Kullanıcı ne zaman sisteme kayıt oldu?
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Güncellenme tarihi
  /// Açıklama: Kullanıcı bilgileri en son ne zaman güncellendi?
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  /// Constructor
  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.passwordHash,
    this.phone,
    this.profilePictureUrl,
    required this.userGroupId,
    required this.isApproved,
    required this.isBanned,
    this.banReason,
    this.banEndDate,
    required this.totalPoints,
    this.rememberMeToken,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON'dan Model'e dönüştürme
  /// Açıklama: Supabase'den gelen JSON verisini UserModel'e çevirir
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Model'den JSON'a dönüştürme
  /// Açıklama: UserModel'i JSON formatına çevirir (Supabase'e göndermek için)
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Kullanıcı banlandı mı kontrol et
  /// Açıklama: Şu an için kullanıcı banlanmış durumda mı?
  /// Süreli ban bitmiş ise false döner
  bool get isCurrentlyBanned {
    if (!isBanned) return false;
    if (banEndDate == null) return true; // Süresiz ban
    return DateTime.now().isBefore(banEndDate!); // Süreli ban kontrol
  }

  /// Kullanıcı onay bekleniyor mu?
  /// Açıklama: Admin onayı almamış mı?
  bool get isPendingApproval => !isApproved && !isBanned;
}

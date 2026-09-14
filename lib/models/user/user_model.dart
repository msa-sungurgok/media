// Kullanıcı Model Sınıfı

class UserModel {
  final String id;
  final String username;
  final String email;
  final String? phone;
  final String? profilePictureUrl;
  final String userGroupId;
  final bool isApproved;
  final bool isBanned;
  final int totalPoints;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    this.profilePictureUrl,
    required this.userGroupId,
    required this.isApproved,
    required this.isBanned,
    required this.totalPoints,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profilePictureUrl: json['profile_picture_url'],
      userGroupId: json['user_group_id'] ?? '',
      isApproved: json['is_approved'] ?? false,
      isBanned: json['is_banned'] ?? false,
      totalPoints: json['total_points'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'profile_picture_url': profilePictureUrl,
      'user_group_id': userGroupId,
      'is_approved': isApproved,
      'is_banned': isBanned,
      'total_points': totalPoints,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

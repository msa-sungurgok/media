// TV Kanalı Model Sınıfı

class TVChannelModel {
  final String id;
  final String name;
  final String? description;
  final String logoUrl;
  final String? epgUrl;
  final bool isEncrypted;
  final List<String>? encryptedForGroups;
  final List<String>? blockedForGroups;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

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

  factory TVChannelModel.fromJson(Map<String, dynamic> json) {
    return TVChannelModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      logoUrl: json['logo_url'] ?? '',
      epgUrl: json['epg_url'],
      isEncrypted: json['is_encrypted'] ?? false,
      encryptedForGroups: List<String>.from(json['encrypted_for_groups'] ?? []),
      blockedForGroups: List<String>.from(json['is_blocked_for_groups'] ?? []),
      isActive: json['is_active'] ?? true,
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'epg_url': epgUrl,
      'is_encrypted': isEncrypted,
      'encrypted_for_groups': encryptedForGroups,
      'is_blocked_for_groups': blockedForGroups,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool canUserWatch(String userGroupId) {
    if (!isActive) return false;
    if (isEncrypted) {
      if (encryptedForGroups == null || encryptedForGroups!.isEmpty) {
        return false;
      }
      return encryptedForGroups!.contains(userGroupId);
    }
    if (blockedForGroups != null && blockedForGroups!.contains(userGroupId)) {
      return false;
    }
    return true;
  }
}

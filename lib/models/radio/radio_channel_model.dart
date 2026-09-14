// Radyo Kanalı Model Sınıfı

class RadioChannelModel {
  final String id;
  final String name;
  final String? description;
  final String logoUrl;
  final String streamUrl;
  final int? bitrate;
  final String? language;
  final String? genre;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

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

  factory RadioChannelModel.fromJson(Map<String, dynamic> json) {
    return RadioChannelModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      logoUrl: json['logo_url'] ?? '',
      streamUrl: json['stream_url'] ?? '',
      bitrate: json['bitrate'],
      language: json['language'],
      genre: json['genre'],
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
      'stream_url': streamUrl,
      'bitrate': bitrate,
      'language': language,
      'genre': genre,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

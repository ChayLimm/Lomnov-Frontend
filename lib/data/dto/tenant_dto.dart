import 'package:app/domain/models/contract/tenant_model.dart';

/// Data Transfer Object for tenant information.
class TenantDto {
  final int id;
  final String name;
  final String? email;
  final String? phonenumber;
  final String? identifyId;
  final String? profileImageUrl;
  final String? identifyImageUrl;
  final String? username;
  final String? telegramId;
  final String createdAt;
  final String updatedAt;

  TenantDto({
    required this.id,
    required this.name,
    this.email,
    this.phonenumber,
    this.identifyId,
    this.profileImageUrl,
    this.identifyImageUrl,
    this.username,
    this.telegramId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TenantDto.fromJson(Map<String, dynamic> json) {
    return TenantDto(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String?,
      phonenumber: json['phonenumber'] as String?,
      identifyId: json['identify_id'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      identifyImageUrl: json['identify_image_url'] as String?,
      username: json['username'] as String?,
      telegramId: json['telegram_id'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  /// Converts DTO to domain model.
  TenantModel toDomain() {
    return TenantModel(
      id: id,
      name: name,
      email: email,
      phoneNumber: phonenumber,
      identifyId: identifyId,
      profileImageUrl: profileImageUrl,
      identifyImageUrl: identifyImageUrl,
      username: username,
      telegramId: telegramId,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}

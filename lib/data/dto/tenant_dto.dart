import 'package:app/domain/models/contract/tenant_model.dart';

class TenantDto {
  final int id;
  final int? landlordId;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? telegramId;
  final String? identifyId;
  final String? profileImageUrl;
  final String? identifyImageUrl;
  final Map<String, dynamic>? emergencyContact;
  final String createdAt;
  final String updatedAt;

  TenantDto({
    required this.id,
    this.landlordId,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.telegramId,
    this.identifyId,
    this.profileImageUrl,
    this.identifyImageUrl,
    this.emergencyContact,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TenantDto.fromJson(Map<String, dynamic> json) {
    // Extract first name and last name from JSON
    String? firstName = json['first_name'] as String?;
    String? lastName = json['last_name'] as String?;
    
    // Fallback: if first_name/last_name are not available, try to split from 'name'
    if (firstName == null || lastName == null) {
      final String? name = json['name'] as String?;
      if (name != null && name.isNotEmpty) {
        final parts = name.split(' ');
        if (parts.length > 1) {
          firstName = parts[0];
          lastName = parts.sublist(1).join(' ');
        } else {
          firstName = name;
          lastName = '';
        }
      }
    }
    
    // Extract phone number
    final String? phone = json['phone'] as String?;
    final String? phonenumber = json['phonenumber'] as String?;

    return TenantDto(
      id: json['id'] as int,
      landlordId: json['landlord_id'] as int?,
      firstName: firstName ?? '',
      lastName: lastName ?? '',
      email: json['email'] as String?,
      phone: phone ?? phonenumber,
      telegramId: json['telegram_id'] as String?,
      identifyId: json['identify_id'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      identifyImageUrl: json['identify_image_url'] as String?,
      emergencyContact: json['emergency_contact'] as Map<String, dynamic>?,
      createdAt: (json['created_at'] as String?) ?? '',
      updatedAt: (json['updated_at'] as String?) ?? '',
    );
  }

  String get fullName {
    final parts = [firstName, lastName].where((part) => part.isNotEmpty);
    return parts.join(' ').trim();
  }

  TenantModel toDomain() {
    return TenantModel(
      id: id,
      name: fullName,
      email: email,
      phoneNumber: phone,
      identifyId: identifyId,
      profileImageUrl: profileImageUrl,
      identifyImageUrl: identifyImageUrl,
      username: null, // Not in your JSON
      telegramId: telegramId,
      createdAt: createdAt.isNotEmpty ? DateTime.tryParse(createdAt) ?? DateTime.now() : DateTime.now(),
      updatedAt: updatedAt.isNotEmpty ? DateTime.tryParse(updatedAt) ?? DateTime.now() : DateTime.now(),
    );
  }

  // Optional: Add a toJson method if you need to serialize back
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'landlord_id': landlordId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'telegram_id': telegramId,
      'identify_id': identifyId,
      'profile_image_url': profileImageUrl,
      'identify_image_url': identifyImageUrl,
      'emergency_contact': emergencyContact,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
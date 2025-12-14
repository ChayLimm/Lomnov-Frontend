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
    // Some APIs use first_name/last_name and phone instead of name/phonenumber.
    final String? firstName = json['first_name'] as String?;
    final String? lastName = json['last_name'] as String?;
    final String? name = json['name'] as String?;
    final String composedName =
        (name ??
                [
                  firstName,
                  lastName,
                ].where((e) => e != null && e!.isNotEmpty).join(' '))
            .trim();

    final String? phone = json['phone'] as String?;
    final String? phonenumber = json['phonenumber'] as String?;

    return TenantDto(
      id: json['id'] as int? ?? 0,
      landlordId: json['landlord_id'] as int?,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      telegramId: json['telegram_id'] as String?,
      identifyId: json['identify_id'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      identifyImageUrl: json['identify_image_url'] as String?,
      emergencyContact: json['emergency_contact'] as Map<String, dynamic>?,
      createdAt: (json['created_at'] as String?) ?? '',
      updatedAt: (json['updated_at'] as String?) ?? '',
    );
  }

  String get fullName => '$firstName $lastName';

  TenantModel toDomain() {
    return TenantModel(
      id: id,
      name: fullName, // Combine first + last
      email: email,
      phoneNumber: phone, // Map 'phone' to 'phoneNumber'
      identifyId: identifyId,
      profileImageUrl: profileImageUrl,
      identifyImageUrl: identifyImageUrl,
      username: null, // Not in your JSON
      telegramId: telegramId,
      createdAt: createdAt.isNotEmpty
          ? DateTime.parse(createdAt)
          : DateTime.now(),
      updatedAt: updatedAt.isNotEmpty
          ? DateTime.parse(updatedAt)
          : DateTime.now(),
    );
  }
}
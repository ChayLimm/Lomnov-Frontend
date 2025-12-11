/// Domain model representing a tenant.
class TenantModel {
  final int id;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? identifyId;
  final String? profileImageUrl;
  final String? identifyImageUrl;
  final String? username;
  final String? telegramId;
  final DateTime createdAt;
  final DateTime updatedAt;

  TenantModel({
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
    this.identifyId,
    this.profileImageUrl,
    this.identifyImageUrl,
    this.username,
    this.telegramId,
    required this.createdAt,
    required this.updatedAt,
  });
}

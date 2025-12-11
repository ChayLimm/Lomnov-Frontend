import 'package:app/domain/models/settings/role_model.dart';

class RoleDto {
  final int id;
  final String roleName;
  final List<UserSummary> users;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RoleDto({
    required this.id,
    required this.roleName,
    this.users = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory RoleDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final usersJson = (data['users'] as List?) ?? const [];
    return RoleDto(
      id: data['id'] ?? 0,
      roleName: data['role_name'] ?? data['roleName'] ?? '',
      users: usersJson
          .map((u) => UserSummary(
                id: (u['id'] ?? 0) as int,
                name: (u['name'] ?? '') as String,
                email: (u['email'] ?? '') as String,
              ))
          .toList(),
      createdAt: _parseDate(data['created_at']),
      updatedAt: _parseDate(data['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role_name': roleName,
        'users': users
            .map((u) => {
                  'id': u.id,
                  'name': u.name,
                  'email': u.email,
                })
            .toList(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  RoleModel toDomain() => RoleModel(
        id: id,
        roleName: roleName,
        users: users,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static List<RoleDto> fromJsonList(List<dynamic> list) {
    return list.map((e) => RoleDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) {
      return DateTime.tryParse(v);
    }
    return null;
  }
}
class RoleModel {
  final int id;
  final String roleName;
  final List<UserSummary> users;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RoleModel({
    required this.id,
    required this.roleName,
    this.users = const [],
    this.createdAt,
    this.updatedAt,
  });

  RoleModel copyWith({
    int? id,
    String? roleName,
    List<UserSummary>? users,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoleModel(
      id: id ?? this.id,
      roleName: roleName ?? this.roleName,
      users: users ?? this.users,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserSummary {
  final int id;
  final String name;
  final String email;

  const UserSummary({required this.id, required this.name, required this.email});
}
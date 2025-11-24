class UserModel {
  final int id;
  final String name;
  final String email;
  final String token;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
      avatarUrl: json['profile_image_url'] as String?,
    );
  }
}

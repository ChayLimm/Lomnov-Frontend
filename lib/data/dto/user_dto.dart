import '../../domain/models/user_model.dart';

class UserDto {
  final int id;
  final String name;
  final String email;
  final String token;

  UserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    final dynamic idVal = json['id'];
    final int id = idVal is int
        ? idVal
        : int.tryParse(idVal?.toString() ?? '') ?? 0;

    return UserDto(
      id: id,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
    };
  }

  UserModel toDomain() {
    return UserModel(
      id: id,
      name: name,
      email: email,
      token: token,
    );
  }

  factory UserDto.fromDomain(UserModel model) {
    return UserDto(
      id: model.id,
      name: model.name,
      email: model.email,
      token: model.token,
    );
  }
}

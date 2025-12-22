import 'dart:convert';

class RegistrationPayload {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final String? identityImageUrl;

  RegistrationPayload({
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.identityImageUrl,
  });

  factory RegistrationPayload.fromJson(Map<String, dynamic> json) {
    return RegistrationPayload(
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      identityImageUrl: json['identity_image_url']?.toString(),
    );
  }

  static RegistrationPayload? fromDynamic(dynamic data) {
    if (data == null) return null;
    
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return RegistrationPayload.fromJson(decoded);
        }
        return null;
      } catch (e) {
        print('Error parsing registration payload: $e');
        return null;
      }
    } else if (data is Map<String, dynamic>) {
      return RegistrationPayload.fromJson(data);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (phone != null) data['phone'] = phone;
    if (email != null) data['email'] = email;
    if (identityImageUrl != null) data['identity_image_url'] = identityImageUrl;
    
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  RegistrationPayload copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? identityImageUrl,
  }) {
    return RegistrationPayload(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      identityImageUrl: identityImageUrl ?? this.identityImageUrl,
    );
  }

  @override
  String toString() {
    return 'RegistrationPayload(firstName: $firstName, lastName: $lastName, email: $email)';
  }
}
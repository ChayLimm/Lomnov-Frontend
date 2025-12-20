import 'package:app/data/services/tenant_service.dart';
import 'package:app/domain/models/contract/tenant_model.dart';

class TenantMapper {
  static TenantModel fromDto(TenantDto dto) {
    return TenantModel(
      id: dto.id,
      name: '${dto.firstName} ${dto.lastName}'.trim(),
      email: null,
      phoneNumber: null,
      identifyId: null,
      profileImageUrl: null,
      identifyImageUrl: null,
      username: null,
      telegramId: null,
      createdAt: DateTime.now(), // Placeholder, not in DTO
      updatedAt: DateTime.now(), // Placeholder, not in DTO
    );
  }
}

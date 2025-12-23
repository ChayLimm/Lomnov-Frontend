class BakongAccount {
  final int id;
  final int landlordId;
  final String bakongId;
  final String bakongName;
  final String? bakongLocation;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BakongAccount({
    required this.id,
    required this.landlordId,
    required this.bakongId,
    required this.bakongName,
    this.bakongLocation,
    this.createdAt,
    this.updatedAt,
  });

  BakongAccount copyWith({
    int? id,
    int? landlordId,
    String? bakongId,
    String? bakongName,
    String? bakongLocation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BakongAccount(
      id: id ?? this.id,
      landlordId: landlordId ?? this.landlordId,
      bakongId: bakongId ?? this.bakongId,
      bakongName: bakongName ?? this.bakongName,
      bakongLocation: bakongLocation ?? this.bakongLocation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

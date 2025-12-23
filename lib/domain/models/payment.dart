class PaymentItem {
  final int id;
  final int paymentId;
  final String serviceName;
  final String unitPrice;
  final int quantity;
  final String subtotal;

  PaymentItem({
    required this.id,
    required this.paymentId,
    required this.serviceName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
  });

  factory PaymentItem.fromJson(Map<String, dynamic> json) {
    return PaymentItem(
      id: json['id'] as int,
      paymentId: json['payment_id'] as int,
      serviceName: json['service_name'] as String? ?? '',
      unitPrice: json['unit_price'] as String? ?? '0.00',
      quantity: (json['quantity'] is int) ? json['quantity'] as int : int.tryParse('${json['quantity']}') ?? 0,
      subtotal: json['subtotal'] as String? ?? '0.00',
    );
  }
}

class Payment {
  final int id;
  final int tenantId;
  final int landlordId;
  final int? transactionId;
  final int? roomId;
  final String? roomName;
  final String? tenantName;
  final String? roomStatus;
  final String status;
  final String? qrCode;
  final String? receiptUrl;
  final DateTime createdAt;
  final List<PaymentItem> items;

  Payment({
    required this.id,
    required this.tenantId,
    required this.landlordId,
    required this.transactionId,
    required this.roomId,
    this.roomName,
    this.tenantName,
    required this.status,
    required this.qrCode,
    required this.receiptUrl,
    required this.createdAt,
    required this.items, this.roomStatus,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    final rawItems = json['payment_items'] as List<dynamic>? ?? <dynamic>[];
    // Extract room name from possible shapes
    String? _roomName;
    if (json['room'] is String) {
      _roomName = json['room'] as String;
    } else if (json['room'] is Map<String, dynamic>) {
      final roomMap = json['room'] as Map<String, dynamic>;
      _roomName = (roomMap['room_number'] as String?) ?? (roomMap['name'] as String?);
    }

    // Extract tenant name from possible shapes
    String? _tenantName;
    if (json['tenant'] is String) {
      _tenantName = json['tenant'] as String;
    } else if (json['tenant'] is Map<String, dynamic>) {
      final t = json['tenant'] as Map<String, dynamic>;
      final f = t['first_name'] as String?;
      final l = t['last_name'] as String?;
      if ((f?.isNotEmpty ?? false) || (l?.isNotEmpty ?? false)) {
        _tenantName = '${f ?? ''}${(f != null && f.isNotEmpty && (l != null && l.isNotEmpty)) ? ' ' : ''}${l ?? ''}'.trim();
      } else {
        _tenantName = (t['name'] as String?) ?? (t['full_name'] as String?);
      }
    }

    return Payment(
      id: json['id'] as int,
      tenantId: json['tenant_id'] as int,
      landlordId: json['landlord_id'] as int,
      transactionId: json['transaction_id'] != null ? (json['transaction_id'] as int) : null,
      roomId: json['room_id'] != null ? (json['room_id'] as int) : null,
      roomName: _roomName,
      tenantName: _tenantName,
      status: json['status'] as String? ?? '',
      roomStatus: (json['room'] is Map<String, dynamic>) ? (json['room']['status'] as String?) : null,
      qrCode: json['qr_code'] as String?,
      receiptUrl: json['receipt_url'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      items: rawItems.map((e) => PaymentItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

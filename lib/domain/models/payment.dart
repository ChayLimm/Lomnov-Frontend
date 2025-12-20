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
    required this.status,
    required this.qrCode,
    required this.receiptUrl,
    required this.createdAt,
    required this.items,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    final rawItems = json['payment_items'] as List<dynamic>? ?? <dynamic>[];
    return Payment(
      id: json['id'] as int,
      tenantId: json['tenant_id'] as int,
      landlordId: json['landlord_id'] as int,
      transactionId: json['transaction_id'] != null ? (json['transaction_id'] as int) : null,
      roomId: json['room_id'] != null ? (json['room_id'] as int) : null,
      status: json['status'] as String? ?? '',
      qrCode: json['qr_code'] as String?,
      receiptUrl: json['receipt_url'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      items: rawItems.map((e) => PaymentItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

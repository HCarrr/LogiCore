class CreatePRRequest {
  final List<PRItem> items;
  final String? notes;
  final DateTime? requiredDate;

  CreatePRRequest({
    required this.items,
    this.notes,
    this.requiredDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'notes': notes,
      'requiredDate': requiredDate?.toIso8601String(),
    };
  }
}

class PRItem {
  final String itemId;
  final int quantity;
  final double? estimatedUnitPrice;
  final String? notes;

  PRItem({
    required this.itemId,
    required this.quantity,
    this.estimatedUnitPrice,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'quantity': quantity,
      'estimatedUnitPrice': estimatedUnitPrice,
      'notes': notes,
    };
  }
}

class PurchaseRequestResponse {
  final String id;
  final String prNumber;
  final String status;
  final DateTime createdAt;

  PurchaseRequestResponse({
    required this.id,
    required this.prNumber,
    required this.status,
    required this.createdAt,
  });

  factory PurchaseRequestResponse.fromJson(Map<String, dynamic> json) {
    return PurchaseRequestResponse(
      id: json['id'] ?? '',
      prNumber: json['prNumber'] ?? '',
      status: json['status'] ?? 'DRAFT',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class PRDetailModel {
  final String id;
  final String prNumber;
  final String status;
  final String? notes;
  final DateTime? requiredDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final UserInfo? requestor;
  final List<PRDetailItem> items;
  final List<PRApproval> approvals;

  PRDetailModel({
    required this.id,
    required this.prNumber,
    required this.status,
    this.notes,
    this.requiredDate,
    required this.createdAt,
    this.updatedAt,
    this.requestor,
    required this.items,
    this.approvals = const [],
  });

  factory PRDetailModel.fromJson(Map<String, dynamic> json) {
    return PRDetailModel(
      id: json['id'] ?? '',
      prNumber: json['prNumber'] ?? '',
      status: json['status'] ?? 'DRAFT',
      notes: json['notes'],
      requiredDate: json['requiredDate'] != null
          ? DateTime.parse(json['requiredDate'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      requestor: json['requestor'] != null
          ? UserInfo.fromJson(json['requestor'])
          : null,
      items: (json['items'] as List?)
              ?.map((item) => PRDetailItem.fromJson(item))
              .toList() ??
          [],
      approvals: (json['approvals'] as List?)
              ?.map((a) => PRApproval.fromJson(a))
              .toList() ??
          [],
    );
  }

  double get totalEstimatedCost {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}

class PRDetailItem {
  final String id;
  final String itemId;
  final String itemName;
  final String? itemCode;
  final String? category;
  final String? unit;
  final int quantity;
  final double estimatedUnitPrice;
  final String? notes;

  PRDetailItem({
    required this.id,
    required this.itemId,
    required this.itemName,
    this.itemCode,
    this.category,
    this.unit,
    required this.quantity,
    required this.estimatedUnitPrice,
    this.notes,
  });

  double get totalPrice => quantity * estimatedUnitPrice;

  factory PRDetailItem.fromJson(Map<String, dynamic> json) {
    final item = json['item'] as Map<String, dynamic>?;

    // Parse estimatedUnitPrice safely (can be string or number)
    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return PRDetailItem(
      id: json['id']?.toString() ?? '',
      itemId: json['itemId']?.toString() ?? item?['id']?.toString() ?? '',
      itemName: item?['name']?.toString() ??
          json['itemName']?.toString() ??
          'Unknown Item',
      itemCode: item?['code']?.toString() ?? json['itemCode']?.toString(),
      category: item?['category']?.toString() ?? json['category']?.toString(),
      unit: item?['unit']?.toString() ?? json['unit']?.toString() ?? 'pcs',
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      estimatedUnitPrice: parsePrice(json['estimatedUnitPrice']),
      notes: json['notes']?.toString(),
    );
  }
}

class PRApproval {
  final String id;
  final String status;
  final String? comments;
  final DateTime? approvedAt;
  final UserInfo? approver;

  PRApproval({
    required this.id,
    required this.status,
    this.comments,
    this.approvedAt,
    this.approver,
  });

  factory PRApproval.fromJson(Map<String, dynamic> json) {
    return PRApproval(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      comments: json['comments'],
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
      approver:
          json['approver'] != null ? UserInfo.fromJson(json['approver']) : null,
    );
  }
}

class UserInfo {
  final String id;
  final String name;
  final String email;
  final String? role;

  UserInfo({
    required this.id,
    required this.name,
    required this.email,
    this.role,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      role: json['role'],
    );
  }
}

class PRListItem {
  final String id;
  final String prNumber;
  final String status;
  final DateTime createdAt;
  final double totalEstimate;
  final int itemCount;
  final String? notes;

  PRListItem({
    required this.id,
    required this.prNumber,
    required this.status,
    required this.createdAt,
    required this.totalEstimate,
    required this.itemCount,
    this.notes,
  });

  factory PRListItem.fromJson(Map<String, dynamic> json) {
    // Parse total estimate safely
    double parseTotal(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Calculate total from items if totalEstimate not provided
    double total = parseTotal(json['totalEstimate']);
    if (total == 0 && json['items'] != null) {
      final items = json['items'] as List;
      for (var item in items) {
        final qty = item['quantity'] ?? 0;
        final price = parseTotal(item['estimatedUnitPrice']);
        total += qty * price;
      }
    }

    return PRListItem(
      id: json['id']?.toString() ?? '',
      prNumber: json['prNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? 'DRAFT',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      totalEstimate: total,
      itemCount: json['items'] != null ? (json['items'] as List).length : 0,
      notes: json['notes']?.toString(),
    );
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get formattedTotal {
    return 'Rp ${totalEstimate.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }
}

class PRListResponse {
  final List<PRListItem> items;
  final int total;

  PRListResponse({
    required this.items,
    required this.total,
  });

  factory PRListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    List<PRListItem> items = [];

    if (data is List) {
      items = data.map((item) => PRListItem.fromJson(item)).toList();
    } else if (data is Map && data['items'] != null) {
      items = (data['items'] as List)
          .map((item) => PRListItem.fromJson(item))
          .toList();
    }

    return PRListResponse(
      items: items,
      total: items.length,
    );
  }
}

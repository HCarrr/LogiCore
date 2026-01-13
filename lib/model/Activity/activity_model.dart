class ActivityModel {
  final String id;
  final String prNumber;
  final String title;
  final String? subtitle;
  final DateTime createdAt;
  final String status;
  final String statusBadge;
  final String icon;

  ActivityModel({
    required this.id,
    required this.prNumber,
    required this.title,
    this.subtitle,
    required this.createdAt,
    required this.status,
    required this.statusBadge,
    this.icon = 'build',
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] ?? '',
      prNumber: json['prNumber'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['createdAt'] != null
          ? _formatDate(DateTime.parse(json['createdAt']))
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      status: json['status'] ?? 'DRAFT',
      statusBadge: _mapStatusToBadge(json['status'] ?? 'DRAFT'),
      icon: _mapStatusToIcon(json['status'] ?? 'DRAFT'),
    );
  }

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day} ${_monthName(date.month)}';
    }
  }

  static String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  static String _mapStatusToBadge(String status) {
    switch (status) {
      case 'APPROVED':
      case 'DELIVERED':
        return 'APPROVED';
      case 'SUBMITTED':
        return 'PENDING';
      case 'REJECTED':
        return 'REJECTED';
      default:
        return status;
    }
  }

  static String _mapStatusToIcon(String status) {
    switch (status) {
      case 'APPROVED':
      case 'ORDERED':
      case 'DELIVERED':
        return 'check_circle';
      case 'SUBMITTED':
        return 'hourglass_empty';
      case 'REJECTED':
        return 'cancel';
      default:
        return 'build';
    }
  }
}

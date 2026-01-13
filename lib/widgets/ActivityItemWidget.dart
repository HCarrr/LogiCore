import 'package:flutter/material.dart';
import '../utilities/colors.dart';

class ActivityItemWidget extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String? badgeText;
  final Color? badgeColor;
  final bool showDivider;
  final VoidCallback? onTap;

  const ActivityItemWidget({
    Key? key,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.badgeText,
    this.badgeColor,
    this.showDivider = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: kColorPureWhite, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badgeText != null)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: badgeColor ?? kColorPrimary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                badgeText!,
                                style: TextStyle(
                                    color: kColorPureWhite,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(subtitle,
                          style: TextStyle(fontSize: 12, color: kColorGrey)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: kColorMediumGrey),
              ],
            ),
          ),
        ),
        if (showDivider) ...[
          const SizedBox(height: 12),
          Divider(),
        ],
      ],
    );
  }

  // Helper methods untuk mapping status ke icon dan warna
  static IconData getIconFromString(String iconName) {
    switch (iconName) {
      case 'build':
        return Icons.build;
      case 'person':
        return Icons.person;
      case 'check_circle':
        return Icons.check_circle;
      case 'hourglass_empty':
        return Icons.hourglass_empty;
      case 'cancel':
        return Icons.cancel;
      default:
        return Icons.build;
    }
  }

  static Color getIconBackgroundColor(String status) {
    switch (status) {
      case 'APPROVED':
      case 'DELIVERED':
        return const Color.fromARGB(255, 76, 175, 80);
      case 'PENDING':
        return const Color.fromARGB(255, 66, 133, 244);
      case 'REJECTED':
        return const Color.fromARGB(255, 244, 67, 54);
      default:
        return const Color.fromARGB(255, 66, 133, 244);
    }
  }

  static Color getBadgeColor(String badge) {
    switch (badge) {
      case 'APPROVED':
        return const Color.fromARGB(255, 76, 175, 80);
      case 'RECEIVED':
        return const Color.fromARGB(255, 76, 101, 175);
      case 'PENDING':
        return const Color.fromARGB(255, 255, 152, 0);
      case 'REJECTED':
        return const Color.fromARGB(255, 244, 67, 54);
      default:
        return kColorPrimary;
    }
  }
}

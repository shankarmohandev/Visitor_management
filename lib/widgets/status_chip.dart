import 'package:flutter/material.dart';
import '../models/visitor.dart';

/// Reusable status indicator strictly implemented using [Chip].
/// Displays distinct, high-contrast, readable status colors and labels for:
/// - Registered (Amber/Pending #D97706)
/// - Checked In (Teal #0F9D8A)
/// - Checked Out (Success Green #16A34A)
class StatusChip extends StatelessWidget {
  final String status;
  final bool compact;

  const StatusChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color backgroundColor;
    Color borderColor;
    IconData icon;

    switch (status) {
      case Visitor.statusCheckedIn:
        textColor = const Color(0xFF0F9D8A);
        backgroundColor = const Color(0xFF0F9D8A).withValues(alpha: 0.12);
        borderColor = const Color(0xFF0F9D8A).withValues(alpha: 0.35);
        icon = Icons.login_rounded;
        break;
      case Visitor.statusCheckedOut:
        textColor = const Color(0xFF16A34A);
        backgroundColor = const Color(0xFF16A34A).withValues(alpha: 0.12);
        borderColor = const Color(0xFF16A34A).withValues(alpha: 0.35);
        icon = Icons.logout_rounded;
        break;
      case Visitor.statusRegistered:
      default:
        textColor = const Color(0xFFD97706);
        backgroundColor = const Color(0xFFD97706).withValues(alpha: 0.12);
        borderColor = const Color(0xFFD97706).withValues(alpha: 0.35);
        icon = Icons.how_to_reg_rounded;
        break;
    }

    return Chip(
      avatar: Icon(
        icon,
        size: compact ? 13 : 15,
        color: textColor,
      ),
      label: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      backgroundColor: backgroundColor,
      side: BorderSide(color: borderColor, width: 1),
      visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
      padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 8, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

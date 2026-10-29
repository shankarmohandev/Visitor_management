import 'package:flutter/material.dart';
import '../models/visitor.dart';
import 'status_chip.dart';

/// Refined Reusable Visitor Card strictly adhering to the assignment requirements:
/// Shows:
/// - Visitor name
/// - Mobile number
/// - Project name
/// - Visitor type
/// - Current status
/// - Edit and Delete actions
/// - Tap to view details
///
/// Features polished PropTech luxury styling with clean metadata rows,
/// squircle monogram avatar, category badge, and dedicated action controls.
class VisitorCard extends StatelessWidget {
  final Visitor visitor;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const VisitorCard({
    super.key,
    required this.visitor,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Visitor Type badge colors
    Color typeBgColor;
    Color typeTextColor;
    if (visitor.visitorType == 'Customer') {
      typeBgColor = const Color(0xFFB3802B).withValues(alpha: 0.1);
      typeTextColor = const Color(0xFF96691E);
    } else if (visitor.visitorType == 'Vendor') {
      typeBgColor = const Color(0xFF4338CA).withValues(alpha: 0.1);
      typeTextColor = const Color(0xFF4338CA);
    } else {
      typeBgColor = const Color(0xFFF1F5F9);
      typeTextColor = const Color(0xFF475569);
    }

    final Color statusDotColor = visitor.isCheckedIn
        ? const Color(0xFF0E8A5E)
        : (visitor.isRegistered ? const Color(0xFFB45309) : const Color(0xFF475569));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDE7DD), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFFB48D54).withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: const Color(0xFFB3802B).withValues(alpha: 0.06),
          highlightColor: const Color(0xFFFAF7F2),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Squircle Avatar + Name & Subtitles + StatusChip
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Squircle Avatar with Status Dot
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFAF7F2), Color(0xFFF3ECE0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: const Color(0xFFB3802B).withValues(alpha: 0.3),
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              visitor.initials,
                              style: const TextStyle(
                                color: Color(0xFF8B601C),
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              color: statusDotColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Name, ID, & Visitor Type
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visitor.name,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1714),
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              // Visitor Type Pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: typeBgColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  visitor.visitorType,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: typeTextColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // ID Pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  visitor.id,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Status Indicator Chip
                    StatusChip(status: visitor.status, compact: true),
                  ],
                ),

                const SizedBox(height: 12),

                // Inset Purpose Banner (if provided)
                if (visitor.purpose.trim().isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF7F2),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: const Color(0xFFEDE7DD), width: 0.8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 1.0),
                          child: Icon(Icons.notes_rounded, size: 13, color: Color(0xFFB3802B)),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            visitor.purpose,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Bottom Row: Mobile, Project & Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Mobile & Project metadata
                    Expanded(
                      child: Row(
                        children: [
                          // Mobile
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.phone_outlined, size: 12, color: Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Text(
                                  visitor.mobile,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF334155),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Project
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.apartment_rounded, size: 12, color: Color(0xFF64748B)),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      visitor.project,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF334155),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Actions: Edit and Delete
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onEdit != null)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onEdit,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB3802B).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFFB3802B)),
                              ),
                            ),
                          ),
                        if (onDelete != null) ...[
                          const SizedBox(width: 6),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onDelete,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDC2626).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFDC2626)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

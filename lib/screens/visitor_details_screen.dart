import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/visitor.dart';
import '../providers/visitor_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/status_chip.dart';
import 'visitor_form_screen.dart';

/// Screen 4: Visitor Details strictly adhering to the assignment requirements:
/// - Visitor information card
/// - QR code display (containing unique visitor ID)
/// - Status indicator
/// - Check-in / check-out action workflow (Registered -> Checked In -> Checked Out)
/// - Check-in / check-out timestamps when available
/// - Edit and Delete actions
class VisitorDetailsScreen extends StatelessWidget {
  final String visitorId;

  const VisitorDetailsScreen({super.key, required this.visitorId});

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return '—';
    try {
      final dt = DateTime.parse(timestamp).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return timestamp;
    }
  }

  void _confirmDelete(BuildContext context, VisitorProvider provider, Visitor visitor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Visitor?'),
        content: Text('Are you sure you want to permanently delete "${visitor.name}" (${visitor.id})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final ok = await provider.deleteVisitor(visitor.id);
              if (context.mounted && ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Visitor "${visitor.name}" deleted'),
                    backgroundColor: AppTheme.onyxDark,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VisitorProvider>(
      builder: (context, provider, _) {
        final visitor = provider.visitors
            .where((v) => v.id.trim().toLowerCase() == visitorId.trim().toLowerCase())
            .firstOrNull;

        if (visitor == null) {
          return Scaffold(
            backgroundColor: AppTheme.background,
            appBar: AppBar(title: const Text('Visitor Details')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off_rounded, size: 48, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 12),
                  Text('Visitor record not found ($visitorId)'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: const Color(0xFF14120F),
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            title: const Text(
              'Visitor Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: const Color(0xFF26201A), height: 1),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Color(0xFFC59A3F)),
                tooltip: 'Edit Visitor',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VisitorFormScreen(visitor: visitor),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                tooltip: 'Delete Visitor',
                onPressed: () => _confirmDelete(context, provider, visitor),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 1. QR Code Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEDE7DD), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14120F),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFC59A3F).withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Image.asset(
                              'assets/icon.png',
                              height: 18,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                            ),
                          ),
                          StatusChip(status: visitor.status),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF7F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFEDE7DD)),
                        ),
                        child: Text(
                          'PASS ID: ${visitor.id}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryGold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // QR Code Container
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: QrImageView(
                          data: visitor.id,
                          version: QrVersions.auto,
                          size: 190,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFF1A1714),
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(0xFF1A1714),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),
                      const Text(
                        'Scan QR at security desk for instant verification',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Visitor Information Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEDE7DD), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Visitor Information',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.onyxDark,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildInfoRow(Icons.person_rounded, 'Full Name', visitor.name),
                      _buildInfoRow(Icons.phone_rounded, 'Mobile Number', visitor.mobile),
                      _buildInfoRow(
                        Icons.email_rounded,
                        'Email Address',
                        visitor.email != null && visitor.email!.isNotEmpty ? visitor.email! : 'Not provided',
                      ),
                      _buildInfoRow(Icons.badge_rounded, 'Visitor Type', visitor.visitorType),
                      _buildInfoRow(Icons.location_city_rounded, 'Project', visitor.project),
                      _buildInfoRow(Icons.notes_rounded, 'Purpose of Visit', visitor.purpose),
                      _buildInfoRow(Icons.app_registration_rounded, 'Registered At', _formatTimestamp(visitor.createdAt)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Visit Activity Timestamps Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEDE7DD), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Visit Activity & Timestamps',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.onyxDark,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildTimestampRow(
                        Icons.login_rounded,
                        'Check-in Timestamp',
                        visitor.checkInTime != null ? _formatTimestamp(visitor.checkInTime) : 'Not checked in yet',
                        visitor.isCheckedIn || visitor.isCheckedOut ? const Color(0xFF0E8A5E) : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: 10),
                      _buildTimestampRow(
                        Icons.logout_rounded,
                        'Check-out Timestamp',
                        visitor.checkOutTime != null
                            ? _formatTimestamp(visitor.checkOutTime)
                            : (visitor.isCheckedIn ? 'Currently checked in' : 'Not checked in yet'),
                        visitor.isCheckedOut ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 4. Status Transition Action Button (Check-in / Check-out)
                if (visitor.isRegistered)
                  CustomButton(
                    label: 'Check In Visitor',
                    icon: Icons.login_rounded,
                    backgroundColor: const Color(0xFF0E8A5E),
                    width: double.infinity,
                    height: 52,
                    isLoading: provider.isActionLoading,
                    onPressed: () async {
                      final updated = await provider.checkInVisitor(visitor.id);
                      if (context.mounted && updated != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Visitor "${visitor.name}" checked in successfully'),
                            backgroundColor: const Color(0xFF0E8A5E),
                          ),
                        );
                      }
                    },
                  )
                else if (visitor.isCheckedIn)
                  CustomButton(
                    label: 'Check Out Visitor',
                    icon: Icons.logout_rounded,
                    backgroundColor: const Color(0xFF1E293B),
                    width: double.infinity,
                    height: 52,
                    isLoading: provider.isActionLoading,
                    onPressed: () async {
                      final updated = await provider.checkOutVisitor(visitor.id);
                      if (context.mounted && updated != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Visitor "${visitor.name}" checked out successfully'),
                            backgroundColor: AppTheme.onyxDark,
                          ),
                        );
                      }
                    },
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, color: Color(0xFF0E8A5E), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Visit Completed • Visitor Checked Out',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestampRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color == const Color(0xFF94A3B8) ? const Color(0xFF64748B) : color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

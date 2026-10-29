import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/visitor_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/loading_view.dart';
import '../widgets/visitor_card.dart';
import 'qr_scanner_screen.dart';
import 'visitor_details_screen.dart';
import 'visitor_form_screen.dart';

/// Screen 1: Dashboard strictly following the Sumadhura assignment requirements
/// with enhanced executive PropTech luxury UI styling:
/// - Application title: "Sumadhura Visitor Management"
/// - Executive Front Desk Welcome & Date header
/// - Three visitor statistics cards:
///   1. Total Visitors Today
///   2. Currently Checked In
///   3. Checked Out Today
/// - Quick action shortcuts:
///   - Register Visitor
///   - Scan QR Code
///   - View All Visitors Directory
/// - Recent visitors stream with tap navigation
class DashboardScreen extends StatelessWidget {
  final void Function(int tabIndex)? onNavigateToTab;

  const DashboardScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF14120F),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/icon.png',
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Text(
                'SUMADHURA',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Color(0xFFC59A3F),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 16,
              width: 1.2,
              color: const Color(0xFF382F24),
            ),
            const SizedBox(width: 8),
            const Text(
              'Visitor Management',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD4AC51),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 20, color: Color(0xFFC59A3F)),
              tooltip: 'Refresh Data',
              visualDensity: VisualDensity.compact,
              onPressed: () {
                Provider.of<VisitorProvider>(context, listen: false).fetchVisitors();
              },
            ),
          ),
        ],
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFF26201A), height: 1),
        ),
      ),
      body: Consumer<VisitorProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.visitors.isEmpty) {
            return const LoadingView(message: 'Loading visitor statistics...');
          }

          final allVisitors = provider.visitors;

          return RefreshIndicator(
            color: AppTheme.primaryGold,
            onRefresh: () => provider.fetchVisitors(),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 90),
              children: [
                // 1. Executive Portal Banner
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E1B17), Color(0xFF14120F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF14120F).withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'FRONT DESK SECURITY PORTAL',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: Color(0xFFC59A3F),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Residential Projects Overview',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 11, color: Color(0xFFC59A3F)),
                            const SizedBox(width: 5),
                            Text(
                              _getFormattedDate(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 2. Section Header: Today's Overview
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's Overview",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.onyxDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'Total: ${provider.totalVisitorsCount} records',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 3. Three Visitor Statistics Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Metric 1: Total Visitors Today
                          Expanded(
                            child: DashboardStatCard(
                              title: 'Total Today',
                              subtitle: 'Visitors registered today',
                              value: provider.totalVisitorsToday.toString(),
                              icon: Icons.people_alt_rounded,
                              accentColor: const Color(0xFFB3802B),
                              badgeText: 'TODAY',
                              onTap: () {
                                if (onNavigateToTab != null) {
                                  provider.setStatusFilter('All');
                                  onNavigateToTab!(2);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Metric 2: Currently Checked In
                          Expanded(
                            child: DashboardStatCard(
                              title: 'Checked In',
                              subtitle: 'Currently inside campus',
                              value: provider.currentlyCheckedIn.toString(),
                              icon: Icons.login_rounded,
                              accentColor: const Color(0xFF0E8A5E),
                              badgeText: 'INSIDE',
                              onTap: () {
                                if (onNavigateToTab != null) {
                                  provider.setStatusFilter('Checked In');
                                  onNavigateToTab!(2);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Metric 3: Checked Out Today
                      DashboardStatCard(
                        title: 'Checked Out Today',
                        subtitle: 'Visitors who have completed visit & exited today',
                        value: provider.checkedOutToday.toString(),
                        icon: Icons.logout_rounded,
                        accentColor: const Color(0xFF475569),
                        badgeText: 'COMPLETED',
                        onTap: () {
                          if (onNavigateToTab != null) {
                            provider.setStatusFilter('Checked Out');
                            onNavigateToTab!(2);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 4. Shortcuts / Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFEDE7DD), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bolt_rounded, size: 18, color: Color(0xFFB3802B)),
                            SizedBox(width: 6),
                            Text(
                              'Quick Shortcuts',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.onyxDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            // Register Visitor Button
                            Expanded(
                              child: CustomButton(
                                label: 'Register Visitor',
                                icon: Icons.person_add_alt_1_rounded,
                                backgroundColor: AppTheme.primaryGold,
                                height: 50,
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const VisitorFormScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Scan QR Code Button
                            Expanded(
                              child: CustomButton(
                                label: 'Scan QR',
                                icon: Icons.qr_code_scanner_rounded,
                                backgroundColor: AppTheme.onyxDark,
                                height: 50,
                                onPressed: () {
                                  if (onNavigateToTab != null) {
                                    onNavigateToTab!(1);
                                  } else {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const QRScannerScreen(),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        CustomButton(
                          label: 'View All Visitors Directory',
                          icon: Icons.list_alt_rounded,
                          isOutlined: true,
                          backgroundColor: AppTheme.primaryNavy,
                          width: double.infinity,
                          height: 46,
                          onPressed: () {
                            if (onNavigateToTab != null) {
                              provider.setStatusFilter('All');
                              onNavigateToTab!(2);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 5. Recent Visitors Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Recent Visitors',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.onyxDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF7F2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFEDE7DD)),
                            ),
                            child: const Text(
                              'Latest entries',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF8B601C),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          if (onNavigateToTab != null) {
                            provider.setStatusFilter('All');
                            onNavigateToTab!(2);
                          }
                        },
                        child: const Row(
                          children: [
                            Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryGold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.primaryGold),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                if (allVisitors.isEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFEDE7DD)),
                    ),
                    child: const Center(
                      child: Text(
                        'No visitor records yet. Tap "Register Visitor" to begin.',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...allVisitors.take(5).map((visitor) {
                    return VisitorCard(
                      visitor: visitor,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VisitorDetailsScreen(visitorId: visitor.id),
                          ),
                        );
                      },
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VisitorFormScreen(visitor: visitor),
                          ),
                        );
                      },
                      onDelete: () => _confirmDelete(context, provider, visitor.id, visitor.name),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  void _confirmDelete(BuildContext context, VisitorProvider provider, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Visitor Record?'),
        content: Text('Are you sure you want to delete the visitor record for "$name"?'),
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
              final ok = await provider.deleteVisitor(id);
              if (context.mounted && ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Visitor "$name" deleted'),
                    backgroundColor: AppTheme.onyxDark,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

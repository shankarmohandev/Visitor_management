import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/visitor_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/visitor_list_screen.dart';
import 'theme/app_theme.dart';

/// Main application entry point providing MaterialApp, SplashScreen, and the primary NavigationBar shell.
class VisitorManagementApp extends StatelessWidget {
  const VisitorManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sumadhura Visitor Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

/// Navigation Shell hosting the 3 primary tabs:
/// 1. Dashboard
/// 2. Scan QR
/// 3. Visitors
class MainNavigationShell extends StatefulWidget {
  final int initialIndex;
  const MainNavigationShell({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _handleBackPress() {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return;
    }

    // Double back to exit when on Dashboard
    final now = DateTime.now();
    if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Press back again to exit',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: AppTheme.onyxDark,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    switch (_currentIndex) {
      case 1:
        currentScreen = QRScannerScreen(
          onBackToDashboard: () {
            setState(() => _currentIndex = 0);
          },
        );
        break;
      case 2:
        currentScreen = VisitorListScreen(
          onBackToDashboard: () {
            setState(() => _currentIndex = 0);
          },
        );
        break;
      case 0:
      default:
        currentScreen = DashboardScreen(
          onNavigateToTab: (index) {
            setState(() => _currentIndex = index);
          },
        );
        break;
    }

    final visitorCount = context.watch<VisitorProvider>().visitors.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        body: currentScreen,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: NavigationBar(
            backgroundColor: Colors.white,
            elevation: 0,
            indicatorColor: const Color(0xFFFAF7F2),
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabSelected,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.dashboard_outlined, color: Color(0xFF94A3B8), size: 24),
                selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.onyxDark, size: 24),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 20),
                ),
                selectedIcon: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 20),
                ),
                label: 'Scan QR',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: visitorCount > 0,
                  label: Text(visitorCount.toString()),
                  backgroundColor: AppTheme.primaryGold,
                  child: const Icon(Icons.people_alt_outlined, color: Color(0xFF94A3B8), size: 24),
                ),
                selectedIcon: Badge(
                  isLabelVisible: visitorCount > 0,
                  label: Text(visitorCount.toString()),
                  backgroundColor: AppTheme.primaryGold,
                  child: const Icon(Icons.people_alt_rounded, color: AppTheme.primaryGold, size: 24),
                ),
                label: 'Visitors',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

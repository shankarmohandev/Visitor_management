import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visitor_management/app.dart';
import 'package:visitor_management/providers/visitor_provider.dart';
import 'package:visitor_management/repositories/visitor_repository.dart';
import 'package:visitor_management/screens/dashboard_screen.dart';
import 'package:visitor_management/screens/splash_screen.dart';
import 'package:visitor_management/screens/visitor_details_screen.dart';
import 'package:visitor_management/screens/visitor_form_screen.dart';
import 'package:visitor_management/screens/visitor_list_screen.dart';
import 'package:visitor_management/services/visitor_api_service.dart';
import 'package:visitor_management/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SplashScreen renders Sumadhura branding and title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(autoNavigate: false),
      ),
    );

    expect(find.text('SUMADHURA'), findsOneWidget);
    expect(find.text('VISITOR MANAGEMENT SYSTEM'), findsOneWidget);
  });

  testWidgets('DashboardScreen renders 3 mandatory metrics and shortcuts', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    late VisitorProvider provider;

    await tester.runAsync(() async {
      final apiService = VisitorApiService();
      await apiService.init();
      final repository = VisitorRepository(apiService: apiService);
      provider = VisitorProvider(repository: repository);
      await provider.init();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: ChangeNotifierProvider<VisitorProvider>.value(
          value: provider,
          child: const DashboardScreen(),
        ),
      ),
    );

    await tester.pump();

    // Verify Title & Metrics
    expect(find.text("Today's Overview"), findsOneWidget);
    expect(find.text('Total Today'), findsOneWidget);
    expect(find.text('Checked In'), findsWidgets);
    expect(find.text('Checked Out Today'), findsOneWidget);

    // Verify Shortcuts
    expect(find.text('Register Visitor'), findsOneWidget);
    expect(find.text('Scan QR'), findsOneWidget);
    expect(find.text('View All Visitors Directory'), findsOneWidget);
  });

  testWidgets('VisitorListScreen renders search, filter chips, and visitor cards', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    late VisitorProvider provider;

    await tester.runAsync(() async {
      final apiService = VisitorApiService();
      await apiService.init();
      final repository = VisitorRepository(apiService: apiService);
      provider = VisitorProvider(repository: repository);
      await provider.init();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: ChangeNotifierProvider<VisitorProvider>.value(
          value: provider,
          child: const VisitorListScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Visitor Directory'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Registered'), findsWidgets);
    expect(find.text('Checked In'), findsWidgets);
    expect(find.text('Checked Out'), findsWidgets);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('VisitorFormScreen renders all 6 mandatory form fields and buttons', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    late VisitorProvider provider;

    await tester.runAsync(() async {
      final apiService = VisitorApiService();
      await apiService.init();
      final repository = VisitorRepository(apiService: apiService);
      provider = VisitorProvider(repository: repository);
      await provider.init();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: ChangeNotifierProvider<VisitorProvider>.value(
          value: provider,
          child: const VisitorFormScreen(),
        ),
      ),
    );

    await tester.pump();

    // Verify the 6 fields from the assignment
    expect(find.text('Visitor Name'), findsOneWidget);
    expect(find.text('Mobile Number'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Visitor Type'), findsOneWidget);
    expect(find.text('Project'), findsOneWidget);
    expect(find.text('Purpose of Visit'), findsOneWidget);

    // Verify Save & Cancel buttons
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Register Visitor'), findsOneWidget);
  });

  testWidgets('VisitorDetailsScreen renders visitor details, QR code, and status action', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    late VisitorProvider provider;

    await tester.runAsync(() async {
      final apiService = VisitorApiService();
      await apiService.init();
      final repository = VisitorRepository(apiService: apiService);
      provider = VisitorProvider(repository: repository);
      await provider.init();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: ChangeNotifierProvider<VisitorProvider>.value(
          value: provider,
          child: const VisitorDetailsScreen(visitorId: 'VIS001'),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Visitor Profile'), findsOneWidget);
    expect(find.text('Rahul Sharma'), findsOneWidget);
    expect(find.text('Check In Visitor'), findsOneWidget);
    expect(find.text('PASS ID: VIS001'), findsOneWidget);
  });

  testWidgets('MainNavigationShell renders bottom navigation destinations', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    late VisitorProvider provider;

    await tester.runAsync(() async {
      final apiService = VisitorApiService();
      await apiService.init();
      final repository = VisitorRepository(apiService: apiService);
      provider = VisitorProvider(repository: repository);
      await provider.init();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: ChangeNotifierProvider<VisitorProvider>.value(
          value: provider,
          child: const MainNavigationShell(),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Scan QR'), findsWidgets);
    expect(find.text('Visitors'), findsOneWidget);
  });
}

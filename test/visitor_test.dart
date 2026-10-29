import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visitor_management/models/visitor.dart';
import 'package:visitor_management/providers/visitor_provider.dart';
import 'package:visitor_management/repositories/visitor_repository.dart';
import 'package:visitor_management/services/visitor_api_service.dart';
import 'package:visitor_management/utils/qr_code_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Visitor Model Tests', () {
    test('Visitor JSON serialization and deserialization matches specification', () {
      final sampleJson = {
        'id': 'VIS001',
        'name': 'Rahul Sharma',
        'mobile': '9876543210',
        'email': 'rahul@example.com',
        'visitor_type': 'Customer',
        'project': 'Project A',
        'purpose': 'Site Visit',
        'status': 'Registered',
        'created_at': '2026-10-26T10:00:00+05:30',
        'check_in_time': null,
        'check_out_time': null,
      };

      final visitor = Visitor.fromJson(sampleJson);
      expect(visitor.id, 'VIS001');
      expect(visitor.name, 'Rahul Sharma');
      expect(visitor.mobile, '9876543210');
      expect(visitor.email, 'rahul@example.com');
      expect(visitor.visitorType, 'Customer');
      expect(visitor.project, 'Project A');
      expect(visitor.purpose, 'Site Visit');
      expect(visitor.status, Visitor.statusRegistered);
      expect(visitor.isRegistered, isTrue);
      expect(visitor.isCheckedIn, isFalse);
      expect(visitor.isCheckedOut, isFalse);

      final serialized = visitor.toJson();
      expect(serialized['id'], 'VIS001');
      expect(serialized['name'], 'Rahul Sharma');
      expect(serialized['mobile'], '9876543210');
      expect(serialized['email'], 'rahul@example.com');
      expect(serialized['visitor_type'], 'Customer');
      expect(serialized['project'], 'Project A');
      expect(serialized['status'], 'Registered');
    });

    test('Status helper methods identify Registered, Checked In, and Checked Out', () {
      final v1 = Visitor(
        id: '1',
        name: 'Rahul Sharma',
        mobile: '9876543210',
        visitorType: 'Customer',
        project: 'Project A',
        purpose: 'Site Visit',
        status: Visitor.statusRegistered,
        createdAt: DateTime.now().toIso8601String(),
      );
      expect(v1.isRegistered, isTrue);
      expect(v1.isCheckedIn, isFalse);
      expect(v1.isCheckedOut, isFalse);

      final v2 = v1.copyWith(status: Visitor.statusCheckedIn);
      expect(v2.isRegistered, isFalse);
      expect(v2.isCheckedIn, isTrue);
      expect(v2.isCheckedOut, isFalse);

      final v3 = v1.copyWith(status: Visitor.statusCheckedOut);
      expect(v3.isRegistered, isFalse);
      expect(v3.isCheckedIn, isFalse);
      expect(v3.isCheckedOut, isTrue);
    });

    test('Initials extraction works properly', () {
      final v1 = Visitor(
        id: '1',
        name: 'Rahul Sharma',
        mobile: '9876543210',
        visitorType: 'Customer',
        project: 'Project A',
        purpose: 'Site Visit',
        createdAt: DateTime.now().toIso8601String(),
      );
      expect(v1.initials, 'RS');

      final v2 = Visitor(
        id: '2',
        name: 'Priya',
        mobile: '9876543210',
        visitorType: 'Customer',
        project: 'Project A',
        purpose: 'Site Visit',
        createdAt: DateTime.now().toIso8601String(),
      );
      expect(v2.initials, 'PR');
    });
  });

  group('Provider Status Workflow and Business Rules', () {
    late VisitorApiService apiService;
    late VisitorRepository repository;
    late VisitorProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      apiService = VisitorApiService();
      await apiService.init();
      repository = VisitorRepository(apiService: apiService);
      provider = VisitorProvider(repository: repository);
      await provider.init();
    });

    test('Initial sample records are loaded and correctly categorized', () {
      expect(provider.visitors.isNotEmpty, isTrue);
      expect(provider.visitors.length, greaterThanOrEqualTo(3));
      // Rahul Sharma should be seeded as Registered
      final rahul = provider.visitors.firstWhere((v) => v.id == 'VIS001');
      expect(rahul.status, Visitor.statusRegistered);
      expect(rahul.name, 'Rahul Sharma');
    });

    test('Check-in allowed only from Registered status', () async {
      final rahul = provider.visitors.firstWhere((v) => v.id == 'VIS001');
      expect(rahul.isRegistered, isTrue);

      final updated = await provider.checkInVisitor(rahul.id);
      expect(updated, isNotNull);
      expect(updated!.status, Visitor.statusCheckedIn);
      expect(updated.checkInTime, isNotNull);

      // Verify Provider state reflected the change
      final refreshed = provider.visitors.firstWhere((v) => v.id == 'VIS001');
      expect(refreshed.status, Visitor.statusCheckedIn);
    });

    test('Duplicate check-in is strictly prevented', () async {
      // VIS002 is already Checked In in the seed
      final priya = provider.visitors.firstWhere((v) => v.id == 'VIS002');
      expect(priya.isCheckedIn, isTrue);

      final result = await provider.checkInVisitor(priya.id);
      expect(result, isNull);
      expect(provider.errorMessage, contains('already checked in'));
    });

    test('Check-out allowed only from Checked In status', () async {
      final priya = provider.visitors.firstWhere((v) => v.id == 'VIS002');
      expect(priya.isCheckedIn, isTrue);

      final updated = await provider.checkOutVisitor(priya.id);
      expect(updated, isNotNull);
      expect(updated!.status, Visitor.statusCheckedOut);
      expect(updated.checkOutTime, isNotNull);

      final refreshed = provider.visitors.firstWhere((v) => v.id == 'VIS002');
      expect(refreshed.status, Visitor.statusCheckedOut);
    });

    test('Visitors cannot check out before checking in', () async {
      final rahul = provider.visitors.firstWhere((v) => v.id == 'VIS001');
      expect(rahul.isRegistered, isTrue);

      final result = await provider.checkOutVisitor(rahul.id);
      expect(result, isNull);
      expect(provider.errorMessage, contains('cannot check out before checking in'));
    });

    test('Completed visits cannot be checked in again', () async {
      // VIS003 is Checked Out in seed
      final amit = provider.visitors.firstWhere((v) => v.id == 'VIS003');
      expect(amit.isCheckedOut, isTrue);

      final result = await provider.checkInVisitor(amit.id);
      expect(result, isNull);
      expect(provider.errorMessage, contains('Completed visits cannot be checked in again'));
    });

    test('Search filters visitors by name or mobile number correctly', () {
      provider.setSearchQuery('Rahul');
      expect(provider.filteredVisitors.length, 1);
      expect(provider.filteredVisitors.first.name, 'Rahul Sharma');

      provider.setSearchQuery('9845123456');
      expect(provider.filteredVisitors.length, 1);
      expect(provider.filteredVisitors.first.name, 'Priya Patel');

      provider.setSearchQuery('NonExistentName999');
      expect(provider.filteredVisitors.isEmpty, isTrue);

      provider.setSearchQuery('');
      expect(provider.filteredVisitors.length, provider.visitors.length);
    });

    test('Register new visitor sets status Registered and adds to list', () async {
      final initialCount = provider.visitors.length;
      final newVisitor = Visitor(
        id: '',
        name: 'Karan Mehra',
        mobile: '9988776655',
        email: 'karan@example.com',
        visitorType: 'Vendor',
        project: 'Project B',
        purpose: 'Vendor Assessment',
        status: Visitor.statusRegistered,
        createdAt: DateTime.now().toIso8601String(),
      );

      final created = await provider.registerVisitor(newVisitor);

      expect(created, isNotNull);
      expect(created!.name, 'Karan Mehra');
      expect(created.status, Visitor.statusRegistered);
      expect(created.id.isNotEmpty, isTrue);
      expect(provider.visitors.length, initialCount + 1);
    });

    test('Delete visitor removes record from provider state', () async {
      final target = provider.visitors.first;
      final targetId = target.id;
      final initialCount = provider.visitors.length;

      final success = await provider.deleteVisitor(targetId);
      expect(success, isTrue);
      expect(provider.visitors.any((v) => v.id == targetId), isFalse);
      expect(provider.visitors.length, initialCount - 1);
    });

    test('Dashboard statistics calculate Total Today, Checked In, and Checked Out Today', () {
      expect(provider.totalVisitorsToday, greaterThanOrEqualTo(1));
      expect(provider.currentlyCheckedIn, greaterThanOrEqualTo(1));
      expect(provider.checkedOutToday, greaterThanOrEqualTo(1));
    });

    test('getVisitorByScannedCode resolves visitor from legacy formatted QR code', () async {
      final visitor = await provider.getVisitorByScannedCode('SUMADHURA-PASS:VIS001:VP-0001:9876543210');
      expect(visitor, isNotNull);
      expect(visitor!.id, 'VIS001');
      expect(visitor.name, 'Rahul Sharma');
    });
  });

  group('QR Code Helper Tests', () {
    test('Extracts VIS001 from legacy Sumadhura pass format', () {
      const legacyPayload = 'SUMADHURA-PASS:VIS001:VP-0001:9876543210';
      expect(QRCodeHelper.extractVisitorId(legacyPayload), 'VIS001');
    });

    test('Extracts plain and lowercase visitor IDs', () {
      expect(QRCodeHelper.extractVisitorId('VIS001'), 'VIS001');
      expect(QRCodeHelper.extractVisitorId('vis002'), 'VIS002');
    });

    test('Extracts visitor ID from prefixed strings', () {
      expect(QRCodeHelper.extractVisitorId('PASS:VIS001'), 'VIS001');
      expect(QRCodeHelper.extractVisitorId('PASS ID: VIS003'), 'VIS003');
      expect(QRCodeHelper.extractVisitorId('ID:VIS001'), 'VIS001');
    });

    test('Extracts visitor ID from JSON payloads', () {
      expect(QRCodeHelper.extractVisitorId('{"id": "VIS001", "name": "Rahul"}'), 'VIS001');
      expect(QRCodeHelper.extractVisitorId('{"visitor_id": "VIS002"}'), 'VIS002');
      expect(QRCodeHelper.extractVisitorId('{"visitorId": "VIS003"}'), 'VIS003');
    });

    test('Extracts visitor ID from URL paths', () {
      expect(QRCodeHelper.extractVisitorId('https://sumadhura.in/visitors/VIS001'), 'VIS001');
    });

    test('Extracts 10-digit mobile number from scanned payload', () {
      expect(QRCodeHelper.extractMobile('SUMADHURA-PASS:VIS001:VP-0001:9876543210'), '9876543210');
      expect(QRCodeHelper.extractMobile('NO_PHONE_HERE'), isNull);
    });
  });
}

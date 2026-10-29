import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/visitor.dart';
import '../repositories/visitor_repository.dart';

/// Provider implementing ChangeNotifier for state management:
/// - Visitor data loading
/// - Visitor list updates
/// - Registration / editing operations
/// - Search results (by name or mobile number)
/// - Visitor status changes (Registered -> Checked In -> Checked Out)
/// - Dashboard statistics (Total Today, Currently Checked In, Checked Out Today)
/// - API error handling
class VisitorProvider with ChangeNotifier {
  final VisitorRepository _repository;

  List<Visitor> _visitors = [];
  String _searchQuery = '';
  String _statusFilter = 'All'; // 'All', 'Registered', 'Checked In', 'Checked Out'
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;
  String? _successMessage;

  VisitorProvider({VisitorRepository? repository})
      : _repository = repository ?? VisitorRepository();

  VisitorRepository get repository => _repository;

  List<Visitor> get visitors => List.unmodifiable(_visitors);
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Filtered visitors by search query (name or mobile number) and status
  List<Visitor> get filteredVisitors {
    var result = _visitors;

    // 1. Status Filter
    if (_statusFilter == 'Registered') {
      result = result.where((v) => v.isRegistered).toList();
    } else if (_statusFilter == 'Checked In') {
      result = result.where((v) => v.isCheckedIn).toList();
    } else if (_statusFilter == 'Checked Out') {
      result = result.where((v) => v.isCheckedOut).toList();
    }

    // 2. Search Query (matches name or mobile number as per specification)
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      result = result.where((v) {
        final matchesName = v.name.toLowerCase().contains(query);
        final matchesMobile = v.mobile.contains(query);
        final matchesProject = v.project.toLowerCase().contains(query);
        return matchesName || matchesMobile || matchesProject;
      }).toList();
    }

    return List.unmodifiable(result);
  }

  // Dashboard Metric 1: Total visitors registered today (using device local date)
  int get totalVisitorsToday {
    final now = DateTime.now();
    return _visitors.where((v) => v.isRegisteredToday(now)).length;
  }

  // Dashboard Metric 2: Visitors whose current status is Checked In
  int get currentlyCheckedIn {
    return _visitors.where((v) => v.isCheckedIn).length;
  }

  // Dashboard Metric 3: Visitors checked out today (using device local date)
  int get checkedOutToday {
    final now = DateTime.now();
    return _visitors.where((v) => v.isCheckedOutToday(now)).length;
  }

  // Total count
  int get totalVisitorsCount => _visitors.length;

  Future<void> init() async {
    await _repository.init();
    await fetchVisitors();
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  void setStatusFilter(String filter) {
    if (_statusFilter != filter) {
      _statusFilter = filter;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  /// Retrieve all visitors from API (GET /visitors)
  Future<void> fetchVisitors() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _visitors = await _repository.getAllVisitors();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _parseError(e, 'Failed to fetch visitors');
      debugPrint('Error fetching visitors: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Retrieve visitor details by ID (GET /visitors/{id})
  Future<Visitor?> getVisitorById(String id) async {
    try {
      // First check local list for immediate response
      final existingIndex = _visitors.indexWhere(
        (v) => v.id.trim().toLowerCase() == id.trim().toLowerCase(),
      );
      if (existingIndex != -1) {
        return _visitors[existingIndex];
      }

      // Fetch from API
      final visitor = await _repository.getVisitorById(id);
      return visitor;
    } catch (e) {
      debugPrint('Error retrieving visitor by ID $id: $e');
      return null;
    }
  }

  /// Register a new visitor via POST /visitors
  Future<Visitor?> registerVisitor(Visitor visitor) async {
    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final created = await _repository.registerVisitor(visitor);
      _visitors.insert(0, created);
      _successMessage = 'Visitor "${created.name}" registered successfully with ID ${created.id}';
      return created;
    } catch (e) {
      _errorMessage = _parseError(e, 'Failed to register visitor');
      return null;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  /// Update existing visitor via PUT /visitors/{id}
  Future<Visitor?> updateVisitor(Visitor visitor) async {
    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateVisitor(visitor);
      final index = _visitors.indexWhere((v) => v.id == updated.id);
      if (index != -1) {
        _visitors[index] = updated;
      }
      _successMessage = 'Visitor "${updated.name}" updated successfully';
      return updated;
    } catch (e) {
      _errorMessage = _parseError(e, 'Failed to update visitor');
      return null;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  /// Check in visitor:
  /// Business rules:
  /// - Allow check-in only when status is Registered
  /// - Record check-in date and time
  /// - Update status to Checked In
  /// - Save changes through API
  Future<Visitor?> checkInVisitor(String id) async {
    final index = _visitors.indexWhere((v) => v.id == id);
    if (index == -1) {
      _errorMessage = 'Visitor not found';
      notifyListeners();
      return null;
    }

    final current = _visitors[index];

    // Business validation rule: cannot check in twice or if already checked in/out
    if (!current.isRegistered) {
      if (current.isCheckedIn) {
        _errorMessage = 'Visitor is already checked in.';
      } else {
        _errorMessage = 'Completed visits cannot be checked in again.';
      }
      notifyListeners();
      return null;
    }

    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now().toIso8601String();
      final updated = await _repository.updateVisitStatus(
        id,
        Visitor.statusCheckedIn,
        checkInTime: now,
      );

      _visitors[index] = updated;
      _successMessage = 'Visitor "${updated.name}" checked in successfully';
      return updated;
    } catch (e) {
      _errorMessage = _parseError(e, 'Failed to check in visitor');
      return null;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  /// Check out visitor:
  /// Business rules:
  /// - Allow check-out only when status is Checked In
  /// - Record check-out date and time
  /// - Update status to Checked Out
  /// - Save changes through API
  Future<Visitor?> checkOutVisitor(String id) async {
    final index = _visitors.indexWhere((v) => v.id == id);
    if (index == -1) {
      _errorMessage = 'Visitor not found';
      notifyListeners();
      return null;
    }

    final current = _visitors[index];

    // Business validation rule: cannot check out before checking in
    if (!current.isCheckedIn) {
      if (current.isRegistered) {
        _errorMessage = 'Visitor cannot check out before checking in.';
      } else {
        _errorMessage = 'Visitor has already checked out.';
      }
      notifyListeners();
      return null;
    }

    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now().toIso8601String();
      final updated = await _repository.updateVisitStatus(
        id,
        Visitor.statusCheckedOut,
        checkOutTime: now,
      );

      _visitors[index] = updated;
      _successMessage = 'Visitor "${updated.name}" checked out successfully';
      return updated;
    } catch (e) {
      _errorMessage = _parseError(e, 'Failed to check out visitor');
      return null;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  /// Delete visitor record via DELETE /visitors/{id}
  Future<bool> deleteVisitor(String id) async {
    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.deleteVisitor(id);
      _visitors.removeWhere((v) => v.id == id);
      _successMessage = 'Visitor record deleted successfully';
      return true;
    } catch (e) {
      _errorMessage = _parseError(e, 'Failed to delete visitor');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  /// Reset to initial sample records
  Future<void> resetToSampleData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.resetData();
      _visitors = await _repository.getAllVisitors();
      _successMessage = 'Reset to sample visitor records';
    } catch (e) {
      _errorMessage = 'Failed to reset data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _parseError(dynamic e, String defaultMsg) {
    if (e is DioException) {
      if (e.response != null && e.response?.data != null) {
        return '$defaultMsg: ${e.response?.statusMessage ?? e.message}';
      }
      return '$defaultMsg (${e.type})';
    }
    return '$defaultMsg: $e';
  }
}

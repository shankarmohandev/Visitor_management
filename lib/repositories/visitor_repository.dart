import '../models/visitor.dart';
import '../services/visitor_api_service.dart';

/// Repository pattern separating REST API interactions from business state.
class VisitorRepository {
  final VisitorApiService _apiService;

  VisitorRepository({VisitorApiService? apiService})
      : _apiService = apiService ?? VisitorApiService();

  VisitorApiService get apiService => _apiService;

  Future<void> init() => _apiService.init();

  /// Retrieve all visitor records via GET /visitors
  Future<List<Visitor>> getAllVisitors() async {
    final list = await _apiService.getVisitors();
    return list.map((json) => Visitor.fromJson(json)).toList();
  }

  /// Retrieve specific visitor by ID via GET /visitors/{id}
  Future<Visitor> getVisitorById(String id) async {
    final json = await _apiService.getVisitorById(id);
    return Visitor.fromJson(json);
  }

  /// Register a new visitor via POST /visitors
  Future<Visitor> registerVisitor(Visitor visitor) async {
    final json = await _apiService.registerVisitor(visitor.toJson());
    return Visitor.fromJson(json);
  }

  /// Update an existing visitor profile via PUT /visitors/{id}
  Future<Visitor> updateVisitor(Visitor visitor) async {
    final json = await _apiService.updateVisitor(visitor.id, visitor.toJson());
    return Visitor.fromJson(json);
  }

  /// Update visit status and corresponding timestamp via PATCH /visitors/{id}
  Future<Visitor> updateVisitStatus(
    String id,
    String status, {
    String? checkInTime,
    String? checkOutTime,
  }) async {
    final patchData = <String, dynamic>{
      'status': status,
    };
    if (checkInTime != null) {
      patchData['check_in_time'] = checkInTime;
    }
    if (checkOutTime != null) {
      patchData['check_out_time'] = checkOutTime;
    }

    final json = await _apiService.patchVisitor(id, patchData);
    return Visitor.fromJson(json);
  }

  /// Delete visitor record via DELETE /visitors/{id}
  Future<void> deleteVisitor(String id) async {
    await _apiService.deleteVisitor(id);
  }

  /// Reset to initial sample records for testing
  Future<void> resetData() => _apiService.resetToSampleData();
}

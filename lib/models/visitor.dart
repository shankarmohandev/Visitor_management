/// Visitor data model strictly matching the Sumadhura assignment specifications:
/// - id: String (Unique visitor ID)
/// - name: String (Visitor name)
/// - mobile: String (Mobile number, 10 digits)
/// - email: nullable String (Email address)
/// - visitor_type: String ("Customer", "Vendor", "Other")
/// - project: String ("Project A", "Project B", "Project C")
/// - purpose: String (Purpose of visit)
/// - status: String ("Registered", "Checked In", "Checked Out")
/// - created_at: String (ISO timestamp)
/// - check_in_time: nullable String (Check-in timestamp)
/// - check_out_time: nullable String (Check-out timestamp)
class Visitor {
  final String id;
  final String name;
  final String mobile;
  final String? email;
  final String visitorType;
  final String project;
  final String purpose;
  final String status;
  final String createdAt;
  final String? checkInTime;
  final String? checkOutTime;

  static const String statusRegistered = 'Registered';
  static const String statusCheckedIn = 'Checked In';
  static const String statusCheckedOut = 'Checked Out';

  static const List<String> visitorTypes = ['Customer', 'Vendor', 'Other'];
  static const List<String> projects = ['Project A', 'Project B', 'Project C'];

  const Visitor({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    required this.visitorType,
    required this.project,
    required this.purpose,
    this.status = statusRegistered,
    required this.createdAt,
    this.checkInTime,
    this.checkOutTime,
  });

  bool get isRegistered => status == statusRegistered;
  bool get isCheckedIn => status == statusCheckedIn;
  bool get isCheckedOut => status == statusCheckedOut;

  /// Two-letter initials for avatar badge (e.g. 'RS', 'PP')
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'V';
  }

  /// Check whether registration date matches today (using local device date)
  bool isRegisteredToday([DateTime? now]) {
    final current = now ?? DateTime.now();
    try {
      final date = DateTime.parse(createdAt).toLocal();
      return date.year == current.year &&
          date.month == current.month &&
          date.day == current.day;
    } catch (_) {
      return false;
    }
  }

  /// Check whether checkout date matches today (using local device date)
  bool isCheckedOutToday([DateTime? now]) {
    if (status != statusCheckedOut || checkOutTime == null) return false;
    final current = now ?? DateTime.now();
    try {
      final date = DateTime.parse(checkOutTime!).toLocal();
      return date.year == current.year &&
          date.month == current.month &&
          date.day == current.day;
    } catch (_) {
      return false;
    }
  }

  /// Deserialization strictly compliant with assignment sample JSON:
  /// {
  ///   "id": "VIS001",
  ///   "name": "Rahul Sharma",
  ///   "mobile": "9876543210",
  ///   "email": "rahul@example.com",
  ///   "visitor_type": "Customer",
  ///   "project": "Project A",
  ///   "purpose": "Site Visit",
  ///   "status": "Registered",
  ///   "created_at": "2026-10-26T10:00:00+05:30",
  ///   "check_in_time": null,
  ///   "check_out_time": null
  /// }
  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      email: (json['email'] != null && json['email'].toString().trim().isNotEmpty)
          ? json['email'].toString().trim()
          : null,
      visitorType: json['visitor_type']?.toString() ??
          json['visitorType']?.toString() ??
          'Customer',
      project: json['project']?.toString() ?? 'Project A',
      purpose: json['purpose']?.toString() ?? '',
      status: json['status']?.toString() ?? statusRegistered,
      createdAt: json['created_at']?.toString() ??
          json['createdAt']?.toString() ??
          DateTime.now().toIso8601String(),
      checkInTime: json['check_in_time']?.toString() ?? json['checkInTime']?.toString(),
      checkOutTime: json['check_out_time']?.toString() ?? json['checkOutTime']?.toString(),
    );
  }

  /// Serialization strictly compliant with assignment sample JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'visitor_type': visitorType,
      'project': project,
      'purpose': purpose,
      'status': status,
      'created_at': createdAt,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
    };
  }

  Visitor copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    bool clearEmail = false,
    String? visitorType,
    String? project,
    String? purpose,
    String? status,
    String? createdAt,
    String? checkInTime,
    bool clearCheckInTime = false,
    String? checkOutTime,
    bool clearCheckOutTime = false,
  }) {
    return Visitor(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: clearEmail ? null : (email ?? this.email),
      visitorType: visitorType ?? this.visitorType,
      project: project ?? this.project,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      checkInTime: clearCheckInTime ? null : (checkInTime ?? this.checkInTime),
      checkOutTime: clearCheckOutTime ? null : (checkOutTime ?? this.checkOutTime),
    );
  }
}

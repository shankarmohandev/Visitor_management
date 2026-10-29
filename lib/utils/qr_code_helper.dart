import 'dart:convert';

/// Helper utility for parsing and extracting Visitor IDs from QR codes.
///
/// Supports multiple encoding schemes:
/// - Legacy/Extended pass format:
///     "SUMADHURA-PASS:VIS001:VP-0001:9876543210" -> "VIS001"
/// - Plain Visitor ID:
///     "VIS001", "vis002" -> "VIS001", "VIS002"
/// - Prefixed formats:
///     "PASS:VIS001", "PASS ID: VIS001", "ID:VIS001", "VISITOR:VIS001" -> "VIS001"
/// - JSON payload format:
///     '{"id": "VIS001", "name": "Rahul"}' -> "VIS001"
///     '{"visitor_id": "VIS001"}' -> "VIS001"
///     '{"visitorId": "VIS001"}' -> "VIS001"
/// - Deep links & URLs:
///     "https://sumadhura.in/visitor/VIS001" -> "VIS001"
///     "sumadhura://visitor/VIS001" -> "VIS001"
/// - Delimited strings (:, |, ;, /):
///     "SUMADHURA-PASS:VIS001" -> "VIS001"
///     "PASS:VIS001:OTHER" -> "VIS001"
class QRCodeHelper {
  const QRCodeHelper._();

  /// Extracts the clean visitor ID from any raw QR string.
  static String extractVisitorId(String rawCode) {
    final trimmed = rawCode.trim();
    if (trimmed.isEmpty) return trimmed;

    // 1. JSON payload support: {"id": "VIS001", ...} or {"visitor_id": ...}
    if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map) {
          final id = decoded['id'] ??
              decoded['visitor_id'] ??
              decoded['visitorId'] ??
              decoded['visitorID'];
          if (id != null && id.toString().trim().isNotEmpty) {
            return id.toString().trim().toUpperCase();
          }
        }
      } catch (_) {}
    }

    // 2. Exact match for standard Visitor ID (e.g. VIS001, VIS002)
    final exactVisRegex = RegExp(r'^VIS\d+$', caseSensitive: false);
    if (exactVisRegex.hasMatch(trimmed)) {
      return trimmed.toUpperCase();
    }

    // 3. Look for standard VIS pattern with digits anywhere in the string
    // Matches "SUMADHURA-PASS:VIS001:VP-0001:9876543210" -> "VIS001"
    final embeddedVisRegex = RegExp(r'\b(VIS\d+)\b', caseSensitive: false);
    final visMatch = embeddedVisRegex.firstMatch(trimmed);
    if (visMatch != null) {
      return visMatch.group(1)!.toUpperCase();
    }

    // 4. Delimited formats with colons, pipes, semicolons, slashes, or whitespace
    final parts = trimmed.split(RegExp(r'[:|;,\s/]+'));
    if (parts.length > 1) {
      // Check if any segment matches the VIS pattern
      for (final part in parts) {
        if (exactVisRegex.hasMatch(part.trim())) {
          return part.trim().toUpperCase();
        }
      }

      // If prefixed with known tags: SUMADHURA-PASS, PASS, ID, VISITOR
      final firstPart = parts[0].toUpperCase();
      if (firstPart.contains('PASS') ||
          firstPart.contains('VISITOR') ||
          firstPart == 'ID') {
        if (parts.length >= 2 && parts[1].trim().isNotEmpty) {
          return parts[1].trim().toUpperCase();
        }
      }
    }

    // 5. URL path check (e.g. https://.../visitors/VIS001)
    try {
      final uri = Uri.tryParse(trimmed);
      if (uri != null && uri.pathSegments.isNotEmpty) {
        final last = uri.pathSegments.last.trim();
        final match = embeddedVisRegex.firstMatch(last);
        if (match != null) {
          return match.group(1)!.toUpperCase();
        }
        if (last.isNotEmpty && last.length <= 15) {
          return last.toUpperCase();
        }
      }
    } catch (_) {}

    // Fallback: return trimmed original string
    return trimmed;
  }

  /// Attempts to extract a 10-digit mobile number from the scanned string if present
  static String? extractMobile(String rawCode) {
    final match = RegExp(r'\b\d{10}\b').firstMatch(rawCode);
    return match?.group(0);
  }
}

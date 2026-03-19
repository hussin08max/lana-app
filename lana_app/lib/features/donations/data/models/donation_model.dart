/// Minimal case info returned with `GET /donations/my-donations`.
class DonationCaseSummary {
  const DonationCaseSummary({
    required this.title,
    required this.location,
    this.id,
  });

  final String? id;
  final String title;
  final String location;

  factory DonationCaseSummary.fromJson(Map<String, dynamic> json) {
    return DonationCaseSummary(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      location: json['location'] as String? ?? '',
    );
  }
}

class DonationModel {
  const DonationModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.caseDetails,
  });

  final String id;
  final double amount;
  final String status;
  final DateTime createdAt;
  final DonationCaseSummary? caseDetails;

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    final caseRaw = json['case'];
    return DonationModel(
      id: json['id'] as String,
      amount: _parseAmount(json['amount']),
      status: json['status']?.toString() ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      caseDetails: caseRaw is Map<String, dynamic>
          ? DonationCaseSummary.fromJson(caseRaw)
          : null,
    );
  }

  static double _parseAmount(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  static DateTime _parseDateTime(dynamic v) {
    if (v is String) {
      return DateTime.tryParse(v) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

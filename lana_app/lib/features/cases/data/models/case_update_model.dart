class CaseUpdateModel {
  const CaseUpdateModel({
    required this.id,
    required this.caseId,
    this.notes,
    required this.images,
    this.video,
    required this.createdAt,
  });

  final String id;
  final String caseId;
  final String? notes;
  final List<String> images;
  final String? video;
  final DateTime createdAt;

  factory CaseUpdateModel.fromJson(Map<String, dynamic> json) {
    final imgs = json['images'];
    return CaseUpdateModel(
      id: json['id'] as String,
      caseId: json['caseId'] as String,
      notes: json['notes'] as String?,
      images: imgs is List
          ? imgs.map((e) => e.toString()).toList()
          : <String>[],
      video: json['video'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  static DateTime _parseDateTime(dynamic v) {
    if (v is String) {
      return DateTime.tryParse(v) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

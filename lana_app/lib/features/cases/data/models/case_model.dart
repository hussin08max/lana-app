import 'case_update_model.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
    );
  }
}

class CaseModel {
  const CaseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.status,
    required this.priority,
    this.createdByUser,
    this.updates,
  });

  final String id;
  final String title;
  final String description;
  final String location;
  final String status;
  final int priority;
  final UserModel? createdByUser;
  final List<CaseUpdateModel>? updates;

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    final created = json['createdByUser'];
    return CaseModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      status: json['status']?.toString() ?? '',
      priority: _parseInt(json['priority']),
      createdByUser: created is Map<String, dynamic>
          ? UserModel.fromJson(created)
          : null,
      updates: _parseUpdates(json['updates']),
    );
  }

  static List<CaseUpdateModel>? _parseUpdates(dynamic v) {
    if (v == null) return null;
    if (v is! List) return null;
    return v
        .map(
          (e) => CaseUpdateModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }
}

import 'package:flutter/material.dart';
import 'package:lana_app/features/cases/data/models/case_model.dart';

/// أيقونات حسب نوع الحالة لعرض حيوي في الواجهة.
IconData iconForCase(CaseModel c) {
  final id = c.id.toLowerCase();
  final title = c.title.toLowerCase();

  if (id.startsWith('demo-')) {
    switch (id) {
      case 'demo-1':
        return Icons.home_work_outlined; // أسرة متضررة من الفيضانات
      case 'demo-2':
        return Icons.local_hospital_outlined; // علاج طبي
      case 'demo-3':
        return Icons.school_outlined; // دعم تعليمي
      case 'demo-4':
        return Icons.emergency_outlined; // إغاثة نازحين
      default:
        break;
    }
  }

  if (title.contains('علاج') ||
      title.contains('عملية') ||
      title.contains('طبي') ||
      title.contains('مستشف')) {
    return Icons.local_hospital_outlined;
  }
  if (title.contains('تعليم') ||
      title.contains('مدرس') ||
      title.contains('أيتام') ||
      title.contains('طلاب')) {
    return Icons.school_outlined;
  }
  if (title.contains('فيضان') ||
      title.contains('نازح') ||
      title.contains('إغاثة') ||
      title.contains('مأوى')) {
    return Icons.home_work_outlined;
  }
  if (title.contains('طعام') || title.contains('غذاء')) {
    return Icons.restaurant_outlined;
  }

  return Icons.volunteer_activism_outlined;
}

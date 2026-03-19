import '../../features/cases/data/models/case_model.dart';
import '../../features/cases/data/models/case_update_model.dart';
import '../../features/donations/data/models/donation_model.dart';

/// بيانات تجريبية للعرض المحلي دون الحاجة للخادم.
class DemoData {
  DemoData._();

  static const _user1 = UserModel(id: 'u1', name: 'فريق لنا الميداني');
  static const _user2 = UserModel(id: 'u2', name: 'جمعية الخير السودانية');

  static final List<CaseModel> cases = [
    CaseModel(
      id: 'demo-1',
      title: 'أسرة متضررة من الفيضانات - الخرطوم',
      description:
          'أسرة مكونة من ٦ أفراد فقدت منزلها بسبب الفيضانات الأخيرة في منطقة الخرطوم بحري. '
          'بحاجة ماسة لمساعدات عاجلة: مأوى، غذاء، وملابس للأطفال.',
      location: 'الخرطوم بحري، السودان',
      status: 'OPEN',
      priority: 8,
      createdByUser: _user1,
      updates: [
        CaseUpdateModel(
          id: 'up1',
          caseId: 'demo-1',
          notes: 'تم زيارة الأسرة والتأكد من الوضع. تم توزيع وجبات وملابس أولية.',
          images: [],
          video: null,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ],
    ),
    CaseModel(
      id: 'demo-2',
      title: 'علاج طبي عاجل لطفل - أم درمان',
      description:
          'طفل يبلغ من العمر ٥ سنوات بحاجة لعملية جراحية عاجلة. الأسرة غير قادرة على تغطية التكاليف.',
      location: 'أم درمان، ولاية الخرطوم',
      status: 'OPEN',
      priority: 9,
      createdByUser: _user2,
      updates: [],
    ),
    CaseModel(
      id: 'demo-3',
      title: 'دعم تعليمي لأيتام - نيالا',
      description:
          'مجموعة من الأطفال الأيتام بحاجة لدعم مستمر للالتحاق بالمدارس وشراء المستلزمات الدراسية.',
      location: 'نيالا، ولاية جنوب دارفور',
      status: 'OPEN',
      priority: 5,
      createdByUser: _user1,
      updates: [
        CaseUpdateModel(
          id: 'up2',
          caseId: 'demo-3',
          notes: 'تم تسجيل ١٢ طفلاً واستلام المستلزمات الأولى.',
          images: [],
          video: null,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ],
    ),
    CaseModel(
      id: 'demo-4',
      title: 'إغاثة نازحين - كسلا',
      description:
          'عائلات نازحة من مناطق النزاع بحاجة لمواد إغاثة أساسية: خيام، بطانيات، ومياه صالحة للشرب.',
      location: 'كسلا، شرق السودان',
      status: 'OPEN',
      priority: 7,
      createdByUser: _user2,
      updates: [],
    ),
  ];

  static CaseModel? caseById(String id) {
    try {
      return cases.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static final List<DonationModel> donations = [
    DonationModel(
      id: 'd1',
      amount: 150.0,
      status: 'COMPLETED',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      caseDetails: const DonationCaseSummary(
        title: 'أسرة متضررة من الفيضانات - الخرطوم',
        location: 'الخرطوم بحري، السودان',
      ),
    ),
    DonationModel(
      id: 'd2',
      amount: 75.5,
      status: 'PENDING',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      caseDetails: const DonationCaseSummary(
        title: 'دعم تعليمي لأيتام - نيالا',
        location: 'نيالا، ولاية جنوب دارفور',
      ),
    ),
  ];
}

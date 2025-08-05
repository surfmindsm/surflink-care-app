import 'dart:convert';
import '../models/report.dart';
import '../config/app_config.dart';

class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  // Mock 데이터 - 추후 실제 API 연동 시 제거
  Future<List<Report>> getUserReports(
    String userId, {
    ReportType? type,
    ReportStatus? status,
    int? limit,
    int? offset,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    var reports = _getMockReports().where(
      (report) => report.reporterId == userId,
    ).toList();

    if (type != null) {
      reports = reports.where((report) => report.type == type).toList();
    }

    if (status != null) {
      reports = reports.where((report) => report.status == status).toList();
    }

    // 최신순 정렬
    reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (offset != null) {
      reports = reports.skip(offset).toList();
    }

    if (limit != null) {
      reports = reports.take(limit).toList();
    }

    return reports;
  }

  Future<Report?> getReportById(String reportId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      return _getMockReports().firstWhere((report) => report.id == reportId);
    } catch (e) {
      return null;
    }
  }

  Future<Report> createReport({
    required String reporterId,
    required ReportCreateRequest request,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final now = DateTime.now();
    final reportId = 'report_${DateTime.now().millisecondsSinceEpoch}';

    final report = Report(
      id: reportId,
      reporterId: reporterId,
      reporterName: '사용자', // 실제로는 사용자 이름 조회
      targetId: request.targetId,
      targetName: request.targetName,
      type: request.type,
      status: ReportStatus.submitted,
      priority: _determinePriority(request.type, request.description),
      subject: request.subject,
      description: request.description,
      attachments: request.attachments,
      createdAt: now,
      updatedAt: now,
      metadata: request.metadata,
    );

    return report;
  }

  Future<void> updateReport(String reportId, Map<String, dynamic> updates) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock implementation - 실제 구현 시 API 호출
  }

  Future<void> deleteReport(String reportId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock implementation - 실제 구현 시 API 호출
  }

  Future<List<FAQ>> getFAQs({String? category}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    var faqs = _getMockFAQs();
    
    if (category != null && category != '전체') {
      faqs = faqs.where((faq) => faq.category == category).toList();
    }

    // 인기순 -> 최신순 정렬
    faqs.sort((a, b) {
      if (a.isPopular && !b.isPopular) return -1;
      if (!a.isPopular && b.isPopular) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    return faqs;
  }

  Future<List<String>> getFAQCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final categories = _getMockFAQs()
        .map((faq) => faq.category)
        .toSet()
        .toList();
    
    categories.insert(0, '전체');
    return categories;
  }

  Future<void> incrementFAQViewCount(String faqId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Mock implementation - 실제 구현 시 API 호출
  }

  // 우선순위 자동 결정 로직
  ReportPriority _determinePriority(ReportType type, String description) {
    final lowercaseDescription = description.toLowerCase();
    
    // 긴급 키워드
    if (lowercaseDescription.contains('긴급') || 
        lowercaseDescription.contains('사기') ||
        lowercaseDescription.contains('위험') ||
        lowercaseDescription.contains('도움')) {
      return ReportPriority.urgent;
    }
    
    // 높음 키워드
    if (lowercaseDescription.contains('문제') ||
        lowercaseDescription.contains('불만') ||
        lowercaseDescription.contains('환불') ||
        type == ReportType.payment) {
      return ReportPriority.high;
    }
    
    // 기본값
    return ReportPriority.medium;
  }

  // Mock 데이터 생성 함수들
  List<Report> _getMockReports() {
    final now = DateTime.now();
    
    return [
      Report(
        id: 'report_001',
        reporterId: 'user_002',
        reporterName: '김프리',
        targetId: 'user_001',
        targetName: '이고객',
        type: ReportType.user,
        status: ReportStatus.resolved,
        priority: ReportPriority.medium,
        subject: '부적절한 언행',
        description: '서비스 중 고객이 부적절한 언행을 했습니다. 계약 조건과 다른 요구사항을 계속 제기하고 있어 문제가 되고 있습니다.',
        attachments: [],
        adminResponse: '해당 사용자에게 경고 조치를 취했습니다. 추가 문제 발생 시 연락 부탁드립니다.',
        adminId: 'admin_001',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 2)),
        resolvedAt: now.subtract(const Duration(days: 2)),
      ),
      Report(
        id: 'report_002',
        reporterId: 'user_002',
        reporterName: '김프리',
        targetId: null,
        targetName: null,
        type: ReportType.payment,
        status: ReportStatus.reviewing,
        priority: ReportPriority.high,
        subject: '정산 지연 문제',
        description: '완료된 서비스에 대한 정산이 예정일보다 일주일 이상 지연되고 있습니다. 빠른 처리 부탁드립니다.',
        attachments: ['payment_evidence.jpg'],
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Report(
        id: 'report_003',
        reporterId: 'user_001',
        reporterName: '이고객',
        targetId: 'user_004',
        targetName: '박프리',
        type: ReportType.service,
        status: ReportStatus.submitted,
        priority: ReportPriority.urgent,
        subject: '서비스 불이행',
        description: '약속된 시간에 나타나지 않았고, 연락도 되지 않습니다. 긴급히 처리해주세요.',
        attachments: ['screenshot.png'],
        createdAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),
      Report(
        id: 'report_004',
        reporterId: 'user_002',
        reporterName: '김프리',
        targetId: null,
        targetName: null,
        type: ReportType.app,
        status: ReportStatus.closed,
        priority: ReportPriority.low,
        subject: '앱 오류',
        description: '채팅 화면에서 가끔 메시지가 중복으로 표시되는 문제가 있습니다.',
        attachments: [],
        adminResponse: '해당 문제는 최신 버전에서 수정되었습니다. 앱을 업데이트해주세요.',
        adminId: 'admin_002',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 8)),
        resolvedAt: now.subtract(const Duration(days: 8)),
      ),
    ];
  }

  List<FAQ> _getMockFAQs() {
    final now = DateTime.now();
    
    return [
      FAQ(
        id: 'faq_001',
        category: '서비스 이용',
        question: '어떤 서비스를 제공하나요?',
        answer: '''Care SurfLink는 다음과 같은 돌봄 서비스를 제공합니다:

• 간병 서비스 - 환자 돌봄 및 생활 지원
• 가사도우미 - 청소, 요리, 세탁 등 가사업무
• 육아도우미 - 아이 돌봄 및 교육 지원
• 반려동물 돌봄 - 펫시팅 및 산책 서비스
• 시니어케어 - 어르신 생활 지원

전문적으로 검증된 프리랜서들이 안전하고 신뢰할 수 있는 서비스를 제공합니다.''',
        viewCount: 1250,
        isPopular: true,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      FAQ(
        id: 'faq_002',
        category: '서비스 이용',
        question: '매칭은 어떻게 이루어지나요?',
        answer: '''매칭 과정은 다음과 같습니다:

1. 서비스 요청서 작성
2. 조건에 맞는 프리랜서 추천
3. 프로필 및 리뷰 확인
4. 채팅으로 상세 조율
5. 계약 체결
6. 서비스 시작

AI 기반 매칭 시스템으로 최적의 프리랜서를 추천해드립니다.''',
        viewCount: 890,
        isPopular: true,
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      FAQ(
        id: 'faq_003',
        category: '결제/정산',
        question: '수수료는 얼마인가요?',
        answer: '''플랫폼 이용 수수료는 다음과 같습니다:

• 서비스 금액의 5% (프리랜서 부담)
• 결제 수수료 별도 (카드결제 시)
• 최소 수수료: 1,000원

정산은 서비스 완료 후 3영업일 이내에 처리됩니다.''',
        viewCount: 670,
        isPopular: false,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      FAQ(
        id: 'faq_004',
        category: '계정 관리',
        question: '프로필 사진은 어떻게 변경하나요?',
        answer: '''프로필 사진 변경 방법:

1. 프로필 화면 진입
2. 편집 버튼 클릭
3. 프로필 사진 영역 터치
4. 갤러리에서 사진 선택 또는 카메라 촬영
5. 저장 버튼 클릭

JPG, PNG 형식의 5MB 이하 파일만 업로드 가능합니다.''',
        viewCount: 450,
        isPopular: false,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 12)),
      ),
      FAQ(
        id: 'faq_005',
        category: '문제 해결',
        question: '서비스 중 문제가 생기면 어떻게 하나요?',
        answer: '''서비스 중 문제 발생 시:

1. 먼저 상대방과 직접 소통
2. 해결되지 않으면 채팅 내 신고 기능 이용
3. 고객센터 신고/문의 접수
4. 관리자가 24시간 내 확인 및 조치

긴급상황 시에는 전화 고객센터(1588-1234)로 연락해주세요.''',
        viewCount: 320,
        isPopular: false,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 8)),
      ),
      FAQ(
        id: 'faq_006',
        category: '결제/정산',
        question: '환불은 어떻게 받나요?',
        answer: '''환불 절차:

1. 환불 사유 발생 시 즉시 신고
2. 관리자 검토 (1-3일 소요)
3. 승인 시 결제 수단으로 환불
4. 카드결제: 3-5일, 계좌이체: 1-2일

서비스 시작 전: 100% 환불
서비스 진행 중: 부분 환불 가능
서비스 완료 후: 특별한 사유 시에만 환불''',
        viewCount: 280,
        isPopular: false,
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }
}

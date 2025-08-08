import 'api_service.dart';
import '../models/settlement.dart';

class SettlementService {
  final ApiService apiService = ApiService();

  // 정산 목록 조회
  Future<List<Settlement>> getSettlements(String freelancerId) async {
    try {
      print('[DEBUG] Settlement API 호출 시도 - freelancerId: $freelancerId');
      // 실제 Supabase 쿼리
      final response = await apiService
          .from('settlements')
          .select('id, total_amount, commission_amount, settlement_amount, status, processed_at, completed_at')
          .eq('freelancer_id', freelancerId)
          .order('processed_at', ascending: false);

      final list = (response as List?) ?? [];
      final settlements = list
          .whereType<Map<String, dynamic>>()
          .map((e) => Settlement.fromJson(e))
          .toList();

      // 빈 리스트일 경우에도 정상 반환
      return settlements;
    } catch (e) {
      print('정산 목록 조회 에러: $e');
      return _getSampleSettlements();
    }
  }

  // 정산 통계 조회
  Future<Map<String, dynamic>> getSettlementStats(String freelancerId) async {
    try {
      print('[DEBUG] Settlement 통계 API 호출 시도 - freelancerId: $freelancerId');
      // 정산 데이터 집계
      final response = await apiService
          .from('settlements')
          .select('total_amount, commission_amount, settlement_amount, status, processed_at, created_at')
          .eq('freelancer_id', freelancerId);

      final list = (response as List?) ?? [];

      double totalEarnings = 0;
      double thisMonthEarnings = 0;
      double pendingAmount = 0;
      double totalFee = 0;
      int completedServices = 0;

      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month, 1);

      for (final item in list.whereType<Map<String, dynamic>>()) {
        final status = (item['status'] as String?)?.toLowerCase();
        final amount = (item['total_amount'] as num?)?.toDouble() ?? 0;
        final fee = (item['commission_amount'] as num?)?.toDouble() ?? 0;
        final net = (item['settlement_amount'] as num?)?.toDouble() ?? (amount - fee);
        final reqAtStr = (item['processed_at'] as String?) ?? (item['created_at'] as String?);
        DateTime? reqAt;
        if (reqAtStr != null) {
          try { reqAt = DateTime.parse(reqAtStr); } catch (_) {}
        }

        // 총합
        totalEarnings += net;
        totalFee += fee;

        // 이번 달
        if (reqAt != null && !reqAt.isBefore(thisMonth)) {
          thisMonthEarnings += net;
        }

        // 상태별
        if (status == 'completed') {
          completedServices += 1;
        } else if (status == 'pending') {
          pendingAmount += net;
        }
      }

      // 리뷰 평점 평균
      double averageRating = 0.0;
      try {
        final reviews = await apiService
            .from('reviews')
            .select('rating')
            .eq('reviewee_id', freelancerId);
        final ratings = (reviews as List?)
                ?.whereType<Map<String, dynamic>>()
                .map((e) => (e['rating'] as num?)?.toDouble())
                .whereType<double>()
                .toList() ??
            [];
        if (ratings.isNotEmpty) {
          averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
        }
      } catch (e) {
        print('리뷰 평균 조회 실패(무시 가능): $e');
      }

      // 서비스별 수익 집계 (settlement_amount를 카테고리별로 누적)
      final Map<String, double> serviceBreakdown = {};
      try {
        final breakdownResp = await apiService
            .from('settlements')
            .select(
                'settlement_amount, payments:payment_id ( contracts:contract_id ( matchings:matching_id ( service_requests:request_id ( category ) ) ) )')
            .eq('freelancer_id', freelancerId);

        final bList = (breakdownResp as List?) ?? [];
        for (final row in bList.whereType<Map<String, dynamic>>()) {
          final amount = (row['settlement_amount'] as num?)?.toDouble() ?? 0.0;

          dynamic payments = row['payments'];
          dynamic contracts;
          if (payments is Map) {
            contracts = payments['contracts'];
          } else if (payments is List && payments.isNotEmpty) {
            contracts = payments.first['contracts'];
          }

          dynamic matchings;
          if (contracts is Map) {
            matchings = contracts['matchings'];
          } else if (contracts is List && contracts.isNotEmpty) {
            matchings = contracts.first['matchings'];
          }

          dynamic serviceReq;
          if (matchings is Map) {
            serviceReq = matchings['service_requests'];
          } else if (matchings is List && matchings.isNotEmpty) {
            serviceReq = matchings.first['service_requests'];
          }

          String category = '기타';
          if (serviceReq is Map && serviceReq['category'] is String) {
            category = serviceReq['category'] as String;
          } else if (serviceReq is List && serviceReq.isNotEmpty && serviceReq.first['category'] is String) {
            category = serviceReq.first['category'] as String;
          }

          serviceBreakdown[category] = (serviceBreakdown[category] ?? 0) + amount;
        }
      } catch (e) {
        print('서비스별 수익 집계 실패(무시 가능): $e');
      }

      return {
        'totalEarnings': totalEarnings,
        'thisMonthEarnings': thisMonthEarnings,
        'pendingAmount': pendingAmount,
        'totalFee': totalFee,
        'completedServices': completedServices,
        'averageRating': double.parse(averageRating.toStringAsFixed(2)),
        'serviceBreakdown': serviceBreakdown,
      };
    } catch (e) {
      print('정산 통계 조회 에러: $e');
      return _getSampleStats();
    }
  }

  // 정산 취소
  Future<bool> cancelSettlement(String settlementId) async {
    try {
      await apiService.from('settlements')
          .update({'status': 'cancelled'})
          .eq('id', settlementId);
      return true;
    } catch (e) {
      print('정산 취소 에러: $e');
      return false;
    }
  }

  // 정산 상태 파싱 헬퍼
  SettlementStatus _parseSettlementStatus(String? status) {
    if (status == null) return SettlementStatus.pending;
    
    switch (status.toLowerCase()) {
      case 'pending':
        return SettlementStatus.pending;
      case 'completed':
        return SettlementStatus.completed;
      case 'rejected':
      case 'cancelled':
        return SettlementStatus.rejected;
      default:
        return SettlementStatus.pending;
    }
  }

  // 샘플 데이터 (API 실패 시 사용)
  List<Settlement> _getSampleSettlements() {
    return [
      Settlement(
        id: '1',
        amount: 150000,
        fee: 15000,
        netAmount: 135000,
        status: SettlementStatus.completed,
        requestDate: DateTime.now().subtract(const Duration(days: 2)),
        completedDate: DateTime.now().subtract(const Duration(days: 1)),
        serviceType: '아이 돌봄',
        clientName: '김고객',
      ),
      Settlement(
        id: '2',
        amount: 200000,
        fee: 20000,
        netAmount: 180000,
        status: SettlementStatus.pending,
        requestDate: DateTime.now().subtract(const Duration(days: 1)),
        serviceType: '영어 과외',
        clientName: '박학부모',
      ),
      Settlement(
        id: '3',
        amount: 100000,
        fee: 10000,
        netAmount: 90000,
        status: SettlementStatus.completed,
        requestDate: DateTime.now().subtract(const Duration(days: 5)),
        completedDate: DateTime.now().subtract(const Duration(days: 3)),
        serviceType: '심리 상담',
        clientName: '이내담자',
      ),
    ];
  }

  Map<String, dynamic> _getSampleStats() {
    return {
      'totalEarnings': 750000.0,
      'thisMonthEarnings': 350000.0,
      'pendingAmount': 200000.0,
      'totalFee': 75000.0,
      'completedServices': 15,
      'averageRating': 4.8,
      'serviceBreakdown': {
        '아이 돌봄': 250000.0,
        '영어 과외': 300000.0,
        '심리 상담': 150000.0,
        '간병 서비스': 50000.0,
      },
    };
  }

  // 프리랜서 수익 현황 조회
  Future<Map<String, dynamic>> getFreelancerEarnings(String freelancerId) async {
    try {
      final response = await apiService.from('settlements')
          .select('settlement_amount, status, created_at')
          .eq('freelancer_id', freelancerId)
          .order('created_at', ascending: false);

      double totalEarnings = 0;
      double thisMonthEarnings = 0;
      int completedJobs = 0;
      int pendingPayments = 0;

      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month, 1);

      final responseList = response as List? ?? [];
      for (final settlement in responseList) {
        if (settlement == null) continue;
        
        final amount = (settlement['settlement_amount'] as num?)?.toDouble() ?? 0;
        final createdAt = DateTime.tryParse(settlement['created_at'] ?? '') ?? DateTime.now();
        final status = settlement['status'] as String? ?? '';

        totalEarnings += amount;
        
        if (createdAt.isAfter(thisMonth)) {
          thisMonthEarnings += amount;
        }

        if (status == 'completed') {
          completedJobs++;
        } else if (status == 'pending') {
          pendingPayments++;
        }
      }

      return {
        'totalEarnings': totalEarnings,
        'thisMonthEarnings': thisMonthEarnings,
        'completedJobs': completedJobs,
        'pendingPayments': pendingPayments,
        'recentSettlements': responseList.take(5).toList(),
      };
    } catch (e) {
      print('프리랜서 수익 조회 에러: $e');
      // 목업 데이터 반환
      return {
        'totalEarnings': 750000.0,
        'thisMonthEarnings': 120000.0,
        'completedJobs': 8,
        'pendingPayments': 2,
        'recentSettlements': [],
      };
    }
  }

  // 프리랜서 진행 중인 의뢰 수 조회
  Future<int> getActiveRequestsCount(String freelancerId) async {
    try {
      final response = await apiService.from('matchings')
          .select('id')
          .eq('freelancer_id', freelancerId)
          .inFilter('status', ['accepted', 'in_progress']);

      final responseList = response as List? ?? [];
      return responseList.length;
    } catch (e) {
      print('진행 중인 의뢰 수 조회 에러: $e');
      return 3; // 목업 데이터
    }
  }

  // 프리랜서의 읽지 않은 메시지 수 조회  
  Future<int> getUnreadMessagesCount(String userId) async {
    try {
      final response = await apiService.from('chat_messages')
          .select('id, chat_rooms!inner(participants)')
          .eq('is_read', false)
          .neq('sender_id', userId);

      int unreadCount = 0;
      final responseList = response as List? ?? [];
      for (final message in responseList) {
        if (message == null) continue;
        
        final chatRoom = message['chat_rooms'];
        if (chatRoom == null) continue;
        
        final participants = chatRoom['participants'] as List?;
        if (participants != null && participants.contains(userId)) {
          unreadCount++;
        }
      }

      return unreadCount;
    } catch (e) {
      print('읽지 않은 메시지 수 조회 에러: $e');
      return 5; // 목업 데이터
    }
  }

  // 프리랜서 프로필 완성도 조회
  Future<Map<String, dynamic>> getProfileCompleteness(String freelancerId) async {
    try {
      final response = await apiService.from('profiles')
          .select('''
            name, email, phone, avatar_url, is_verified,
            freelancer_profiles (
              bio, service_categories, experience_years, hourly_rate, portfolio_urls
            )
          ''')
          .eq('id', freelancerId)
          .eq('user_type', 'freelancer')
          .maybeSingle();

      if (response == null) {
        return {'completedSteps': 1, 'totalSteps': 5, 'percentage': 20};
      }

      int completedSteps = 0;
      int totalSteps = 5;

      // 기본 정보
      if (response['name'] != null && (response['name'] as String).isNotEmpty) {
        completedSteps++;
      }
      if (response['email'] != null && (response['email'] as String).isNotEmpty) {
        completedSteps++;
      }
      if (response['phone'] != null && (response['phone'] as String).isNotEmpty) {
        completedSteps++;
      }

      // 프리랜서 전용 정보 (List 또는 Map 양쪽 처리)
      final fp = response['freelancer_profiles'];
      Map<String, dynamic>? freelancerProfile;
      if (fp is List && fp.isNotEmpty) {
        final first = fp.first;
        if (first is Map<String, dynamic>) {
          freelancerProfile = first;
        }
      } else if (fp is Map<String, dynamic>) {
        freelancerProfile = fp;
      } else {
        freelancerProfile = null;
      }

      if (freelancerProfile != null && 
          freelancerProfile['bio'] != null && 
          (freelancerProfile['bio'] as String).isNotEmpty) {
        completedSteps++;
      }
      if (response['is_verified'] == true) {
        completedSteps++;
      }

      return {
        'completedSteps': completedSteps,
        'totalSteps': totalSteps,
        'percentage': (completedSteps / totalSteps * 100).round(),
      };
    } catch (e) {
      print('프로필 완성도 조회 에러: $e');
      return {'completedSteps': 3, 'totalSteps': 5, 'percentage': 60};
    }
  }
}

// 전역 정산 서비스 인스턴스
final settlementService = SettlementService();

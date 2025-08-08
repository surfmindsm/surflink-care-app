import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/matching.dart';
import '../models/request.dart';
import '../models/user.dart';

class MatchingService {
  static final MatchingService _instance = MatchingService._internal();
  factory MatchingService() => _instance;
  MatchingService._internal();

  String get _baseUrl => AppConfig.supabaseUrl;

  // 매칭 요청 생성 (고객 → 프리랜서)
  Future<Map<String, dynamic>> createMatchingRequest(MatchingCreateRequest request) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // TODO: 실제 API 호출
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl/matching/request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAccessToken()}',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': '매칭 요청이 전송되었습니다.',
          'matching': MatchingRequest.fromJson(data),
        };
      } else {
        return {
          'success': false,
          'message': '매칭 요청 전송에 실패했습니다.',
        };
      }
      */
      
      // Mock 응답
      final now = DateTime.now();
      final mockMatching = MatchingRequest(
        id: 'matching_${now.millisecondsSinceEpoch}',
        requestId: request.requestId,
        customerId: 'current_user_id',
        freelancerId: request.freelancerId,
        type: request.type,
        status: MatchingStatus.pending,
        message: request.message,
        createdAt: now,
        updatedAt: now,
        expiresAt: now.add(const Duration(hours: 24)),
        customerName: '김고객',
        freelancerName: '박프리랜서',
        requestTitle: '아이돌봄 서비스',
        freelancerRating: 4.5,
      );
      
      return {
        'success': true,
        'message': '매칭 요청이 전송되었습니다.',
        'matching': mockMatching,
      };
    } catch (e) {
      return {
        'success': false,
        'message': '매칭 요청 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 매칭 요청에 응답 (프리랜서)
  Future<Map<String, dynamic>> respondToMatching(MatchingResponseRequest request) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      // TODO: 실제 API 호출
      /*
      final response = await http.put(
        Uri.parse('$_baseUrl/matching/${request.matchingId}/respond'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAccessToken()}',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': request.status == MatchingStatus.accepted 
              ? '매칭을 수락했습니다.' 
              : '매칭을 거절했습니다.',
        };
      } else {
        return {
          'success': false,
          'message': '응답 처리에 실패했습니다.',
        };
      }
      */
      
      return {
        'success': true,
        'message': request.status == MatchingStatus.accepted 
            ? '매칭을 수락했습니다. 채팅방에서 자세한 내용을 논의해보세요.' 
            : '매칭을 거절했습니다.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': '응답 처리 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 매칭 취소 (고객)
  Future<Map<String, dynamic>> cancelMatching(String matchingId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // TODO: 실제 API 호출
      /*
      final response = await http.delete(
        Uri.parse('$_baseUrl/matching/$matchingId'),
        headers: {
          'Authorization': 'Bearer ${await _getAccessToken()}',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': '매칭 요청이 취소되었습니다.',
        };
      } else {
        return {
          'success': false,
          'message': '매칭 취소에 실패했습니다.',
        };
      }
      */
      
      return {
        'success': true,
        'message': '매칭 요청이 취소되었습니다.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': '매칭 취소 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 내가 보낸 매칭 요청 목록 (고객용)
  Future<List<MatchingRequest>> getMyMatchingRequests({
    MatchingFilter? filter,
    int? limit,
    int? offset,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // TODO: 실제 API 호출
    /*
    final queryParams = <String, String>{
      if (limit != null) 'limit': limit.toString(),
      if (offset != null) 'offset': offset.toString(),
      if (filter != null) ...filter.toQueryParams().map((k, v) => MapEntry(k, v.toString())),
    };
    
    final uri = Uri.parse('$_baseUrl/matching/my-requests').replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${await _getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => MatchingRequest.fromJson(item)).toList();
    } else {
      throw Exception('매칭 요청 목록 조회에 실패했습니다.');
    }
    */
    
    // Mock 데이터
    return _generateMockMatchingRequests(isCustomer: true, filter: filter);
  }

  // 나에게 온 매칭 요청 목록 (프리랜서용)
  Future<List<MatchingRequest>> getReceivedMatchingRequests({
    MatchingFilter? filter,
    int? limit,
    int? offset,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // TODO: 실제 API 호출
    return _generateMockMatchingRequests(isCustomer: false, filter: filter);
  }

  // 매칭 요청 상세 조회
  Future<MatchingRequest> getMatchingRequest(String matchingId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // TODO: 실제 API 호출
    /*
    final response = await http.get(
      Uri.parse('$_baseUrl/matching/$matchingId'),
      headers: {
        'Authorization': 'Bearer ${await _getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MatchingRequest.fromJson(data);
    } else {
      throw Exception('매칭 요청 조회에 실패했습니다.');
    }
    */
    
    // Mock 데이터
    final now = DateTime.now();
    return MatchingRequest(
      id: matchingId,
      requestId: 'request_001',
      customerId: 'customer_001',
      freelancerId: 'freelancer_001',
      type: MatchingType.manual,
      status: MatchingStatus.pending,
      message: '아이가 7세이고 활발한 편이에요. 경험 많으신 분을 찾고 있습니다.',
      createdAt: now.subtract(const Duration(hours: 2)),
      updatedAt: now.subtract(const Duration(hours: 2)),
      expiresAt: now.add(const Duration(hours: 22)),
      customerName: '김은주',
      freelancerName: '박나영',
      requestTitle: '아이돌봄 서비스 (강남구)',
      freelancerRating: 4.8,
    );
  }

  // 자동 매칭 추천 (프리랜서에게 적합한 의뢰 추천)
  Future<List<ServiceRequest>> getRecommendedRequests({
    int? limit,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // TODO: 실제 API 호출
    /*
    final queryParams = <String, String>{
      if (limit != null) 'limit': limit.toString(),
    };
    
    final uri = Uri.parse('$_baseUrl/matching/recommendations').replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${await _getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => ServiceRequest.fromJson(item)).toList();
    } else {
      throw Exception('추천 의뢰 조회에 실패했습니다.');
    }
    */
    
    // Mock 데이터
    return _generateMockRecommendedRequests(limit ?? 5);
  }

  // 매칭 통계
  Future<MatchingSummary> getMatchingSummary({String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    // TODO: 실제 API 호출
    /*
    final queryParams = <String, String>{
      if (userId != null) 'user_id': userId,
    };
    
    final uri = Uri.parse('$_baseUrl/matching/summary').replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${await _getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MatchingSummary.fromJson(data);
    } else {
      throw Exception('매칭 통계 조회에 실패했습니다.');
    }
    */
    
    // Mock 데이터
    return const MatchingSummary(
      totalRequests: 47,
      pendingRequests: 8,
      acceptedRequests: 32,
      rejectedRequests: 5,
      expiredRequests: 2,
      acceptanceRate: 78.5,
    );
  }

  // 적합한 프리랜서 추천 (의뢰에 대한)
  Future<List<User>> getRecommendedFreelancers(String requestId, {int? limit}) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // TODO: 실제 API 호출
    /*
    final queryParams = <String, String>{
      if (limit != null) 'limit': limit.toString(),
    };
    
    final uri = Uri.parse('$_baseUrl/matching/recommended-freelancers/$requestId')
        .replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${await _getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => User.fromJson(item)).toList();
    } else {
      throw Exception('추천 프리랜서 조회에 실패했습니다.');
    }
    */
    
    // Mock 데이터
    return _generateMockRecommendedFreelancers(limit ?? 5);
  }

  // Mock 데이터 생성 메서드들
  List<MatchingRequest> _generateMockMatchingRequests({
    required bool isCustomer, 
    MatchingFilter? filter,
  }) {
    final requests = <MatchingRequest>[];
    final now = DateTime.now();
    final statuses = [
      MatchingStatus.pending,
      MatchingStatus.accepted,
      MatchingStatus.rejected,
      MatchingStatus.expired,
    ];
    
    for (int i = 0; i < 10; i++) {
      final status = statuses[i % statuses.length];
      final createdAt = now.subtract(Duration(days: i, hours: i * 2));
      
      if (filter?.status != null && filter!.status != status) continue;
      
      requests.add(MatchingRequest(
        id: 'matching_${isCustomer ? 'sent' : 'received'}_$i',
        requestId: 'request_$i',
        customerId: isCustomer ? 'current_user' : 'customer_$i',
        freelancerId: isCustomer ? 'freelancer_$i' : 'current_user',
        type: i % 2 == 0 ? MatchingType.manual : MatchingType.auto,
        status: status,
        message: _getMatchingMessage(i),
        rejectionReason: status == MatchingStatus.rejected ? '일정이 맞지 않습니다.' : null,
        createdAt: createdAt,
        updatedAt: createdAt,
        expiresAt: createdAt.add(const Duration(hours: 24)),
        respondedAt: status != MatchingStatus.pending 
            ? createdAt.add(Duration(hours: i + 1))
            : null,
        customerName: isCustomer ? '나' : '김고객$i',
        freelancerName: isCustomer ? '박프리랜서$i' : '나',
        requestTitle: _getRequestTitle(i),
        freelancerRating: 3.5 + (i % 3) * 0.5,
      ));
    }
    
    return requests;
  }

  List<ServiceRequest> _generateMockRecommendedRequests(int count) {
    final requests = <ServiceRequest>[];
    final now = DateTime.now();
    final serviceTypes = ServiceType.values;
    
    for (int i = 0; i < count; i++) {
      final serviceType = serviceTypes[i % serviceTypes.length];
      requests.add(ServiceRequest(
        id: 'request_rec_$i',
        customerId: 'customer_$i',
        serviceType: serviceType,
        title: _getRecommendedRequestTitle(serviceType, i),
        description: _getRecommendedRequestDescription(serviceType),
        region: _getRegion(i),
        startDate: now.add(Duration(days: i + 1)),
        endDate: now.add(Duration(days: i + 7)),
        preferredTimes: ['오전', '오후'],
        conditions: {
          'experience_years': i + 1,
          'age_preference': '20-40세',
          'gender_preference': i % 2 == 0 ? '여성' : '무관',
        },
        specialNotes: '성실하고 책임감 있는 분을 찾습니다.',
        attachments: [],
        status: RequestStatus.pending,
        budget: 15000 + (i * 2000),
        createdAt: now.subtract(Duration(hours: i)),
        updatedAt: now.subtract(Duration(hours: i)),
      ));
    }
    
    return requests;
  }

  List<User> _generateMockRecommendedFreelancers(int count) {
    final freelancers = <User>[];
    
    for (int i = 0; i < count; i++) {
      freelancers.add(User(
        id: 'freelancer_rec_$i',
        email: 'freelancer$i@example.com',
        name: '박프리랜서$i',
        phone: '010-1234-567$i',
        userType: UserType.freelancer,
        status: UserStatus.active,
        isVerified: true,
        profileImageUrl: null,
        createdAt: DateTime.now().subtract(Duration(days: 30 + i)),
        updatedAt: DateTime.now(),
      ));
    }
    
    return freelancers;
  }

  String _getMatchingMessage(int index) {
    final messages = [
      '안녕하세요! 아이돌봄 경험이 많습니다. 잘 부탁드려요.',
      '성실하게 임하겠습니다. 연락 기다리겠습니다.',
      '프로필 확인해주세요. 좋은 조건으로 함께했으면 좋겠어요.',
      '경력이 풍부합니다. 언제든 상담 가능해요.',
      '책임감 있게 서비스하겠습니다.',
    ];
    return messages[index % messages.length];
  }

  String _getRequestTitle(int index) {
    final titles = [
      '아이돌봄 서비스 (강남구)',
      '어르신 간병 도움 (서초구)',
      '중학생 수학 과외 (송파구)',
      '심리상담 서비스 (마포구)',
      '유아 돌봄 서비스 (영등포구)',
    ];
    return titles[index % titles.length];
  }

  String _getRecommendedRequestTitle(ServiceType serviceType, int index) {
    switch (serviceType) {
      case ServiceType.childcare:
        return '${index + 3}세 아이 돌봄 서비스';
      case ServiceType.eldercare:
        return '${70 + index}세 어르신 간병 서비스';
      case ServiceType.tutoring:
        return '${index % 2 == 0 ? '초등' : '중등'} ${_getSubject(index)} 과외';
      case ServiceType.counseling:
        return '${_getCounselingType(index)} 심리상담';
    }
  }

  String _getRecommendedRequestDescription(ServiceType serviceType) {
    switch (serviceType) {
      case ServiceType.childcare:
        return '활발한 아이이지만 잘 따릅니다. 경험 많으신 분을 찾고 있어요.';
      case ServiceType.eldercare:
        return '거동이 불편하신 어르신 간병을 부탁드립니다. 성실한 분 희망해요.';
      case ServiceType.tutoring:
        return '기초가 부족한 편이라 차근차근 가르쳐주실 분을 찾습니다.';
      case ServiceType.counseling:
        return '전문적인 상담을 통해 도움을 받고 싶습니다.';
    }
  }

  String _getSubject(int index) {
    final subjects = ['수학', '영어', '국어', '과학'];
    return subjects[index % subjects.length];
  }

  String _getCounselingType(int index) {
    final types = ['개인', '가족', '청소년', '부부'];
    return types[index % types.length];
  }

  String _getRegion(int index) {
    final regions = ['강남구', '서초구', '송파구', '강동구', '마포구'];
    return regions[index % regions.length];
  }

  Future<String?> _getAccessToken() async {
    // TODO: 실제 토큰 관리 로직
    return 'mock_access_token';
  }
}

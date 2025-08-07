import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/request.dart';
import 'api_service.dart';
import '../providers/auth_provider.dart';

class RequestService {
  static final RequestService _instance = RequestService._internal();
  factory RequestService() => _instance;
  RequestService._internal();

  final ApiService _api = apiService;
  AuthProvider? _authProvider;
  
  // AuthProvider 설정
  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  // 의뢰 생성
  Future<Map<String, dynamic>> createRequest(ServiceRequest request) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // TODO: 실제 API 호출
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl/requests'),
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
          'message': '의뢰가 성공적으로 등록되었습니다.',
          'request': ServiceRequest.fromJson(data),
        };
      } else {
        return {
          'success': false,
          'message': '의뢰 등록에 실패했습니다.',
        };
      }
      */
      
      // Mock 응답
      return {
        'success': true,
        'message': '의뢰가 성공적으로 등록되었습니다.',
        'request': request.copyWith(
          id: 'request_${DateTime.now().millisecondsSinceEpoch}',
        ),
      };
    } catch (e) {
      return {
        'success': false,
        'message': '의뢰 등록 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 의뢰 수정
  Future<Map<String, dynamic>> updateRequest(ServiceRequest request) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      // TODO: 실제 API 호출
      /*
      final response = await http.put(
        Uri.parse('$_baseUrl/requests/${request.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAccessToken()}',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': '의뢰가 성공적으로 수정되었습니다.',
        };
      } else {
        return {
          'success': false,
          'message': '의뢰 수정에 실패했습니다.',
        };
      }
      */
      
      return {
        'success': true,
        'message': '의뢰가 성공적으로 수정되었습니다.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': '의뢰 수정 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 내 의뢰 목록 조회
  Future<List<ServiceRequest>> getMyRequests({
    RequestStatus? status,
    int? limit,
    int? offset,
  }) async {
    try {
      // AuthProvider에서 현재 사용자 정보 가져오기
      String? currentUserId;
      if (_authProvider != null && _authProvider!.currentUser != null) {
        currentUserId = _authProvider!.currentUser!.id;
      } else {
        // Fallback: Supabase auth 사용
        currentUserId = _api.auth.currentUser?.id;
      }
      
      if (currentUserId == null) {
        throw Exception('로그인이 필요합니다');
      }
      
      final response = await _api.from('service_requests')
          .select('*')
          .eq('customer_id', currentUserId)
          .order('created_at', ascending: false)
          .limit(limit ?? 10);
      
      if ((response as List<dynamic>).isNotEmpty) {
        return (response as List<dynamic>)
            .map((item) => ServiceRequest.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        // 비어있는 결과인 경우 빈 리스트 반환
        return <ServiceRequest>[];
      }
    } catch (e) {
      print('내 의뢰 목록 조회 오류: $e');
      // 오류 시 목업 데이터 반환
      return _generateMockRequests(status: status);
    }
  }

  // 의뢰 상세 조회
  Future<ServiceRequest> getRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // TODO: 실제 API 호출
    /*
    final response = await http.get(
      Uri.parse('$_baseUrl/requests/$requestId'),
      headers: {
        'Authorization': 'Bearer ${await _getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ServiceRequest.fromJson(data);
    } else {
      throw Exception('의뢰 조회에 실패했습니다.');
    }
    */
    
    // Mock 데이터
    return _generateMockRequests().first.copyWith(id: requestId);
  }

  // 의뢰 삭제
  Future<Map<String, dynamic>> deleteRequest(String requestId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // TODO: 실제 API 호출
      /*
      final response = await http.delete(
        Uri.parse('$_baseUrl/requests/$requestId'),
        headers: {
          'Authorization': 'Bearer ${await _getAccessToken()}',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': '의뢰가 삭제되었습니다.',
        };
      } else {
        return {
          'success': false,
          'message': '의뢰 삭제에 실패했습니다.',
        };
      }
      */
      
      return {
        'success': true,
        'message': '의뢰가 삭제되었습니다.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': '의뢰 삭제 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 공개 의뢰 목록 조회 (프리랜서용)
  Future<List<ServiceRequest>> getPublicRequests({
    ServiceType? serviceType,
    String? region,
    double? minBudget,
    double? maxBudget,
    int? limit,
    int? offset,
  }) async {
    try {
      // Supabase에서 공개 의뢰 데이터 조회 시도
      final response = await _api.from('service_requests')
          .select('*')
          .eq('status', 'pending')
          .order('created_at', ascending: false)
          .limit(limit ?? 10);
      
      if ((response as List<dynamic>).isNotEmpty) {
        return (response as List<dynamic>)
            .map((item) => ServiceRequest.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        // 비어있는 결과인 경우 빈 리스트 반환
        return <ServiceRequest>[];
      }
    } catch (e) {
      print('공개 의뢰 목록 조회 오류: $e');
      // 오류 시 목업 데이터 반환
      return _generateMockPublicRequests(
        serviceType: serviceType,
        region: region,
      );
    }
  }

  // 의뢰 통계
  Future<Map<String, int>> getRequestStats() async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    // TODO: 실제 API 호출
    /*
    final response = await http.get(
      Uri.parse('$_baseUrl/requests/stats'),
      headers: {
        'Authorization': 'Bearer ${await _getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data.cast<String, int>();
    } else {
      throw Exception('의뢰 통계 조회에 실패했습니다.');
    }
    */
    
    return {
      'total': 47,
      'pending': 12,
      'in_progress': 8,
      'completed': 23,
      'cancelled': 4,
    };
  }

  // Mock 데이터 생성 메서드들
  List<ServiceRequest> _generateMockRequests({RequestStatus? status}) {
    final requests = <ServiceRequest>[];
    final now = DateTime.now();
    final statuses = RequestStatus.values;
    final serviceTypes = ServiceType.values;
    
    for (int i = 0; i < 15; i++) {
      final requestStatus = statuses[i % statuses.length];
      final serviceType = serviceTypes[i % serviceTypes.length];
      
      if (status != null && requestStatus != status) continue;
      
      final createdAt = now.subtract(Duration(days: i, hours: i));
      
      requests.add(ServiceRequest(
        id: 'request_my_$i',
        customerId: 'current_user',
        serviceType: serviceType,
        title: _getRequestTitle(serviceType, i),
        description: _getRequestDescription(serviceType),
        region: _getRegion(i),
        startDate: now.add(Duration(days: i + 1)),
        endDate: i % 3 == 0 ? now.add(Duration(days: i + 7)) : null,
        preferredTimes: _getPreferredTimes(i),
        conditions: _getConditions(serviceType, i),
        specialNotes: i % 4 == 0 ? '특별한 요청사항이 있습니다.' : null,
        attachments: [],
        status: requestStatus,
        budget: 15000 + (i * 1500),
        createdAt: createdAt,
        updatedAt: createdAt,
        matchedFreelancerId: requestStatus == RequestStatus.matched 
            ? 'freelancer_$i' 
            : null,
        matchedAt: requestStatus == RequestStatus.matched 
            ? createdAt.add(Duration(days: 1))
            : null,
        contractId: requestStatus == RequestStatus.in_progress ||
                   requestStatus == RequestStatus.completed
            ? 'contract_$i'
            : null,
      ));
    }
    
    return requests;
  }

  List<ServiceRequest> _generateMockPublicRequests({
    ServiceType? serviceType,
    String? region,
  }) {
    final requests = <ServiceRequest>[];
    final now = DateTime.now();
    final serviceTypes = ServiceType.values;
    
    for (int i = 0; i < 20; i++) {
      final requestServiceType = serviceTypes[i % serviceTypes.length];
      final requestRegion = _getRegion(i);
      
      if (serviceType != null && requestServiceType != serviceType) continue;
      if (region != null && requestRegion != region) continue;
      
      requests.add(ServiceRequest(
        id: 'public_request_$i',
        customerId: 'customer_$i',
        serviceType: requestServiceType,
        title: _getRequestTitle(requestServiceType, i),
        description: _getRequestDescription(requestServiceType),
        region: requestRegion,
        startDate: now.add(Duration(days: i % 10 + 1)),
        endDate: i % 3 == 0 ? now.add(Duration(days: i % 10 + 7)) : null,
        preferredTimes: _getPreferredTimes(i),
        conditions: _getConditions(requestServiceType, i),
        specialNotes: null,
        attachments: [],
        status: RequestStatus.pending,
        budget: 12000 + (i * 2000),
        createdAt: now.subtract(Duration(hours: i)),
        updatedAt: now.subtract(Duration(hours: i)),
      ));
    }
    
    return requests;
  }

  String _getRequestTitle(ServiceType serviceType, int index) {
    switch (serviceType) {
      case ServiceType.childcare:
        return '${index % 2 == 0 ? '초등학생' : '유아'} 돌봄 서비스';
      case ServiceType.eldercare:
        return '어르신 생활지원 및 간병 서비스';
      case ServiceType.tutoring:
        return '${_getSubject(index)} 개인 과외';
      case ServiceType.counseling:
        return '${_getCounselingType(index)} 심리상담';
    }
  }

  String _getRequestDescription(ServiceType serviceType) {
    switch (serviceType) {
      case ServiceType.childcare:
        return '성실하고 경험이 풍부한 분을 찾고 있습니다. 아이가 활발하지만 잘 따르는 편입니다.';
      case ServiceType.eldercare:
        return '거동이 불편하신 어르신을 정성스럽게 돌봐주실 분을 찾습니다.';
      case ServiceType.tutoring:
        return '기초부터 차근차근 가르쳐주실 선생님을 찾고 있습니다.';
      case ServiceType.counseling:
        return '전문적이고 따뜻한 상담을 받고 싶습니다.';
    }
  }

  String _getRegion(int index) {
    final regions = [
      '강남구', '서초구', '송파구', '강동구', '광진구',
      '성동구', '마포구', '서대문구', '영등포구', '구로구'
    ];
    return regions[index % regions.length];
  }

  List<String> _getPreferredTimes(int index) {
    final timeOptions = [
      ['오전 (08:00-12:00)'],
      ['오후 (12:00-18:00)'],
      ['저녁 (18:00-22:00)'],
      ['오전 (08:00-12:00)', '오후 (12:00-18:00)'],
      ['오후 (12:00-18:00)', '저녁 (18:00-22:00)'],
    ];
    return timeOptions[index % timeOptions.length];
  }

  Map<String, dynamic> _getConditions(ServiceType serviceType, int index) {
    switch (serviceType) {
      case ServiceType.childcare:
        return {
          'child_age': '${5 + index % 8}세',
          'experience_level': index % 2 == 0 ? '3년 이상' : '1년 이상',
          'gender_preference': index % 3 == 0 ? '여성' : '무관',
        };
      case ServiceType.eldercare:
        return {
          'patient_age': '${65 + index % 20}세',
          'care_level': index % 2 == 0 ? '기본 간병' : '일상생활 도움',
          'medical_knowledge': index % 4 == 0,
        };
      case ServiceType.tutoring:
        return {
          'student_grade': '${index % 2 == 0 ? '초등학교' : '중학교'} ${1 + index % 6}학년',
          'subjects': _getSubject(index),
          'tutoring_type': '1:1 개별수업',
        };
      case ServiceType.counseling:
        return {
          'counseling_type': _getCounselingType(index),
          'session_type': index % 2 == 0 ? '대면상담' : '온라인상담',
          'certified_required': index % 3 == 0,
        };
    }
  }

  String _getSubject(int index) {
    final subjects = ['수학', '영어', '국어', '과학', '사회'];
    return subjects[index % subjects.length];
  }

  String _getCounselingType(int index) {
    final types = ['개인상담', '가족상담', '부부상담', '청소년상담'];
    return types[index % types.length];
  }

  Future<String?> _getAccessToken() async {
    // TODO: 실제 토큰 관리 로직
    return 'mock_access_token';
  }
}

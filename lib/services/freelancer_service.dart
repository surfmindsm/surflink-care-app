import '../models/user.dart';
import '../models/request.dart';
import 'api_service.dart';

class FreelancerService {
  static final FreelancerService _instance = FreelancerService._internal();
  factory FreelancerService() => _instance;
  FreelancerService._internal();

  // 전문가 목록 조회
  Future<List<User>> getFreelancers({
    String? searchQuery,
    ServiceType? serviceType,
    String? region,
    double? minRating,
    int? limit,
    int? offset,
  }) async {
    try {
      // Supabase에서 프리랜서 목록 조회 (프로필과 프리랜서 프로필 조인)
      dynamic query = apiService.from('profiles')
          .select('''
            id, email, name, phone, user_type, avatar_url, is_verified, created_at, updated_at,
            freelancer_profiles!inner (
              hourly_rate, specialties, career_years, rating, review_count
            )
          ''')
          .eq('user_type', 'freelancer')
          .eq('is_verified', true);

      // 검색어 필터링
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%');
      }

      // 서비스 타입 필터링
      if (serviceType != null) {
        query = query.contains('specialties', [serviceType.name]);
      }

      // 지역 필터링
      if (region != null && region.isNotEmpty && region != '전체') {
        query = query.eq('region', region);
      }

      // 최소 평점 필터링
      if (minRating != null) {
        query = query.gte('rating', minRating);
      }

      // 정렬 및 페이징
      query = query.order('rating', ascending: false);
      if (limit != null) {
        query = query.limit(limit);
      }
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 20) - 1);
      }

      final response = await query;
      
      return (response as List).map((json) {
        // freelancer_profiles 데이터를 profile 데이터와 병합
        final freelancerProfile = json['freelancer_profiles'] != null && 
            (json['freelancer_profiles'] as List).isNotEmpty 
            ? (json['freelancer_profiles'] as List).first 
            : <String, dynamic>{};
        
        final combinedData = <String, dynamic>{
          ...Map<String, dynamic>.from(json),
          'introduction': '전문적인 서비스를 제공합니다.',
          'rating': freelancerProfile['rating'],
          'review_count': freelancerProfile['review_count'],
          'specialties': freelancerProfile['specialties'],
          'career_years': freelancerProfile['career_years'],
          'hourly_rate': freelancerProfile['hourly_rate'],
          'profile_image_url': json['avatar_url'],
          'status': json['is_verified'] ? 'active' : 'pending',
        };
        
        return User.fromJson(combinedData);
      }).toList();
    } catch (e) {
      print('전문가 목록 조회 에러: $e');
      throw Exception('전문가 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 전문가 상세 정보 조회
  Future<User?> getFreelancer(String freelancerId) async {
    try {
      final response = await apiService.from('profiles')
          .select('''
            id, email, name, phone, user_type, avatar_url, is_verified, created_at, updated_at,
            freelancer_profiles (
              hourly_rate, specialties, career_years, rating, review_count
            )
          ''')
          .eq('id', freelancerId)
          .eq('user_type', 'freelancer')
          .maybeSingle();

      if (response == null) {
        return null;
      }

      // freelancer_profiles 데이터를 profile 데이터와 병합
      final freelancerProfile = response['freelancer_profiles'] != null &&
          (response['freelancer_profiles'] as List).isNotEmpty
          ? (response['freelancer_profiles'] as List).first
          : <String, dynamic>{};
      
      final combinedData = <String, dynamic>{
        ...Map<String, dynamic>.from(response),
        'introduction': '전문적인 서비스를 제공합니다.',
        'rating': freelancerProfile['rating'],
        'review_count': freelancerProfile['review_count'],
        'specialties': freelancerProfile['specialties'],
        'career_years': freelancerProfile['career_years'],
        'hourly_rate': freelancerProfile['hourly_rate'],
        'profile_image_url': response['avatar_url'],
        'status': response['is_verified'] ? 'active' : 'pending',
      };

      return User.fromJson(combinedData);
    } catch (e) {
      print('전문가 상세 조회 에러: $e');
      throw Exception('전문가 정보를 불러오는데 실패했습니다: $e');
    }
  }

  // 전문가 리뷰 목록 조회
  Future<List<Map<String, dynamic>>> getFreelancerReviews(String freelancerId, {
    int? limit,
    int? offset,
  }) async {
    try {
      dynamic query = apiService.from('reviews')
          .select('''
            id, rating, content, created_at, service_type,
            customer:customer_id (
              id, name
            )
          ''')
          .eq('freelancer_id', freelancerId)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;
      
      return (response as List).map((json) {
        return {
          'id': json['id'],
          'customerName': json['customer']?['name'] ?? '익명',
          'rating': (json['rating'] as num).toDouble(),
          'content': json['content'],
          'createdAt': DateTime.parse(json['created_at']),
          'serviceType': ServiceType.values.firstWhere(
            (type) => type.name == json['service_type'],
            orElse: () => ServiceType.childcare,
          ),
        };
      }).toList();
    } catch (e) {
      print('전문가 리뷰 조회 에러: $e');
      throw Exception('리뷰를 불러오는데 실패했습니다: $e');
    }
  }

  // 전문가 포트폴리오/경력 조회
  Future<List<String>> getFreelancerPortfolios(String freelancerId) async {
    try {
      final response = await apiService.from('certifications')
          .select('title, description, type')
          .eq('user_id', freelancerId)
          .eq('status', 'verified')
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        final title = json['title'] ?? '';
        final description = json['description'] ?? '';
        return description.isNotEmpty ? '$title - $description' : title;
      }).cast<String>().toList();
    } catch (e) {
      print('전문가 포트폴리오 조회 에러: $e');
      // 포트폴리오가 없어도 에러를 던지지 않고 빈 리스트 반환
      return [];
    }
  }

  // 전문가 즐겨찾기 추가/제거
  Future<bool> toggleFavorite(String freelancerId, String customerId) async {
    try {
      // 기존 즐겨찾기 확인
      final existing = await apiService.from('favorites')
          .select('id')
          .eq('customer_id', customerId)
          .eq('freelancer_id', freelancerId)
          .maybeSingle();

      if (existing != null) {
        // 즐겨찾기 제거
        await apiService.from('favorites')
            .delete()
            .eq('customer_id', customerId)
            .eq('freelancer_id', freelancerId);
        return false;
      } else {
        // 즐겨찾기 추가
        await apiService.from('favorites').insert({
          'customer_id': customerId,
          'freelancer_id': freelancerId,
          'created_at': DateTime.now().toIso8601String(),
        });
        return true;
      }
    } catch (e) {
      print('즐겨찾기 토글 에러: $e');
      throw Exception('즐겨찾기 처리에 실패했습니다: $e');
    }
  }

  // 전문가 즐겨찾기 상태 확인
  Future<bool> isFavorite(String freelancerId, String customerId) async {
    try {
      final response = await apiService.from('favorites')
          .select('id')
          .eq('customer_id', customerId)
          .eq('freelancer_id', freelancerId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('즐겨찾기 상태 확인 에러: $e');
      return false;
    }
  }

  // 추천 전문가 목록 조회
  Future<List<User>> getRecommendedFreelancers({
    String? customerId,
    ServiceType? preferredServiceType,
    String? region,
    int limit = 5,
  }) async {
    try {
      dynamic query = apiService.from('profiles')
          .select('''
            id, email, name, phone, user_type, avatar_url, is_verified, created_at, updated_at,
            freelancer_profiles!inner (
              hourly_rate, specialties, career_years, rating, review_count
            )
          ''')
          .eq('user_type', 'freelancer')
          .eq('is_verified', true);

      // 서비스 타입 기반 추천
      if (preferredServiceType != null) {
        query = query.contains('freelancer_profiles.specialties', [preferredServiceType.name]);
      }

      // 평점순 정렬하여 추천
      query = query.order('freelancer_profiles.rating', ascending: false)
          .order('freelancer_profiles.review_count', ascending: false)
          .limit(limit);

      final response = await query;
      
      return (response as List).map((json) {
        // freelancer_profiles 데이터를 profile 데이터와 병합
        final freelancerProfile = json['freelancer_profiles'] != null && 
            (json['freelancer_profiles'] as List).isNotEmpty 
            ? (json['freelancer_profiles'] as List).first 
            : <String, dynamic>{};
        
        final combinedData = <String, dynamic>{
          ...Map<String, dynamic>.from(json),
          'introduction': '전문적인 서비스를 제공합니다.',
          'rating': freelancerProfile['rating'],
          'review_count': freelancerProfile['review_count'],
          'specialties': freelancerProfile['specialties'],
          'career_years': freelancerProfile['career_years'],
          'hourly_rate': freelancerProfile['hourly_rate'],
          'profile_image_url': json['avatar_url'],
          'status': json['is_verified'] ? 'active' : 'pending',
        };
        
        return User.fromJson(combinedData);
      }).toList();
    } catch (e) {
      print('추천 전문가 조회 에러: $e');
      throw Exception('추천 전문가를 불러오는데 실패했습니다: $e');
    }
  }
}

// 전역 전문가 서비스 인스턴스
final freelancerService = FreelancerService();

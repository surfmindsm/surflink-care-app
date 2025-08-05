import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/review.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  String get _baseUrl => AppConfig.apiBaseUrl;

  // 리뷰 목록 조회 (특정 사용자에 대한 리뷰)
  Future<List<Review>> getReviews({
    required String userId,
    ReviewType? type,
    int? limit,
    int? offset,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // TODO: 실제 API 호출
    return _generateMockReviews(userId: userId, type: type, count: limit ?? 10);
  }

  // 계약별 리뷰 조회 (상호 리뷰 확인)
  Future<List<Review>> getContractReviews(String contractId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // TODO: 실제 API 호출
    return _generateMockContractReviews(contractId);
  }

  // 리뷰 작성
  Future<Map<String, dynamic>> createReview(ReviewCreateRequest request) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // TODO: 실제 API 호출
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAccessToken()}',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final reviewData = json.decode(response.body);
        return {
          'success': true,
          'message': '리뷰가 성공적으로 등록되었습니다.',
          'review': Review.fromJson(reviewData),
        };
      } else {
        return {
          'success': false,
          'message': '리뷰 등록에 실패했습니다.',
        };
      }
      */
      
      // Mock 응답
      return {
        'success': true,
        'message': '리뷰가 성공적으로 등록되었습니다.',
        'review': Review(
          id: 'review_${DateTime.now().millisecondsSinceEpoch}',
          contractId: request.contractId,
          reviewerId: 'current_user_id',
          revieweeId: request.revieweeId,
          type: request.type,
          status: ReviewStatus.completed,
          rating: request.rating,
          title: request.title,
          content: request.content,
          tags: request.tags,
          imageUrls: request.imageUrls,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isAnonymous: request.isAnonymous,
          reviewerName: request.isAnonymous ? null : '김고객',
          reviewerProfileUrl: null,
          revieweeName: '박프리랜서',
          contractTitle: '아이돌봄 서비스',
        ),
      };
    } catch (e) {
      return {
        'success': false,
        'message': '리뷰 등록 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 리뷰 수정
  Future<Map<String, dynamic>> updateReview(String reviewId, ReviewCreateRequest request) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      // TODO: 실제 API 호출
      /*
      final response = await http.put(
        Uri.parse('$_baseUrl/reviews/$reviewId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAccessToken()}',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final reviewData = json.decode(response.body);
        return {
          'success': true,
          'message': '리뷰가 성공적으로 수정되었습니다.',
          'review': Review.fromJson(reviewData),
        };
      } else {
        return {
          'success': false,
          'message': '리뷰 수정에 실패했습니다.',
        };
      }
      */
      
      return {
        'success': true,
        'message': '리뷰가 성공적으로 수정되었습니다.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': '리뷰 수정 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 리뷰 삭제
  Future<Map<String, dynamic>> deleteReview(String reviewId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // TODO: 실제 API 호출
      /*
      final response = await http.delete(
        Uri.parse('$_baseUrl/reviews/$reviewId'),
        headers: {
          'Authorization': 'Bearer ${await _getAccessToken()}',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': '리뷰가 삭제되었습니다.',
        };
      } else {
        return {
          'success': false,
          'message': '리뷰 삭제에 실패했습니다.',
        };
      }
      */
      
      return {
        'success': true,
        'message': '리뷰가 삭제되었습니다.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': '리뷰 삭제 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 리뷰 신고
  Future<Map<String, dynamic>> reportReview(String reviewId, String reason) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // TODO: 실제 API 호출
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl/reviews/$reviewId/report'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAccessToken()}',
        },
        body: json.encode({'reason': reason}),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': '리뷰 신고가 접수되었습니다.',
        };
      } else {
        return {
          'success': false,
          'message': '리뷰 신고에 실패했습니다.',
        };
      }
      */
      
      return {
        'success': true,
        'message': '리뷰 신고가 접수되었습니다. 검토 후 조치하겠습니다.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': '리뷰 신고 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 리뷰 요약 통계 조회
  Future<ReviewSummary> getReviewSummary(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    // TODO: 실제 API 호출
    /*
    final response = await http.get(
      Uri.parse('$_baseUrl/reviews/summary/$userId'),
      headers: {
        'Authorization': 'Bearer ${await _getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ReviewSummary.fromJson(data);
    } else {
      throw Exception('리뷰 요약 조회에 실패했습니다.');
    }
    */
    
    // Mock 데이터
    return ReviewSummary(
      userId: userId,
      averageRating: 4.6,
      totalReviews: 47,
      ratingDistribution: {
        5: 28,
        4: 15,
        3: 3,
        2: 1,
        1: 0,
      },
      topTags: ['친절해요', '꼼꼼해요', '시간약속 잘 지켜요', '전문적이에요'],
    );
  }

  // 작성 대기 중인 리뷰 목록
  Future<List<Map<String, dynamic>>> getPendingReviews() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // TODO: 실제 API 호출
    return [
      {
        'contract_id': 'contract_001',
        'contract_title': '아이돌봄 서비스',
        'reviewee_name': '박프리랜서',
        'reviewee_profile_url': null,
        'service_date': DateTime.now().subtract(const Duration(days: 2)),
        'review_deadline': DateTime.now().add(const Duration(days: 5)),
        'type': ReviewType.client,
      },
      {
        'contract_id': 'contract_002',
        'contract_title': '간병 서비스',
        'reviewee_name': '이간병사',
        'reviewee_profile_url': null,
        'service_date': DateTime.now().subtract(const Duration(days: 5)),
        'review_deadline': DateTime.now().add(const Duration(days: 2)),
        'type': ReviewType.client,
      },
    ];
  }

  // 리뷰 이미지 업로드
  Future<Map<String, dynamic>> uploadReviewImages(List<File> images) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: 실제 파일 업로드 구현
      /*
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/reviews/images'));
      request.headers['Authorization'] = 'Bearer ${await _getAccessToken()}';
      
      for (int i = 0; i < images.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath('images', images[i].path),
        );
      }
      
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);
        return {
          'success': true,
          'message': '이미지가 업로드되었습니다.',
          'urls': List<String>.from(data['urls']),
        };
      } else {
        return {
          'success': false,
          'message': '이미지 업로드에 실패했습니다.',
        };
      }
      */
      
      // Mock 응답
      final urls = images.asMap().entries
          .map((entry) => 'https://example.com/review-images/image_${entry.key}_${DateTime.now().millisecondsSinceEpoch}.jpg')
          .toList();
      
      return {
        'success': true,
        'message': '이미지가 업로드되었습니다.',
        'urls': urls,
      };
    } catch (e) {
      return {
        'success': false,
        'message': '이미지 업로드 중 오류가 발생했습니다: $e',
      };
    }
  }

  // Mock 데이터 생성 메서드들
  List<Review> _generateMockReviews({
    required String userId,
    ReviewType? type,
    int count = 10,
  }) {
    final reviews = <Review>[];
    final now = DateTime.now();
    
    for (int i = 0; i < count; i++) {
      final isClient = type == ReviewType.client || (type == null && i % 2 == 0);
      final rating = 3.0 + (i % 3) + 0.5;
      
      reviews.add(Review(
        id: 'review_${userId}_$i',
        contractId: 'contract_$i',
        reviewerId: isClient ? 'client_$i' : 'freelancer_$i',
        revieweeId: userId,
        type: isClient ? ReviewType.client : ReviewType.freelancer,
        status: ReviewStatus.completed,
        rating: rating,
        title: isClient ? _getClientReviewTitle(rating) : _getFreelancerReviewTitle(rating),
        content: isClient ? _getClientReviewContent(rating) : _getFreelancerReviewContent(rating),
        tags: isClient ? _getClientReviewTags(rating) : _getFreelancerReviewTags(rating),
        imageUrls: i % 3 == 0 ? ['https://example.com/review_image_$i.jpg'] : null,
        createdAt: now.subtract(Duration(days: i * 3 + 1)),
        updatedAt: now.subtract(Duration(days: i * 3 + 1)),
        isAnonymous: i % 4 == 0,
        reviewerName: i % 4 == 0 ? null : isClient ? '김고객$i' : '박프리랜서$i',
        reviewerProfileUrl: null,
        revieweeName: isClient ? '프리랜서' : '고객',
        contractTitle: isClient ? _getServiceTitle(i) : _getServiceTitle(i),
      ));
    }
    
    return reviews;
  }

  List<Review> _generateMockContractReviews(String contractId) {
    final now = DateTime.now();
    
    return [
      Review(
        id: 'review_${contractId}_client',
        contractId: contractId,
        reviewerId: 'client_001',
        revieweeId: 'freelancer_001',
        type: ReviewType.client,
        status: ReviewStatus.completed,
        rating: 4.5,
        title: '정말 만족스러운 서비스였어요!',
        content: '아이를 정말 잘 봐주시고, 시간도 정확히 지켜주셨어요. 다음에도 꼭 부탁드리고 싶습니다.',
        tags: ['친절해요', '시간약속 잘 지켜요', '아이를 좋아해요'],
        imageUrls: null,
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        isAnonymous: false,
        reviewerName: '김은주',
        reviewerProfileUrl: null,
        revieweeName: '박나영',
        contractTitle: '아이돌봄 서비스',
      ),
      Review(
        id: 'review_${contractId}_freelancer',
        contractId: contractId,
        reviewerId: 'freelancer_001',
        revieweeId: 'client_001',
        type: ReviewType.freelancer,
        status: ReviewStatus.completed,
        rating: 5.0,
        title: '좋은 가정에서 일할 수 있어서 감사했습니다',
        content: '아이가 정말 순하고 예뻐서 돌보기 쉬웠어요. 부모님도 배려심이 깊으시고 소통이 원활했습니다.',
        tags: ['소통 원활해요', '배려해주세요', '좋은 환경'],
        imageUrls: null,
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(hours: 1)),
        isAnonymous: false,
        reviewerName: '박나영',
        reviewerProfileUrl: null,
        revieweeName: '김은주',
        contractTitle: '아이돌봄 서비스',
      ),
    ];
  }

  String _getClientReviewTitle(double rating) {
    if (rating >= 4.5) return '매우 만족스러운 서비스였어요!';
    if (rating >= 3.5) return '전체적으로 만족합니다';
    return '보통 수준이었어요';
  }

  String _getClientReviewContent(double rating) {
    if (rating >= 4.5) return '정말 전문적이고 친절하게 서비스해주셨어요. 다음에도 꼭 부탁드리고 싶습니다.';
    if (rating >= 3.5) return '서비스는 괜찮았지만 약간의 아쉬운 점이 있었어요.';
    return '기대했던 것보다는 아쉬웠지만 나쁘지 않았습니다.';
  }

  List<String> _getClientReviewTags(double rating) {
    if (rating >= 4.5) return ['친절해요', '전문적이에요', '시간약속 잘 지켜요'];
    if (rating >= 3.5) return ['괜찮아요', '보통이에요'];
    return ['아쉬워요'];
  }

  String _getFreelancerReviewTitle(double rating) {
    if (rating >= 4.5) return '좋은 고객님과 일할 수 있어서 감사했습니다';
    if (rating >= 3.5) return '전체적으로 원활했습니다';
    return '조금 아쉬운 부분이 있었어요';
  }

  String _getFreelancerReviewContent(double rating) {
    if (rating >= 4.5) return '소통이 원활하시고 배려심이 깊으신 고객님이었어요. 작업환경도 좋았습니다.';
    if (rating >= 3.5) return '대체로 원활했지만 소통에서 약간의 어려움이 있었어요.';
    return '다음엔 더 명확한 소통이 필요할 것 같아요.';
  }

  List<String> _getFreelancerReviewTags(double rating) {
    if (rating >= 4.5) return ['소통 원활해요', '배려해주세요', '좋은 환경'];
    if (rating >= 3.5) return ['괜찮아요', '보통이에요'];
    return ['소통 어려워요'];
  }

  String _getServiceTitle(int index) {
    final services = ['아이돌봄 서비스', '간병 서비스', '수학 과외', '영어 과외', '심리상담'];
    return services[index % services.length];
  }

  Future<String?> _getAccessToken() async {
    // TODO: 실제 토큰 관리 로직
    return 'mock_access_token';
  }
}

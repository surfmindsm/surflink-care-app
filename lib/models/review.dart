import 'package:intl/intl.dart';

enum ReviewType {
  client,      // 고객이 프리랜서에게 작성
  freelancer,  // 프리랜서가 고객에게 작성
}

enum ReviewStatus {
  pending,   // 작성 대기
  completed, // 작성 완료
  hidden,    // 숨김 처리
}

extension ReviewTypeExtension on ReviewType {
  String get displayName {
    switch (this) {
      case ReviewType.client:
        return '고객 리뷰';
      case ReviewType.freelancer:
        return '프리랜서 리뷰';
    }
  }
}

extension ReviewStatusExtension on ReviewStatus {
  String get displayName {
    switch (this) {
      case ReviewStatus.pending:
        return '작성 대기';
      case ReviewStatus.completed:
        return '작성 완료';
      case ReviewStatus.hidden:
        return '숨김 처리';
    }
  }
}

class Review {
  final String id;
  final String contractId;
  final String reviewerId;     // 리뷰 작성자 ID
  final String revieweeId;     // 리뷰 대상자 ID
  final ReviewType type;
  final ReviewStatus status;
  final double rating;         // 1.0 ~ 5.0
  final String title;
  final String content;
  final List<String> tags;     // 리뷰 태그
  final List<String>? imageUrls; // 첨부 이미지
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? hiddenAt;
  final String? hiddenReason;
  final bool isAnonymous;      // 익명 리뷰 여부
  
  // 추가 정보 (조인을 통해 가져오는 데이터)
  final String? reviewerName;
  final String? reviewerProfileUrl;
  final String? revieweeName;
  final String? contractTitle;

  const Review({
    required this.id,
    required this.contractId,
    required this.reviewerId,
    required this.revieweeId,
    required this.type,
    required this.status,
    required this.rating,
    required this.title,
    required this.content,
    required this.tags,
    this.imageUrls,
    required this.createdAt,
    required this.updatedAt,
    this.hiddenAt,
    this.hiddenReason,
    required this.isAnonymous,
    this.reviewerName,
    this.reviewerProfileUrl,
    this.revieweeName,
    this.contractTitle,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      contractId: json['contract_id'],
      reviewerId: json['reviewer_id'],
      revieweeId: json['reviewee_id'],
      type: ReviewType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReviewType.client,
      ),
      status: ReviewStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReviewStatus.pending,
      ),
      rating: (json['rating'] as num).toDouble(),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      imageUrls: json['image_urls'] != null 
          ? List<String>.from(json['image_urls'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      hiddenAt: json['hidden_at'] != null 
          ? DateTime.parse(json['hidden_at'])
          : null,
      hiddenReason: json['hidden_reason'],
      isAnonymous: json['is_anonymous'] ?? false,
      reviewerName: json['reviewer_name'],
      reviewerProfileUrl: json['reviewer_profile_url'],
      revieweeName: json['reviewee_name'],
      contractTitle: json['contract_title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contract_id': contractId,
      'reviewer_id': reviewerId,
      'reviewee_id': revieweeId,
      'type': type.name,
      'status': status.name,
      'rating': rating,
      'title': title,
      'content': content,
      'tags': tags,
      'image_urls': imageUrls,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'hidden_at': hiddenAt?.toIso8601String(),
      'hidden_reason': hiddenReason,
      'is_anonymous': isAnonymous,
      'reviewer_name': reviewerName,
      'reviewer_profile_url': reviewerProfileUrl,
      'reviewee_name': revieweeName,
      'contract_title': contractTitle,
    };
  }

  Review copyWith({
    String? id,
    String? contractId,
    String? reviewerId,
    String? revieweeId,
    ReviewType? type,
    ReviewStatus? status,
    double? rating,
    String? title,
    String? content,
    List<String>? tags,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? hiddenAt,
    String? hiddenReason,
    bool? isAnonymous,
    String? reviewerName,
    String? reviewerProfileUrl,
    String? revieweeName,
    String? contractTitle,
  }) {
    return Review(
      id: id ?? this.id,
      contractId: contractId ?? this.contractId,
      reviewerId: reviewerId ?? this.reviewerId,
      revieweeId: revieweeId ?? this.revieweeId,
      type: type ?? this.type,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hiddenAt: hiddenAt ?? this.hiddenAt,
      hiddenReason: hiddenReason ?? this.hiddenReason,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewerProfileUrl: reviewerProfileUrl ?? this.reviewerProfileUrl,
      revieweeName: revieweeName ?? this.revieweeName,
      contractTitle: contractTitle ?? this.contractTitle,
    );
  }

  // Helper methods
  String get formattedDate => DateFormat('yyyy.MM.dd').format(createdAt);
  String get formattedTime => DateFormat('HH:mm').format(createdAt);
  String get formattedDateTime => DateFormat('yyyy.MM.dd HH:mm').format(createdAt);
  
  bool get isCompleted => status == ReviewStatus.completed;
  bool get isPending => status == ReviewStatus.pending;
  bool get isHidden => status == ReviewStatus.hidden;
  
  String get displayName {
    if (isAnonymous) {
      return '익명';
    }
    return reviewerName ?? '알 수 없음';
  }
  
  int get ratingStars => rating.round();
  
  String get ratingText {
    switch (ratingStars) {
      case 5:
        return '매우 만족';
      case 4:
        return '만족';
      case 3:
        return '보통';
      case 2:
        return '불만족';
      case 1:
        return '매우 불만족';
      default:
        return '평가 없음';
    }
  }
}

class ReviewSummary {
  final String userId;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // 1~5점별 개수
  final List<String> topTags; // 자주 언급되는 태그
  
  const ReviewSummary({
    required this.userId,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.topTags,
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    return ReviewSummary(
      userId: json['user_id'],
      averageRating: (json['average_rating'] as num).toDouble(),
      totalReviews: json['total_reviews'],
      ratingDistribution: Map<int, int>.from(json['rating_distribution'] ?? {}),
      topTags: List<String>.from(json['top_tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'rating_distribution': ratingDistribution,
      'top_tags': topTags,
    };
  }

  String get formattedRating => averageRating.toStringAsFixed(1);
  
  double get satisfactionRate {
    if (totalReviews == 0) return 0.0;
    final positiveReviews = (ratingDistribution[4] ?? 0) + (ratingDistribution[5] ?? 0);
    return (positiveReviews / totalReviews * 100);
  }
  
  String get formattedSatisfactionRate => '${satisfactionRate.toStringAsFixed(0)}%';
}

class ReviewCreateRequest {
  final String contractId;
  final String revieweeId;
  final ReviewType type;
  final double rating;
  final String title;
  final String content;
  final List<String> tags;
  final List<String>? imageUrls;
  final bool isAnonymous;

  const ReviewCreateRequest({
    required this.contractId,
    required this.revieweeId,
    required this.type,
    required this.rating,
    required this.title,
    required this.content,
    required this.tags,
    this.imageUrls,
    required this.isAnonymous,
  });

  Map<String, dynamic> toJson() {
    return {
      'contract_id': contractId,
      'reviewee_id': revieweeId,
      'type': type.name,
      'rating': rating,
      'title': title,
      'content': content,
      'tags': tags,
      'image_urls': imageUrls,
      'is_anonymous': isAnonymous,
    };
  }
}

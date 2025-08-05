import 'package:intl/intl.dart';

enum MatchingStatus {
  pending,     // 매칭 요청 대기
  accepted,    // 수락
  rejected,    // 거절
  expired,     // 만료
  cancelled,   // 취소
}

enum MatchingType {
  auto,        // 자동 매칭
  manual,      // 수동 매칭 (직접 선택)
}

extension MatchingStatusExtension on MatchingStatus {
  String get displayName {
    switch (this) {
      case MatchingStatus.pending:
        return '대기중';
      case MatchingStatus.accepted:
        return '수락됨';
      case MatchingStatus.rejected:
        return '거절됨';
      case MatchingStatus.expired:
        return '만료됨';
      case MatchingStatus.cancelled:
        return '취소됨';
    }
  }

  String get description {
    switch (this) {
      case MatchingStatus.pending:
        return '프리랜서의 응답을 기다리고 있습니다';
      case MatchingStatus.accepted:
        return '매칭이 성사되었습니다';
      case MatchingStatus.rejected:
        return '프리랜서가 거절했습니다';
      case MatchingStatus.expired:
        return '응답 시간이 만료되었습니다';
      case MatchingStatus.cancelled:
        return '요청자가 취소했습니다';
    }
  }
}

extension MatchingTypeExtension on MatchingType {
  String get displayName {
    switch (this) {
      case MatchingType.auto:
        return '자동 매칭';
      case MatchingType.manual:
        return '직접 선택';
    }
  }
}

class MatchingRequest {
  final String id;
  final String requestId;
  final String customerId;
  final String freelancerId;
  final MatchingType type;
  final MatchingStatus status;
  final String? message;         // 매칭 요청 메시지
  final String? rejectionReason; // 거절 사유
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime expiresAt;      // 만료 시간
  final DateTime? respondedAt;   // 응답 시간
  
  // 조인을 통해 가져오는 추가 정보
  final String? customerName;
  final String? freelancerName;
  final String? freelancerProfileUrl;
  final String? requestTitle;
  final double? freelancerRating;

  const MatchingRequest({
    required this.id,
    required this.requestId,
    required this.customerId,
    required this.freelancerId,
    required this.type,
    required this.status,
    this.message,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAt,
    this.respondedAt,
    this.customerName,
    this.freelancerName,
    this.freelancerProfileUrl,
    this.requestTitle,
    this.freelancerRating,
  });

  factory MatchingRequest.fromJson(Map<String, dynamic> json) {
    return MatchingRequest(
      id: json['id'],
      requestId: json['request_id'],
      customerId: json['customer_id'],
      freelancerId: json['freelancer_id'],
      type: MatchingType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MatchingType.manual,
      ),
      status: MatchingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MatchingStatus.pending,
      ),
      message: json['message'],
      rejectionReason: json['rejection_reason'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'])
          : null,
      customerName: json['customer_name'],
      freelancerName: json['freelancer_name'],
      freelancerProfileUrl: json['freelancer_profile_url'],
      requestTitle: json['request_title'],
      freelancerRating: json['freelancer_rating']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'customer_id': customerId,
      'freelancer_id': freelancerId,
      'type': type.name,
      'status': status.name,
      'message': message,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
      'customer_name': customerName,
      'freelancer_name': freelancerName,
      'freelancer_profile_url': freelancerProfileUrl,
      'request_title': requestTitle,
      'freelancer_rating': freelancerRating,
    };
  }

  MatchingRequest copyWith({
    String? id,
    String? requestId,
    String? customerId,
    String? freelancerId,
    MatchingType? type,
    MatchingStatus? status,
    String? message,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
    DateTime? respondedAt,
    String? customerName,
    String? freelancerName,
    String? freelancerProfileUrl,
    String? requestTitle,
    double? freelancerRating,
  }) {
    return MatchingRequest(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      customerId: customerId ?? this.customerId,
      freelancerId: freelancerId ?? this.freelancerId,
      type: type ?? this.type,
      status: status ?? this.status,
      message: message ?? this.message,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      respondedAt: respondedAt ?? this.respondedAt,
      customerName: customerName ?? this.customerName,
      freelancerName: freelancerName ?? this.freelancerName,
      freelancerProfileUrl: freelancerProfileUrl ?? this.freelancerProfileUrl,
      requestTitle: requestTitle ?? this.requestTitle,
      freelancerRating: freelancerRating ?? this.freelancerRating,
    );
  }

  // Helper methods
  String get formattedCreatedAt => DateFormat('MM.dd HH:mm').format(createdAt);
  String get formattedExpiresAt => DateFormat('MM.dd HH:mm').format(expiresAt);
  
  bool get isPending => status == MatchingStatus.pending;
  bool get isAccepted => status == MatchingStatus.accepted;
  bool get isRejected => status == MatchingStatus.rejected;
  bool get isExpired => status == MatchingStatus.expired || DateTime.now().isAfter(expiresAt);
  bool get isCancelled => status == MatchingStatus.cancelled;
  
  bool get isActive => isPending && !isExpired;
  
  Duration get timeRemaining {
    if (isExpired) return Duration.zero;
    return expiresAt.difference(DateTime.now());
  }
  
  String get timeRemainingText {
    final remaining = timeRemaining;
    if (remaining == Duration.zero) return '만료됨';
    
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}시간 ${minutes}분 남음';
    } else {
      return '${minutes}분 남음';
    }
  }
}

class MatchingCreateRequest {
  final String requestId;
  final String freelancerId;
  final MatchingType type;
  final String? message;

  const MatchingCreateRequest({
    required this.requestId,
    required this.freelancerId,
    required this.type,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'freelancer_id': freelancerId,
      'type': type.name,
      'message': message,
    };
  }
}

class MatchingResponseRequest {
  final String matchingId;
  final MatchingStatus status;
  final String? rejectionReason;

  const MatchingResponseRequest({
    required this.matchingId,
    required this.status,
    this.rejectionReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'matching_id': matchingId,
      'status': status.name,
      'rejection_reason': rejectionReason,
    };
  }
}

class MatchingFilter {
  final MatchingStatus? status;
  final MatchingType? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchText;

  const MatchingFilter({
    this.status,
    this.type,
    this.startDate,
    this.endDate,
    this.searchText,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status!.name;
    if (type != null) params['type'] = type!.name;
    if (startDate != null) params['start_date'] = startDate!.toIso8601String();
    if (endDate != null) params['end_date'] = endDate!.toIso8601String();
    if (searchText != null && searchText!.isNotEmpty) params['search'] = searchText;
    return params;
  }

  bool get hasFilters {
    return status != null || 
           type != null || 
           startDate != null || 
           endDate != null || 
           (searchText != null && searchText!.isNotEmpty);
  }
}

class MatchingSummary {
  final int totalRequests;
  final int pendingRequests;
  final int acceptedRequests;
  final int rejectedRequests;
  final int expiredRequests;
  final double acceptanceRate;

  const MatchingSummary({
    required this.totalRequests,
    required this.pendingRequests,
    required this.acceptedRequests,
    required this.rejectedRequests,
    required this.expiredRequests,
    required this.acceptanceRate,
  });

  factory MatchingSummary.fromJson(Map<String, dynamic> json) {
    return MatchingSummary(
      totalRequests: json['total_requests'] ?? 0,
      pendingRequests: json['pending_requests'] ?? 0,
      acceptedRequests: json['accepted_requests'] ?? 0,
      rejectedRequests: json['rejected_requests'] ?? 0,
      expiredRequests: json['expired_requests'] ?? 0,
      acceptanceRate: (json['acceptance_rate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_requests': totalRequests,
      'pending_requests': pendingRequests,
      'accepted_requests': acceptedRequests,
      'rejected_requests': rejectedRequests,
      'expired_requests': expiredRequests,
      'acceptance_rate': acceptanceRate,
    };
  }

  String get formattedAcceptanceRate => '${acceptanceRate.toStringAsFixed(1)}%';
}

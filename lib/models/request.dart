enum ServiceType { 
  childcare, // 돌봄
  eldercare, // 간병
  tutoring, // 튜터링
  counseling // 심리상담
}

extension ServiceTypeExtension on ServiceType {
  String get displayName {
    switch (this) {
      case ServiceType.childcare:
        return '돌봄';
      case ServiceType.eldercare:
        return '간병';
      case ServiceType.tutoring:
        return '튜터링';
      case ServiceType.counseling:
        return '심리상담';
    }
  }
}

enum RequestStatus {
  pending, // 매칭대기
  matched, // 매칭완료
  inProgress, // 진행중
  completed, // 완료
  cancelled // 취소
}

class ServiceRequest {
  final String id;
  final String customerId;
  final ServiceType serviceType;
  final String title;
  final String description;
  final String region;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> preferredTimes;
  final Map<String, dynamic> conditions; // 희망조건
  final String? specialNotes; // 특이사항
  final List<String> attachments; // 첨부파일
  final RequestStatus status;
  final double? budget;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // 매칭 관련
  final String? matchedFreelancerId;
  final DateTime? matchedAt;
  final String? contractId;
  
  const ServiceRequest({
    required this.id,
    required this.customerId,
    required this.serviceType,
    required this.title,
    required this.description,
    required this.region,
    required this.startDate,
    this.endDate,
    required this.preferredTimes,
    required this.conditions,
    this.specialNotes,
    required this.attachments,
    required this.status,
    this.budget,
    required this.createdAt,
    required this.updatedAt,
    this.matchedFreelancerId,
    this.matchedAt,
    this.contractId,
  });
  
  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'],
      customerId: json['customer_id'],
      serviceType: ServiceType.values.firstWhere(
        (type) => type.toString().split('.').last == json['service_type'],
      ),
      title: json['title'],
      description: json['description'],
      region: json['region'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      preferredTimes: json['preferred_times'].cast<String>(),
      conditions: json['conditions'],
      specialNotes: json['special_notes'],
      attachments: json['attachments'].cast<String>(),
      status: RequestStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['status'],
      ),
      budget: json['budget']?.toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      matchedFreelancerId: json['matched_freelancer_id'],
      matchedAt: json['matched_at'] != null ? DateTime.parse(json['matched_at']) : null,
      contractId: json['contract_id'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'service_type': serviceType.toString().split('.').last,
      'title': title,
      'description': description,
      'region': region,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'preferred_times': preferredTimes,
      'conditions': conditions,
      'special_notes': specialNotes,
      'attachments': attachments,
      'status': status.toString().split('.').last,
      'budget': budget,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'matched_freelancer_id': matchedFreelancerId,
      'matched_at': matchedAt?.toIso8601String(),
      'contract_id': contractId,
    };
  }
  
  ServiceRequest copyWith({
    String? id,
    String? customerId,
    ServiceType? serviceType,
    String? title,
    String? description,
    String? region,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? preferredTimes,
    Map<String, dynamic>? conditions,
    String? specialNotes,
    List<String>? attachments,
    RequestStatus? status,
    double? budget,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? matchedFreelancerId,
    DateTime? matchedAt,
    String? contractId,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      serviceType: serviceType ?? this.serviceType,
      title: title ?? this.title,
      description: description ?? this.description,
      region: region ?? this.region,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      preferredTimes: preferredTimes ?? this.preferredTimes,
      conditions: conditions ?? this.conditions,
      specialNotes: specialNotes ?? this.specialNotes,
      attachments: attachments ?? this.attachments,
      status: status ?? this.status,
      budget: budget ?? this.budget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      matchedFreelancerId: matchedFreelancerId ?? this.matchedFreelancerId,
      matchedAt: matchedAt ?? this.matchedAt,
      contractId: contractId ?? this.contractId,
    );
  }
}

// 서비스 타입별 한국어 라벨
extension ServiceTypeExtension on ServiceType {
  String get label {
    switch (this) {
      case ServiceType.childcare:
        return '돌봄';
      case ServiceType.eldercare:
        return '간병';
      case ServiceType.tutoring:
        return '튜터링';
      case ServiceType.counseling:
        return '심리상담';
    }
  }
  
  String get description {
    switch (this) {
      case ServiceType.childcare:
        return '아이 돌봄 서비스';
      case ServiceType.eldercare:
        return '어르신 간병 서비스';
      case ServiceType.tutoring:
        return '학습 지도 서비스';
      case ServiceType.counseling:
        return '심리 상담 서비스';
    }
  }
}

// 요청 상태별 한국어 라벨
extension RequestStatusExtension on RequestStatus {
  String get label {
    switch (this) {
      case RequestStatus.pending:
        return '매칭대기';
      case RequestStatus.matched:
        return '매칭완료';
      case RequestStatus.inProgress:
        return '진행중';
      case RequestStatus.completed:
        return '완료';
      case RequestStatus.cancelled:
        return '취소';
    }
  }
}

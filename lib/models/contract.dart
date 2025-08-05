enum ContractStatus {
  draft,      // 초안
  pending,    // 서명 대기
  signed,     // 서명 완료
  active,     // 활성
  completed,  // 완료
  cancelled,  // 취소
  disputed    // 분쟁
}

enum PaymentStatus {
  pending,    // 결제 대기
  escrow,     // 에스크로 예치
  paid,       // 결제 완료
  refunded,   // 환불
  disputed    // 분쟁
}

enum PaymentMethod {
  creditCard,    // 신용카드
  bankTransfer,  // 계좌이체
  virtualAccount, // 가상계좌
  kakaoPay,      // 카카오페이
  naverPay,      // 네이버페이
  payco          // 페이코
}

class Contract {
  final String id;
  final String serviceRequestId;
  final String customerId;
  final String freelancerId;
  final String title;
  final String description;
  final double totalAmount;
  final double platformFee;
  final double freelancerAmount;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> terms;
  final ContractStatus status;
  final DateTime createdAt;
  final DateTime? signedAt;
  final DateTime? completedAt;
  
  // 서명 정보
  final String? customerSignature;
  final String? freelancerSignature;
  final DateTime? customerSignedAt;
  final DateTime? freelancerSignedAt;
  
  // 결제 정보
  final PaymentStatus paymentStatus;
  final PaymentMethod? paymentMethod;
  final String? paymentId;
  final DateTime? paidAt;
  
  // 기타
  final String? notes;
  final List<String> attachments;

  const Contract({
    required this.id,
    required this.serviceRequestId,
    required this.customerId,
    required this.freelancerId,
    required this.title,
    required this.description,
    required this.totalAmount,
    required this.platformFee,
    required this.freelancerAmount,
    required this.startDate,
    required this.endDate,
    required this.terms,
    required this.status,
    required this.createdAt,
    this.signedAt,
    this.completedAt,
    this.customerSignature,
    this.freelancerSignature,
    this.customerSignedAt,
    this.freelancerSignedAt,
    required this.paymentStatus,
    this.paymentMethod,
    this.paymentId,
    this.paidAt,
    this.notes,
    this.attachments = const [],
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id'],
      serviceRequestId: json['service_request_id'],
      customerId: json['customer_id'],
      freelancerId: json['freelancer_id'],
      title: json['title'],
      description: json['description'],
      totalAmount: json['total_amount'].toDouble(),
      platformFee: json['platform_fee'].toDouble(),
      freelancerAmount: json['freelancer_amount'].toDouble(),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      terms: List<String>.from(json['terms'] ?? []),
      status: ContractStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['status'],
      ),
      createdAt: DateTime.parse(json['created_at']),
      signedAt: json['signed_at'] != null ? DateTime.parse(json['signed_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      customerSignature: json['customer_signature'],
      freelancerSignature: json['freelancer_signature'],
      customerSignedAt: json['customer_signed_at'] != null ? DateTime.parse(json['customer_signed_at']) : null,
      freelancerSignedAt: json['freelancer_signed_at'] != null ? DateTime.parse(json['freelancer_signed_at']) : null,
      paymentStatus: PaymentStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['payment_status'],
      ),
      paymentMethod: json['payment_method'] != null 
        ? PaymentMethod.values.firstWhere(
            (method) => method.toString().split('.').last == json['payment_method'],
          )
        : null,
      paymentId: json['payment_id'],
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      notes: json['notes'],
      attachments: List<String>.from(json['attachments'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_request_id': serviceRequestId,
      'customer_id': customerId,
      'freelancer_id': freelancerId,
      'title': title,
      'description': description,
      'total_amount': totalAmount,
      'platform_fee': platformFee,
      'freelancer_amount': freelancerAmount,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'terms': terms,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'signed_at': signedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'customer_signature': customerSignature,
      'freelancer_signature': freelancerSignature,
      'customer_signed_at': customerSignedAt?.toIso8601String(),
      'freelancer_signed_at': freelancerSignedAt?.toIso8601String(),
      'payment_status': paymentStatus.toString().split('.').last,
      'payment_method': paymentMethod?.toString().split('.').last,
      'payment_id': paymentId,
      'paid_at': paidAt?.toIso8601String(),
      'notes': notes,
      'attachments': attachments,
    };
  }

  Contract copyWith({
    String? id,
    String? serviceRequestId,
    String? customerId,
    String? freelancerId,
    String? title,
    String? description,
    double? totalAmount,
    double? platformFee,
    double? freelancerAmount,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? terms,
    ContractStatus? status,
    DateTime? createdAt,
    DateTime? signedAt,
    DateTime? completedAt,
    String? customerSignature,
    String? freelancerSignature,
    DateTime? customerSignedAt,
    DateTime? freelancerSignedAt,
    PaymentStatus? paymentStatus,
    PaymentMethod? paymentMethod,
    String? paymentId,
    DateTime? paidAt,
    String? notes,
    List<String>? attachments,
  }) {
    return Contract(
      id: id ?? this.id,
      serviceRequestId: serviceRequestId ?? this.serviceRequestId,
      customerId: customerId ?? this.customerId,
      freelancerId: freelancerId ?? this.freelancerId,
      title: title ?? this.title,
      description: description ?? this.description,
      totalAmount: totalAmount ?? this.totalAmount,
      platformFee: platformFee ?? this.platformFee,
      freelancerAmount: freelancerAmount ?? this.freelancerAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      terms: terms ?? this.terms,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      signedAt: signedAt ?? this.signedAt,
      completedAt: completedAt ?? this.completedAt,
      customerSignature: customerSignature ?? this.customerSignature,
      freelancerSignature: freelancerSignature ?? this.freelancerSignature,
      customerSignedAt: customerSignedAt ?? this.customerSignedAt,
      freelancerSignedAt: freelancerSignedAt ?? this.freelancerSignedAt,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      paidAt: paidAt ?? this.paidAt,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
    );
  }

  // Helper methods
  String get statusDisplayName {
    switch (status) {
      case ContractStatus.draft:
        return '초안';
      case ContractStatus.pending:
        return '서명 대기';
      case ContractStatus.signed:
        return '서명 완료';
      case ContractStatus.active:
        return '진행 중';
      case ContractStatus.completed:
        return '완료';
      case ContractStatus.cancelled:
        return '취소';
      case ContractStatus.disputed:
        return '분쟁';
    }
  }

  String get paymentStatusDisplayName {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return '결제 대기';
      case PaymentStatus.escrow:
        return '에스크로 예치';
      case PaymentStatus.paid:
        return '결제 완료';
      case PaymentStatus.refunded:
        return '환불';
      case PaymentStatus.disputed:
        return '분쟁';
    }
  }

  String get paymentMethodDisplayName {
    if (paymentMethod == null) return '미선택';
    switch (paymentMethod!) {
      case PaymentMethod.creditCard:
        return '신용카드';
      case PaymentMethod.bankTransfer:
        return '계좌이체';
      case PaymentMethod.virtualAccount:
        return '가상계좌';
      case PaymentMethod.kakaoPay:
        return '카카오페이';
      case PaymentMethod.naverPay:
        return '네이버페이';
      case PaymentMethod.payco:
        return '페이코';
    }
  }

  bool get isSignedByCustomer => customerSignature != null;
  bool get isSignedByFreelancer => freelancerSignature != null;
  bool get isFullySigned => isSignedByCustomer && isSignedByFreelancer;
  bool get canSign => status == ContractStatus.pending;
  bool get canPay => status == ContractStatus.signed && paymentStatus == PaymentStatus.pending;
}

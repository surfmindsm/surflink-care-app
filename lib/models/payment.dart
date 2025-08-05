import 'package:flutter/material.dart';

enum PaymentStatus {
  pending,     // 정산 예정
  processing,  // 정산 처리중
  completed,   // 정산 완료
  failed,      // 정산 실패
  cancelled    // 정산 취소
}

enum PaymentType {
  contract,    // 계약 정산
  bonus,       // 보너스
  refund,      // 환불
  penalty      // 위약금
}

enum PaymentMethod {
  bankTransfer, // 계좌이체
  card,         // 카드
  digitalWallet // 전자지갑
}

class Payment {
  final String id;
  final String contractId;
  final String fromUserId;
  final String toUserId;
  final double amount;
  final double platformFee;
  final double actualAmount; // 실지급액
  final PaymentType type;
  final PaymentStatus status;
  final PaymentMethod? method;
  final String? bankName;
  final String? accountNumber;
  final String? accountHolder;
  final String? description;
  final DateTime scheduledDate; // 정산 예정일
  final DateTime? processedAt;  // 정산 처리일
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const Payment({
    required this.id,
    required this.contractId,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.platformFee,
    required this.actualAmount,
    required this.type,
    required this.status,
    this.method,
    this.bankName,
    this.accountNumber,
    this.accountHolder,
    this.description,
    required this.scheduledDate,
    this.processedAt,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      contractId: json['contract_id'],
      fromUserId: json['from_user_id'],
      toUserId: json['to_user_id'],
      amount: (json['amount'] as num).toDouble(),
      platformFee: (json['platform_fee'] as num).toDouble(),
      actualAmount: (json['actual_amount'] as num).toDouble(),
      type: PaymentType.values.firstWhere(
        (type) => type.toString().split('.').last == json['type'],
      ),
      status: PaymentStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['status'],
      ),
      method: json['method'] != null
          ? PaymentMethod.values.firstWhere(
              (method) => method.toString().split('.').last == json['method'],
            )
          : null,
      bankName: json['bank_name'],
      accountNumber: json['account_number'],
      accountHolder: json['account_holder'],
      description: json['description'],
      scheduledDate: DateTime.parse(json['scheduled_date']),
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contract_id': contractId,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'amount': amount,
      'platform_fee': platformFee,
      'actual_amount': actualAmount,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'method': method?.toString().split('.').last,
      'bank_name': bankName,
      'account_number': accountNumber,
      'account_holder': accountHolder,
      'description': description,
      'scheduled_date': scheduledDate.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  Payment copyWith({
    String? id,
    String? contractId,
    String? fromUserId,
    String? toUserId,
    double? amount,
    double? platformFee,
    double? actualAmount,
    PaymentType? type,
    PaymentStatus? status,
    PaymentMethod? method,
    String? bankName,
    String? accountNumber,
    String? accountHolder,
    String? description,
    DateTime? scheduledDate,
    DateTime? processedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Payment(
      id: id ?? this.id,
      contractId: contractId ?? this.contractId,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      amount: amount ?? this.amount,
      platformFee: platformFee ?? this.platformFee,
      actualAmount: actualAmount ?? this.actualAmount,
      type: type ?? this.type,
      status: status ?? this.status,
      method: method ?? this.method,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolder: accountHolder ?? this.accountHolder,
      description: description ?? this.description,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      processedAt: processedAt ?? this.processedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

class PaymentSummary {
  final double totalEarnings;    // 총 수익
  final double totalPending;     // 정산 대기 금액
  final double totalCompleted;   // 정산 완료 금액
  final double totalFees;        // 총 수수료
  final int totalTransactions;   // 총 거래 수
  final List<Payment> recentPayments; // 최근 정산 내역

  const PaymentSummary({
    required this.totalEarnings,
    required this.totalPending,
    required this.totalCompleted,
    required this.totalFees,
    required this.totalTransactions,
    required this.recentPayments,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      totalEarnings: (json['total_earnings'] as num).toDouble(),
      totalPending: (json['total_pending'] as num).toDouble(),
      totalCompleted: (json['total_completed'] as num).toDouble(),
      totalFees: (json['total_fees'] as num).toDouble(),
      totalTransactions: json['total_transactions'],
      recentPayments: (json['recent_payments'] as List<dynamic>)
          .map((item) => Payment.fromJson(item))
          .toList(),
    );
  }
}

class BankAccount {
  final String id;
  final String userId;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final bool isDefault;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BankAccount({
    required this.id,
    required this.userId,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
    required this.isDefault,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'],
      userId: json['user_id'],
      bankName: json['bank_name'],
      accountNumber: json['account_number'],
      accountHolder: json['account_holder'],
      isDefault: json['is_default'] ?? false,
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bank_name': bankName,
      'account_number': accountNumber,
      'account_holder': accountHolder,
      'is_default': isDefault,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return '정산 예정';
      case PaymentStatus.processing:
        return '정산 처리중';
      case PaymentStatus.completed:
        return '정산 완료';
      case PaymentStatus.failed:
        return '정산 실패';
      case PaymentStatus.cancelled:
        return '정산 취소';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.processing:
        return Colors.blue;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.cancelled:
        return Colors.grey;
    }
  }
}

extension PaymentTypeExtension on PaymentType {
  String get displayName {
    switch (this) {
      case PaymentType.contract:
        return '계약 정산';
      case PaymentType.bonus:
        return '보너스';
      case PaymentType.refund:
        return '환불';
      case PaymentType.penalty:
        return '위약금';
    }
  }
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.bankTransfer:
        return '계좌이체';
      case PaymentMethod.card:
        return '카드';
      case PaymentMethod.digitalWallet:
        return '전자지갑';
    }
  }
}

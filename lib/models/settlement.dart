enum SettlementStatus {
  pending,
  completed,
  rejected,
}

class Settlement {
  final String id;
  final int amount;
  final int fee;
  final int netAmount;
  final SettlementStatus status;
  final DateTime requestDate;
  final DateTime? completedDate;
  final String serviceType;
  final String clientName;

  Settlement({
    required this.id,
    required this.amount,
    required this.fee,
    required this.netAmount,
    required this.status,
    required this.requestDate,
    this.completedDate,
    required this.serviceType,
    required this.clientName,
  });

  factory Settlement.fromJson(Map<String, dynamic> json) {
    int _asInt(dynamic v) {
      // 숫자 안전 파싱: NaN/Infinity 방지
      if (v is num) {
        if (v is double && (v.isNaN || v.isInfinite)) return 0;
        return v.toInt();
      }
      if (v is String) {
        final s = v.trim();
        final lower = s.toLowerCase();
        if (lower == 'nan' || lower == 'infinity' || lower == '-infinity') return 0;
        final parsedInt = int.tryParse(s);
        if (parsedInt != null) return parsedInt;
        final parsedDouble = double.tryParse(s);
        if (parsedDouble == null) return 0;
        if (parsedDouble.isNaN || parsedDouble.isInfinite) return 0;
        return parsedDouble.toInt();
      }
      return 0;
    }

    // 상태 파싱 (알 수 없는 값은 pending으로 처리)
    final statusStr = (json['status'] as String?)?.toLowerCase();
    final SettlementStatus parsedStatus;
    switch (statusStr) {
      case 'completed':
        parsedStatus = SettlementStatus.completed;
        break;
      case 'rejected':
      case 'cancelled':
        parsedStatus = SettlementStatus.rejected;
        break;
      default:
        parsedStatus = SettlementStatus.pending;
    }

    // 금액 필드 매핑 (스키마 차이 허용)
    final int amount = json.containsKey('total_amount')
        ? _asInt(json['total_amount'])
        : json.containsKey('amount')
            ? _asInt(json['amount'])
            : _asInt(json['settlement_amount']); // 최후보: 실수령액

    final int fee = json.containsKey('commission_amount')
        ? _asInt(json['commission_amount'])
        : _asInt(json['fee']);

    final int netAmount = json.containsKey('net_amount')
        ? _asInt(json['net_amount'])
        : json.containsKey('settlement_amount')
            ? _asInt(json['settlement_amount'])
            : (amount - fee);

    // 날짜 필드 매핑
    final String? requestAtStr = (json['request_date'] ?? json['processed_at'] ?? json['created_at']) as String?;
    final DateTime requestDate = requestAtStr != null
        ? DateTime.parse(requestAtStr)
        : DateTime.now();

    final String? completedAtStr = (json['completed_date'] ?? json['completed_at']) as String?;
    final DateTime? completedDate = completedAtStr != null ? DateTime.parse(completedAtStr) : null;

    return Settlement(
      id: json['id'] as String,
      amount: amount,
      fee: fee,
      netAmount: netAmount,
      status: parsedStatus,
      requestDate: requestDate,
      completedDate: completedDate,
      serviceType: (json['service_type'] as String?) ?? '기타 서비스',
      clientName: (json['client_name'] as String?) ?? '고객',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'fee': fee,
      'net_amount': netAmount,
      'status': status.toString().split('.').last,
      'request_date': requestDate.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'service_type': serviceType,
      'client_name': clientName,
    };
  }
}

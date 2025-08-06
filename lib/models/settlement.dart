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
    return Settlement(
      id: json['id'],
      amount: json['amount'],
      fee: json['fee'],
      netAmount: json['net_amount'],
      status: SettlementStatus.values.firstWhere(
        (s) => s.toString().split('.').last == json['status'],
      ),
      requestDate: DateTime.parse(json['request_date']),
      completedDate: json['completed_date'] != null 
          ? DateTime.parse(json['completed_date'])
          : null,
      serviceType: json['service_type'],
      clientName: json['client_name'],
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

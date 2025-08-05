import 'dart:convert';
import '../models/payment.dart';
import '../config/app_config.dart';
import '../providers/auth_provider.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  // Mock 데이터 - 추후 실제 API 연동 시 제거
  Future<PaymentSummary> getPaymentSummary(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final mockPayments = _getMockPayments();
    final userPayments = mockPayments.where(
      (payment) => payment.toUserId == userId || payment.fromUserId == userId,
    ).toList();

    double totalEarnings = 0;
    double totalPending = 0;
    double totalCompleted = 0;
    double totalFees = 0;

    for (final payment in userPayments) {
      if (payment.toUserId == userId) {
        totalEarnings += payment.actualAmount;
        totalFees += payment.platformFee;
        
        switch (payment.status) {
          case PaymentStatus.pending:
          case PaymentStatus.processing:
            totalPending += payment.actualAmount;
            break;
          case PaymentStatus.completed:
            totalCompleted += payment.actualAmount;
            break;
          default:
            break;
        }
      }
    }

    return PaymentSummary(
      totalEarnings: totalEarnings,
      totalPending: totalPending,
      totalCompleted: totalCompleted,
      totalFees: totalFees,
      totalTransactions: userPayments.length,
      recentPayments: userPayments.take(5).toList(),
    );
  }

  Future<List<Payment>> getUserPayments(String userId, {
    PaymentStatus? status,
    PaymentType? type,
    int? limit,
    int? offset,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    var payments = _getMockPayments().where(
      (payment) => payment.toUserId == userId || payment.fromUserId == userId,
    ).toList();

    if (status != null) {
      payments = payments.where((payment) => payment.status == status).toList();
    }

    if (type != null) {
      payments = payments.where((payment) => payment.type == type).toList();
    }

    // 최신순 정렬
    payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (offset != null) {
      payments = payments.skip(offset).toList();
    }

    if (limit != null) {
      payments = payments.take(limit).toList();
    }

    return payments;
  }

  Future<Payment?> getPaymentById(String paymentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    try {
      return _getMockPayments().firstWhere((payment) => payment.id == paymentId);
    } catch (e) {
      return null;
    }
  }

  Future<List<BankAccount>> getUserBankAccounts(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _getMockBankAccounts().where(
      (account) => account.userId == userId,
    ).toList();
  }

  Future<BankAccount> addBankAccount({
    required String userId,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
    bool isDefault = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final now = DateTime.now();
    final newAccount = BankAccount(
      id: 'account_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      bankName: bankName,
      accountNumber: accountNumber,
      accountHolder: accountHolder,
      isDefault: isDefault,
      isVerified: false,
      createdAt: now,
      updatedAt: now,
    );

    return newAccount;
  }

  Future<void> deleteBankAccount(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock implementation - 실제 구현 시 API 호출
  }

  Future<void> setDefaultBankAccount(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock implementation - 실제 구현 시 API 호출
  }

  Future<Payment> requestPayment({
    required String contractId,
    required String fromUserId,
    required String toUserId,
    required double amount,
    String? description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final now = DateTime.now();
    final platformFee = amount * 0.05; // 5% 수수료
    final actualAmount = amount - platformFee;

    final payment = Payment(
      id: 'payment_${DateTime.now().millisecondsSinceEpoch}',
      contractId: contractId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      amount: amount,
      platformFee: platformFee,
      actualAmount: actualAmount,
      type: PaymentType.contract,
      status: PaymentStatus.pending,
      description: description,
      scheduledDate: now.add(const Duration(days: 3)), // 3일 후 정산 예정
      createdAt: now,
      updatedAt: now,
    );

    return payment;
  }

  Future<void> cancelPayment(String paymentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock implementation - 실제 구현 시 API 호출
  }

  // Mock 데이터 생성 함수들
  List<Payment> _getMockPayments() {
    final now = DateTime.now();
    
    return [
      Payment(
        id: 'payment_001',
        contractId: 'contract_001',
        fromUserId: 'user_001',
        toUserId: 'user_002',
        amount: 100000,
        platformFee: 5000,
        actualAmount: 95000,
        type: PaymentType.contract,
        status: PaymentStatus.completed,
        method: PaymentMethod.bankTransfer,
        bankName: '국민은행',
        accountNumber: '123-456-789',
        accountHolder: '김프리',
        description: '간병인 서비스 정산',
        scheduledDate: now.subtract(const Duration(days: 5)),
        processedAt: now.subtract(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      Payment(
        id: 'payment_002',
        contractId: 'contract_002',
        fromUserId: 'user_003',
        toUserId: 'user_002',
        amount: 150000,
        platformFee: 7500,
        actualAmount: 142500,
        type: PaymentType.contract,
        status: PaymentStatus.processing,
        description: '가사도우미 서비스 정산',
        scheduledDate: now.add(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Payment(
        id: 'payment_003',
        contractId: 'contract_003',
        fromUserId: 'user_001',
        toUserId: 'user_004',
        amount: 80000,
        platformFee: 4000,
        actualAmount: 76000,
        type: PaymentType.contract,
        status: PaymentStatus.pending,
        description: '반려동물 돌봄 서비스 정산',
        scheduledDate: now.add(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Payment(
        id: 'payment_004',
        contractId: 'contract_001',
        fromUserId: 'user_002',
        toUserId: 'user_001',
        amount: 10000,
        platformFee: 500,
        actualAmount: 9500,
        type: PaymentType.refund,
        status: PaymentStatus.completed,
        method: PaymentMethod.bankTransfer,
        description: '서비스 부분 환불',
        scheduledDate: now.subtract(const Duration(days: 2)),
        processedAt: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  List<BankAccount> _getMockBankAccounts() {
    final now = DateTime.now();
    
    return [
      BankAccount(
        id: 'account_001',
        userId: 'user_002',
        bankName: '국민은행',
        accountNumber: '123-456-789',
        accountHolder: '김프리',
        isDefault: true,
        isVerified: true,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      BankAccount(
        id: 'account_002',
        userId: 'user_002',
        bankName: '신한은행',
        accountNumber: '987-654-321',
        accountHolder: '김프리',
        isDefault: false,
        isVerified: false,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      BankAccount(
        id: 'account_003',
        userId: 'user_001',
        bankName: '우리은행',
        accountNumber: '555-666-777',
        accountHolder: '이고객',
        isDefault: true,
        isVerified: true,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }
}

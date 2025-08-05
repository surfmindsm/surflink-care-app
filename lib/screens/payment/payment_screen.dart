import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/payment.dart';
import '../../services/payment_service.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_config.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PaymentService _paymentService = PaymentService();
  
  PaymentSummary? _paymentSummary;
  List<Payment> _allPayments = [];
  List<Payment> _pendingPayments = [];
  List<Payment> _completedPayments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPaymentData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id ?? 'user_002'; // Mock user

      final summary = await _paymentService.getPaymentSummary(userId);
      final allPayments = await _paymentService.getUserPayments(userId);
      final pendingPayments = await _paymentService.getUserPayments(
        userId,
        status: PaymentStatus.pending,
      );
      final completedPayments = await _paymentService.getUserPayments(
        userId,
        status: PaymentStatus.completed,
      );

      if (mounted) {
        setState(() {
          _paymentSummary = summary;
          _allPayments = allPayments;
          _pendingPayments = pendingPayments;
          _completedPayments = completedPayments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('정산 정보를 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('정산 관리'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '요약'),
            Tab(text: '정산 내역'),
            Tab(text: '계좌 관리'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(),
                _buildPaymentHistoryTab(),
                _buildBankAccountTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBankAccountDialog(),
        icon: const Icon(Icons.add),
        label: const Text('계좌 추가'),
      ),
    );
  }

  Widget _buildSummaryTab() {
    if (_paymentSummary == null) {
      return const Center(child: Text('정산 요약 정보가 없습니다.'));
    }

    final summary = _paymentSummary!;
    final formatter = NumberFormat('#,###');

    return RefreshIndicator(
      onRefresh: _loadPaymentData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 수익 요약 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet,
                            color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          '수익 요약',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryRow('총 수익', summary.totalEarnings, Colors.green),
                    _buildSummaryRow('정산 대기', summary.totalPending, Colors.orange),
                    _buildSummaryRow('정산 완료', summary.totalCompleted, Colors.blue),
                    _buildSummaryRow('수수료', summary.totalFees, Colors.red),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '총 거래 수',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${summary.totalTransactions}건',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 최근 정산 내역
            const Text(
              '최근 정산 내역',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (summary.recentPayments.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text('최근 정산 내역이 없습니다.'),
                  ),
                ),
              )
            else
              ...summary.recentPayments.map((payment) => _buildPaymentCard(payment)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, Color color) {
    final formatter = NumberFormat('#,###');
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '${formatter.format(amount.toInt())}원',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryTab() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '전체'),
              Tab(text: '정산 대기'),
              Tab(text: '정산 완료'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildPaymentList(_allPayments),
                _buildPaymentList(_pendingPayments),
                _buildPaymentList(_completedPayments),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentList(List<Payment> payments) {
    if (payments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('정산 내역이 없습니다.'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPaymentData,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          return _buildPaymentCard(payment);
        },
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    final formatter = NumberFormat('#,###');
    final dateFormatter = DateFormat('yyyy.MM.dd HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showPaymentDetail(payment),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    payment.type.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: payment.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: payment.status.color.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      payment.status.displayName,
                      style: TextStyle(
                        color: payment.status.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              if (payment.description != null)
                Text(
                  payment.description!,
                  style: const TextStyle(color: Colors.grey),
                ),
              
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '실지급액',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${formatter.format(payment.actualAmount.toInt())}원',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        payment.processedAt != null ? '정산일' : '예정일',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        dateFormatter.format(
                          payment.processedAt ?? payment.scheduledDate,
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankAccountTab() {
    return FutureBuilder<List<BankAccount>>(
      future: _paymentService.getUserBankAccounts('user_002'), // Mock user
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(
            child: Text('계좌 정보를 불러오는데 실패했습니다.'),
          );
        }

        final accounts = snapshot.data!;

        if (accounts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('등록된 계좌가 없습니다.'),
                SizedBox(height: 8),
                Text(
                  '정산을 받을 계좌를 추가해주세요.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            final account = accounts[index];
            return _buildBankAccountCard(account);
          },
        );
      },
    );
  }

  Widget _buildBankAccountCard(BankAccount account) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.account_balance, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.bankName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          account.accountNumber,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleAccountAction(value, account),
                  itemBuilder: (context) => [
                    if (!account.isDefault)
                      const PopupMenuItem(
                        value: 'setDefault',
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 20),
                            SizedBox(width: 8),
                            Text('기본 계좌로 설정'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('삭제', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Text(
                  '예금주: ${account.accountHolder}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 16),
                if (account.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: const Text(
                      '기본계좌',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (account.isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Text(
                      '인증완료',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDetail(Payment payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _PaymentDetailSheet(payment: payment),
    );
  }

  void _showBankAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => _BankAccountDialog(
        onAdded: () {
          setState(() {}); // 계좌 목록 새로고침
        },
      ),
    );
  }

  void _handleAccountAction(String action, BankAccount account) {
    switch (action) {
      case 'setDefault':
        _setDefaultAccount(account);
        break;
      case 'delete':
        _deleteAccount(account);
        break;
    }
  }

  Future<void> _setDefaultAccount(BankAccount account) async {
    try {
      await _paymentService.setDefaultBankAccount(account.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기본 계좌로 설정했습니다.')),
        );
        setState(() {}); // 계좌 목록 새로고침
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('기본 계좌 설정에 실패했습니다: $e')),
        );
      }
    }
  }

  Future<void> _deleteAccount(BankAccount account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계좌 삭제'),
        content: Text('${account.bankName} ${account.accountNumber}\n계좌를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _paymentService.deleteBankAccount(account.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('계좌를 삭제했습니다.')),
          );
          setState(() {}); // 계좌 목록 새로고침
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('계좌 삭제에 실패했습니다: $e')),
          );
        }
      }
    }
  }
}

class _PaymentDetailSheet extends StatelessWidget {
  final Payment payment;

  const _PaymentDetailSheet({required this.payment});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final dateFormatter = DateFormat('yyyy년 MM월 dd일 HH:mm');

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '정산 상세',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildDetailRow('정산 유형', payment.type.displayName),
          _buildDetailRow('정산 상태', payment.status.displayName),
          _buildDetailRow('결제 금액', '${formatter.format(payment.amount.toInt())}원'),
          _buildDetailRow('플랫폼 수수료', '${formatter.format(payment.platformFee.toInt())}원'),
          _buildDetailRow('실지급액', '${formatter.format(payment.actualAmount.toInt())}원'),
          
          if (payment.description != null)
            _buildDetailRow('설명', payment.description!),
          
          if (payment.bankName != null && payment.accountNumber != null)
            _buildDetailRow('입금 계좌', '${payment.bankName} ${payment.accountNumber}'),
          
          if (payment.accountHolder != null)
            _buildDetailRow('예금주', payment.accountHolder!),
          
          _buildDetailRow(
            '정산 예정일',
            dateFormatter.format(payment.scheduledDate),
          ),
          
          if (payment.processedAt != null)
            _buildDetailRow(
              '정산 완료일',
              dateFormatter.format(payment.processedAt!),
            ),
          
          const SizedBox(height: 24),
          
          if (payment.status == PaymentStatus.pending)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // 정산 취소 로직
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('정산 취소'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _BankAccountDialog extends StatefulWidget {
  final VoidCallback onAdded;

  const _BankAccountDialog({required this.onAdded});

  @override
  State<_BankAccountDialog> createState() => _BankAccountDialogState();
}

class _BankAccountDialogState extends State<_BankAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderController = TextEditingController();
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('계좌 추가'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _bankNameController,
              decoration: const InputDecoration(
                labelText: '은행명',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '은행명을 입력해주세요.';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _accountNumberController,
              decoration: const InputDecoration(
                labelText: '계좌번호',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '계좌번호를 입력해주세요.';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _accountHolderController,
              decoration: const InputDecoration(
                labelText: '예금주명',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '예금주명을 입력해주세요.';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            CheckboxListTile(
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value ?? false),
              title: const Text('기본 계좌로 설정'),
              dense: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addBankAccount,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('추가'),
        ),
      ],
    );
  }

  Future<void> _addBankAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await PaymentService().addBankAccount(
        userId: 'user_002', // Mock user
        bankName: _bankNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        accountHolder: _accountHolderController.text.trim(),
        isDefault: _isDefault,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('계좌가 추가되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('계좌 추가에 실패했습니다: $e')),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/contract.dart';
import '../../services/contract_service.dart';
import '../../widgets/custom_button.dart';
import 'escrow_payment_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final Contract contract;

  const PaymentMethodScreen({
    super.key,
    required this.contract,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  PaymentMethod? _selectedMethod;
  bool _isLoading = false;
  final ContractService _contractService = ContractService();

  final List<PaymentMethodInfo> _paymentMethods = [
    PaymentMethodInfo(
      method: PaymentMethod.creditCard,
      title: '신용카드',
      subtitle: '국내 모든 카드 (일시불/할부)',
      icon: Icons.credit_card,
      color: Colors.blue,
    ),
    PaymentMethodInfo(
      method: PaymentMethod.kakaoPay,
      title: '카카오페이',
      subtitle: '간편하고 빠른 결제',
      icon: Icons.chat,
      color: Colors.yellow[700]!,
    ),
    PaymentMethodInfo(
      method: PaymentMethod.naverPay,
      title: '네이버페이',
      subtitle: '네이버 계정으로 간편결제',
      icon: Icons.payment,
      color: Colors.green,
    ),
    PaymentMethodInfo(
      method: PaymentMethod.bankTransfer,
      title: '계좌이체',
      subtitle: '실시간 계좌이체',
      icon: Icons.account_balance,
      color: Colors.orange,
    ),
    PaymentMethodInfo(
      method: PaymentMethod.virtualAccount,
      title: '가상계좌',
      subtitle: '무통장 입금',
      icon: Icons.receipt,
      color: Colors.purple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결제 방법 선택'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaymentInfo(),
            const SizedBox(height: 24),
            _buildEscrowNotice(),
            const SizedBox(height: 24),
            _buildPaymentMethods(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '결제 정보',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('계약서', widget.contract.title),
            _buildInfoRow('서비스 기간', 
              '${DateFormat('yyyy.MM.dd').format(widget.contract.startDate)} - ${DateFormat('yyyy.MM.dd').format(widget.contract.endDate)}'),
            const Divider(),
            _buildAmountRow('총 결제금액', widget.contract.totalAmount, isTotal: true),
            _buildAmountRow('플랫폼 수수료', widget.contract.platformFee),
            _buildAmountRow('프리랜서 수령액', widget.contract.freelancerAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildEscrowNotice() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  '에스크로 결제 안내',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '• 결제된 금액은 서비스 완료 시까지 안전하게 보관됩니다.\n'
              '• 서비스 완료 후 고객 확인을 거쳐 프리랜서에게 지급됩니다.\n'
              '• 분쟁 발생 시 플랫폼에서 중재하여 해결합니다.\n'
              '• 서비스 미제공 시 전액 환불이 가능합니다.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '결제 수단',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(_paymentMethods.length, (index) {
              final method = _paymentMethods[index];
              return _buildPaymentMethodTile(method);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(PaymentMethodInfo methodInfo) {
    final isSelected = _selectedMethod == methodInfo.method;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? Colors.blue[50] : null,
      ),
      child: RadioListTile<PaymentMethod>(
        value: methodInfo.method,
        groupValue: _selectedMethod,
        onChanged: (value) {
          setState(() {
            _selectedMethod = value;
          });
        },
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: methodInfo.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                methodInfo.icon,
                color: methodInfo.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  methodInfo.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  methodInfo.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: '결제하기',
            onPressed: _selectedMethod == null || _isLoading ? null : _proceedToPayment,
            isLoading: _isLoading,
            type: ButtonType.primary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: '취소',
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            type: ButtonType.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            '${NumberFormat('#,###').format(amount)}원',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.blue[700] : null,
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EscrowPaymentScreen(
          contract: widget.contract,
          paymentMethod: _selectedMethod!,
        ),
      ),
    );
  }
}

class PaymentMethodInfo {
  final PaymentMethod method;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const PaymentMethodInfo({
    required this.method,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

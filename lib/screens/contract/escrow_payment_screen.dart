import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/contract.dart';
import '../../services/contract_service.dart';
import '../../widgets/custom_button.dart';

class EscrowPaymentScreen extends StatefulWidget {
  final Contract contract;
  final PaymentMethod paymentMethod;

  const EscrowPaymentScreen({
    super.key,
    required this.contract,
    required this.paymentMethod,
  });

  @override
  State<EscrowPaymentScreen> createState() => _EscrowPaymentScreenState();
}

class _EscrowPaymentScreenState extends State<EscrowPaymentScreen>
    with TickerProviderStateMixin {
  final ContractService _contractService = ContractService();
  bool _isProcessing = false;
  bool _isCompleted = false;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.paymentMethod.displayName} 결제'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: !_isProcessing,
      ),
      body: WillPopScope(
        onWillPop: () async => !_isProcessing,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isCompleted) ...[
                _buildSuccessSection(),
              ] else if (_isProcessing) ...[
                _buildProcessingSection(),
              ] else ...[
                _buildPaymentConfirmation(),
                const SizedBox(height: 24),
                _buildEscrowProcess(),
                const SizedBox(height: 24),
                _buildPaymentDetails(),
                const SizedBox(height: 24),
                _buildTermsAgreement(),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessSection() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green[100],
          ),
          child: Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green[600],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          '결제가 완료되었습니다!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          '결제 금액이 에스크로에 안전하게 예치되었습니다.\n서비스 완료 후 프리랜서에게 지급됩니다.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildResultRow('결제 금액', '${NumberFormat('#,###').format(widget.contract.totalAmount)}원'),
                _buildResultRow('결제 방법', widget.paymentMethod.displayName),
                _buildResultRow('결제 일시', DateFormat('yyyy.MM.dd HH:mm').format(DateTime.now())),
                _buildResultRow('거래 번호', 'TXN${DateTime.now().millisecondsSinceEpoch}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: '확인',
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            type: ButtonType.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingSection() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Container(
          width: 120,
          height: 120,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          '결제 처리 중입니다...',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          '잠시만 기다려주세요.\n페이지를 벗어나지 마세요.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Column(
              children: [
                LinearProgressIndicator(
                  value: _progressAnimation.value,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                ),
                const SizedBox(height: 16),
                Text(
                  '${(_progressAnimation.value * 100).toInt()}% 완료',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentConfirmation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '결제 확인',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  _getPaymentMethodIcon(),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.paymentMethod.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${NumberFormat('#,###').format(widget.contract.totalAmount)}원',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEscrowProcess() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '에스크로 결제 프로세스',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildProcessStep(1, '결제 완료', '고객이 결제를 완료합니다', true),
            _buildProcessStep(2, '에스크로 예치', '결제 금액이 안전하게 보관됩니다', false),
            _buildProcessStep(3, '서비스 제공', '프리랜서가 서비스를 제공합니다', false),
            _buildProcessStep(4, '서비스 확인', '고객이 서비스 완료를 확인합니다', false),
            _buildProcessStep(5, '정산 완료', '프리랜서에게 금액이 지급됩니다', false),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessStep(int step, String title, String description, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.blue[600] : Colors.grey[300],
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.blue[700] : null,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '결제 상세',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('계약서', widget.contract.title),
            _buildDetailRow('서비스 기간', 
              '${DateFormat('yyyy.MM.dd').format(widget.contract.startDate)} - ${DateFormat('yyyy.MM.dd').format(widget.contract.endDate)}'),
            const Divider(),
            _buildDetailRow('총 결제 금액', '${NumberFormat('#,###').format(widget.contract.totalAmount)}원'),
            _buildDetailRow('플랫폼 수수료', '${NumberFormat('#,###').format(widget.contract.platformFee)}원'),
            _buildDetailRow('프리랜서 수령액', '${NumberFormat('#,###').format(widget.contract.freelancerAmount)}원'),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsAgreement() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '결제 동의사항',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Text(
                '• 결제 금액은 서비스 완료 시까지 에스크로에 안전하게 보관됩니다.\n'
                '• 서비스 미완료 시 전액 환불이 가능합니다.\n'
                '• 분쟁 발생 시 플랫폼 정책에 따라 해결됩니다.\n'
                '• 결제 후 취소는 서비스 시작 전에만 가능합니다.',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
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
            onPressed: _processPayment,
            type: ButtonType.primary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: '취소',
            onPressed: () => Navigator.pop(context),
            type: ButtonType.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _getPaymentMethodIcon() {
    IconData iconData;
    Color color;

    switch (widget.paymentMethod) {
      case PaymentMethod.creditCard:
        iconData = Icons.credit_card;
        color = Colors.blue;
        break;
      case PaymentMethod.kakaoPay:
        iconData = Icons.chat;
        color = Colors.yellow[700]!;
        break;
      case PaymentMethod.naverPay:
        iconData = Icons.payment;
        color = Colors.green;
        break;
      case PaymentMethod.bankTransfer:
        iconData = Icons.account_balance;
        color = Colors.orange;
        break;
      case PaymentMethod.virtualAccount:
        iconData = Icons.receipt;
        color = Colors.purple;
        break;
      case PaymentMethod.payco:
        iconData = Icons.wallet;
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: color,
        size: 32,
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    _animationController.forward();

    try {
      final result = await _contractService.processPayment(
        contractId: widget.contract.id,
        paymentMethod: widget.paymentMethod,
        paymentData: {
          'amount': widget.contract.totalAmount,
          'currency': 'KRW',
        },
      );

      await Future.delayed(const Duration(seconds: 3)); // 애니메이션 완료 대기

      if (result['success']) {
        setState(() {
          _isCompleted = true;
          _isProcessing = false;
        });
      } else {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('결제 처리 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

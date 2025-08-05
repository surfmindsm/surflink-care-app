import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../models/contract.dart';
import '../../services/contract_service.dart';
import '../../widgets/custom_button.dart';

class DigitalSignatureScreen extends StatefulWidget {
  final Contract contract;
  final bool isCustomer;

  const DigitalSignatureScreen({
    super.key,
    required this.contract,
    required this.isCustomer,
  });

  @override
  State<DigitalSignatureScreen> createState() => _DigitalSignatureScreenState();
}

class _DigitalSignatureScreenState extends State<DigitalSignatureScreen> {
  late SignatureController _signatureController;
  final ContractService _contractService = ContractService();
  bool _isLoading = false;
  bool _hasAgreed = false;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('전자서명'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContractInfo(),
            const SizedBox(height: 24),
            _buildSignerInfo(),
            const SizedBox(height: 24),
            _buildContractTerms(),
            const SizedBox(height: 24),
            _buildAgreementSection(),
            const SizedBox(height: 24),
            _buildSignatureSection(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildContractInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '계약 정보',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('계약서 제목', widget.contract.title),
            _buildInfoRow('계약 금액', '${widget.contract.totalAmount.toInt():,}원'),
            _buildInfoRow('서비스 기간', 
              '${widget.contract.startDate.month}/${widget.contract.startDate.day} - ${widget.contract.endDate.month}/${widget.contract.endDate.day}'),
            _buildInfoRow('계약 상태', widget.contract.statusDisplayName),
          ],
        ),
      ),
    );
  }

  Widget _buildSignerInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '서명자 정보',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isCustomer ? Icons.person : Icons.work,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isCustomer ? '서비스 이용자' : '서비스 제공자',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.isCustomer ? '김고객' : '이프리랜서', // TODO: 실제 사용자 정보
                        style: const TextStyle(fontSize: 16),
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

  Widget _buildContractTerms() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '계약 조건',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[50],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...widget.contract.terms.map((term) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(term)),
                        ],
                      ),
                    )),
                    if (widget.contract.notes != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        '추가 사항:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.contract.notes!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgreementSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '동의사항',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '전자서명 관련 안내',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• 전자서명은 법적 효력을 갖습니다.\n'
                    '• 서명 후에는 계약 내용을 변경할 수 없습니다.\n'
                    '• 계약서의 모든 조건을 충분히 검토하신 후 서명해주세요.\n'
                    '• 서명 완료 후 양 당사자 모두 서명하면 계약이 체결됩니다.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('위 내용을 모두 확인하였으며, 계약 조건에 동의합니다.'),
              subtitle: const Text('서명하기 위해서는 반드시 체크해주세요.'),
              value: _hasAgreed,
              onChanged: (value) {
                setState(() {
                  _hasAgreed = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '서명',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _signatureController.clear,
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 그리기'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Signature(
                controller: _signatureController,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '위 영역에 손가락으로 서명해주세요.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
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
            text: '서명 완료',
            onPressed: _isLoading || !_hasAgreed ? null : _submitSignature,
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
            width: 80,
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

  Future<void> _submitSignature() async {
    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서명을 그려주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 서명 데이터를 이미지로 변환
      final signatureData = await _signatureController.toPngBytes();
      
      // 서명 처리
      final result = await _contractService.signContract(
        contractId: widget.contract.id,
        signatureData: signatureData.toString(), // TODO: 실제로는 base64 등으로 변환
        isCustomer: widget.isCustomer,
      );

      setState(() => _isLoading = false);

      if (result['success']) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
            title: const Text('서명 완료'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(result['message']),
                const SizedBox(height: 16),
                if (!widget.contract.isFullySigned)
                  const Text(
                    '상대방의 서명을 기다리고 있습니다.',
                    style: TextStyle(color: Colors.grey),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  Navigator.of(context).pop(true); // 서명 화면 닫기
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('서명 처리 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

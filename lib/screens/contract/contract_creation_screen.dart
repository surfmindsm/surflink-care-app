import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/contract.dart';
import '../../models/request.dart';
import '../../models/user.dart';
import '../../services/contract_service.dart';
import '../../widgets/custom_button.dart';

class ContractCreationScreen extends StatefulWidget {
  final ServiceRequest serviceRequest;
  final User freelancer;

  const ContractCreationScreen({
    super.key,
    required this.serviceRequest,
    required this.freelancer,
  });

  @override
  State<ContractCreationScreen> createState() => _ContractCreationScreenState();
}

class _ContractCreationScreenState extends State<ContractCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _totalAmountController = TextEditingController();
  final _notesController = TextEditingController();
  final ContractService _contractService = ContractService();
  
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  
  final List<String> _terms = [
    '서비스 제공자는 약속된 시간에 정확히 서비스를 제공해야 합니다.',
    '서비스 이용자는 서비스 제공에 필요한 환경을 조성해야 합니다.',
    '양 당사자는 상호 존중하며 원활한 소통을 유지해야 합니다.',
    '응급상황 발생 시 즉시 연락처로 연락해야 합니다.',
    '서비스 중 발생한 손해에 대해서는 플랫폼 정책에 따라 처리됩니다.',
  ];
  
  final List<bool> _selectedTerms = List.generate(5, (index) => true);

  @override
  void initState() {
    super.initState();
    _totalAmountController.text = widget.serviceRequest.budget?.toString() ?? '';
    _startDate = widget.serviceRequest.startDate;
    _endDate = widget.serviceRequest.endDate;
  }

  @override
  void dispose() {
    _totalAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('계약서 작성'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildServiceInfo(),
              const SizedBox(height: 24),
              _buildParticipants(),
              const SizedBox(height: 24),
              _buildServiceDetails(),
              const SizedBox(height: 24),
              _buildTermsAndConditions(),
              const SizedBox(height: 24),
              _buildPaymentInfo(),
              const SizedBox(height: 24),
              _buildNotes(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '서비스 정보',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('서비스 타입', widget.serviceRequest.serviceType.displayName),
            _buildInfoRow('제목', widget.serviceRequest.title),
            _buildInfoRow('지역', widget.serviceRequest.region),
            _buildInfoRow('설명', widget.serviceRequest.description),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipants() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '계약 당사자',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('서비스 이용자', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('고객명'), // TODO: 실제 고객 정보
                      Text('customer@example.com'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('서비스 제공자', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(widget.freelancer.name),
                      Text(widget.freelancer.email),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '서비스 상세',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDateSelector(),
            const SizedBox(height: 16),
            if (widget.serviceRequest.preferredTimes.isNotEmpty) ...[
              const Text('선호 시간', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: widget.serviceRequest.preferredTimes
                    .map((time) => Chip(label: Text(time)))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (widget.serviceRequest.specialNotes != null) ...[
              const Text('특별 요청사항', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(widget.serviceRequest.specialNotes!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('서비스 기간', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(true),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('시작일', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(_startDate != null 
                        ? DateFormat('yyyy.MM.dd').format(_startDate!)
                        : '날짜 선택'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(false),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('종료일', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(_endDate != null 
                        ? DateFormat('yyyy.MM.dd').format(_endDate!)
                        : '날짜 선택'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions() {
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
            ...List.generate(_terms.length, (index) {
              return CheckboxListTile(
                title: Text(_terms[index]),
                value: _selectedTerms[index],
                onChanged: (value) {
                  setState(() {
                    _selectedTerms[index] = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    final totalAmount = double.tryParse(_totalAmountController.text) ?? 0;
    final platformFee = totalAmount * 0.1;
    final freelancerAmount = totalAmount - platformFee;

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
            TextFormField(
              controller: _totalAmountController,
              decoration: const InputDecoration(
                labelText: '총 금액',
                suffixText: '원',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '금액을 입력해주세요';
                }
                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                  return '올바른 금액을 입력해주세요';
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildPaymentRow('총 금액', totalAmount),
                  _buildPaymentRow('플랫폼 수수료 (10%)', platformFee),
                  const Divider(),
                  _buildPaymentRow('프리랜서 수령액', freelancerAmount, isTotal: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String label, double amount, {bool isTotal = false}) {
    return Row(
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
    );
  }

  Widget _buildNotes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '추가 사항',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: '특별 요청사항이나 참고사항을 입력해주세요',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
            text: '계약서 생성',
            onPressed: _isLoading ? null : _createContract,
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

  Future<void> _selectDate(bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = DateTime.now();
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = selectedDate;
          if (_endDate != null && _endDate!.isBefore(selectedDate)) {
            _endDate = null;
          }
        } else {
          _endDate = selectedDate;
        }
      });
    }
  }

  Future<void> _createContract() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서비스 기간을 선택해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final selectedTerms = <String>[];
    for (int i = 0; i < _terms.length; i++) {
      if (_selectedTerms[i]) {
        selectedTerms.add(_terms[i]);
      }
    }

    final result = await _contractService.createContract(
      serviceRequestId: widget.serviceRequest.id,
      freelancerId: widget.freelancer.id,
      totalAmount: double.parse(_totalAmountController.text),
      startDate: _startDate!,
      endDate: _endDate!,
      terms: selectedTerms,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      Navigator.pop(context, result['contract']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

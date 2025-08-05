import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/request.dart';
import '../../config/app_config.dart';
import '../../widgets/loading_button.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _regionController = TextEditingController();
  final _budgetController = TextEditingController();
  
  ServiceType _selectedServiceType = ServiceType.childcare;
  DateTime? _selectedDate;
  List<String> _preferredTimes = [];
  Map<String, dynamic> _conditions = {};
  bool _isLoading = false;

  final List<String> _timeSlots = [
    '09:00-12:00',
    '12:00-15:00',
    '15:00-18:00',
    '18:00-21:00',
    '21:00-24:00',
    '시간 협의',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _regionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('의뢰 등록'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          children: [
            // 서비스 유형 선택
            _buildServiceTypeSection(),
            const SizedBox(height: 24),

            // 제목
            _buildTitleSection(),
            const SizedBox(height: 24),

            // 상세 설명
            _buildDescriptionSection(),
            const SizedBox(height: 24),

            // 지역
            _buildRegionSection(),
            const SizedBox(height: 24),

            // 시작 날짜
            _buildDateSection(),
            const SizedBox(height: 24),

            // 선호 시간대
            _buildTimeSection(),
            const SizedBox(height: 24),

            // 예산
            _buildBudgetSection(),
            const SizedBox(height: 24),

            // 추가 조건
            _buildConditionsSection(),
            const SizedBox(height: 32),

            // 등록 버튼
            LoadingButton(
              onPressed: _submitRequest,
              loading: _isLoading,
              child: const Text('의뢰 등록하기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '서비스 유형',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: ServiceType.values.map((type) {
            final isSelected = _selectedServiceType == type;
            return ChoiceChip(
              label: Text(type.label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedServiceType = type;
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '제목',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: '간단하고 명확한 제목을 입력해주세요',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '제목을 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '상세 설명',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: '원하는 서비스의 구체적인 내용을 설명해주세요',
          ),
          maxLines: 5,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '상세 설명을 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRegionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '서비스 지역',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _regionController,
          decoration: const InputDecoration(
            hintText: '예) 강남구 역삼동',
            suffixIcon: Icon(Icons.location_on_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '서비스 지역을 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '시작 날짜',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('yyyy년 MM월 dd일').format(_selectedDate!)
                        : '날짜를 선택해주세요',
                    style: TextStyle(
                      color: _selectedDate != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today_outlined),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '선호 시간대',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _timeSlots.map((time) {
            final isSelected = _preferredTimes.contains(time);
            return FilterChip(
              label: Text(time),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _preferredTimes.add(time);
                  } else {
                    _preferredTimes.remove(time);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBudgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '예산 (시급)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _budgetController,
          decoration: const InputDecoration(
            hintText: '원하는 시급을 입력해주세요',
            suffixText: '원',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
      ],
    );
  }

  Widget _buildConditionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '추가 조건',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '선택한 서비스에 따른 추가 조건을 설정할 수 있습니다.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        // TODO: 서비스 유형별 추가 조건 UI 구현
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시작 날짜를 선택해주세요')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 실제 API 호출로 대체
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('의뢰가 등록되었습니다')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

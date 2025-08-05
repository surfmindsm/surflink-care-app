import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../models/request.dart';
import '../../services/request_service.dart';
import '../../widgets/custom_button.dart';

class RequestCreateScreen extends StatefulWidget {
  final ServiceRequest? existingRequest; // 수정 모드인 경우

  const RequestCreateScreen({
    super.key,
    this.existingRequest,
  });

  @override
  State<RequestCreateScreen> createState() => _RequestCreateScreenState();
}

class _RequestCreateScreenState extends State<RequestCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _specialNotesController = TextEditingController();
  final _budgetController = TextEditingController();
  final RequestService _requestService = RequestService();

  ServiceType _selectedServiceType = ServiceType.childcare;
  String _selectedRegion = '강남구';
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _endDate;
  List<String> _selectedTimes = [];
  Map<String, dynamic> _conditions = {};
  List<File> _selectedFiles = [];
  bool _isSubmitting = false;
  bool _isDraft = false;

  // 시간대 옵션
  final List<String> _timeOptions = [
    '새벽 (05:00-08:00)',
    '오전 (08:00-12:00)',
    '오후 (12:00-18:00)',
    '저녁 (18:00-22:00)',
    '야간 (22:00-05:00)',
  ];

  // 지역 옵션
  final List<String> _regionOptions = [
    '강남구', '서초구', '송파구', '강동구', '광진구', '성동구', '중구', '종로구',
    '마포구', '서대문구', '은평구', '강서구', '양천구', '구로구', '영등포구', '동작구', '관악구'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingRequest != null) {
      _initializeForEdit();
    }
  }

  void _initializeForEdit() {
    final request = widget.existingRequest!;
    _titleController.text = request.title;
    _descriptionController.text = request.description;
    _specialNotesController.text = request.specialNotes ?? '';
    _budgetController.text = request.budget?.toString() ?? '';
    _selectedServiceType = request.serviceType;
    _selectedRegion = request.region;
    _startDate = request.startDate;
    _endDate = request.endDate;
    _selectedTimes = List.from(request.preferredTimes);
    _conditions = Map.from(request.conditions);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _specialNotesController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingRequest != null ? '의뢰 수정' : '의뢰 등록'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : () => _submitRequest(isDraft: true),
            child: const Text(
              '임시저장',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildServiceTypeSection(),
              const SizedBox(height: 24),
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildLocationSection(),
              const SizedBox(height: 24),
              _buildScheduleSection(),
              const SizedBox(height: 24),
              _buildConditionsSection(),
              const SizedBox(height: 24),
              _buildBudgetSection(),
              const SizedBox(height: 24),
              _buildSpecialNotesSection(),
              const SizedBox(height: 24),
              _buildAttachmentsSection(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '서비스 종류',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: ServiceType.values.map((type) {
              return RadioListTile<ServiceType>(
                title: Text(type.displayName),
                subtitle: Text(_getServiceDescription(type)),
                value: type,
                groupValue: _selectedServiceType,
                onChanged: (value) {
                  setState(() {
                    _selectedServiceType = value!;
                    _conditions.clear(); // 서비스 타입 변경시 조건 초기화
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '기본 정보',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: '제목',
            hintText: '예: 7세 아이 돌봄 서비스 구해요',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '제목을 입력해주세요';
            }
            if (value.trim().length < 5) {
              return '제목은 최소 5자 이상 입력해주세요';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: '상세 설명',
            hintText: '서비스에 대한 자세한 내용을 작성해주세요',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '상세 설명을 입력해주세요';
            }
            if (value.trim().length < 20) {
              return '상세 설명은 최소 20자 이상 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '서비스 지역',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedRegion,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
          items: _regionOptions.map((region) {
            return DropdownMenuItem<String>(
              value: region,
              child: Text(region),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRegion = value!;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '서비스 지역을 선택해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '일정',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(isStartDate: true),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '시작일',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('yyyy.MM.dd (E)', 'ko_KR').format(_startDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(isStartDate: false),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '종료일 (선택)',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _endDate != null 
                            ? DateFormat('yyyy.MM.dd (E)', 'ko_KR').format(_endDate!)
                            : '선택 안함',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          '희망 시간대',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _timeOptions.map((time) {
            final isSelected = _selectedTimes.contains(time);
            return FilterChip(
              label: Text(time),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTimes.add(time);
                  } else {
                    _selectedTimes.remove(time);
                  }
                });
              },
              selectedColor: Colors.blue[100],
              checkmarkColor: Colors.blue[700],
            );
          }).toList(),
        ),
        if (_selectedTimes.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '적어도 1개 이상의 시간대를 선택해주세요',
            style: TextStyle(
              color: Colors.red[600],
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConditionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '희망 조건',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildServiceSpecificConditions(),
      ],
    );
  }

  Widget _buildServiceSpecificConditions() {
    switch (_selectedServiceType) {
      case ServiceType.childcare:
        return _buildChildcareConditions();
      case ServiceType.eldercare:
        return _buildEldercareConditions();
      case ServiceType.tutoring:
        return _buildTutoringConditions();
      case ServiceType.counseling:
        return _buildCounselingConditions();
    }
  }

  Widget _buildChildcareConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: '아이 나이',
            hintText: '예: 7세',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _conditions['child_age'] = value,
          initialValue: _conditions['child_age'],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _conditions['experience_level'],
          decoration: const InputDecoration(
            labelText: '경력 요구사항',
            border: OutlineInputBorder(),
          ),
          items: ['무관', '1년 이상', '3년 이상', '5년 이상'].map((level) {
            return DropdownMenuItem<String>(value: level, child: Text(level));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _conditions['experience_level'] = value;
            });
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _conditions['gender_preference'],
          decoration: const InputDecoration(
            labelText: '성별 선호',
            border: OutlineInputBorder(),
          ),
          items: ['무관', '여성', '남성'].map((gender) {
            return DropdownMenuItem<String>(value: gender, child: Text(gender));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _conditions['gender_preference'] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildEldercareConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: '돌봄 대상자 나이',
            hintText: '예: 75세',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _conditions['patient_age'] = value,
          initialValue: _conditions['patient_age'],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _conditions['care_level'],
          decoration: const InputDecoration(
            labelText: '간병 정도',
            border: OutlineInputBorder(),
          ),
          items: ['일상생활 도움', '기본 간병', '전문 간병'].map((level) {
            return DropdownMenuItem<String>(value: level, child: Text(level));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _conditions['care_level'] = value;
            });
          },
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          title: const Text('의료 지식 필요'),
          value: _conditions['medical_knowledge'] ?? false,
          onChanged: (value) {
            setState(() {
              _conditions['medical_knowledge'] = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  Widget _buildTutoringConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: '학생 학년',
            hintText: '예: 중학교 2학년',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _conditions['student_grade'] = value,
          initialValue: _conditions['student_grade'],
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: '과목',
            hintText: '예: 수학, 영어',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _conditions['subjects'] = value,
          initialValue: _conditions['subjects'],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _conditions['tutoring_type'],
          decoration: const InputDecoration(
            labelText: '수업 형태',
            border: OutlineInputBorder(),
          ),
          items: ['1:1 개별수업', '그룹수업', '온라인수업'].map((type) {
            return DropdownMenuItem<String>(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _conditions['tutoring_type'] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCounselingConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _conditions['counseling_type'],
          decoration: const InputDecoration(
            labelText: '상담 유형',
            border: OutlineInputBorder(),
          ),
          items: ['개인상담', '가족상담', '부부상담', '청소년상담'].map((type) {
            return DropdownMenuItem<String>(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _conditions['counseling_type'] = value;
            });
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _conditions['session_type'],
          decoration: const InputDecoration(
            labelText: '진행 방식',
            border: OutlineInputBorder(),
          ),
          items: ['대면상담', '온라인상담', '전화상담'].map((type) {
            return DropdownMenuItem<String>(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _conditions['session_type'] = value;
            });
          },
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          title: const Text('자격증 보유자 선호'),
          value: _conditions['certified_required'] ?? false,
          onChanged: (value) {
            setState(() {
              _conditions['certified_required'] = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  Widget _buildBudgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '예산',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _budgetController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '희망 시급 (원)',
            hintText: '예: 15000',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.attach_money),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final budget = int.tryParse(value);
              if (budget == null || budget <= 0) {
                return '올바른 금액을 입력해주세요';
              }
              if (budget < 5000) {
                return '최소 5,000원 이상 입력해주세요';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSpecialNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '특이사항',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _specialNotesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: '추가로 알려드릴 내용이 있다면 작성해주세요',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '첨부파일',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(선택)',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_selectedFiles.isNotEmpty) ...[
          ...(_selectedFiles.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_file),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      file.path.split('/').last,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _selectedFiles.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            );
          })),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: _pickFiles,
          icon: const Icon(Icons.add),
          label: const Text('파일 추가'),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Column(
      children: [
        if (_isDraft) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.drafts, color: Colors.orange[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '임시저장된 의뢰입니다. 등록하여 매칭을 시작하세요.',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: widget.existingRequest != null ? '수정 완료' : '의뢰 등록',
            onPressed: _isSubmitting ? null : () => _submitRequest(isDraft: false),
            type: ButtonType.primary,
            isLoading: _isSubmitting,
          ),
        ),
      ],
    );
  }

  String _getServiceDescription(ServiceType type) {
    switch (type) {
      case ServiceType.childcare:
        return '아이 돌봄, 육아 도움';
      case ServiceType.eldercare:
        return '어르신 간병, 생활 지원';
      case ServiceType.tutoring:
        return '학습 지도, 과외';
      case ServiceType.counseling:
        return '심리상담, 치료';
    }
  }

  Future<void> _selectDate({required bool isStartDate}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartDate 
          ? _startDate 
          : (_endDate ?? _startDate.add(const Duration(days: 1))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ko', 'KR'),
    );

    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
          // 시작일이 종료일보다 늦으면 종료일 초기화
          if (_endDate != null && _endDate!.isBefore(_startDate)) {
            _endDate = null;
          }
        } else {
          _endDate = date;
        }
      });
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        final newFiles = result.files
            .map((file) => File(file.path!))
            .where((file) => !_selectedFiles.any((f) => f.path == file.path))
            .toList();

        if (_selectedFiles.length + newFiles.length > 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('최대 5개 파일까지 첨부할 수 있습니다.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        setState(() {
          _selectedFiles.addAll(newFiles);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('파일 선택 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitRequest({required bool isDraft}) async {
    if (!isDraft && !_formKey.currentState!.validate()) {
      return;
    }

    if (!isDraft && _selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('희망 시간대를 최소 1개 이상 선택해주세요'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _isDraft = isDraft;
    });

    try {
      // TODO: 파일 업로드 구현
      final attachmentUrls = <String>[];
      
      final budget = _budgetController.text.isNotEmpty 
          ? double.tryParse(_budgetController.text)
          : null;

      final request = ServiceRequest(
        id: widget.existingRequest?.id ?? '',
        customerId: 'current_user_id',
        serviceType: _selectedServiceType,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        region: _selectedRegion,
        startDate: _startDate,
        endDate: _endDate,
        preferredTimes: _selectedTimes,
        conditions: _conditions,
        specialNotes: _specialNotesController.text.trim().isNotEmpty 
            ? _specialNotesController.text.trim() 
            : null,
        attachments: attachmentUrls,
        status: isDraft ? RequestStatus.pending : RequestStatus.pending,
        budget: budget,
        createdAt: widget.existingRequest?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      Map<String, dynamic> result;
      if (widget.existingRequest != null) {
        result = await _requestService.updateRequest(request);
      } else {
        result = await _requestService.createRequest(request);
      }

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('의뢰 ${isDraft ? '임시저장' : '등록'} 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

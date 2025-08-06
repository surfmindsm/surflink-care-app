import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/report.dart';
import '../../services/report_service.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_config.dart';

class ReportCreateScreen extends StatefulWidget {
  final ReportType? preSelectedType;
  final VoidCallback? onReportCreated;

  const ReportCreateScreen({
    super.key,
    this.preSelectedType,
    this.onReportCreated,
  });

  @override
  State<ReportCreateScreen> createState() => _ReportCreateScreenState();
}

class _ReportCreateScreenState extends State<ReportCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetNameController = TextEditingController();
  
  ReportType _selectedType = ReportType.user;
  bool _isLoading = false;
  List<String> _attachments = [];

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedType != null) {
      _selectedType = widget.preSelectedType!;
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _targetNameController.dispose();
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
        title: const Text('신고/문의하기'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitReport,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('제출'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '신고/문의 유형',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              DropdownButtonFormField<ReportType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: ReportType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Text(type.icon, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(type.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              
              const SizedBox(height: 24),
              const Text(
                '제목',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: '간단한 제목을 입력해주세요',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '제목을 입력해주세요.';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              const Text(
                '상세 내용',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '상황을 자세히 설명해주세요',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '내용을 입력해주세요.';
                  }
                  if (value.trim().length < 10) {
                    return '10자 이상 입력해주세요.';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              const Text(
                '첨부파일',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(Icons.cloud_upload, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    const Text('사진이나 스크린샷을 첨부해주세요'),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _addAttachment,
                      icon: const Icon(Icons.add),
                      label: const Text('파일 추가'),
                    ),
                  ],
                ),
              ),
              
              if (_attachments.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _attachments.map((attachment) {
                    return Chip(
                      label: Text(attachment),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _attachments.remove(attachment);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '신고 처리 안내',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 접수된 신고는 24시간 내에 검토됩니다.\n'
                      '• 허위 신고는 제재 대상이 될 수 있습니다.\n'
                      '• 긴급한 경우 전화 상담을 이용해주세요.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addAttachment() {
    final fileName = 'attachment_${_attachments.length + 1}.jpg';
    setState(() {
      _attachments.add(fileName);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$fileName 파일이 추가되었습니다.')),
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id ?? 'user_002';

      final request = ReportCreateRequest(
        type: _selectedType,
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        attachments: _attachments,
      );

      await ReportService().createReport(
        reporterId: userId,
        request: request,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onReportCreated?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('신고가 접수되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('신고 접수에 실패했습니다: $e')),
        );
      }
    }
  }
}

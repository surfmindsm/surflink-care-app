import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../models/certification.dart';
import '../../services/certification_service.dart';
import '../../widgets/custom_button.dart';

class CertificationUploadScreen extends StatefulWidget {
  final Certification? existingCertification;

  const CertificationUploadScreen({
    super.key,
    this.existingCertification,
  });

  @override
  State<CertificationUploadScreen> createState() => _CertificationUploadScreenState();
}

class _CertificationUploadScreenState extends State<CertificationUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _issuerController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final CertificationService _certificationService = CertificationService();

  CertificationType _selectedType = CertificationType.license;
  DateTime? _issueDate;
  DateTime? _expiryDate;
  List<File> _selectedFiles = [];
  List<String> _uploadedFileUrls = [];
  bool _isLoading = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingCertification != null) {
      _loadExistingData();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _issuerController.dispose();
    _licenseNumberController.dispose();
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
        title: Text(widget.existingCertification != null ? '인증서류 수정' : '인증서류 등록'),
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
              _buildTypeSelection(),
              const SizedBox(height: 24),
              _buildBasicInfo(),
              const SizedBox(height: 24),
              _buildIssuerInfo(),
              const SizedBox(height: 24),
              _buildDateSelection(),
              const SizedBox(height: 24),
              _buildFileUpload(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '인증서류 유형',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CertificationType.values.map((type) {
                final isSelected = _selectedType == type;
                return FilterChip(
                  label: Text(type.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                  selectedColor: Colors.blue[100],
                  checkmarkColor: Colors.blue[700],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '기본 정보',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목 *',
                hintText: '예: 보육교사 2급 자격증',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '제목을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '설명',
                hintText: '인증서류에 대한 상세 설명을 입력해주세요',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssuerInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '발급 정보',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _issuerController,
              decoration: const InputDecoration(
                labelText: '발급기관',
                hintText: '예: 한국보육진흥원',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _licenseNumberController,
              decoration: const InputDecoration(
                labelText: '자격증/수료증 번호',
                hintText: '번호가 있는 경우 입력해주세요',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '유효 기간',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
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
                          const Text('발급일', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(_issueDate != null 
                            ? DateFormat('yyyy.MM.dd').format(_issueDate!)
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
                          const Text('만료일 (선택)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(_expiryDate != null 
                            ? DateFormat('yyyy.MM.dd').format(_expiryDate!)
                            : '날짜 선택'),
                        ],
                      ),
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

  Widget _buildFileUpload() {
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
                  '파일 첨부',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _isUploading ? null : _pickFiles,
                  icon: const Icon(Icons.add),
                  label: const Text('파일 선택'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• 지원 형식: PDF, JPG, PNG, DOC, DOCX\n'
                    '• 최대 파일 크기: 10MB\n'
                    '• 최대 5개 파일까지 업로드 가능',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedFiles.isNotEmpty || _uploadedFileUrls.isNotEmpty) ...[
              const Text('선택된 파일:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
            ],
            ..._selectedFiles.map((file) => _buildFileItem(
              fileName: file.path.split('/').last,
              fileSize: null,
              isUploaded: false,
              onRemove: () => _removeFile(file),
            )),
            ..._uploadedFileUrls.map((url) => _buildFileItem(
              fileName: url.split('/').last,
              fileSize: null,
              isUploaded: true,
              onRemove: () => _removeUploadedFile(url),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem({
    required String fileName,
    int? fileSize,
    required bool isUploaded,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: isUploaded ? Colors.green[50] : Colors.blue[50],
      ),
      child: Row(
        children: [
          Icon(
            isUploaded ? Icons.check_circle : Icons.upload_file,
            color: isUploaded ? Colors.green : Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (fileSize != null)
                  Text(
                    _formatFileSize(fileSize),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            color: Colors.red,
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: widget.existingCertification != null ? '수정' : '등록',
            onPressed: _isLoading || _isUploading ? null : _submitCertification,
            isLoading: _isLoading,
            type: ButtonType.primary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: '취소',
            onPressed: _isLoading || _isUploading ? null : () => Navigator.pop(context),
            type: ButtonType.secondary,
          ),
        ),
      ],
    );
  }

  void _loadExistingData() {
    final cert = widget.existingCertification!;
    _titleController.text = cert.title;
    _descriptionController.text = cert.description;
    _issuerController.text = cert.issuer ?? '';
    _licenseNumberController.text = cert.licenseNumber ?? '';
    _selectedType = cert.type;
    _issueDate = cert.issueDate;
    _expiryDate = cert.expiryDate;
    _uploadedFileUrls = List.from(cert.fileUrls);
  }

  Future<void> _selectDate(bool isIssueDate) async {
    final initialDate = isIssueDate 
        ? (_issueDate ?? DateTime.now())
        : (_expiryDate ?? DateTime.now().add(const Duration(days: 365)));
    
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );

    if (selectedDate != null) {
      setState(() {
        if (isIssueDate) {
          _issueDate = selectedDate;
        } else {
          _expiryDate = selectedDate;
        }
      });
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: true,
      );

      if (result != null) {
        final totalFiles = _selectedFiles.length + _uploadedFileUrls.length + result.files.length;
        if (totalFiles > 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('최대 5개 파일까지만 선택할 수 있습니다')),
          );
          return;
        }

        setState(() {
          _selectedFiles.addAll(
            result.paths.where((path) => path != null).map((path) => File(path!))
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('파일 선택 중 오류가 발생했습니다: $e')),
      );
    }
  }

  void _removeFile(File file) {
    setState(() {
      _selectedFiles.remove(file);
    });
  }

  void _removeUploadedFile(String url) {
    setState(() {
      _uploadedFileUrls.remove(url);
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  Future<void> _submitCertification() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFiles.isEmpty && _uploadedFileUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('파일을 선택해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 새로 선택된 파일들 업로드
      if (_selectedFiles.isNotEmpty) {
        setState(() => _isUploading = true);
        
        final uploadResults = await _certificationService.uploadMultipleFiles(_selectedFiles);
        
        for (final result in uploadResults) {
          if (result.success) {
            _uploadedFileUrls.add(result.fileUrl!);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('파일 업로드 실패: ${result.error}')),
            );
          }
        }
        
        setState(() => _isUploading = false);
      }

      // 인증서류 등록/수정
      Map<String, dynamic> result;
      if (widget.existingCertification != null) {
        result = await _certificationService.updateCertification(
          certificationId: widget.existingCertification!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          type: _selectedType,
          fileUrls: _uploadedFileUrls,
          issuer: _issuerController.text.trim().isNotEmpty ? _issuerController.text.trim() : null,
          issueDate: _issueDate,
          expiryDate: _expiryDate,
          licenseNumber: _licenseNumberController.text.trim().isNotEmpty ? _licenseNumberController.text.trim() : null,
        );
      } else {
        result = await _certificationService.createCertification(
          freelancerId: 'current_freelancer', // TODO: 실제 프리랜서 ID
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          type: _selectedType,
          fileUrls: _uploadedFileUrls,
          issuer: _issuerController.text.trim().isNotEmpty ? _issuerController.text.trim() : null,
          issueDate: _issueDate,
          expiryDate: _expiryDate,
          licenseNumber: _licenseNumberController.text.trim().isNotEmpty ? _licenseNumberController.text.trim() : null,
        );
      }

      setState(() => _isLoading = false);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('처리 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

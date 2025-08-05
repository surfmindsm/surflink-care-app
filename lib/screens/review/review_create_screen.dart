import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/review.dart';
import '../../models/contract.dart';
import '../../services/review_service.dart';
import '../../widgets/custom_button.dart';

class ReviewCreateScreen extends StatefulWidget {
  final String contractId;
  final ReviewType reviewType;
  final String revieweeId;
  final String revieweeName;
  final String? contractTitle;
  final Review? existingReview; // 수정 모드인 경우

  const ReviewCreateScreen({
    super.key,
    required this.contractId,
    required this.reviewType,
    required this.revieweeId,
    required this.revieweeName,
    this.contractTitle,
    this.existingReview,
  });

  @override
  State<ReviewCreateScreen> createState() => _ReviewCreateScreenState();
}

class _ReviewCreateScreenState extends State<ReviewCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final ReviewService _reviewService = ReviewService();
  final ImagePicker _imagePicker = ImagePicker();

  double _rating = 5.0;
  List<String> _selectedTags = [];
  List<File> _selectedImages = [];
  List<String> _uploadedImageUrls = [];
  bool _isAnonymous = false;
  bool _isSubmitting = false;

  // 리뷰 태그 옵션
  final List<String> _clientReviewTags = [
    '친절해요',
    '전문적이에요',
    '꼼꼼해요',
    '시간약속 잘 지켜요',
    '소통이 원활해요',
    '아이를 좋아해요',
    '경험이 많아요',
    '책임감이 강해요',
    '재이용 하고싶어요',
    '추천해요',
  ];

  final List<String> _freelancerReviewTags = [
    '소통 원활해요',
    '배려해주세요',
    '좋은 환경',
    '명확한 요청',
    '시간 준수',
    '합리적 요청',
    '이해심 많아요',
    '감사 표현 잘해요',
    '다시 일하고 싶어요',
    '추천해요',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _initializeForEdit();
    }
  }

  void _initializeForEdit() {
    final review = widget.existingReview!;
    _titleController.text = review.title;
    _contentController.text = review.content;
    _rating = review.rating;
    _selectedTags = List.from(review.tags);
    _uploadedImageUrls = review.imageUrls ?? [];
    _isAnonymous = review.isAnonymous;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingReview != null ? '리뷰 수정' : '리뷰 작성'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContractInfo(),
              const SizedBox(height: 24),
              _buildRatingSection(),
              const SizedBox(height: 24),
              _buildTitleSection(),
              const SizedBox(height: 24),
              _buildContentSection(),
              const SizedBox(height: 24),
              _buildTagsSection(),
              const SizedBox(height: 24),
              _buildImagesSection(),
              const SizedBox(height: 24),
              _buildAnonymousOption(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 16),
            ],
          ),
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
            Row(
              children: [
                Icon(
                  widget.reviewType == ReviewType.client
                      ? Icons.person_outline
                      : Icons.work_outline,
                  color: Colors.blue[700],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.reviewType == ReviewType.client
                        ? '${widget.revieweeName}님에 대한 리뷰'
                        : '${widget.revieweeName}님과의 거래에 대한 리뷰',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (widget.contractTitle != null) ...[
              const SizedBox(height: 8),
              Text(
                '서비스: ${widget.contractTitle}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '전체적인 만족도',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Column(
            children: [
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 40,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              const SizedBox(height: 8),
              Text(
                _getRatingText(_rating),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _getRatingColor(_rating),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '리뷰 제목',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          maxLength: 50,
          decoration: const InputDecoration(
            hintText: '리뷰 제목을 입력해주세요',
            border: OutlineInputBorder(),
            counterText: '',
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
      ],
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '상세 리뷰',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _contentController,
          maxLines: 6,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: '서비스에 대한 자세한 후기를 작성해주세요',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '리뷰 내용을 입력해주세요';
            }
            if (value.trim().length < 10) {
              return '리뷰는 최소 10자 이상 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    final availableTags = widget.reviewType == ReviewType.client
        ? _clientReviewTags
        : _freelancerReviewTags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '태그 선택 (최대 5개)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    if (_selectedTags.length < 5) {
                      _selectedTags.add(tag);
                    }
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
              selectedColor: Colors.blue[100],
              checkmarkColor: Colors.blue[700],
            );
          }).toList(),
        ),
        if (_selectedTags.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '적어도 1개 이상의 태그를 선택해주세요',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '사진 첨부',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(선택, 최대 3장)',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ..._buildUploadedImages(),
              ..._buildSelectedImages(),
              if (_selectedImages.length + _uploadedImageUrls.length < 3)
                _buildAddImageButton(),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildUploadedImages() {
    return _uploadedImageUrls.map((url) => Container(
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                );
              },
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _uploadedImageUrls.remove(url);
                });
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  List<Widget> _buildSelectedImages() {
    return _selectedImages.map((image) => Container(
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedImages.remove(image);
                });
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, color: Colors.grey[600]),
            const SizedBox(height: 4),
            Text(
              '사진 추가',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnonymousOption() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _isAnonymous ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '익명 리뷰',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '내 이름 대신 "익명"으로 표시됩니다',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isAnonymous,
              onChanged: (value) {
                setState(() {
                  _isAnonymous = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: widget.existingReview != null ? '리뷰 수정' : '리뷰 등록',
        onPressed: _isSubmitting ? null : _submitReview,
        type: ButtonType.primary,
        isLoading: _isSubmitting,
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 4.5) return '매우 만족';
    if (rating >= 3.5) return '만족';
    if (rating >= 2.5) return '보통';
    if (rating >= 1.5) return '불만족';
    return '매우 불만족';
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 3.5) return Colors.blue;
    if (rating >= 2.5) return Colors.orange;
    return Colors.red;
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 선택 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('적어도 1개 이상의 태그를 선택해주세요'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 새 이미지가 있다면 업로드
      List<String> allImageUrls = List.from(_uploadedImageUrls);
      if (_selectedImages.isNotEmpty) {
        final uploadResult = await _reviewService.uploadReviewImages(_selectedImages);
        if (uploadResult['success']) {
          allImageUrls.addAll(List<String>.from(uploadResult['urls']));
        } else {
          throw Exception(uploadResult['message']);
        }
      }

      final request = ReviewCreateRequest(
        contractId: widget.contractId,
        revieweeId: widget.revieweeId,
        type: widget.reviewType,
        rating: _rating,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        tags: _selectedTags,
        imageUrls: allImageUrls.isNotEmpty ? allImageUrls : null,
        isAnonymous: _isAnonymous,
      );

      Map<String, dynamic> result;
      if (widget.existingReview != null) {
        result = await _reviewService.updateReview(widget.existingReview!.id, request);
      } else {
        result = await _reviewService.createReview(request);
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
          content: Text('리뷰 ${widget.existingReview != null ? '수정' : '등록'} 중 오류가 발생했습니다: $e'),
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

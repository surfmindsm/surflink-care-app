import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/request.dart';
import '../../models/matching.dart';
import '../../models/user.dart';
import '../../services/matching_service.dart';
import '../../widgets/custom_button.dart';

class MatchingRequestScreen extends StatefulWidget {
  final ServiceRequest request;

  const MatchingRequestScreen({
    super.key,
    required this.request,
  });

  @override
  State<MatchingRequestScreen> createState() => _MatchingRequestScreenState();
}

class _MatchingRequestScreenState extends State<MatchingRequestScreen> {
  final MatchingService _matchingService = MatchingService();
  final _messageController = TextEditingController();
  
  List<User> _recommendedFreelancers = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  User? _selectedFreelancer;

  @override
  void initState() {
    super.initState();
    _loadRecommendedFreelancers();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendedFreelancers() async {
    try {
      final freelancers = await _matchingService.getRecommendedFreelancers(
        widget.request.id,
        limit: 10,
      );

      setState(() {
        _recommendedFreelancers = freelancers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('추천 프리랜서 로딩 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('매칭 요청'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRequestSummary(),
                  const SizedBox(height: 24),
                  _buildRecommendedFreelancers(),
                  const SizedBox(height: 24),
                  _buildMessageSection(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildRequestSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment,
                  color: Colors.blue[700],
                ),
                const SizedBox(width: 8),
                const Text(
                  '의뢰 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.request.serviceType.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.request.serviceType.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (widget.request.budget != null)
                        Text(
                          '${NumberFormat('#,###').format(widget.request.budget)}원',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.request.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.request.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        widget.request.region,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.schedule, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MM/dd').format(widget.request.startDate),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
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

  Widget _buildRecommendedFreelancers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.people_outline,
              color: Colors.blue[700],
            ),
            const SizedBox(width: 8),
            const Text(
              '추천 프리랜서',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_recommendedFreelancers.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.person_search,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  '추천 프리랜서가 없습니다',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '조건을 변경하거나 나중에 다시 시도해보세요',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          ...(_recommendedFreelancers.map((freelancer) {
            return _FreelancerCard(
              freelancer: freelancer,
              isSelected: _selectedFreelancer?.id == freelancer.id,
              onTap: () {
                setState(() {
                  _selectedFreelancer = freelancer;
                });
              },
            );
          })),
      ],
    );
  }

  Widget _buildMessageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.message_outlined,
              color: Colors.blue[700],
            ),
            const SizedBox(width: 8),
            const Text(
              '매칭 요청 메시지',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _messageController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: '프리랜서에게 전달할 메시지를 작성해주세요.\n예: 안녕하세요! 제 의뢰에 관심을 가져주셔서 감사합니다. 자세한 상담을 위해 연락드리고 싶습니다.',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '매칭 요청이 승인되면 1:1 채팅방이 생성되어 자세한 내용을 논의할 수 있습니다.',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Column(
      children: [
        if (_selectedFreelancer != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    _selectedFreelancer!.name.substring(0, 1),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${_selectedFreelancer!.name}님에게 매칭 요청을 보냅니다',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
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
            text: '매칭 요청',
            onPressed: _selectedFreelancer != null && !_isSubmitting 
                ? _submitMatchingRequest
                : null,
            type: ButtonType.primary,
            isLoading: _isSubmitting,
          ),
        ),
      ],
    );
  }

  Future<void> _submitMatchingRequest() async {
    if (_selectedFreelancer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('프리랜서를 선택해주세요'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final request = MatchingCreateRequest(
        requestId: widget.request.id,
        freelancerId: _selectedFreelancer!.id,
        type: MatchingType.manual,
        message: _messageController.text.trim().isNotEmpty 
            ? _messageController.text.trim()
            : null,
      );

      final result = await _matchingService.createMatchingRequest(request);

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
          content: Text('매칭 요청 중 오류가 발생했습니다: $e'),
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

class _FreelancerCard extends StatelessWidget {
  final User freelancer;
  final bool isSelected;
  final VoidCallback onTap;

  const _FreelancerCard({
    required this.freelancer,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isSelected 
                ? Border.all(color: Colors.blue, width: 2)
                : null,
            color: isSelected 
                ? Colors.blue.withOpacity(0.05)
                : null,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blue[100],
                backgroundImage: freelancer.profileImageUrl != null
                    ? NetworkImage(freelancer.profileImageUrl!)
                    : null,
                child: freelancer.profileImageUrl == null
                    ? Text(
                        freelancer.name.substring(0, 1),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          freelancer.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (freelancer.isVerified) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: Colors.blue[600],
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '4.5',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '리뷰 32개',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateTime.now().year - freelancer.createdAt.year + 1}년 경력 • 완료 건수 28건',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Colors.blue[600],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ServiceType 색상 확장 (request_list_screen에서 중복)
extension ServiceTypeColorExtension on ServiceType {
  Color get color {
    switch (this) {
      case ServiceType.childcare:
        return Colors.pink;
      case ServiceType.eldercare:
        return Colors.purple;
      case ServiceType.tutoring:
        return Colors.indigo;
      case ServiceType.counseling:
        return Colors.teal;
    }
  }
}

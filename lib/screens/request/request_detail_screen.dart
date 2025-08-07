import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../models/request.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_config.dart';
import '../../widgets/loading_button.dart';
import '../../utils/navigation_utils.dart';

class RequestDetailScreen extends StatefulWidget {
  final String requestId;

  const RequestDetailScreen({
    super.key,
    required this.requestId,
  });

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  ServiceRequest? _request;
  User? _customer;
  bool _isLoading = true;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _loadRequestDetail();
  }

  void _loadRequestDetail() {
    // TODO: 실제 API 호출로 대체
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _request = _getSampleRequest();
        _customer = _getSampleCustomer();
        _isLoading = false;
      });
    });
  }

  ServiceRequest _getSampleRequest() {
    return ServiceRequest(
      id: widget.requestId,
      customerId: 'customer1',
      serviceType: ServiceType.childcare,
      title: '7세 아이 돌봄 부탁드려요',
      description: '평일 오후 2시~6시까지 아이 돌봄을 부탁드립니다. 아이는 활발하고 밝은 성격이며, 간단한 간식 준비와 숙제 도움이 필요합니다.',
      region: '강남구 역삼동',
      startDate: DateTime.now().add(const Duration(days: 1)),
      preferredTimes: ['14:00-18:00'],
      conditions: {'age': 7, 'gender': 'any'},
      attachments: [],
      status: RequestStatus.pending,
      budget: 15000,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    );
  }

  User _getSampleCustomer() {
    return User(
      id: 'customer1',
      email: 'customer@example.com',
      name: '김고객',
      phone: '010-1234-5678',
      userType: UserType.customer,
      status: UserStatus.active,
      profileImageUrl: null,
      region: '강남구',
      rating: 4.8,
      reviewCount: 25,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_request == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('의뢰 상세')),
        body: const Center(
          child: Text('의뢰를 찾을 수 없습니다'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: NavigationUtils.buildBackButton(context),
        title: const Text('의뢰 상세'),
        actions: [
          if (user?.id == _request!.customerId)
            PopupMenuButton<String>(
              onSelected: _handleMenuSelection,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('수정'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('삭제'),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConfig.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(),
                  const SizedBox(height: 16),
                  _buildBasicInfo(),
                  const SizedBox(height: 16),
                  _buildDescription(),
                  const SizedBox(height: 16),
                  _buildConditions(),
                  const SizedBox(height: 16),
                  _buildCustomerInfo(),
                ],
              ),
            ),
          ),
          if (user?.isFreelancer == true && _request!.status == RequestStatus.pending)
            _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    switch (_request!.status) {
      case RequestStatus.draft:
        statusColor = Colors.grey;
        break;
      case RequestStatus.waiting:
        statusColor = Colors.orange;
        break;
      case RequestStatus.matching:
        statusColor = Colors.orange;
        break;
      case RequestStatus.pending:
        statusColor = Colors.orange;
        break;
      case RequestStatus.matched:
        statusColor = Colors.blue;
        break;
      case RequestStatus.in_progress:
        statusColor = Colors.purple;
        break;
      case RequestStatus.completed:
        statusColor = Colors.green;
        break;
      case RequestStatus.cancelled:
        statusColor = Colors.red;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _request!.status.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
            const Spacer(),
            if (_request!.budget != null)
              Text(
                '시급 ${NumberFormat('#,###').format(_request!.budget)}원',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
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
            Row(
              children: [
                _buildServiceTypeChip(),
                const Spacer(),
                Text(
                  _getTimeAgo(_request!.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _request!.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _request!.region,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('yyyy년 MM월 dd일').format(_request!.startDate)} 시작',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (_request!.preferredTimes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _request!.preferredTimes.join(', '),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
            Text(
              _request!.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditions() {
    if (_request!.conditions.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
            ..._request!.conditions.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(
                      '${entry.key}: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${entry.value}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    if (_customer == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '의뢰자 정보',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: _customer!.profileImage != null
                      ? NetworkImage(_customer!.profileImage!)
                      : null,
                  child: _customer!.profileImage == null
                      ? Text(_customer!.name[0])
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _customer!.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_customer!.rating} (${_customer!.reviewCount})',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showContactDialog(),
              child: const Text('문의하기'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LoadingButton(
              onPressed: _applyForRequest,
              loading: _isApplying,
              child: const Text('지원하기'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTypeChip() {
    Color color;
    switch (_request!.serviceType) {
      case ServiceType.childcare:
        color = Colors.pink;
        break;
      case ServiceType.eldercare:
        color = Colors.orange;
        break;
      case ServiceType.tutoring:
        color = Colors.blue;
        break;
      case ServiceType.counseling:
        color = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _request!.serviceType.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return DateFormat('MM/dd').format(dateTime);
    }
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('문의하기'),
        content: const Text('의뢰자에게 메시지를 보내시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 채팅 화면으로 이동
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('채팅 기능은 준비 중입니다')),
              );
            },
            child: const Text('문의하기'),
          ),
        ],
      ),
    );
  }

  Future<void> _applyForRequest() async {
    setState(() {
      _isApplying = true;
    });

    try {
      // TODO: 실제 API 호출로 대체
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('지원이 완료되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('지원 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
      }
    }
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'edit':
        // TODO: 수정 화면으로 이동
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수정 기능은 준비 중입니다')),
        );
        break;
      case 'delete':
        _showDeleteDialog();
        break;
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('의뢰 삭제'),
        content: const Text('정말로 이 의뢰를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 삭제 API 호출
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('의뢰가 삭제되었습니다')),
              );
              context.pop();
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

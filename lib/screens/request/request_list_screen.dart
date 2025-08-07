import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/request.dart';
import '../../services/request_service.dart';
import '../../widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import 'request_create_screen.dart';

class RequestListScreen extends StatefulWidget {
  const RequestListScreen({super.key});

  @override
  State<RequestListScreen> createState() => _RequestListScreenState();
}

class _RequestListScreenState extends State<RequestListScreen> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  final RequestService _requestService = RequestService();
  
  List<ServiceRequest> _requests = [];
  Map<String, int> _stats = {};
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final futures = await Future.wait([
        _requestService.getMyRequests(),
        _requestService.getRequestStats(),
      ]);

      setState(() {
        _requests = futures[0] as List<ServiceRequest>;
        _stats = futures[1] as Map<String, int>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('데이터 로딩 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    
    await _loadData();
    
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final isFreelancer = user?.isFreelancer == true;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(isFreelancer ? '일거리 찾기' : '내 의뢰'),
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: isFreelancer ? [
                Tab(text: '전체 (${_stats['total'] ?? 0})'),
                Tab(text: '지원가능 (${_stats['available'] ?? 0})'),
                Tab(text: '지원함 (${_stats['applied'] ?? 0})'),
                Tab(text: '매칭완료 (${_stats['matched'] ?? 0})'),
                Tab(text: '진행중 (${_stats['in_progress'] ?? 0})'),
                Tab(text: '완료 (${_stats['completed'] ?? 0})'),
              ] : [
                Tab(text: '전체 (${_stats['total'] ?? 0})'),
                Tab(text: '임시저장 (${_stats['draft'] ?? 0})'),
                Tab(text: '매칭중 (${_stats['pending'] ?? 0})'),
                Tab(text: '매칭완료 (${_stats['matched'] ?? 0})'),
                Tab(text: '진행중 (${_stats['in_progress'] ?? 0})'),
                Tab(text: '완료 (${_stats['completed'] ?? 0})'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _isRefreshing ? null : _refreshData,
              ),
            ],
          ),
          body: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  child: TabBarView(
                    controller: _tabController,
                    children: isFreelancer ? [
                      _buildRequestList(null, isFreelancer), // 전체
                      _buildAvailableRequestsList(), // 지원 가능한 의뢰
                      _buildAppliedRequestsList(), // 지원한 의뢰
                      _buildRequestList(RequestStatus.matched, isFreelancer),
                      _buildRequestList(RequestStatus.in_progress, isFreelancer),
                      _buildRequestList(RequestStatus.completed, isFreelancer),
                    ] : [
                      _buildRequestList(null, isFreelancer), // 전체
                      _buildRequestList(RequestStatus.draft, isFreelancer),
                      _buildRequestList(RequestStatus.pending, isFreelancer),
                      _buildRequestList(RequestStatus.matched, isFreelancer),
                      _buildRequestList(RequestStatus.in_progress, isFreelancer),
                      _buildRequestList(RequestStatus.completed, isFreelancer),
                    ],
                  ),
                ),
          floatingActionButton: isFreelancer ? null : FloatingActionButton.extended(
            onPressed: () => _navigateToCreateRequest(),
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('의뢰 등록'),
          ),
        );
      },
    );
  }

  Widget _buildRequestList(RequestStatus? status, bool isFreelancer) {
    final filteredRequests = status == null 
        ? _requests
        : _requests.where((r) => r.status == status).toList();

    if (filteredRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFreelancer ? Icons.work_outline : Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isFreelancer 
                  ? (status == null ? '아직 의뢰가 없습니다' : '해당 상태의 의뢰가 없습니다')
                  : (status == null ? '등록한 의뢰가 없습니다' : '해당 상태의 의뢰가 없습니다'),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (!isFreelancer) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _navigateToCreateRequest(),
                child: const Text('첫 의뢰 등록하기'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRequests.length,
      itemBuilder: (context, index) {
        final request = filteredRequests[index];
        return _RequestCard(
          request: request,
          isFreelancer: isFreelancer,
          onTap: () => _navigateToRequestDetail(request),
          onEdit: !isFreelancer ? () => _navigateToEditRequest(request) : null,
          onDelete: !isFreelancer ? () => _showDeleteDialog(request) : null,
          onApply: isFreelancer ? () => _applyToRequest(request) : null,
        );
      },
    );
  }

  Widget _buildAvailableRequestsList() {
    // 프리랜서가 지원 가능한 의뢰 목록
    final availableRequests = _requests
        .where((r) => r.status == RequestStatus.pending)
        .toList();

    return _buildRequestList(RequestStatus.pending, true);
  }

  Widget _buildAppliedRequestsList() {
    // 프리랜서가 지원한 의뢰 목록 (임시 구현)
    final appliedRequests = _requests
        .where((r) => r.status == RequestStatus.matched || r.status == RequestStatus.in_progress)
        .toList();

    if (appliedRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text('지원한 의뢰가 없습니다'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appliedRequests.length,
      itemBuilder: (context, index) {
        final request = appliedRequests[index];
        return _RequestCard(
          request: request,
          isFreelancer: true,
          onTap: () => _navigateToRequestDetail(request),
        );
      },
    );
  }

  void _navigateToCreateRequest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RequestCreateScreen(),
      ),
    ).then((result) {
      if (result == true) {
        _loadData(); // 의뢰 생성 후 목록 새로고침
      }
    });
  }

  void _navigateToEditRequest(ServiceRequest request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestCreateScreen(existingRequest: request),
      ),
    ).then((result) {
      if (result == true) {
        _loadData(); // 의뢰 수정 후 목록 새로고침
      }
    });
  }

  void _navigateToRequestDetail(ServiceRequest request) {
    // context.go('/requests/${request.id}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('의뢰 상세 페이지로 이동')),
    );
  }

  void _applyToRequest(ServiceRequest request) {
    // 프리랜서가 의뢰에 지원하는 기능
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('의뢰 지원'),
        content: Text('${request.title}에 지원하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('의뢰에 지원했습니다')),
              );
            },
            child: const Text('지원하기'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(ServiceRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('의뢰 삭제'),
        content: Text('${request.title}을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteRequest(request);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRequest(ServiceRequest request) async {
    try {
      await _requestService.deleteRequest(request.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('의뢰가 삭제되었습니다')),
      );
      _loadData(); // 목록 새로고침
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('삭제 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _RequestCard extends StatelessWidget {
  final ServiceRequest request;
  final bool isFreelancer;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onApply;

  const _RequestCard({
    required this.request,
    required this.isFreelancer,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: request.serviceType.color.withOpacity(0.1),
                      border: Border.all(color: request.serviceType.color),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      request.serviceType.displayName,
                      style: TextStyle(
                        color: request.serviceType.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: request.status.color.withOpacity(0.1),
                      border: Border.all(color: request.status.color),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      request.status.displayName,
                      style: TextStyle(
                        color: request.status.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                request.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                request.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    request.region,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MM/dd').format(request.startDate),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  if (request.budget != null) ...[
                    const Spacer(),
                    Text(
                      '${NumberFormat('#,###').format(request.budget)}원',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ],
              ),
              // 액션 버튼들 (역할에 따라 다름)
              if (isFreelancer) ...[
                if (request.status == RequestStatus.pending && onApply != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onApply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('지원하기'),
                    ),
                  ),
                ],
              ] else ...[
                if (request.status == RequestStatus.draft ||
                    request.status == RequestStatus.pending) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onDelete != null) 
                        TextButton(
                          onPressed: onDelete,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('삭제'),
                        ),
                      const SizedBox(width: 8),
                      if (onEdit != null)
                        TextButton(
                          onPressed: onEdit,
                          child: const Text('수정'),
                        ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ServiceType 색상 확장
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

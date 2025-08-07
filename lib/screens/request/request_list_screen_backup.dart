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
              tabs: [
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
                    children: [
                      _buildRequestList(null), // 전체
                      _buildRequestList(RequestStatus.draft),
                      _buildRequestList(RequestStatus.pending),
                      _buildRequestList(RequestStatus.matched),
                      _buildRequestList(RequestStatus.in_progress),
                      _buildRequestList(RequestStatus.completed),
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
  }

  Widget _buildRequestList(RequestStatus? status) {
    final filteredRequests = status == null 
        ? _requests
        : _requests.where((r) => r.status == status).toList();

    if (filteredRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              status == null ? '등록된 의뢰가 없습니다' : '${status.displayName} 의뢰가 없습니다',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              status == RequestStatus.draft 
                  ? '의뢰를 임시저장하여 나중에 완성할 수 있습니다'
                  : '새로운 의뢰를 등록해보세요',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            if (status == null || status == RequestStatus.draft) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: '의뢰 등록',
                onPressed: () => _navigateToCreateRequest(),
                type: ButtonType.primary,
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
          onTap: () => _navigateToRequestDetail(request),
          onEdit: () => _navigateToEditRequest(request),
          onDelete: () => _showDeleteDialog(request),
        );
      },
    );
  }

  void _navigateToCreateRequest() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const RequestCreateScreen(),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  void _navigateToEditRequest(ServiceRequest request) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => RequestCreateScreen(existingRequest: request),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  void _navigateToRequestDetail(ServiceRequest request) {
    // TODO: RequestDetailScreen으로 이동
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('의뢰 상세 화면으로 이동 (구현 예정)')),
    );
  }

  void _showDeleteDialog(ServiceRequest request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('의뢰 삭제'),
          content: const Text('정말로 이 의뢰를 삭제하시겠습니까?\n삭제된 의뢰는 복구할 수 없습니다.'),
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
        );
      },
    );
  }

  Future<void> _deleteRequest(ServiceRequest request) async {
    try {
      final result = await _requestService.deleteRequest(request.id);
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('의뢰 삭제 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _RequestCard extends StatelessWidget {
  final ServiceRequest request;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RequestCard({
    required this.request,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
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
                      color: request.serviceType.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      request.serviceType.displayName,
                      style: const TextStyle(
                        color: Colors.white,
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
              if (request.status == RequestStatus.draft ||
                  request.status == RequestStatus.pending) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: onDelete,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('삭제'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: onEdit,
                      child: const Text('수정'),
                    ),
                  ],
                ),
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

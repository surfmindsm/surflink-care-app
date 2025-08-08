import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/request.dart';
import '../../services/request_service.dart';
import '../../providers/auth_provider.dart';
import 'request_create_screen.dart';
import '../../components/index.dart' as ui;

class RequestListScreen extends StatefulWidget {
  const RequestListScreen({super.key});

  @override
  State<RequestListScreen> createState() => _RequestListScreenState();
}

class _RequestListScreenState extends State<RequestListScreen> {
  final RequestService _requestService = RequestService();
  
  List<ServiceRequest> _requests = [];
  Map<String, int> _stats = {};
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
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
      ui.AppToast.error(
        context,
        '데이터 로딩 중 오류가 발생했습니다: $e',
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
            actions: [
              ui.IconButton(
                icon: Icons.refresh,
                onPressed: _isRefreshing ? null : _refreshData,
                variant: ui.ButtonVariant.ghost,
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ui.AppTabs(
                      variant: ui.TabsVariant.pills,
                      scrollable: true,
                      tabs: isFreelancer
                          ? [
                              ui.AppTab(
                                label: '전체 (${_stats['total'] ?? 0})',
                                content: _buildRequestList(null, true),
                              ),
                              ui.AppTab(
                                label: '지원가능 (${_stats['available'] ?? 0})',
                                content: _buildAvailableRequestsList(),
                              ),
                              ui.AppTab(
                                label: '지원함 (${_stats['applied'] ?? 0})',
                                content: _buildAppliedRequestsList(),
                              ),
                              ui.AppTab(
                                label: '매칭완료 (${_stats['matched'] ?? 0})',
                                content: _buildRequestList(RequestStatus.matched, true),
                              ),
                              ui.AppTab(
                                label: '진행중 (${_stats['in_progress'] ?? 0})',
                                content: _buildRequestList(RequestStatus.in_progress, true),
                              ),
                              ui.AppTab(
                                label: '완료 (${_stats['completed'] ?? 0})',
                                content: _buildRequestList(RequestStatus.completed, true),
                              ),
                            ]
                          : [
                              ui.AppTab(
                                label: '전체 (${_stats['total'] ?? 0})',
                                content: _buildRequestList(null, false),
                              ),
                              ui.AppTab(
                                label: '임시저장 (${_stats['draft'] ?? 0})',
                                content: _buildRequestList(RequestStatus.draft, false),
                              ),
                              ui.AppTab(
                                label: '매칭중 (${_stats['pending'] ?? 0})',
                                content: _buildRequestList(RequestStatus.pending, false),
                              ),
                              ui.AppTab(
                                label: '매칭완료 (${_stats['matched'] ?? 0})',
                                content: _buildRequestList(RequestStatus.matched, false),
                              ),
                              ui.AppTab(
                                label: '진행중 (${_stats['in_progress'] ?? 0})',
                                content: _buildRequestList(RequestStatus.in_progress, false),
                              ),
                              ui.AppTab(
                                label: '완료 (${_stats['completed'] ?? 0})',
                                content: _buildRequestList(RequestStatus.completed, false),
                              ),
                            ],
                    ),
                  ),
                ),
          floatingActionButton: isFreelancer ? null : FloatingActionButton.extended(
            onPressed: _navigateToCreateRequest,
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
        child: ui.InfoCard(
          icon: isFreelancer ? Icons.work_outline : Icons.assignment_outlined,
          title: isFreelancer 
              ? (status == null ? '아직 의뢰가 없습니다' : '해당 상태의 의뢰가 없습니다')
              : (status == null ? '등록한 의뢰가 없습니다' : '해당 상태의 의뢰가 없습니다'),
          description: isFreelancer 
              ? '새로운 의뢰가 등록되면 알려드릴게요'
              : '첫 의뢰를 등록하여 전문가를 찾아보세요',
          actions: !isFreelancer ? [
            ui.PrimaryButton(
              text: '첫 의뢰 등록하기',
              onPressed: _navigateToCreateRequest,
            ),
          ] : null,
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
    ui.AppDialog.show(
      context: context,
      title: '의뢰 삭제',
      description: '${request.title}을(를) 삭제하시겠습니까?',
      actions: [
        ui.SecondaryButton(
          text: '취소',
          onPressed: () => Navigator.pop(context),
        ),
        ui.AppButton(
          text: '삭제',
          onPressed: () {
            Navigator.pop(context);
            _deleteRequest(request);
          },
          variant: ui.ButtonVariant.destructive,
        ),
      ],
    );
  }

  Future<void> _deleteRequest(ServiceRequest request) async {
    try {
      await _requestService.deleteRequest(request.id);
      ui.AppToast.success(
        context,
        '의뢰가 삭제되었습니다',
      );
      _loadData(); // 목록 새로고침
    } catch (e) {
      ui.AppToast.error(
        context,
        '삭제 중 오류가 발생했습니다: $e',
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
    return ui.AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ui.AppCardHeader(
            title: request.title,
            subtitle: request.serviceType.displayName,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ui.AppBadge(
                  text: request.serviceType.displayName,
                  variant: ui.BadgeVariant.outline,
                  size: ui.BadgeSize.sm,
                ),
                const SizedBox(width: 8),
                ui.AppBadge(
                  text: request.status.displayName,
                  variant: _statusToBadgeVariant(request.status),
                  size: ui.BadgeSize.sm,
                ),
              ],
            ),
          ),
          ui.AppCardContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.5,
                  ),
                  maxLines: 3,
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
              ],
            ),
          ),
          if (isFreelancer && request.status == RequestStatus.pending && onApply != null)
            ui.AppCardFooter(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: ui.PrimaryButton(
                    text: '지원하기',
                    onPressed: onApply,
                  ),
                ),
              ],
            )
          else if (!isFreelancer && (request.status == RequestStatus.draft || request.status == RequestStatus.pending))
            ui.AppCardFooter(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onDelete != null)
                  ui.SecondaryButton(
                    text: '삭제',
                    onPressed: onDelete,
                  ),
                const SizedBox(width: 8),
                if (onEdit != null)
                  ui.OutlineButton(
                    text: '수정',
                    onPressed: onEdit,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

// 상태를 뱃지 스타일에 매핑
ui.BadgeVariant _statusToBadgeVariant(RequestStatus status) {
  switch (status) {
    case RequestStatus.draft:
      return ui.BadgeVariant.outline;
    case RequestStatus.pending:
      return ui.BadgeVariant.warning;
    case RequestStatus.matched:
      return ui.BadgeVariant.success;
    case RequestStatus.in_progress:
      return ui.BadgeVariant.primary;
    case RequestStatus.completed:
      return ui.BadgeVariant.secondary;
    default:
      return ui.BadgeVariant.secondary;
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

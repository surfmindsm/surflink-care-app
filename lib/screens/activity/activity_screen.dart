import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/activity.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Activity> _allActivities = [];
  List<Activity> _filteredActivities = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_filterActivities);
    _loadActivities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadActivities() {
    // TODO: 실제 API 호출로 대체
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _allActivities = _getSampleActivities();
        _filteredActivities = _allActivities;
        _isLoading = false;
      });
    });
  }

  void _filterActivities() {
    if (!mounted) return;
    
    setState(() {
      switch (_tabController.index) {
        case 0:
          _filteredActivities = _allActivities;
          break;
        case 1:
          _filteredActivities = _allActivities.where(
            (a) => a.type == ActivityType.matching || 
                   a.type == ActivityType.contract ||
                   a.type == ActivityType.service
          ).toList();
          break;
        case 2:
          _filteredActivities = _allActivities.where(
            (a) => a.type == ActivityType.payment || 
                   a.type == ActivityType.settlement
          ).toList();
          break;
        case 3:
          _filteredActivities = _allActivities.where(
            (a) => a.type == ActivityType.review || 
                   a.type == ActivityType.message
          ).toList();
          break;
      }
    });
  }

  List<Activity> _getSampleActivities() {
    return [
      Activity(
        id: '1',
        type: ActivityType.matching,
        title: '매칭이 성사되었습니다',
        description: '김선생님과 아이 돌봄 서비스로 매칭되었습니다',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      Activity(
        id: '2',
        type: ActivityType.message,
        title: '새로운 메시지가 도착했습니다',
        description: '박선생님이 메시지를 보냈습니다',
        date: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: false,
      ),
      Activity(
        id: '3',
        type: ActivityType.payment,
        title: '결제가 완료되었습니다',
        description: '영어 과외 서비스 결제 150,000원',
        date: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: true,
      ),
      Activity(
        id: '4',
        type: ActivityType.contract,
        title: '계약서가 작성되었습니다',
        description: '수학 과외 서비스 계약이 완료되었습니다',
        date: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      Activity(
        id: '5',
        type: ActivityType.review,
        title: '후기를 작성해주세요',
        description: '심리 상담 서비스가 완료되었습니다',
        date: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
      ),
      Activity(
        id: '6',
        type: ActivityType.settlement,
        title: '정산이 완료되었습니다',
        description: '아이 돌봄 서비스 정산 135,000원이 지급되었습니다',
        date: DateTime.now().subtract(const Duration(days: 3)),
        isRead: true,
      ),
      Activity(
        id: '7',
        type: ActivityType.service,
        title: '서비스가 시작되었습니다',
        description: '간병 서비스가 시작되었습니다',
        date: DateTime.now().subtract(const Duration(days: 4)),
        isRead: true,
      ),
      Activity(
        id: '8',
        type: ActivityType.matching,
        title: '의뢰가 등록되었습니다',
        description: '튜터링 서비스 의뢰가 성공적으로 등록되었습니다',
        date: DateTime.now().subtract(const Duration(days: 5)),
        isRead: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('활동 내역'),
        backgroundColor: Color(AppConfig.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: _markAllAsRead,
            tooltip: '모두 읽음 처리',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(text: '전체'),
            Tab(text: '서비스'),
            Tab(text: '결제/정산'),
            Tab(text: '소통'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                _loadActivities();
              },
              child: _filteredActivities.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _filteredActivities.length,
                      itemBuilder: (context, index) {
                        final activity = _filteredActivities[index];
                        return _buildActivityItem(activity);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '활동 내역이 없습니다',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '서비스를 이용하시면 활동 내역이 표시됩니다',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Activity activity) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConfig.defaultPadding,
        vertical: 4,
      ),
      child: ListTile(
        leading: _buildActivityIcon(activity.type),
        title: Text(
          activity.title,
          style: TextStyle(
            fontWeight: activity.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              activity.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(activity.date),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!activity.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color(AppConfig.primaryColor),
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
        onTap: () => _onActivityTap(activity),
      ),
    );
  }

  Widget _buildActivityIcon(ActivityType type) {
    IconData icon;
    Color color;

    switch (type) {
      case ActivityType.matching:
        icon = Icons.handshake;
        color = Colors.blue;
        break;
      case ActivityType.message:
        icon = Icons.message;
        color = Colors.green;
        break;
      case ActivityType.payment:
        icon = Icons.payment;
        color = Colors.purple;
        break;
      case ActivityType.contract:
        icon = Icons.description;
        color = Colors.orange;
        break;
      case ActivityType.review:
        icon = Icons.star;
        color = Colors.amber;
        break;
      case ActivityType.settlement:
        icon = Icons.account_balance_wallet;
        color = Colors.teal;
        break;
      case ActivityType.service:
        icon = Icons.work;
        color = Colors.indigo;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    }
  }

  void _onActivityTap(Activity activity) {
    // 읽음 처리
    if (!activity.isRead) {
      setState(() {
        activity.isRead = true;
      });
    }

    // TODO: 활동 유형별 상세 화면으로 이동
    switch (activity.type) {
      case ActivityType.matching:
        // 매칭 상세로 이동
        break;
      case ActivityType.message:
        // 채팅으로 이동
        break;
      case ActivityType.payment:
        // 결제 내역으로 이동
        break;
      case ActivityType.contract:
        // 계약 상세로 이동
        break;
      case ActivityType.review:
        // 후기 작성으로 이동
        break;
      case ActivityType.settlement:
        // 정산 내역으로 이동
        break;
      case ActivityType.service:
        // 서비스 상세로 이동
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${activity.title} 상세 화면으로 이동 (개발 예정)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (final activity in _allActivities) {
        activity.isRead = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('모든 활동을 읽음 처리했습니다.'),
      ),
    );
  }
}

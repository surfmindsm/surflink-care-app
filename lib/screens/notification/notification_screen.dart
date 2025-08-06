import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../models/notification.dart';
import '../../services/notification_service.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_config.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NotificationService _notificationService = NotificationService();
  
  List<AppNotification> _allNotifications = [];
  List<AppNotification> _unreadNotifications = [];
  List<AppNotification> _readNotifications = [];
  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id ?? 'user_002'; // Mock user

      final allNotifications = await _notificationService.getUserNotifications(userId);
      final unreadNotifications = await _notificationService.getUserNotifications(
        userId,
        status: NotificationStatus.unread,
      );
      final readNotifications = await _notificationService.getUserNotifications(
        userId,
        status: NotificationStatus.read,
      );
      final unreadCount = await _notificationService.getUnreadCount(userId);

      if (mounted) {
        setState(() {
          _allNotifications = allNotifications;
          _unreadNotifications = unreadNotifications;
          _readNotifications = readNotifications;
          _unreadCount = unreadCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('알림을 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Row(
          children: [
            const Text('알림'),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'markAllRead',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read, size: 20),
                    SizedBox(width: 8),
                    Text('모두 읽음 표시'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('알림 설정'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '전체 (${_allNotifications.length})'),
            Tab(text: '읽지 않음 (${_unreadNotifications.length})'),
            Tab(text: '읽음 (${_readNotifications.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationList(_allNotifications),
                _buildNotificationList(_unreadNotifications),
                _buildNotificationList(_readNotifications),
              ],
            ),
    );
  }

  Widget _buildNotificationList(List<AppNotification> notifications) {
    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '알림이 없습니다.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final dateFormatter = DateFormat('MM.dd HH:mm');
    final isUnread = notification.status == NotificationStatus.unread;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isUnread ? 2 : 1,
      color: isUnread ? Colors.blue.withOpacity(0.02) : null,
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 타입 아이콘
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getTypeColor(notification.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        notification.type.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 알림 내용
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              notification.type.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                color: _getTypeColor(notification.type),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              dateFormatter.format(notification.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          notification.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // 메뉴 버튼
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleNotificationAction(value, notification),
                    itemBuilder: (context) => [
                      if (isUnread)
                        const PopupMenuItem(
                          value: 'markRead',
                          child: Row(
                            children: [
                              Icon(Icons.mark_email_read, size: 16),
                              SizedBox(width: 8),
                              Text('읽음 표시'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'archive',
                        child: Row(
                          children: [
                            Icon(Icons.archive, size: 16),
                            SizedBox(width: 8),
                            Text('보관'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('삭제', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert, size: 20),
                  ),
                ],
              ),
              
              // 읽지 않음 표시
              if (isUnread)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '읽지 않음',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
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

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.match:
        return Colors.green;
      case NotificationType.contract:
        return Colors.blue;
      case NotificationType.payment:
        return Colors.orange;
      case NotificationType.review:
        return Colors.purple;
      case NotificationType.chat:
        return Colors.teal;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.promotion:
        return Colors.red;
    }
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'markAllRead':
        await _markAllAsRead();
        break;
      case 'settings':
        _navigateToSettings();
        break;
    }
  }

  void _handleNotificationTap(AppNotification notification) async {
    // 읽지 않은 알림인 경우 읽음 표시
    if (notification.status == NotificationStatus.unread) {
      await _markAsRead(notification);
    }

    // 액션 URL이 있는 경우 해당 화면으로 이동
    if (notification.actionUrl != null) {
      // TODO: 실제 네비게이션 구현
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${notification.actionUrl}로 이동')),
      );
    }
  }

  void _handleNotificationAction(String action, AppNotification notification) async {
    switch (action) {
      case 'markRead':
        await _markAsRead(notification);
        break;
      case 'archive':
        await _archiveNotification(notification);
        break;
      case 'delete':
        await _deleteNotification(notification);
        break;
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    try {
      await _notificationService.markAsRead(notification.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('읽음 표시했습니다.')),
        );
        _loadNotifications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('읽음 표시에 실패했습니다: $e')),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id ?? 'user_002';
      
      await _notificationService.markAllAsRead(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모든 알림을 읽음 표시했습니다.')),
        );
        _loadNotifications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('전체 읽음 표시에 실패했습니다: $e')),
        );
      }
    }
  }

  Future<void> _archiveNotification(AppNotification notification) async {
    try {
      await _notificationService.archiveNotification(notification.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('알림을 보관했습니다.')),
        );
        _loadNotifications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('알림 보관에 실패했습니다: $e')),
        );
      }
    }
  }

  Future<void> _deleteNotification(AppNotification notification) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림 삭제'),
        content: const Text('이 알림을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _notificationService.deleteNotification(notification.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('알림을 삭제했습니다.')),
          );
          _loadNotifications();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('알림 삭제에 실패했습니다: $e')),
          );
        }
      }
    }
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationSettingsScreen(),
      ),
    );
  }
}

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  NotificationSettings? _settings;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id ?? 'user_002';
      
      final settings = await _notificationService.getNotificationSettings(userId);
      
      if (mounted) {
        setState(() {
          _settings = settings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('설정을 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
        actions: [
          if (!_isLoading && _settings != null)
            TextButton(
              onPressed: _isSaving ? null : _saveSettings,
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('저장'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _settings == null
              ? const Center(child: Text('설정을 불러올 수 없습니다.'))
              : _buildSettingsContent(),
    );
  }

  Widget _buildSettingsContent() {
    final settings = _settings!;

    return ListView(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      children: [
        // 알림 방식 설정
        const Text(
          '알림 방식',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Card(
          child: Column(
            children: [
              _buildSwitchTile(
                '푸시 알림',
                '앱 알림을 받습니다.',
                settings.pushEnabled,
                (value) => _updateSettings(settings.copyWith(pushEnabled: value)),
              ),
              _buildSwitchTile(
                '이메일 알림',
                '이메일로 알림을 받습니다.',
                settings.emailEnabled,
                (value) => _updateSettings(settings.copyWith(emailEnabled: value)),
              ),
              _buildSwitchTile(
                'SMS 알림',
                '문자메시지로 알림을 받습니다.',
                settings.smsEnabled,
                (value) => _updateSettings(settings.copyWith(smsEnabled: value)),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // 알림 종류 설정
        const Text(
          '알림 종류',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Card(
          child: Column(
            children: [
              _buildSwitchTile(
                '매칭 알림',
                '새로운 매칭 요청을 알려드립니다.',
                settings.matchNotifications,
                (value) => _updateSettings(settings.copyWith(matchNotifications: value)),
              ),
              _buildSwitchTile(
                '계약 알림',
                '계약 관련 업데이트를 알려드립니다.',
                settings.contractNotifications,
                (value) => _updateSettings(settings.copyWith(contractNotifications: value)),
              ),
              _buildSwitchTile(
                '정산 알림',
                '정산 관련 정보를 알려드립니다.',
                settings.paymentNotifications,
                (value) => _updateSettings(settings.copyWith(paymentNotifications: value)),
              ),
              _buildSwitchTile(
                '리뷰 알림',
                '새로운 리뷰를 알려드립니다.',
                settings.reviewNotifications,
                (value) => _updateSettings(settings.copyWith(reviewNotifications: value)),
              ),
              _buildSwitchTile(
                '채팅 알림',
                '새로운 메시지를 알려드립니다.',
                settings.chatNotifications,
                (value) => _updateSettings(settings.copyWith(chatNotifications: value)),
              ),
              _buildSwitchTile(
                '시스템 알림',
                '중요한 시스템 공지를 알려드립니다.',
                settings.systemNotifications,
                (value) => _updateSettings(settings.copyWith(systemNotifications: value)),
              ),
              _buildSwitchTile(
                '프로모션 알림',
                '이벤트 및 혜택 정보를 알려드립니다.',
                settings.promotionNotifications,
                (value) => _updateSettings(settings.copyWith(promotionNotifications: value)),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // 방해금지 시간 설정
        const Text(
          '방해금지 시간',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('시작 시간'),
                    TextButton(
                      onPressed: () => _selectTime(true),
                      child: Text(settings.quietStartTime),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('종료 시간'),
                    TextButton(
                      onPressed: () => _selectTime(false),
                      child: Text(settings.quietEndTime),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // 기타 설정
        const Text(
          '기타',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Card(
          child: Column(
            children: [
              _buildSwitchTile(
                '주말 알림',
                '주말에도 알림을 받습니다.',
                settings.weekendNotifications,
                (value) => _updateSettings(settings.copyWith(weekendNotifications: value)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  void _updateSettings(NotificationSettings newSettings) {
    setState(() {
      _settings = newSettings;
    });
  }

  Future<void> _selectTime(bool isStartTime) async {
    final currentSettings = _settings!;
    final currentTime = isStartTime 
        ? currentSettings.quietStartTime 
        : currentSettings.quietEndTime;
    
    final timeParts = currentTime.split(':');
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
    );

    if (selectedTime != null) {
      final timeString = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      
      final newSettings = isStartTime
          ? currentSettings.copyWith(quietStartTime: timeString)
          : currentSettings.copyWith(quietEndTime: timeString);
      
      _updateSettings(newSettings);
    }
  }

  Future<void> _saveSettings() async {
    if (_settings == null) return;

    setState(() => _isSaving = true);

    try {
      await _notificationService.updateNotificationSettings(_settings!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('설정을 저장했습니다.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('설정 저장에 실패했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

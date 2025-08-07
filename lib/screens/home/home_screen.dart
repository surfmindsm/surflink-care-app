import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../models/request.dart';
import '../../models/notification.dart';

import '../../config/app_config.dart';
import '../../widgets/service_type_card.dart';
import '../../widgets/recent_activity_card.dart';
import '../../widgets/quick_action_button.dart';

import '../../services/notification_service.dart';
import '../../services/request_service.dart';
import '../../services/chat_service.dart';
import '../../services/freelancer_service.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  // 상태 정보
  int _unreadNotificationCount = 0;
  int _unreadMessageCount = 0;
  int _pendingRequestCount = 0;

  bool _isVerified = false;
  Map<String, dynamic>? _profileStatus;
  
  // 실제 데이터
  List<ServiceRequest> _recentRequests = [];
  List<dynamic> _recommendations = [];
  List<AppNotification> _recentNotifications = [];
  bool _isLoadingData = true;
  
  final NotificationService _notificationService = NotificationService();
  final RequestService _requestService = RequestService();
  final ChatService _chatService = ChatService();
  final FreelancerService _freelancerService = FreelancerService();

  @override
  void initState() {
    super.initState();
    
    // AuthProvider를 서비스들에 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _requestService.setAuthProvider(authProvider);
      _notificationService.setAuthProvider(authProvider);
      _chatService.setAuthProvider(authProvider);
      
      _loadHomeData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  void _loadHomeData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    if (user != null) {
      setState(() {
        _isLoadingData = true;
      });
      
      try {
        // 병렬로 데이터 로드
        await Future.wait([
          _loadNotificationData(user),
          _loadRequestData(user),
          _loadChatData(user),
          _loadRecommendationData(user),
        ]);
        
        setState(() {
          _isVerified = user.isFreelancer ? (user.name.length > 2) : true;
          _profileStatus = _getProfileStatus(user);
          _isLoadingData = false;
        });
      } catch (e) {
        setState(() {
          _isLoadingData = false;
        });
        print('홈 데이터 로딩 오류: $e');
      }
    }
  }
  
  Future<void> _loadNotificationData(User user) async {
    try {
      final notifications = await _notificationService.getUserNotifications(user.id);
      final unreadNotifications = notifications.where((n) => !n.isRead).toList();
      
      setState(() {
        _recentNotifications = notifications.take(3).toList();
        _unreadNotificationCount = unreadNotifications.length;
      });
    } catch (e) {
      // 목업 데이터 사용
      setState(() {
        _unreadNotificationCount = 3;
        _recentNotifications = [];
      });
    }
  }
  
  Future<void> _loadRequestData(User user) async {
    try {
      if (user.isFreelancer) {
        // 프리랜서: 지원 가능한 의뢰 조회
        final publicRequests = await _requestService.getPublicRequests(limit: 5);
        setState(() {
          _recentRequests = publicRequests;
          _pendingRequestCount = publicRequests.where((r) => r.status == RequestStatus.pending).length;
        });
      } else {
        // 고객: 내 의뢰 조회
        final myRequests = await _requestService.getMyRequests(limit: 5);
        setState(() {
          _recentRequests = myRequests;
          _pendingRequestCount = myRequests.where((r) => r.status == RequestStatus.pending).length;
        });
      }
    } catch (e) {
      setState(() {
        _pendingRequestCount = user.isFreelancer ? 5 : 1;
        _recentRequests = [];
      });
    }
  }
  
  Future<void> _loadChatData(User user) async {
    try {
      final chatRooms = await _chatService.getChatRooms();
      final unreadCount = chatRooms.fold<int>(0, (sum, room) => sum + room.unreadCount);
      
      setState(() {
        _unreadMessageCount = unreadCount;
      });
    } catch (e) {
      setState(() {
        _unreadMessageCount = 2;
      });
    }
  }
  
  Future<void> _loadRecommendationData(User user) async {
    try {
      if (user.isFreelancer) {
        // 프리랜서: 추천 의뢰
        final recommendedRequests = await _requestService.getPublicRequests(
          serviceType: null, // 전체 서비스 타입
          limit: 5,
        );
        setState(() {
          _recommendations = recommendedRequests;
        });
      } else {
        // 고객: 추천 전문가 (실제 API 호출)
        final recommendedFreelancers = await _freelancerService.getRecommendedFreelancers(
          customerId: user.id,
          region: user.region,
          limit: 5,
        );
        setState(() {
          _recommendations = recommendedFreelancers;
        });
      }
    } catch (e) {
      setState(() {
        _recommendations = [];
      });
    }
  }
  
  Map<String, dynamic> _getProfileStatus(User user) {
    if (user.isFreelancer) {
      int completedSteps = 0;
      int totalSteps = 5;
      
      if (user.name.isNotEmpty) completedSteps++;
      if (user.email.isNotEmpty) completedSteps++;
      if (user.phone != null && user.phone!.isNotEmpty) completedSteps++;
      if (_isVerified) completedSteps++;
      if (user.name.length > 2) completedSteps++; // 자기소개 등
      
      return {
        'completedSteps': completedSteps,
        'totalSteps': totalSteps,
        'percentage': (completedSteps / totalSteps * 100).round(),
        'missingItems': _getMissingItems(user),
      };
    }
    return {
      'completedSteps': 3,
      'totalSteps': 3,
      'percentage': 100,
      'missingItems': <String>[],
    };
  }
  
  List<String> _getMissingItems(User user) {
    List<String> missing = [];
    if (user.name.isEmpty) missing.add('이름');
    if (user.phone == null || user.phone!.isEmpty) missing.add('연락처');
    if (!_isVerified) missing.add('경력 인증');
    if (user.name.length <= 2) missing.add('자기소개');
    return missing;
  }
  
  // 헬퍼 메서드들
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
  
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'matching':
        return Icons.people;
      case 'message':
        return Icons.message;
      case 'payment':
        return Icons.payment;
      case 'review':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }
  
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'matching':
        return Colors.green;
      case 'message':
        return Colors.blue;
      case 'payment':
        return Colors.orange;
      case 'review':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getServiceIcon(ServiceType serviceType) {
    switch (serviceType) {
      case ServiceType.childcare:
        return Icons.child_care;
      case ServiceType.eldercare:
        return Icons.elderly;
      case ServiceType.tutoring:
        return Icons.school;
      case ServiceType.counseling:
        return Icons.psychology;
    }
  }
  
  Color _getServiceColor(ServiceType serviceType) {
    switch (serviceType) {
      case ServiceType.childcare:
        return Colors.pink;
      case ServiceType.eldercare:
        return Colors.purple;
      case ServiceType.tutoring:
        return Colors.blue;
      case ServiceType.counseling:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildStatusCards(),
            const SizedBox(height: 24),
            _buildServiceTypes(),
            const SizedBox(height: 32),
            _buildQuickActions(),
            const SizedBox(height: 32),
            _buildRecentActivity(),
            const SizedBox(height: 32),
            _buildRecommendations(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        return Container(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(AppConfig.primaryColor),
                Color(AppConfig.primaryColor).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.isFreelancer == true ? '안녕하세요, ${user?.name}님!' : '필요한 서비스를 찾아보세요',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.isFreelancer == true 
                            ? '새로운 의뢰를 확인해보세요'
                            : '신뢰할 수 있는 전문가들이 기다리고 있어요',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                            onPressed: () => context.go('/notifications'),
                          ),
                          if (_unreadNotificationCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  _unreadNotificationCount > 99 ? '99+' : '$_unreadNotificationCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Colors.white),
                        onPressed: () => context.go('/settings'),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 검색바
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: user?.isFreelancer == true ? '원하는 의뢰를 검색하세요' : '필요한 서비스를 검색하세요',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onTap: () => context.go('/search'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceTypes() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding),
              child: Text(
                user?.isFreelancer == true ? '서비스 분야' : '어떤 서비스가 필요하신가요?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding),
                children: [
                  ServiceTypeCard(
                    title: '돌봄',
                    subtitle: '아이 돌봄 서비스',
                    icon: Icons.child_care,
                    color: Colors.pink,
                    onTap: () {
                      if (user?.isFreelancer == true) {
                        context.go('/freelancers?type=childcare');
                      } else {
                        context.go('/requests/create?type=childcare');
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  ServiceTypeCard(
                    title: '간병',
                    subtitle: '어르신 간병 서비스',
                    icon: Icons.elderly,
                    color: Colors.orange,
                    onTap: () {
                      if (user?.isFreelancer == true) {
                        context.go('/freelancers?type=eldercare');
                      } else {
                        context.go('/requests/create?type=eldercare');
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  ServiceTypeCard(
                    title: '튜터링',
                    subtitle: '학습 지도 서비스',
                    icon: Icons.school,
                    color: Colors.blue,
                    onTap: () {
                      if (user?.isFreelancer == true) {
                        context.go('/freelancers?type=tutoring');
                      } else {
                        context.go('/requests/create?type=tutoring');
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  ServiceTypeCard(
                    title: '심리상담',
                    subtitle: '전문 심리 상담',
                    icon: Icons.psychology,
                    color: Colors.green,
                    onTap: () {
                      if (user?.isFreelancer == true) {
                        context.go('/freelancers?type=counseling');
                      } else {
                        context.go('/requests/create?type=counseling');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding),
              child: Text(
                '빠른 메뉴',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding),
              child: Row(
                children: user?.isFreelancer == true ? [
                  Expanded(
                    child: QuickActionButton(
                      title: '새 의뢰 찾기',
                      icon: Icons.search,
                      color: Colors.blue,
                      onTap: () => context.go('/requests'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickActionButton(
                      title: '내 프로필',
                      icon: Icons.person,
                      color: Colors.green,
                      onTap: () => context.go('/profile'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickActionButton(
                      title: '수익 현황',
                      icon: Icons.analytics,
                      color: Colors.orange,
                      onTap: () => context.go('/settlement'),
                    ),
                  ),
                ] : [
                  Expanded(
                    child: QuickActionButton(
                      title: '의뢰 등록',
                      icon: Icons.add,
                      color: Colors.blue,
                      onTap: () => context.go('/requests/create'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickActionButton(
                      title: '전문가 찾기',
                      icon: Icons.people,
                      color: Colors.green,
                      onTap: () => context.go('/freelancers'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickActionButton(
                      title: '내 의뢰',
                      icon: Icons.list,
                      color: Colors.orange,
                      onTap: () => context.go('/requests'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final isFreelancer = user?.isFreelancer == true;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '최근 활동',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/activity'),
                    child: const Text('전체 보기'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            if (_isLoadingData)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_recentNotifications.isNotEmpty)
              // 실제 알림 데이터 표시
              ..._recentNotifications.take(3).map((notification) => RecentActivityCard(
                title: notification.title,
                subtitle: notification.content,
                time: _formatTimeAgo(notification.createdAt),
                icon: _getNotificationIcon(notification.type.toString().split('.').last),
                color: _getNotificationColor(notification.type.toString().split('.').last),
              ))
            else if (_recentRequests.isNotEmpty)
              // 최근 의뢰 데이터 표시
              ..._recentRequests.take(3).map((request) => RecentActivityCard(
                title: isFreelancer 
                    ? '새로운 의뢰: ${request.title}'
                    : '의뢰 상태: ${request.status.displayName}',
                subtitle: '${request.region} • ${request.serviceType.displayName}',
                time: _formatTimeAgo(request.updatedAt),
                icon: _getServiceIcon(request.serviceType),
                color: _getServiceColor(request.serviceType),
              ))
            else
              // 기본 메시지
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    '최근 활동이 없습니다',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRecommendations() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final isFreelancer = user?.isFreelancer == true;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding),
              child: Text(
                isFreelancer ? '추천 의뢰' : '추천 전문가',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _isLoadingData
                  ? const Center(child: CircularProgressIndicator())
                  : _recommendations.isEmpty
                      ? Center(
                          child: Text(
                            isFreelancer ? '추천 의뢰가 없습니다' : '추천 전문가가 없습니다',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding),
                          itemCount: _recommendations.length,
                          itemBuilder: (context, index) {
                            final item = _recommendations[index];
                            
                            return Container(
                              width: 160,
                              margin: const EdgeInsets.only(right: 12),
                              child: Card(
                                child: InkWell(
                                  onTap: () {
                                    if (isFreelancer && item is ServiceRequest) {
                                      context.go('/requests/${item.id}');
                                    } else if (item is User) {
                                      // 전문가 상세 페이지로 이동
                                      context.go('/freelancers/${item.id}');
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: isFreelancer && item is ServiceRequest
                                              ? _getServiceColor(item.serviceType)
                                              : Color(AppConfig.primaryColor),
                                          child: Icon(
                                            isFreelancer && item is ServiceRequest
                                                ? _getServiceIcon(item.serviceType)
                                                : Icons.person,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          isFreelancer && item is ServiceRequest
                                              ? item.title
                                              : (item is User ? item.name : '전문가'),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isFreelancer && item is ServiceRequest
                                              ? '${item.region} • ${item.serviceType.displayName}'
                                              : (item is User ? '${item.region ?? "지역미정"} • ${item.careerYears ?? 0}년 경력' : '전문 분야'),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            if (!isFreelancer) ...[
                                              const Icon(Icons.star, size: 12, color: Colors.orange),
                                              const SizedBox(width: 2),
                                              Text(
                                                (item is User && item.rating != null) 
                                                    ? item.rating!.toStringAsFixed(1)
                                                    : '4.8',
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                            ],
                                            const Spacer(),
                                            Text(
                                              isFreelancer && item is ServiceRequest
                                                  ? '${item.budget != null ? "${(item.budget! / 1000).toInt()}만원" : "협의"}'
                                                  : (item is User 
                                                      ? '경력 ${item.careerYears ?? 0}년'
                                                      : '시급 20,000원'),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusCards() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding),
          child: Column(
            children: [
              // 프로필 상태 카드
              if (user?.isFreelancer == true && _profileStatus != null && _profileStatus!['percentage'] < 100)
                _buildProfileStatusCard(),
              
              // 상태 요약 카드
              Row(
                children: [
                  Expanded(
                    child: _buildStatusItem(
                      '진행 중인\n${user?.isFreelancer == true ? '의뢰' : '요청'}',
                      '$_pendingRequestCount',
                      Colors.blue,
                      Icons.work_outline,
                      onTap: () => context.go('/requests'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatusItem(
                      '읽지 않은\n메시지',
                      '$_unreadMessageCount',
                      Colors.green,
                      Icons.message_outlined,
                      onTap: () => context.go('/chats'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatusItem(
                      user?.isFreelancer == true ? '수익 현황' : '이용 내역',
                      user?.isFreelancer == true ? '보기' : '보기',
                      user?.isFreelancer == true ? Colors.orange : Colors.purple,
                      user?.isFreelancer == true ? Icons.analytics_outlined : Icons.history,
                      onTap: () {
                        if (user?.isFreelancer == true) {
                          context.go('/settlement');
                        } else {
                          context.go('/activity');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileStatusCard() {
    final status = _profileStatus!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.orange.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: Colors.orange.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '프로필 완성도 ${status['percentage']}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/profile/edit'),
                child: const Text('완성하기'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: status['percentage'] / 100.0,
            backgroundColor: Colors.orange.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
          ),
          if (status['missingItems'].isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '미완성: ${(status['missingItems'] as List).join(', ')}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    String title,
    String value,
    Color color,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }


}

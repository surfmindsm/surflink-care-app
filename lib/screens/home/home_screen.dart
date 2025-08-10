import 'package:care_surflink/resource/color_style.dart';
import 'package:care_surflink/resource/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../models/request.dart';
import '../../models/notification.dart';

import '../../config/app_config.dart';
import '../../components/index.dart' hide IconButton;

import '../../services/notification_service.dart';
import '../../services/request_service.dart';
import '../../services/chat_service.dart';
import '../../services/freelancer_service.dart';
import '../../services/settlement_service.dart';

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

  // 프리랜서 수익 데이터
  Map<String, dynamic>? _earningsData;

  // 실제 데이터
  List<ServiceRequest> _recentRequests = [];
  List<dynamic> _recommendations = [];
  List<AppNotification> _recentNotifications = [];
  bool _isLoadingData = true;

  // 검색 상태 (홈에서 인라인 검색)
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  List<dynamic> _searchResults = [];

  final NotificationService _notificationService = NotificationService();
  final RequestService _requestService = RequestService();
  final ChatService _chatService = ChatService();
  final FreelancerService _freelancerService = FreelancerService();
  final SettlementService _settlementService = SettlementService();

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
    _searchController.dispose();
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
          if (user.isFreelancer) _loadFreelancerData(user),
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
      final notifications =
          await _notificationService.getUserNotifications(user.id);
      final unreadNotifications =
          notifications.where((n) => !n.isRead).toList();

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
        final publicRequests =
            await _requestService.getPublicRequests(limit: 5);
        setState(() {
          _recentRequests = publicRequests;
          _pendingRequestCount = publicRequests
              .where((r) =>
                  r.status == RequestStatus.waiting ||
                  r.status == RequestStatus.pending)
              .length;
        });
      } else {
        // 고객: 내 의뢰 조회
        final myRequests = await _requestService.getMyRequests(limit: 5);
        setState(() {
          _recentRequests = myRequests;
          _pendingRequestCount = myRequests
              .where((r) =>
                  r.status == RequestStatus.waiting ||
                  r.status == RequestStatus.pending)
              .length;
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
      final unreadCount =
          chatRooms.fold<int>(0, (sum, room) => sum + room.unreadCount);

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
        final recommendedFreelancers =
            await _freelancerService.getRecommendedFreelancers(
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

  Future<void> _loadFreelancerData(User user) async {
    try {
      // 프리랜서 전용 데이터 로드
      final results = await Future.wait([
        _settlementService.getActiveRequestsCount(user.id),
        _settlementService.getUnreadMessagesCount(user.id),
        _settlementService.getProfileCompleteness(user.id),
        _settlementService.getFreelancerEarnings(user.id),
      ]);

      setState(() {
        _pendingRequestCount = results[0] as int;
        _unreadMessageCount = results[1] as int;
        final profileData = results[2] as Map<String, dynamic>;
        _profileStatus = profileData;
        _earningsData = results[3] as Map<String, dynamic>;
      });
    } catch (e) {
      print('프리랜서 데이터 로딩 오류: $e');
      // 목업 데이터 사용
      setState(() {
        _pendingRequestCount = 3;
        _unreadMessageCount = 5;
        _profileStatus = {
          'completedSteps': 3,
          'totalSteps': 5,
          'percentage': 60,
        };
        _earningsData = {
          'thisMonthEarnings': 120000.0,
          'totalEarnings': 750000.0,
          'completedJobs': 8,
          'pendingPayments': 2,
        };
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
      child: Scaffold(
        backgroundColor: AppColor.background,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildSearchBar(),
              if (_searchQuery.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildInlineSearchResults(),
              ],
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
      ),
    );
  }

  Widget _buildHeader() {
    final user = Provider.of<AuthProvider>(context).currentUser;
    if (user == null) return const SizedBox();

    return AppCard(
      backgroundColor: AppColor.white,
      variant: CardVariant.filled,
      padding: EdgeInsets.all(16.r),
      margin: EdgeInsets.all(16.r),
      child: Row(
        children: [
          AppAvatar(
            initials: user.name.substring(0, 1),
            size: AvatarSize.md,
            imageUrl: user.profileImageUrl,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '안녕하세요',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${user.name}님',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_isVerified) ...[
                  const SizedBox(height: 8),
                  AppBadge(
                    text: '프로필 인증 필요',
                    variant: BadgeVariant.warning,
                    size: BadgeSize.sm,
                    icon: Icons.warning_amber,
                  ),
                ],
              ],
            ),
          ),
          Row(
            children: [
              Stack(
                children: [
                  AppButton(
                    variant: ButtonVariant.ghost,
                    size: ButtonSize.icon,
                    icon: Icons.notifications_outlined,
                    onPressed: () => context.go('/notifications'),
                  ),
                  if (_unreadNotificationCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: AppBadge(
                        text: _unreadNotificationCount > 99
                            ? '99+'
                            : '$_unreadNotificationCount',
                        variant: BadgeVariant.error,
                        size: BadgeSize.sm,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              AppButton(
                variant: ButtonVariant.ghost,
                size: ButtonSize.icon,
                icon: Icons.settings_outlined,
                onPressed: () => context.go('/settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.r),
      child: AppInput(
        placeholder:
            user?.isFreelancer == true ? '원하는 의뢰를 검색하세요' : '필요한 서비스를 검색하세요',
        prefixIcon: Icons.search,
        size: InputSize.lg,
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim();
          });
          // 입력이 비어지면 결과도 초기화
          if (_searchQuery.isEmpty) {
            setState(() {
              _searchResults = [];
              _isSearching = false;
            });
          }
        },
        onSubmitted: (value) => _performInlineSearch(value),
        disabled: false,
        // Border customization
        borderColor: AppColor.secondary02,
        focusedBorderColor: AppColor.primary7,
        errorBorderColor: AppColor.error,
        borderWidth: 0,
        focusedBorderWidth: 2,
        borderRadius: 12,
        backgroundColor: AppColor.white,
      ),
    );
  }

  // 홈 화면 인라인 검색 실행
  Future<void> _performInlineSearch(String value) async {
    final query = value.trim();
    if (query.isEmpty) return;

    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });

    try {
      if (user?.isFreelancer == true) {
        // 프리랜서: 의뢰 목록에서 텍스트 매칭으로 간단 검색 (제목/설명/지역)
        final list = await _requestService.getPublicRequests(limit: 50);
        final lowered = query.toLowerCase();
        final filtered = list.where((r) {
          final t = (r.title ?? '').toLowerCase();
          final d = (r.description ?? '').toLowerCase();
          final reg = (r.region ?? '').toLowerCase();
          return t.contains(lowered) ||
              d.contains(lowered) ||
              reg.contains(lowered);
        }).toList();
        setState(() {
          _searchResults = filtered;
        });
      } else {
        // 고객: 프리랜서 검색 API 사용
        final freelancers = await _freelancerService.getFreelancers(
          searchQuery: query,
          limit: 20,
        );
        setState(() {
          _searchResults = freelancers;
        });
      }
    } catch (e) {
      // 실패 시 결과 초기화
      setState(() {
        _searchResults = [];
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  // 인라인 검색 결과 렌더링
  Widget _buildInlineSearchResults() {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.r),
      child: AppCard(
        backgroundColor: AppColor.white,
        variant: CardVariant.filled,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _isSearching
                        ? '검색 중...'
                        : (_searchResults.isEmpty
                            ? '검색 결과 없음'
                            : '검색 결과 (${_searchResults.length})'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  AppButton(
                    text: '지우기',
                    size: ButtonSize.sm,
                    variant: ButtonVariant.ghost,
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _searchResults = [];
                        _isSearching = false;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isSearching)
              const LinearProgressIndicator(minHeight: 2)
            else ...[..._buildInlineResultItems(user?.isFreelancer == true)],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildInlineResultItems(bool isFreelancerView) {
    // 프리랜서는 의뢰 리스트, 고객은 프리랜서 리스트
    final items = _searchResults.take(5).toList();
    return items.map((item) {
      if (isFreelancerView) {
        final r = item as ServiceRequest;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.assignment_outlined,
                  color: Colors.blueGrey, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.title ?? '의뢰',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [r.region, r.description].whereType<String>().join(' · '),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        final u = item as User;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.teal, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        (u.specialties?.isNotEmpty == true)
                            ? u.specialties!.join(', ')
                            : null,
                        u.region
                      ].whereType<String>().join(' · '),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    }).toList();
  }

  Widget _buildQuickActions() {
    final user = Provider.of<AuthProvider>(context).currentUser;
    if (user == null) return const SizedBox();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '빠른 메뉴',
            style: AppTextStyle(
              color: AppColor.secondary06,
            ).h2(),
          ),
          const SizedBox(height: 16),
          Row(
            children: user.isFreelancer
                ? [
                    _buildQuickActionItem(
                      '새 의뢰 찾기',
                      Icons.search,
                      Colors.blue,
                      () => context.go('/requests'),
                    ),
                    const SizedBox(width: 12),
                    _buildQuickActionItem(
                      '내 프로필',
                      Icons.person,
                      Colors.green,
                      () => context.go('/profile'),
                    ),
                    const SizedBox(width: 12),
                    _buildQuickActionItem(
                      '수익 현황',
                      Icons.analytics,
                      Colors.orange,
                      () => context.go('/settlement'),
                    ),
                  ]
                : [
                    _buildQuickActionItem(
                      '의뢰 등록',
                      Icons.add_box,
                      Colors.blue,
                      () => context.go('/requests/create'),
                    ),
                    const SizedBox(width: 12),
                    _buildQuickActionItem(
                      '전문가 찾기',
                      Icons.search,
                      Colors.green,
                      () => context.go('/freelancers'),
                    ),
                    const SizedBox(width: 12),
                    _buildQuickActionItem(
                      '내 의뢰',
                      Icons.list_alt,
                      Colors.orange,
                      () => context.go('/requests'),
                    ),
                  ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: AppCard(
        backgroundColor: AppColor.white,
        variant: CardVariant.outlined,
        padding: EdgeInsets.symmetric(vertical: 20.r, horizontal: 12.r),
        onTap: onTap,
        borderColor: color.withOpacity(0.3),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final isFreelancer = user?.isFreelancer == true;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '최근 활동',
                style: AppTextStyle(
                  color: AppColor.secondary06,
                ).h2(),
              ),
              AppButton(
                text: '전체 보기',
                variant: ButtonVariant.ghost,
                size: ButtonSize.sm,
                onPressed: () => context.go('/activity'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingData)
            AppCard(
              variant: CardVariant.filled,
              padding: const EdgeInsets.all(32),
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (_recentNotifications.isNotEmpty)
            // 실제 알림 데이터 표시
            Column(
              children: _recentNotifications
                  .take(3)
                  .map(
                    (notification) => AppCard(
                      variant: CardVariant.outlined,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppAvatar(
                            initials: '',
                            size: AvatarSize.sm,
                            backgroundColor: _getNotificationColor(
                                notification.type.toString().split('.').last),
                            fallback: Icon(
                              _getNotificationIcon(
                                  notification.type.toString().split('.').last),
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: AppTextStyle(
                                    color: AppColor.secondary06,
                                  ).h3(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notification.content,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          AppBadge(
                            text: _formatTimeAgo(notification.createdAt),
                            variant: BadgeVariant.secondary,
                            size: BadgeSize.sm,
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            )
          else if (_recentRequests.isNotEmpty)
            // 최근 의뢰 데이터 표시
            Column(
              children: _recentRequests
                  .take(3)
                  .map(
                    (request) => AppCard(
                      variant: CardVariant.outlined,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppAvatar(
                            initials: '',
                            size: AvatarSize.sm,
                            backgroundColor:
                                _getServiceColor(request.serviceType),
                            fallback: Icon(
                              _getServiceIcon(request.serviceType),
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isFreelancer
                                      ? '새로운 의뢰: ${request.title}'
                                      : '의뢰 상태: ${request.status.displayName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${request.region} • ${request.serviceType.displayName}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          AppBadge(
                            text: _formatTimeAgo(request.updatedAt),
                            variant: BadgeVariant.secondary,
                            size: BadgeSize.sm,
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            )
          else
            // 기본 메시지
            AppCard(
              variant: CardVariant.filled,
              padding: const EdgeInsets.all(32),
              child: const Center(
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
      ),
    );
  }

  Widget _buildRecommendations() {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final isFreelancer = user?.isFreelancer == true;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isFreelancer ? '추천 의뢰' : '추천 전문가',
            style: AppTextStyle(
              color: AppColor.secondary06,
            ).h2(),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 200,
            child: _isLoadingData
                ? AppCard(
                    variant: CardVariant.filled,
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : _recommendations.isEmpty
                    ? AppCard(
                        variant: CardVariant.filled,
                        child: Center(
                          child: Text(
                            isFreelancer ? '추천 의뢰가 없습니다' : '추천 전문가가 없습니다',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _recommendations.length,
                        itemBuilder: (context, index) {
                          final item = _recommendations[index];

                          return AppCard(
                            variant: CardVariant.outlined,
                            width: 160,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(12),
                            onTap: () {
                              if (isFreelancer && item is ServiceRequest) {
                                context.go('/requests/${item.id}');
                              } else if (item is User) {
                                context.go('/freelancers/${item.id}');
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppAvatar(
                                  initials:
                                      isFreelancer && item is ServiceRequest
                                          ? item.title.substring(0, 1)
                                          : (item is User
                                              ? item.name.substring(0, 1)
                                              : 'A'),
                                  size: AvatarSize.md,
                                  backgroundColor:
                                      isFreelancer && item is ServiceRequest
                                          ? _getServiceColor(item.serviceType)
                                          : Color(AppConfig.primaryColor),
                                  fallback: Icon(
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
                                      : (item is User
                                          ? '${item.region ?? "지역미정"} • ${item.careerYears ?? 0}년 경력'
                                          : '전문 분야'),
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
                                      Icon(
                                        Icons.star,
                                        size: 12,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        (item is User && item.rating != null)
                                            ? item.rating!.toStringAsFixed(1)
                                            : '4.8',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                    const Spacer(),
                                    AppBadge(
                                      text: isFreelancer &&
                                              item is ServiceRequest
                                          ? '${item.budget != null ? "${(item.budget! / 1000).toInt()}만원" : "협의"}'
                                          : (item is User
                                              ? '${item.careerYears ?? 0}년'
                                              : '2만원'),
                                      variant: BadgeVariant.primary,
                                      size: BadgeSize.sm,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTypes() {
    final user = Provider.of<AuthProvider>(context).currentUser;
    if (user == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '서비스 타입',
            style: AppTextStyle(
              color: AppColor.secondary06,
            ).h2(),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            children: [
              _buildServiceTypeCard(
                '돌봄',
                '노인/아동 돌봄',
                Icons.favorite_outline,
                Colors.pink,
                () => context.go('/services/care'),
              ),
              _buildServiceTypeCard(
                '간병',
                '환자 간병',
                Icons.local_hospital_outlined,
                Colors.red,
                () => context.go('/services/nursing'),
              ),
              _buildServiceTypeCard(
                '튜터링',
                '학습 지도',
                Icons.school_outlined,
                Colors.blue,
                () => context.go('/services/tutoring'),
              ),
              _buildServiceTypeCard(
                '심리상담',
                '정신건강 상담',
                Icons.psychology_outlined,
                Colors.green,
                () => context.go('/services/counseling'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTypeCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return AppCard(
      variant: CardVariant.outlined,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      borderColor: color.withOpacity(0.3),
      backgroundColor: color.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCards() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        // 안전한 표시 조건 계산 (percentage가 null이어도 안전)
        final bool showProfileCard = user?.isFreelancer == true &&
            _profileStatus != null &&
            (((_profileStatus!['percentage'] as num?) ?? 0) < 100);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // 프로필 상태 카드
              if (showProfileCard) _buildProfileStatusCard(),

              // 상태 요약 카드
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      backgroundColor: AppColor.white,
                      variant: CardVariant.filled,
                      padding: const EdgeInsets.all(16),
                      onTap: () => context.go('/requests'),
                      child: Column(
                        children: [
                          Icon(
                            Icons.work_outline,
                            color: Colors.blue,
                            size: 24.sp,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_pendingRequestCount',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '진행 중',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppCard(
                      backgroundColor: AppColor.white,
                      variant: CardVariant.filled,
                      padding: const EdgeInsets.all(16),
                      onTap: () => context.go('/chats'),
                      child: Column(
                        children: [
                          Icon(
                            Icons.message_outlined,
                            color: Colors.green,
                            size: 24.sp,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_unreadMessageCount',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '메시지',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppCard(
                      backgroundColor: AppColor.white,
                      variant: CardVariant.filled,
                      padding: const EdgeInsets.all(16),
                      onTap: () {
                        if (user?.isFreelancer == true) {
                          context.go('/settlement');
                        } else {
                          context.go('/activity');
                        }
                      },
                      child: Column(
                        children: [
                          Icon(
                            user?.isFreelancer == true
                                ? Icons.analytics_outlined
                                : Icons.history,
                            color: user?.isFreelancer == true
                                ? Colors.orange
                                : Colors.purple,
                            size: 24.sp,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user?.isFreelancer == true
                                ? (_earningsData != null
                                    ? '${((_earningsData!['thisMonthEarnings'] as double) / 10000).toInt()}만'
                                    : '-')
                                : '보기',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: user?.isFreelancer == true
                                  ? Colors.orange
                                  : Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.isFreelancer == true ? '이번달 수익' : '내역',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
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

    final percentage = (status['percentage'] as num?)?.toDouble() ?? 0.0;
    return AppCard(
      backgroundColor: AppColor.white,
      variant: CardVariant.filled,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: Colors.orange,
                size: 20.sp,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '프로필 완성도',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              AppButton(
                text: '완성하기',
                variant: ButtonVariant.link,
                size: ButtonSize.sm,
                onPressed: () => context.go('/profile/edit'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppProgress.percentage(
            percentage: percentage,
            variant: ProgressVariant.warning,
            showPercentage: true,
          ),
          if (((status['missingItems'] as List?) ?? const []).isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '미완성: ${(((status['missingItems'] as List?) ?? const []).join(', '))}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.orange,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

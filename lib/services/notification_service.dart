import 'dart:convert';
import '../models/notification.dart';
import '../config/app_config.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Mock 데이터 - 추후 실제 API 연동 시 제거
  Future<List<AppNotification>> getUserNotifications(
    String userId, {
    NotificationType? type,
    NotificationStatus? status,
    int? limit,
    int? offset,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    var notifications = _getMockNotifications().where(
      (notification) => notification.userId == userId,
    ).toList();

    if (type != null) {
      notifications = notifications.where(
        (notification) => notification.type == type,
      ).toList();
    }

    if (status != null) {
      notifications = notifications.where(
        (notification) => notification.status == status,
      ).toList();
    }

    // 최신순 정렬
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (offset != null) {
      notifications = notifications.skip(offset).toList();
    }

    if (limit != null) {
      notifications = notifications.take(limit).toList();
    }

    return notifications;
  }

  Future<int> getUnreadCount(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    return _getMockNotifications()
        .where((notification) => 
            notification.userId == userId && 
            notification.status == NotificationStatus.unread)
        .length;
  }

  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock implementation - 실제 구현 시 API 호출
  }

  Future<void> markAllAsRead(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock implementation - 실제 구현 시 API 호출
  }

  Future<void> deleteNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock implementation - 실제 구현 시 API 호출
  }

  Future<void> archiveNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock implementation - 실제 구현 시 API 호출
  }

  Future<NotificationSettings> getNotificationSettings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return NotificationSettings(
      userId: userId,
      pushEnabled: true,
      emailEnabled: true,
      smsEnabled: false,
      matchNotifications: true,
      contractNotifications: true,
      paymentNotifications: true,
      reviewNotifications: true,
      chatNotifications: true,
      systemNotifications: true,
      promotionNotifications: false,
      quietStartTime: '22:00',
      quietEndTime: '08:00',
      weekendNotifications: true,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock implementation - 실제 구현 시 API 호출
  }

  Future<void> sendNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String content,
    String? imageUrl,
    String? actionUrl,
    Map<String, dynamic>? data,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock implementation - 실제 구현 시 API 호출
  }

  // Mock 데이터 생성 함수
  List<AppNotification> _getMockNotifications() {
    final now = DateTime.now();
    
    return [
      AppNotification(
        id: 'notification_001',
        userId: 'user_002',
        type: NotificationType.match,
        status: NotificationStatus.unread,
        title: '새로운 매칭 요청',
        content: '김고객님이 간병 서비스를 요청했습니다. 확인해보세요!',
        actionUrl: '/matching/001',
        data: {'matchId': 'match_001'},
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
      AppNotification(
        id: 'notification_002',
        userId: 'user_002',
        type: NotificationType.contract,
        status: NotificationStatus.read,
        title: '계약 승인 완료',
        content: '김고객님과의 계약이 승인되었습니다. 서비스를 시작해보세요.',
        actionUrl: '/contract/001',
        data: {'contractId': 'contract_001'},
        createdAt: now.subtract(const Duration(hours: 2)),
        readAt: now.subtract(const Duration(hours: 1)),
      ),
      AppNotification(
        id: 'notification_003',
        userId: 'user_002',
        type: NotificationType.payment,
        status: NotificationStatus.unread,
        title: '정산 완료',
        content: '95,000원이 등록하신 계좌로 입금되었습니다.',
        actionUrl: '/payment/001',
        data: {'paymentId': 'payment_001', 'amount': 95000},
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      AppNotification(
        id: 'notification_004',
        userId: 'user_002',
        type: NotificationType.review,
        status: NotificationStatus.read,
        title: '새로운 리뷰',
        content: '김고객님이 리뷰를 작성했습니다. (⭐⭐⭐⭐⭐ 5점)',
        actionUrl: '/review/001',
        data: {'reviewId': 'review_001', 'rating': 5},
        createdAt: now.subtract(const Duration(days: 1)),
        readAt: now.subtract(const Duration(hours: 20)),
      ),
      AppNotification(
        id: 'notification_005',
        userId: 'user_002',
        type: NotificationType.chat,
        status: NotificationStatus.unread,
        title: '새로운 메시지',
        content: '김고객: 안녕하세요! 궁금한 점이 있어서 연락드립니다.',
        actionUrl: '/chat/room_001',
        data: {'chatRoomId': 'room_001'},
        createdAt: now.subtract(const Duration(minutes: 15)),
      ),
      AppNotification(
        id: 'notification_006',
        userId: 'user_002',
        type: NotificationType.system,
        status: NotificationStatus.read,
        title: '앱 업데이트 알림',
        content: '새로운 기능이 추가된 최신 버전이 출시되었습니다.',
        actionUrl: '/app-update',
        createdAt: now.subtract(const Duration(days: 3)),
        readAt: now.subtract(const Duration(days: 2)),
      ),
      AppNotification(
        id: 'notification_007',
        userId: 'user_002',
        type: NotificationType.promotion,
        status: NotificationStatus.unread,
        title: '특별 이벤트 🎉',
        content: '첫 서비스 완료 시 보너스 적립! 지금 바로 확인하세요.',
        imageUrl: 'https://example.com/promo.jpg',
        actionUrl: '/promotion/001',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      // user_001 알림
      AppNotification(
        id: 'notification_008',
        userId: 'user_001',
        type: NotificationType.match,
        status: NotificationStatus.read,
        title: '매칭 성공',
        content: '김프리님이 매칭되었습니다. 채팅으로 상세 내용을 논의해보세요.',
        actionUrl: '/chat/room_001',
        data: {'matchId': 'match_001', 'freelancerId': 'user_002'},
        createdAt: now.subtract(const Duration(hours: 6)),
        readAt: now.subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: 'notification_009',
        userId: 'user_001',
        type: NotificationType.contract,
        status: NotificationStatus.unread,
        title: '계약서 확인 요청',
        content: '김프리님이 작성한 계약서를 확인하고 승인해주세요.',
        actionUrl: '/contract/001',
        data: {'contractId': 'contract_001'},
        createdAt: now.subtract(const Duration(minutes: 45)),
      ),
    ];
  }
}

enum NotificationType {
  match,        // 매칭 알림
  contract,     // 계약 알림
  payment,      // 정산 알림
  review,       // 리뷰 알림
  chat,         // 채팅 알림
  system,       // 시스템 알림
  promotion     // 프로모션 알림
}

enum NotificationStatus {
  unread,       // 읽지 않음
  read,         // 읽음
  archived      // 보관됨
}

class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final NotificationStatus status;
  final String title;
  final String content;
  final String? imageUrl;
  final String? actionUrl;  // 알림 클릭 시 이동할 URL
  final Map<String, dynamic>? data; // 추가 데이터
  final DateTime createdAt;
  final DateTime? readAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.title,
    required this.content,
    this.imageUrl,
    this.actionUrl,
    this.data,
    required this.createdAt,
    this.readAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['user_id'],
      type: NotificationType.values.firstWhere(
        (type) => type.toString().split('.').last == json['type'],
      ),
      status: NotificationStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['status'],
      ),
      title: json['title'],
      content: json['content'],
      imageUrl: json['image_url'],
      actionUrl: json['action_url'],
      data: json['data'],
      createdAt: DateTime.parse(json['created_at']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'action_url': actionUrl,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    NotificationStatus? status,
    String? title,
    String? content,
    String? imageUrl,
    String? actionUrl,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  bool get isRead => status != NotificationStatus.unread;
}

class NotificationSettings {
  final String userId;
  final bool pushEnabled;              // 푸시 알림 활성화
  final bool emailEnabled;             // 이메일 알림 활성화
  final bool smsEnabled;               // SMS 알림 활성화
  final bool matchNotifications;       // 매칭 알림
  final bool contractNotifications;    // 계약 알림
  final bool paymentNotifications;     // 정산 알림
  final bool reviewNotifications;      // 리뷰 알림
  final bool chatNotifications;        // 채팅 알림
  final bool systemNotifications;      // 시스템 알림
  final bool promotionNotifications;   // 프로모션 알림
  final String quietStartTime;         // 방해금지 시작 시간 (HH:mm)
  final String quietEndTime;           // 방해금지 종료 시간 (HH:mm)
  final bool weekendNotifications;     // 주말 알림 허용
  final DateTime updatedAt;

  const NotificationSettings({
    required this.userId,
    required this.pushEnabled,
    required this.emailEnabled,
    required this.smsEnabled,
    required this.matchNotifications,
    required this.contractNotifications,
    required this.paymentNotifications,
    required this.reviewNotifications,
    required this.chatNotifications,
    required this.systemNotifications,
    required this.promotionNotifications,
    required this.quietStartTime,
    required this.quietEndTime,
    required this.weekendNotifications,
    required this.updatedAt,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      userId: json['user_id'],
      pushEnabled: json['push_enabled'] ?? true,
      emailEnabled: json['email_enabled'] ?? true,
      smsEnabled: json['sms_enabled'] ?? false,
      matchNotifications: json['match_notifications'] ?? true,
      contractNotifications: json['contract_notifications'] ?? true,
      paymentNotifications: json['payment_notifications'] ?? true,
      reviewNotifications: json['review_notifications'] ?? true,
      chatNotifications: json['chat_notifications'] ?? true,
      systemNotifications: json['system_notifications'] ?? true,
      promotionNotifications: json['promotion_notifications'] ?? false,
      quietStartTime: json['quiet_start_time'] ?? '22:00',
      quietEndTime: json['quiet_end_time'] ?? '08:00',
      weekendNotifications: json['weekend_notifications'] ?? true,
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'push_enabled': pushEnabled,
      'email_enabled': emailEnabled,
      'sms_enabled': smsEnabled,
      'match_notifications': matchNotifications,
      'contract_notifications': contractNotifications,
      'payment_notifications': paymentNotifications,
      'review_notifications': reviewNotifications,
      'chat_notifications': chatNotifications,
      'system_notifications': systemNotifications,
      'promotion_notifications': promotionNotifications,
      'quiet_start_time': quietStartTime,
      'quiet_end_time': quietEndTime,
      'weekend_notifications': weekendNotifications,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  NotificationSettings copyWith({
    String? userId,
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
    bool? matchNotifications,
    bool? contractNotifications,
    bool? paymentNotifications,
    bool? reviewNotifications,
    bool? chatNotifications,
    bool? systemNotifications,
    bool? promotionNotifications,
    String? quietStartTime,
    String? quietEndTime,
    bool? weekendNotifications,
    DateTime? updatedAt,
  }) {
    return NotificationSettings(
      userId: userId ?? this.userId,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      matchNotifications: matchNotifications ?? this.matchNotifications,
      contractNotifications: contractNotifications ?? this.contractNotifications,
      paymentNotifications: paymentNotifications ?? this.paymentNotifications,
      reviewNotifications: reviewNotifications ?? this.reviewNotifications,
      chatNotifications: chatNotifications ?? this.chatNotifications,
      systemNotifications: systemNotifications ?? this.systemNotifications,
      promotionNotifications: promotionNotifications ?? this.promotionNotifications,
      quietStartTime: quietStartTime ?? this.quietStartTime,
      quietEndTime: quietEndTime ?? this.quietEndTime,
      weekendNotifications: weekendNotifications ?? this.weekendNotifications,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.match:
        return '매칭';
      case NotificationType.contract:
        return '계약';
      case NotificationType.payment:
        return '정산';
      case NotificationType.review:
        return '리뷰';
      case NotificationType.chat:
        return '채팅';
      case NotificationType.system:
        return '시스템';
      case NotificationType.promotion:
        return '프로모션';
    }
  }

  String get icon {
    switch (this) {
      case NotificationType.match:
        return '🤝';
      case NotificationType.contract:
        return '📋';
      case NotificationType.payment:
        return '💰';
      case NotificationType.review:
        return '⭐';
      case NotificationType.chat:
        return '💬';
      case NotificationType.system:
        return '⚙️';
      case NotificationType.promotion:
        return '🎉';
    }
  }
}

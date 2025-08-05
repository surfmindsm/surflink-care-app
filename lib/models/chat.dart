import 'package:flutter/material.dart';

enum MessageType {
  text,
  image,
  file,
  system,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

enum ChatRoomStatus {
  active,
  completed,
  reported,
  blocked,
}

enum ChatRoomType {
  matching, // 매칭으로 생성된 채팅방
  contract, // 계약 관련 채팅방
  support, // 고객 지원 채팅방
}

extension ChatRoomTypeExtension on ChatRoomType {
  String get displayName {
    switch (this) {
      case ChatRoomType.matching:
        return '매칭 채팅';
      case ChatRoomType.contract:
        return '계약 채팅';
      case ChatRoomType.support:
        return '고객지원';
    }
  }
  
  Color get color {
    switch (this) {
      case ChatRoomType.matching:
        return Colors.blue;
      case ChatRoomType.contract:
        return Colors.green;
      case ChatRoomType.support:
        return Colors.orange;
    }
  }
}

// Extensions for display names
extension MessageTypeExtension on MessageType {
  String get displayName {
    switch (this) {
      case MessageType.text:
        return '텍스트';
      case MessageType.image:
        return '이미지';
      case MessageType.file:
        return '파일';
      case MessageType.system:
        return '시스템';
    }
  }

  IconData get icon {
    switch (this) {
      case MessageType.text:
        return Icons.message;
      case MessageType.image:
        return Icons.image;
      case MessageType.file:
        return Icons.attach_file;
      case MessageType.system:
        return Icons.info;
    }
  }
}

extension MessageStatusExtension on MessageStatus {
  String get displayName {
    switch (this) {
      case MessageStatus.sending:
        return '전송중';
      case MessageStatus.sent:
        return '전송됨';
      case MessageStatus.delivered:
        return '전달됨';
      case MessageStatus.read:
        return '읽음';
      case MessageStatus.failed:
        return '전송실패';
    }
  }

  Color get color {
    switch (this) {
      case MessageStatus.sending:
        return Colors.grey;
      case MessageStatus.sent:
        return Colors.blue;
      case MessageStatus.delivered:
        return Colors.green;
      case MessageStatus.read:
        return Colors.teal;
      case MessageStatus.failed:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case MessageStatus.sending:
        return Icons.schedule;
      case MessageStatus.sent:
        return Icons.done;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error;
    }
  }
}

extension ChatRoomStatusExtension on ChatRoomStatus {
  String get displayName {
    switch (this) {
      case ChatRoomStatus.active:
        return '활성';
      case ChatRoomStatus.completed:
        return '완료';
      case ChatRoomStatus.reported:
        return '신고됨';
      case ChatRoomStatus.blocked:
        return '차단됨';
    }
  }

  Color get color {
    switch (this) {
      case ChatRoomStatus.active:
        return Colors.green;
      case ChatRoomStatus.completed:
        return Colors.blue;
      case ChatRoomStatus.reported:
        return Colors.orange;
      case ChatRoomStatus.blocked:
        return Colors.red;
    }
  }
}

class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String? senderName;
  final String? senderProfileUrl;
  final MessageType type;
  final String content;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? thumbnailUrl;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? replyToMessageId;
  final Map<String, dynamic>? metadata;

  const ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    this.senderName,
    this.senderProfileUrl,
    required this.type,
    required this.content,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.thumbnailUrl,
    required this.status,
    required this.createdAt,
    this.readAt,
    this.replyToMessageId,
    this.metadata,
  });

  // JSON serialization
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      chatRoomId: json['chat_room_id'],
      senderId: json['sender_id'],
      senderName: json['sender_name'],
      senderProfileUrl: json['sender_profile_url'],
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      content: json['content'],
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      fileSize: json['file_size'],
      thumbnailUrl: json['thumbnail_url'],
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      createdAt: DateTime.parse(json['created_at']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      replyToMessageId: json['reply_to_message_id'],
      metadata: json['metadata']?.cast<String, dynamic>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_room_id': chatRoomId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_profile_url': senderProfileUrl,
      'type': type.name,
      'content': content,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size': fileSize,
      'thumbnail_url': thumbnailUrl,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'reply_to_message_id': replyToMessageId,
      'metadata': metadata,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? senderProfileUrl,
    MessageType? type,
    String? content,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? thumbnailUrl,
    MessageStatus? status,
    DateTime? createdAt,
    DateTime? readAt,
    String? replyToMessageId,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderProfileUrl: senderProfileUrl ?? this.senderProfileUrl,
      type: type ?? this.type,
      content: content ?? this.content,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper getters
  bool get isRead => readAt != null;
  bool get isImage => type == MessageType.image;
  bool get isFile => type == MessageType.file;
  bool get isSystem => type == MessageType.system;
  bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;
  
  String get displayContent {
    switch (type) {
      case MessageType.text:
        return content;
      case MessageType.image:
        return '📷 이미지';
      case MessageType.file:
        return '📁 ${fileName ?? '파일'}';
      case MessageType.system:
        return content;
    }
  }
}

class ChatRoom {
  final String id;
  final String name;
  final ChatRoomType type;
  final ChatRoomStatus status;
  final List<String> participantIds;
  final List<ChatParticipant> participants;
  final String? requestId;
  final String? contractId;
  final String? matchingId;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActivityAt;
  final Map<String, dynamic>? metadata;

  const ChatRoom({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.participantIds,
    required this.participants,
    this.requestId,
    this.contractId,
    this.matchingId,
    this.lastMessage,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
    this.lastActivityAt,
    this.metadata,
  });

  // JSON serialization
  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      name: json['name'],
      type: ChatRoomType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChatRoomType.matching,
      ),
      status: ChatRoomStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ChatRoomStatus.active,
      ),
      participantIds: List<String>.from(json['participant_ids']),
      participants: (json['participants'] as List)
          .map((p) => ChatParticipant.fromJson(p))
          .toList(),
      requestId: json['request_id'],
      contractId: json['contract_id'],
      matchingId: json['matching_id'],
      lastMessage: json['last_message'] != null
          ? ChatMessage.fromJson(json['last_message'])
          : null,
      unreadCount: json['unread_count'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      lastActivityAt: json['last_activity_at'] != null
          ? DateTime.parse(json['last_activity_at'])
          : null,
      metadata: json['metadata']?.cast<String, dynamic>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'status': status.name,
      'participant_ids': participantIds,
      'participants': participants.map((p) => p.toJson()).toList(),
      'request_id': requestId,
      'contract_id': contractId,
      'matching_id': matchingId,
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_activity_at': lastActivityAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Helper methods
  ChatParticipant? getOtherParticipant(String currentUserId) {
    return participants.firstWhere(
      (p) => p.userId != currentUserId,
      orElse: () => participants.first,
    );
  }

  bool hasUnreadMessages() => unreadCount > 0;
  bool get isActive => status == ChatRoomStatus.active;
  bool get isBlocked => status == ChatRoomStatus.blocked;
}

class ChatParticipant {
  final String userId;
  final String name;
  final String? profileImageUrl;
  final String role; // 'customer' or 'freelancer'
  final DateTime joinedAt;
  final DateTime? leftAt;
  final DateTime? lastReadAt;
  final bool isOnline;
  final DateTime? lastSeenAt;

  const ChatParticipant({
    required this.userId,
    required this.name,
    this.profileImageUrl,
    required this.role,
    required this.joinedAt,
    this.leftAt,
    this.lastReadAt,
    required this.isOnline,
    this.lastSeenAt,
  });

  // JSON serialization
  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      userId: json['user_id'],
      name: json['name'],
      profileImageUrl: json['profile_image_url'],
      role: json['role'],
      joinedAt: DateTime.parse(json['joined_at']),
      leftAt: json['left_at'] != null ? DateTime.parse(json['left_at']) : null,
      lastReadAt: json['last_read_at'] != null
          ? DateTime.parse(json['last_read_at'])
          : null,
      isOnline: json['is_online'],
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.parse(json['last_seen_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'profile_image_url': profileImageUrl,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
      'left_at': leftAt?.toIso8601String(),
      'last_read_at': lastReadAt?.toIso8601String(),
      'is_online': isOnline,
      'last_seen_at': lastSeenAt?.toIso8601String(),
    };
  }
}

// Request models for chat operations
class ChatMessageSendRequest {
  final String chatRoomId;
  final MessageType type;
  final String content;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? replyToMessageId;
  final Map<String, dynamic>? metadata;

  const ChatMessageSendRequest({
    required this.chatRoomId,
    required this.type,
    required this.content,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.replyToMessageId,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'chat_room_id': chatRoomId,
      'type': type.name,
      'content': content,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size': fileSize,
      'reply_to_message_id': replyToMessageId,
      'metadata': metadata,
    };
  }
}

class ChatRoomCreateRequest {
  final ChatRoomType type;
  final String name;
  final List<String> participantIds;
  final String? requestId;
  final String? contractId;
  final String? matchingId;
  final Map<String, dynamic>? metadata;

  const ChatRoomCreateRequest({
    required this.type,
    required this.name,
    required this.participantIds,
    this.requestId,
    this.contractId,
    this.matchingId,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'name': name,
      'participant_ids': participantIds,
      'request_id': requestId,
      'contract_id': contractId,
      'matching_id': matchingId,
      'metadata': metadata,
    };
  }
}

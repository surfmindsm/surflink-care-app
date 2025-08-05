import 'package:flutter/material.dart';

enum ReportType {
  user,         // 사용자 신고
  contract,     // 계약 관련 신고
  payment,      // 정산 관련 신고
  service,      // 서비스 관련 신고
  app,          // 앱 관련 문의
  other         // 기타
}

enum ReportStatus {
  submitted,    // 신고 접수
  reviewing,    // 검토중
  resolved,     // 해결됨
  rejected,     // 반려됨
  closed        // 종료됨
}

enum ReportPriority {
  low,          // 낮음
  medium,       // 보통
  high,         // 높음
  urgent        // 긴급
}

class Report {
  final String id;
  final String reporterId;    // 신고자 ID
  final String? reporterName; // 신고자 이름
  final String? targetId;     // 신고 대상 ID (사용자, 계약 등)
  final String? targetName;   // 신고 대상 이름
  final ReportType type;
  final ReportStatus status;
  final ReportPriority priority;
  final String subject;       // 신고 제목
  final String description;   // 신고 내용
  final List<String> attachments; // 첨부파일 URL 목록
  final String? adminResponse;    // 관리자 답변
  final String? adminId;          // 처리한 관리자 ID
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;     // 해결된 시간
  final Map<String, dynamic>? metadata;

  const Report({
    required this.id,
    required this.reporterId,
    this.reporterName,
    this.targetId,
    this.targetName,
    required this.type,
    required this.status,
    required this.priority,
    required this.subject,
    required this.description,
    required this.attachments,
    this.adminResponse,
    this.adminId,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.metadata,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      reporterId: json['reporter_id'],
      reporterName: json['reporter_name'],
      targetId: json['target_id'],
      targetName: json['target_name'],
      type: ReportType.values.firstWhere(
        (type) => type.toString().split('.').last == json['type'],
      ),
      status: ReportStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['status'],
      ),
      priority: ReportPriority.values.firstWhere(
        (priority) => priority.toString().split('.').last == json['priority'],
      ),
      subject: json['subject'],
      description: json['description'],
      attachments: (json['attachments'] as List<dynamic>?)?.cast<String>() ?? [],
      adminResponse: json['admin_response'],
      adminId: json['admin_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'reporter_name': reporterName,
      'target_id': targetId,
      'target_name': targetName,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'subject': subject,
      'description': description,
      'attachments': attachments,
      'admin_response': adminResponse,
      'admin_id': adminId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Report copyWith({
    String? id,
    String? reporterId,
    String? reporterName,
    String? targetId,
    String? targetName,
    ReportType? type,
    ReportStatus? status,
    ReportPriority? priority,
    String? subject,
    String? description,
    List<String>? attachments,
    String? adminResponse,
    String? adminId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Report(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      targetId: targetId ?? this.targetId,
      targetName: targetName ?? this.targetName,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      attachments: attachments ?? this.attachments,
      adminResponse: adminResponse ?? this.adminResponse,
      adminId: adminId ?? this.adminId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isResolved => status == ReportStatus.resolved || status == ReportStatus.closed;
  bool get hasResponse => adminResponse != null && adminResponse!.isNotEmpty;
}

class ReportCreateRequest {
  final String? targetId;
  final String? targetName;
  final ReportType type;
  final String subject;
  final String description;
  final List<String> attachments;
  final Map<String, dynamic>? metadata;

  const ReportCreateRequest({
    this.targetId,
    this.targetName,
    required this.type,
    required this.subject,
    required this.description,
    required this.attachments,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'target_id': targetId,
      'target_name': targetName,
      'type': type.toString().split('.').last,
      'subject': subject,
      'description': description,
      'attachments': attachments,
      'metadata': metadata,
    };
  }
}

// FAQ 모델
class FAQ {
  final String id;
  final String category;
  final String question;
  final String answer;
  final int viewCount;
  final bool isPopular;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FAQ({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    required this.viewCount,
    required this.isPopular,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      id: json['id'],
      category: json['category'],
      question: json['question'],
      answer: json['answer'],
      viewCount: json['view_count'] ?? 0,
      isPopular: json['is_popular'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'question': question,
      'answer': answer,
      'view_count': viewCount,
      'is_popular': isPopular,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

extension ReportTypeExtension on ReportType {
  String get displayName {
    switch (this) {
      case ReportType.user:
        return '사용자 신고';
      case ReportType.contract:
        return '계약 관련';
      case ReportType.payment:
        return '정산 관련';
      case ReportType.service:
        return '서비스 관련';
      case ReportType.app:
        return '앱 관련';
      case ReportType.other:
        return '기타';
    }
  }

  String get icon {
    switch (this) {
      case ReportType.user:
        return '👤';
      case ReportType.contract:
        return '📋';
      case ReportType.payment:
        return '💰';
      case ReportType.service:
        return '🛠️';
      case ReportType.app:
        return '📱';
      case ReportType.other:
        return '❓';
    }
  }
}

extension ReportStatusExtension on ReportStatus {
  String get displayName {
    switch (this) {
      case ReportStatus.submitted:
        return '접수됨';
      case ReportStatus.reviewing:
        return '검토중';
      case ReportStatus.resolved:
        return '해결됨';
      case ReportStatus.rejected:
        return '반려됨';
      case ReportStatus.closed:
        return '종료됨';
    }
  }

  Color get color {
    switch (this) {
      case ReportStatus.submitted:
        return Colors.blue;
      case ReportStatus.reviewing:
        return Colors.orange;
      case ReportStatus.resolved:
        return Colors.green;
      case ReportStatus.rejected:
        return Colors.red;
      case ReportStatus.closed:
        return Colors.grey;
    }
  }
}

extension ReportPriorityExtension on ReportPriority {
  String get displayName {
    switch (this) {
      case ReportPriority.low:
        return '낮음';
      case ReportPriority.medium:
        return '보통';
      case ReportPriority.high:
        return '높음';
      case ReportPriority.urgent:
        return '긴급';
    }
  }

  Color get color {
    switch (this) {
      case ReportPriority.low:
        return Colors.green;
      case ReportPriority.medium:
        return Colors.blue;
      case ReportPriority.high:
        return Colors.orange;
      case ReportPriority.urgent:
        return Colors.red;
    }
  }
}

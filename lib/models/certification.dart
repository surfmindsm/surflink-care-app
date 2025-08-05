enum CertificationType {
  license,        // 자격증
  certificate,    // 수료증
  education,      // 학위/학력
  experience,     // 경력증명
  portfolio,      // 포트폴리오
  other          // 기타
}

enum CertificationStatus {
  pending,       // 검토중
  approved,      // 승인됨
  rejected,      // 거부됨
  expired        // 만료됨
}

extension CertificationTypeExtension on CertificationType {
  String get displayName {
    switch (this) {
      case CertificationType.license:
        return '자격증';
      case CertificationType.certificate:
        return '수료증';
      case CertificationType.education:
        return '학력';
      case CertificationType.experience:
        return '경력증명';
      case CertificationType.portfolio:
        return '포트폴리오';
      case CertificationType.other:
        return '기타';
    }
  }
}

extension CertificationStatusExtension on CertificationStatus {
  String get displayName {
    switch (this) {
      case CertificationStatus.pending:
        return '검토중';
      case CertificationStatus.approved:
        return '승인됨';
      case CertificationStatus.rejected:
        return '거부됨';
      case CertificationStatus.expired:
        return '만료됨';
    }
  }
}

class Certification {
  final String id;
  final String freelancerId;
  final String title;
  final String description;
  final CertificationType type;
  final CertificationStatus status;
  final List<String> fileUrls;
  final String? issuer;           // 발급기관
  final DateTime? issueDate;      // 발급일
  final DateTime? expiryDate;     // 만료일
  final String? licenseNumber;    // 자격증 번호
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? reviewNotes;      // 검토 의견
  final DateTime? reviewedAt;     // 검토일
  final String? reviewerId;       // 검토자 ID

  const Certification({
    required this.id,
    required this.freelancerId,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.fileUrls,
    this.issuer,
    this.issueDate,
    this.expiryDate,
    this.licenseNumber,
    required this.createdAt,
    required this.updatedAt,
    this.reviewNotes,
    this.reviewedAt,
    this.reviewerId,
  });

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      id: json['id'],
      freelancerId: json['freelancer_id'],
      title: json['title'],
      description: json['description'],
      type: CertificationType.values.firstWhere(
        (type) => type.toString().split('.').last == json['type'],
      ),
      status: CertificationStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['status'],
      ),
      fileUrls: List<String>.from(json['file_urls'] ?? []),
      issuer: json['issuer'],
      issueDate: json['issue_date'] != null ? DateTime.parse(json['issue_date']) : null,
      expiryDate: json['expiry_date'] != null ? DateTime.parse(json['expiry_date']) : null,
      licenseNumber: json['license_number'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      reviewNotes: json['review_notes'],
      reviewedAt: json['reviewed_at'] != null ? DateTime.parse(json['reviewed_at']) : null,
      reviewerId: json['reviewer_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'freelancer_id': freelancerId,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'file_urls': fileUrls,
      'issuer': issuer,
      'issue_date': issueDate?.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'license_number': licenseNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'review_notes': reviewNotes,
      'reviewed_at': reviewedAt?.toIso8601String(),
      'reviewer_id': reviewerId,
    };
  }

  Certification copyWith({
    String? id,
    String? freelancerId,
    String? title,
    String? description,
    CertificationType? type,
    CertificationStatus? status,
    List<String>? fileUrls,
    String? issuer,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? licenseNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? reviewNotes,
    DateTime? reviewedAt,
    String? reviewerId,
  }) {
    return Certification(
      id: id ?? this.id,
      freelancerId: freelancerId ?? this.freelancerId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      fileUrls: fileUrls ?? this.fileUrls,
      issuer: issuer ?? this.issuer,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewerId: reviewerId ?? this.reviewerId,
    );
  }

  // Helper methods
  String get typeDisplayName {
    switch (type) {
      case CertificationType.license:
        return '자격증';
      case CertificationType.certificate:
        return '수료증';
      case CertificationType.education:
        return '학력';
      case CertificationType.experience:
        return '경력증명';
      case CertificationType.portfolio:
        return '포트폴리오';
      case CertificationType.other:
        return '기타';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case CertificationStatus.pending:
        return '검토중';
      case CertificationStatus.approved:
        return '승인됨';
      case CertificationStatus.rejected:
        return '거부됨';
      case CertificationStatus.expired:
        return '만료됨';
    }
  }

  bool get isApproved => status == CertificationStatus.approved;
  bool get isPending => status == CertificationStatus.pending;
  bool get isRejected => status == CertificationStatus.rejected;
  bool get isExpired => status == CertificationStatus.expired;
  
  bool get isExpiring {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final daysUntilExpiry = expiryDate!.difference(now).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  bool get hasExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }
}

// 파일 업로드 결과를 위한 모델
class FileUploadResult {
  final bool success;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? error;

  const FileUploadResult({
    required this.success,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.error,
  });

  factory FileUploadResult.success({
    required String fileUrl,
    required String fileName,
    required int fileSize,
  }) {
    return FileUploadResult(
      success: true,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSize: fileSize,
    );
  }

  factory FileUploadResult.failure(String error) {
    return FileUploadResult(
      success: false,
      error: error,
    );
  }
}

enum UserType { freelancer, customer }

enum UserStatus { active, inactive, suspended }

class User {
  final String id;
  final String email;
  final String? phone;
  final String name;
  final DateTime? birth;
  final String? gender;
  final UserType userType;
  final UserStatus status;
  final String? profileImageUrl;
  final String? region;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // 프리랜서 전용 필드
  final List<String>? specialties; // 전문분야
  final int? careerYears; // 경력기간
  final String? introduction; // 자기소개
  final List<String>? availableTimes; // 서비스 가능 시간
  final Map<String, dynamic>? payInfo; // 급여 정보
  final bool? isVerified; // 인증 여부
  final double? rating; // 평점
  final int? reviewCount; // 리뷰 수
  
  // 고객 전용 필드
  final String? purpose; // 이용목적
  final Map<String, bool>? notificationSettings; // 알림설정
  
  const User({
    required this.id,
    required this.email,
    this.phone,
    required this.name,
    this.birth,
    this.gender,
    required this.userType,
    required this.status,
    this.profileImageUrl,
    this.region,
    required this.createdAt,
    required this.updatedAt,
    // 프리랜서 필드
    this.specialties,
    this.careerYears,
    this.introduction,
    this.availableTimes,
    this.payInfo,
    this.isVerified,
    this.rating,
    this.reviewCount,
    // 고객 필드
    this.purpose,
    this.notificationSettings,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      name: json['name'],
      birth: json['birth'] != null ? DateTime.parse(json['birth']) : null,
      gender: json['gender'],
      userType: UserType.values.firstWhere(
        (type) => type.toString().split('.').last == json['user_type'],
      ),
      status: UserStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['status'],
      ),
      profileImageUrl: json['profile_image_url'],
      region: json['region'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      // 프리랜서 필드
      specialties: json['specialties']?.cast<String>(),
      careerYears: json['career_years'],
      introduction: json['introduction'],
      availableTimes: json['available_times']?.cast<String>(),
      payInfo: json['pay_info'],
      isVerified: json['is_verified'],
      rating: json['rating']?.toDouble(),
      reviewCount: json['review_count'],
      // 고객 필드
      purpose: json['purpose'],
      notificationSettings: json['notification_settings']?.cast<String, bool>(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'name': name,
      'birth': birth?.toIso8601String(),
      'gender': gender,
      'user_type': userType.toString().split('.').last,
      'status': status.toString().split('.').last,
      'profile_image_url': profileImageUrl,
      'region': region,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      // 프리랜서 필드
      if (specialties != null) 'specialties': specialties,
      if (careerYears != null) 'career_years': careerYears,
      if (introduction != null) 'introduction': introduction,
      if (availableTimes != null) 'available_times': availableTimes,
      if (payInfo != null) 'pay_info': payInfo,
      if (isVerified != null) 'is_verified': isVerified,
      if (rating != null) 'rating': rating,
      if (reviewCount != null) 'review_count': reviewCount,
      // 고객 필드
      if (purpose != null) 'purpose': purpose,
      if (notificationSettings != null) 'notification_settings': notificationSettings,
    };
  }
  
  User copyWith({
    String? id,
    String? email,
    String? phone,
    String? name,
    DateTime? birth,
    String? gender,
    UserType? userType,
    UserStatus? status,
    String? profileImageUrl,
    String? region,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? specialties,
    int? careerYears,
    String? introduction,
    List<String>? availableTimes,
    Map<String, dynamic>? payInfo,
    bool? isVerified,
    double? rating,
    int? reviewCount,
    String? purpose,
    Map<String, bool>? notificationSettings,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      birth: birth ?? this.birth,
      gender: gender ?? this.gender,
      userType: userType ?? this.userType,
      status: status ?? this.status,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      region: region ?? this.region,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      specialties: specialties ?? this.specialties,
      careerYears: careerYears ?? this.careerYears,
      introduction: introduction ?? this.introduction,
      availableTimes: availableTimes ?? this.availableTimes,
      payInfo: payInfo ?? this.payInfo,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      purpose: purpose ?? this.purpose,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }
  
  bool get isFreelancer => userType == UserType.freelancer;
  bool get isCustomer => userType == UserType.customer;
  bool get isActive => status == UserStatus.active;
  String? get profileImage => profileImageUrl; // Backward compatibility
}

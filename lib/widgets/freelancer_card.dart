import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/request.dart';
import '../config/app_config.dart';

class FreelancerCard extends StatelessWidget {
  final User freelancer;
  final VoidCallback onTap;

  const FreelancerCard({
    super.key,
    required this.freelancer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 헤더
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: freelancer.profileImage != null
                        ? NetworkImage(freelancer.profileImage!)
                        : null,
                    child: freelancer.profileImage == null
                        ? Text(
                            freelancer.name[0],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          freelancer.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${freelancer.rating ?? 0} (${freelancer.reviewCount ?? 0})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              freelancer.region ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildOnlineIndicator(),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 전문 분야
              if (freelancer.specialties?.isNotEmpty == true)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: freelancer.specialties!.map((specialty) {
                    return _buildSpecialtyChip(specialty);
                  }).toList(),
                ),
              
              const SizedBox(height: 12),
              
              // 소개
              if (freelancer.introduction?.isNotEmpty == true)
                Text(
                  freelancer.introduction!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const SizedBox(height: 12),
              
              // 하단 정보
              Row(
                children: [
                  if (freelancer.careerYears != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(AppConfig.primaryColor).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '경력 ${freelancer.careerYears}년',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(AppConfig.primaryColor),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                  Text(
                    '활동 ${_getActivityPeriod(freelancer.createdAt)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialtyChip(String specialty) {
    // specialty 문자열을 ServiceType으로 변환
    ServiceType? serviceType;
    switch (specialty) {
      case 'childcare':
        serviceType = ServiceType.childcare;
        break;
      case 'eldercare':
        serviceType = ServiceType.eldercare;
        break;
      case 'tutoring':
        serviceType = ServiceType.tutoring;
        break;
      case 'counseling':
        serviceType = ServiceType.counseling;
        break;
    }

    Color color;
    String label;
    if (serviceType != null) {
      label = serviceType.label;
      switch (serviceType) {
        case ServiceType.childcare:
          color = Colors.pink;
          break;
        case ServiceType.eldercare:
          color = Colors.orange;
          break;
        case ServiceType.tutoring:
          color = Colors.blue;
          break;
        case ServiceType.counseling:
          color = Colors.green;
          break;
      }
    } else {
      label = specialty;
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildOnlineIndicator() {
    // TODO: 실제 온라인 상태 API 연동
    final isOnline = DateTime.now().millisecondsSinceEpoch % 2 == 0;
    
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isOnline ? Colors.green : Colors.grey[400],
        shape: BoxShape.circle,
      ),
    );
  }

  String _getActivityPeriod(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays < 30) {
      return '${difference.inDays}일';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}개월';
    } else {
      return '${(difference.inDays / 365).floor()}년';
    }
  }
}

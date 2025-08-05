import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/request.dart';
import '../config/app_config.dart';

class RequestCard extends StatelessWidget {
  final ServiceRequest request;
  final VoidCallback onTap;

  const RequestCard({
    super.key,
    required this.request,
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
              // 헤더
              Row(
                children: [
                  _buildServiceTypeChip(),
                  const Spacer(),
                  _buildStatusChip(),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 제목
              Text(
                request.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // 설명
              Text(
                request.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // 정보
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      request.region,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.schedule_outlined,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MM/dd').format(request.startDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 하단 정보
              Row(
                children: [
                  if (request.budget != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(AppConfig.primaryColor).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '시급 ${NumberFormat('#,###').format(request.budget)}원',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(AppConfig.primaryColor),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                  Text(
                    _getTimeAgo(request.createdAt),
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

  Widget _buildServiceTypeChip() {
    Color color;
    switch (request.serviceType) {
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        request.serviceType.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    switch (request.status) {
      case RequestStatus.pending:
        color = Colors.orange;
        break;
      case RequestStatus.matched:
        color = Colors.blue;
        break;
      case RequestStatus.inProgress:
        color = Colors.purple;
        break;
      case RequestStatus.completed:
        color = Colors.green;
        break;
      case RequestStatus.cancelled:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        request.status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return DateFormat('MM/dd').format(dateTime);
    }
  }
}

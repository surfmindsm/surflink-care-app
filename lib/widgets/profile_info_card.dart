import 'package:flutter/material.dart';
import '../config/app_config.dart';

class ProfileInfoItem {
  final String label;
  final String value;
  final IconData icon;
  final int maxLines;

  const ProfileInfoItem({
    required this.label,
    required this.value,
    required this.icon,
    this.maxLines = 1,
  });
}

class ProfileInfoCard extends StatelessWidget {
  final List<ProfileInfoItem> items;

  const ProfileInfoCard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(AppConfig.primaryColor).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item.icon,
                        color: Color(AppConfig.primaryColor),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.value,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: item.maxLines,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

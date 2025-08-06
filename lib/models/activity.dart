enum ActivityType {
  matching,
  message,
  payment,
  contract,
  review,
  settlement,
  service,
}

class Activity {
  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final DateTime date;
  bool isRead;

  Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.date,
    this.isRead = false,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      type: ActivityType.values.firstWhere(
        (t) => t.toString().split('.').last == json['type'],
      ),
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'is_read': isRead,
    };
  }
}

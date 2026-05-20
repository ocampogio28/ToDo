class TodoItem {
  String id;
  String title;
  String? details; // 👈 Must be nullable
  DateTime? dueDate; // 👈 Must be nullable

  TodoItem({required this.id, required this.title, this.details, this.dueDate});

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String,
      title: json['title'] as String,
      details: json['details'] as String?, // 👈 Read from JSON
      dueDate: json['dueDate'] != null
          ? DateTime.parse(
              json['dueDate'] as String,
            ) // 👈 Parse string back to DateTime
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'details': details, // 👈 Write to JSON
      'dueDate': dueDate?.toIso8601String(), // 👈 Convert DateTime to string
    };
  }
}

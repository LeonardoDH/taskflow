import 'package:cloud_firestore/cloud_firestore.dart';

enum Priority { high, medium, low }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final Priority priority;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = Priority.medium,
    this.isCompleted = false,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromJson(String id, Map<String, dynamic> json) {
    return TaskModel(
      id: id,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      priority: Priority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => Priority.medium,
      ),
      isCompleted: json['isCompleted'] as bool? ?? false,
      dueDate: (json['dueDate'] as Timestamp?)?.toDate(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'priority': priority.name,
        'isCompleted': isCompleted,
        'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  TaskModel copyWith({
    String? title,
    String? description,
    Priority? priority,
    bool? isCompleted,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime date;
  final DateTime time;
  final bool isCompleted;

  Task({
    String? id,
    required this.title,
    this.description = '',
    required this.category,
    required this.date,
    required this.time,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  Task copyWith({
    String? title,
    String? description,
    String? category,
    DateTime? date,
    DateTime? time,
    bool? isCompleted,
  }) {
    return Task(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
      'time': time.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      date: DateTime.parse(json['date']),
      time: DateTime.parse(json['time']),
      isCompleted: json['isCompleted'],
    );
  }

  DateTime get combinedDateTime {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
}
import 'package:equatable/equatable.dart';

/// Перечисление для приоритетов задач.
enum TaskPriority { low, medium, high }

/// Сущность задачи, представляющая бизнес-логику.
class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final String? category;
  final bool isCompleted;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    this.category,
    this.isCompleted = false,
    required this.createdAt,
  });

  /// Создаёт копию задачи с обновлёнными полями.
  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    String? category,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    priority,
    category,
    isCompleted,
    createdAt,
  ];

  @override
  String toString() {
    return 'Task(id: $id, title: $title, description: $description, priority: $priority, category: $category, isCompleted: $isCompleted, createdAt: $createdAt)';
  }
}
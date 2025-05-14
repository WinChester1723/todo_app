import 'package:hive/hive.dart';
import 'package:todo_app/domain/entities/task.dart';

part 'task_model.g.dart';

/// Модель задачи для хранения в Hive.
@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String priority;

  @HiveField(4)
  final String? category;

  @HiveField(5)
  final bool isCompleted;

  @HiveField(6)
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    this.category,
    this.isCompleted = false,
    required this.createdAt,
  });

  /// Конвертирует TaskModel в доменную сущность Task.
  Task toEntity() => Task(
        id: id,
        title: title,
        description: description,
        priority: TaskPriority.values.firstWhere(
          (e) => e.toString() == priority,
          orElse: () => TaskPriority.low,
        ),
        category: category,
        isCompleted: isCompleted,
        createdAt: createdAt,
      );

  /// Создаёт TaskModel из доменной сущности Task.
  factory TaskModel.fromEntity(Task task) => TaskModel(
        id: task.id,
        title: task.title,
        description: task.description,
        priority: task.priority.toString(),
        category: task.category,
        isCompleted: task.isCompleted,
        createdAt: task.createdAt,
      );
}
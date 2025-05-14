import 'package:equatable/equatable.dart';
import 'package:todo_app/domain/entities/task.dart';

/// Базовый класс для состояний задач.
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние, когда задачи ещё не загружены.
class TaskInitial extends TaskState {
  @override
  String toString() => 'TaskInitial';
}

/// Состояние загрузки задач.
class TaskLoading extends TaskState {
  @override
  String toString() => 'TaskLoading';
}

/// Состояние, когда задачи успешно загружены.
class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final String? categoryFilter;
  final bool isSortedAscending;

  const TaskLoaded({
    required this.tasks,
    this.categoryFilter,
    this.isSortedAscending = false,
  });

  @override
  List<Object?> get props => [tasks, categoryFilter, isSortedAscending];

  @override
  String toString() => 'TaskLoaded(tasks: ${tasks.length}, filter: $categoryFilter, sorted: $isSortedAscending)';
}

/// Состояние ошибки при работе с задачами.
class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'TaskError(message: $message)';
}
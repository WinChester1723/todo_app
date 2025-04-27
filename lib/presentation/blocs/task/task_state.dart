import 'package:equatable/equatable.dart';
import 'package:todo_app/domain/entities/task.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  @override
  String toString() => 'TaskInitial';
}

class TaskLoading extends TaskState {
  @override
  String toString() => 'TaskLoading';
}

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

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);
  @override
  List<Object?> get props => [message];
  @override
  String toString() => 'TaskError(message: $message)';
}
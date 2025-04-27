import 'package:equatable/equatable.dart';
import 'package:todo_app/domain/entities/task.dart';

/// Базовый класс для событий задач.
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

/// Событие для загрузки задач с опциональным фильтром по категории.
class LoadTasks extends TaskEvent {
  final String? categoryFilter;

  const LoadTasks({this.categoryFilter});

  @override
  List<Object?> get props => [categoryFilter];
}

/// Событие для добавления новой задачи.
class AddTask extends TaskEvent {
  final Task task;

  const AddTask(this.task);

  @override
  List<Object?> get props => [task];
}

/// Событие для обновления существующей задачи.
class UpdateTask extends TaskEvent {
  final Task task;

  const UpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

/// Событие для удаления задачи по её идентификатору.
class DeleteTask extends TaskEvent {
  final String taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Событие для фильтрации задач по категории.
class FilterTasks extends TaskEvent {
  final String? categoryFilter;

  const FilterTasks({this.categoryFilter});

  @override
  List<Object?> get props => [categoryFilter];
}

/// Событие для сортировки задач по приоритету.
class SortTasks extends TaskEvent {
  final bool ascending;

  const SortTasks({this.ascending = false});

  @override
  List<Object?> get props => [ascending];
}
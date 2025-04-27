import 'package:equatable/equatable.dart';
import 'package:todo_app/domain/entities/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  final String? categoryFilter;

  const LoadTasks({this.categoryFilter});
  @override
  List<Object?> get props => [categoryFilter];
}

class AddTask extends TaskEvent {
  final Task task;
  const AddTask(this.task);
  @override
  List<Object?> get props => [task];
}

class UpdateTask extends TaskEvent {
  final Task task;
  const UpdateTask(this.task);
  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;
  const DeleteTask(this.taskId);
  @override
  List<Object?> get props => [taskId];
}

class FilterTasks extends TaskEvent {
  final String? categoryFilter;

  const FilterTasks({this.categoryFilter});
  @override
  List<Object?> get props => [categoryFilter];
}

class SortTasks extends TaskEvent {
  final bool ascending;

  const SortTasks({this.ascending = false});
  @override
  List<Object?> get props => [ascending];
}
import 'package:dartz/dartz.dart' as dartz; // Добавляем префикс as dartz
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:todo_app/core/error/failures.dart';
import 'package:todo_app/data/models/task_model.dart';
import 'package:todo_app/domain/entities/task.dart';
import 'package:todo_app/domain/repositories/task_repository.dart';

/// Реализация репозитория задач с использованием Hive для локального хранения.
class TaskRepositoryImpl implements TaskRepository {
  final Box<TaskModel> _taskBox;
  final Logger _logger = Logger();

  TaskRepositoryImpl(this._taskBox);

  @override
  Future<dartz.Either<Failure, List<Task>>> getTasks() async {
    try {
      final tasks = _taskBox.values.map((taskModel) => taskModel.toEntity()).toList();
      _logger.d('Retrieved ${tasks.length} tasks from Hive');
      print('Tasks in Hive: ${tasks.map((task) => task.title).toList()}');
      return dartz.Right(tasks);
    } catch (e, stackTrace) {
      _logger.e('Error while retrieving tasks: $e\n$stackTrace');
      return dartz.Left(DatabaseFailure('Failed to retrieve tasks: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, void>> addTask(Task task) async {
    try {
      await _taskBox.put(task.id, TaskModel.fromEntity(task));
      _logger.d('Task added to Hive: ${task.title}');
      print('After adding task, Hive contains: ${_taskBox.values.map((t) => t.title).toList()}');
      return const dartz.Right(null);
    } catch (e, stackTrace) {
      _logger.e('Error while adding task: $e\n$stackTrace');
      return dartz.Left(DatabaseFailure('Failed to add task: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, void>> updateTask(Task task) async {
    try {
      await _taskBox.put(task.id, TaskModel.fromEntity(task));
      _logger.d('Task updated in Hive: ${task.title}');
      print('After updating task, Hive contains: ${_taskBox.values.map((t) => t.title).toList()}');
      return const dartz.Right(null);
    } catch (e, stackTrace) {
      _logger.e('Error while updating task: $e\n$stackTrace');
      return dartz.Left(DatabaseFailure('Failed to update task: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, void>> deleteTask(String taskId) async {
    try {
      await _taskBox.delete(taskId);
      _logger.d('Task deleted from Hive: $taskId');
      print('After deleting task, Hive contains: ${_taskBox.values.map((t) => t.title).toList()}');
      return const dartz.Right(null);
    } catch (e, stackTrace) {
      _logger.e('Error while deleting task: $e\n$stackTrace');
      return dartz.Left(DatabaseFailure('Failed to delete task: $e'));
    }
  }
}
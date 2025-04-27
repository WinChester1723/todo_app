import 'package:dartz/dartz.dart' as dartz;
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:todo_app/core/error/failures.dart';
import 'package:todo_app/data/models/task_model.dart';
import 'package:todo_app/domain/entities/task.dart';
import 'package:todo_app/domain/repositories/task_repository.dart';

/// Реализация репозитория задач, использующая Hive для локального хранения.
class TaskRepositoryImpl implements TaskRepository {
  final Box<TaskModel> taskBox;
  final Logger _logger = Logger();

  TaskRepositoryImpl(this.taskBox);

  /// Получает список всех задач из локального хранилища.
  @override
  Future<dartz.Either<Failure, List<Task>>> getTasks() async {
    try {
      final tasks = taskBox.values.map((taskModel) => taskModel.toEntity()).toList();
      _logger.d('Retrieved ${tasks.length} tasks from Hive');
      return dartz.Right(tasks);
    } catch (e) {
      _logger.e('Failed to retrieve tasks: $e');
      return dartz.Left(CacheFailure('Failed to retrieve tasks: $e'));
    }
  }

  /// Добавляет новую задачу в локальное хранилище.
  @override
  Future<dartz.Either<Failure, void>> addTask(Task task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      await taskBox.put(task.id, taskModel);
      _logger.d('Task added to Hive: ${task.title}');
      return const dartz.Right(null);
    } catch (e) {
      _logger.e('Failed to add task: $e');
      return dartz.Left(CacheFailure('Failed to add task: $e'));
    }
  }

  /// Обновляет существующую задачу в локальном хранилище.
  @override
  Future<dartz.Either<Failure, void>> updateTask(Task task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      await taskBox.put(task.id, taskModel);
      _logger.d('Task updated in Hive: ${task.title}');
      return const dartz.Right(null);
    } catch (e) {
      _logger.e('Failed to update task: $e');
      return dartz.Left(CacheFailure('Failed to update task: $e'));
    }
  }

  /// Удаляет задачу из локального хранилища по её идентификатору.
  @override
  Future<dartz.Either<Failure, void>> deleteTask(String taskId) async {
    try {
      await taskBox.delete(taskId);
      _logger.d('Task deleted from Hive: $taskId');
      return const dartz.Right(null);
    } catch (e) {
      _logger.e('Failed to delete task: $e');
      return dartz.Left(CacheFailure('Failed to delete task: $e'));
    }
  }
}
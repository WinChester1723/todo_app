import 'package:dartz/dartz.dart' as dartz;
import 'package:todo_app/core/error/failures.dart';
import 'package:todo_app/domain/entities/task.dart';

/// Абстрактный репозиторий для работы с задачами.
abstract class TaskRepository {
  /// Получает список всех задач.
  Future<dartz.Either<Failure, List<Task>>> getTasks();

  /// Добавляет новую задачу.
  Future<dartz.Either<Failure, void>> addTask(Task task);

  /// Обновляет существующую задачу.
  Future<dartz.Either<Failure, void>> updateTask(Task task);

  /// Удаляет задачу по её идентификатору.
  Future<dartz.Either<Failure, void>> deleteTask(String taskId);
}
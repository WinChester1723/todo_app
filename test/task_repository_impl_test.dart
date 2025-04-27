import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_app/core/error/failures.dart';
import 'package:todo_app/data/models/task_model.dart';
import 'package:todo_app/data/repositories/task_repository_impl.dart';
import 'package:todo_app/domain/entities/task.dart';

import 'task_repository_impl_test.mocks.dart';

@GenerateMocks([Box])
void main() {
  late TaskRepositoryImpl repository;
  late MockBox<TaskModel> mockTaskBox;

  setUp(() {
    mockTaskBox = MockBox();
    repository = TaskRepositoryImpl(mockTaskBox);
  });

  group('TaskRepositoryImpl', () {
    const tTask = Task(
      id: '1',
      title: 'Test Task',
      description: 'Test Description',
      priority: TaskPriority.low,
      category: 'Work',
      isCompleted: false,
      createdAt: DateTime(2025, 4, 27),
    );
    final tTaskModel = TaskModel.fromEntity(tTask);

    group('getTasks', () {
      test('should return a list of tasks when Hive returns data', () async {
        // Arrange
        when(mockTaskBox.values).thenReturn([tTaskModel]);

        // Act
        final result = await repository.getTasks();

        // Assert
        expect(result, dartz.Right([tTask]));
        verify(mockTaskBox.values).called(1);
      });

      test('should return CacheFailure when Hive throws an exception', () async {
        // Arrange
        when(mockTaskBox.values).thenThrow(Exception('Hive error'));

        // Act
        final result = await repository.getTasks();

        // Assert
        expect(result, dartz.Left(CacheFailure('Failed to retrieve tasks: Exception: Hive error')));
        verify(mockTaskBox.values).called(1);
      });
    });

    group('addTask', () {
      test('should add a task to Hive and return success', () async {
        // Arrange
        when(mockTaskBox.put(any, any)).thenAnswer((_) async => null);

        // Act
        final result = await repository.addTask(tTask);

        // Assert
        expect(result, const dartz.Right(null));
        verify(mockTaskBox.put(tTask.id, tTaskModel)).called(1);
      });

      test('should return CacheFailure when Hive throws an exception', () async {
        // Arrange
        when(mockTaskBox.put(any, any)).thenThrow(Exception('Hive error'));

        // Act
        final result = await repository.addTask(tTask);

        // Assert
        expect(result, dartz.Left(CacheFailure('Failed to add task: Exception: Hive error')));
        verify(mockTaskBox.put(tTask.id, tTaskModel)).called(1);
      });
    });

    // Аналогичные тесты для updateTask и deleteTask
  });
}
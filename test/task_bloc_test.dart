import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_app/core/error/failures.dart';
import 'package:todo_app/domain/entities/task.dart';
import 'package:todo_app/domain/repositories/task_repository.dart';
import 'package:todo_app/presentation/blocs/task/task_bloc.dart';
import 'package:todo_app/presentation/blocs/task/task_event.dart';
import 'package:todo_app/presentation/blocs/task/task_state.dart';
import 'package:bloc_test/bloc_test.dart';

import 'task_bloc_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  late TaskBloc taskBloc;
  late MockTaskRepository mockTaskRepository;

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    taskBloc = TaskBloc()..repository = mockTaskRepository;
  });

  tearDown(() {
    taskBloc.close();
  });

  group('TaskBloc', () {
    const tTask = Task(
      id: '1',
      title: 'Test Task',
      description: 'Test Description',
      priority: TaskPriority.low,
      category: 'Work',
      isCompleted: false,
      createdAt: DateTime(2025, 4, 27),
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskLoaded] when LoadTasks is added and repository returns data',
      build: () {
        when(mockTaskRepository.getTasks())
            .thenAnswer((_) async => dartz.Right([tTask]));
        return taskBloc;
      },
      act: (bloc) => bloc.add(const LoadTasks()),
      expect: () => [
        TaskLoading(),
        const TaskLoaded(tasks: [tTask], categoryFilter: null, isSortedAscending: false),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskError] when LoadTasks is added and repository fails',
      build: () {
        when(mockTaskRepository.getTasks())
            .thenAnswer((_) async => dartz.Left(CacheFailure('Failed to load tasks')));
        return taskBloc;
      },
      act: (bloc) => bloc.add(const LoadTasks()),
      expect: () => [
        TaskLoading(),
        const TaskError('Failed to load tasks'),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskLoaded] when AddTask is added and repository succeeds',
      build: () {
        when(mockTaskRepository.addTask(any))
            .thenAnswer((_) async => const dartz.Right(null));
        when(mockTaskRepository.getTasks())
            .thenAnswer((_) async => dartz.Right([tTask]));
        return taskBloc;
      },
      act: (bloc) => bloc.add(const AddTask(tTask)),
      expect: () => [
        TaskLoading(),
        const TaskLoaded(tasks: [tTask], categoryFilter: null, isSortedAscending: false),
      ],
    );

    // Аналогичные тесты для UpdateTask, DeleteTask, FilterTasks, SortTasks
  });
}import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_app/core/error/failures.dart';
import 'package:todo_app/domain/entities/task.dart';
import 'package:todo_app/domain/repositories/task_repository.dart';
import 'package:todo_app/presentation/blocs/task/task_bloc.dart';
import 'package:todo_app/presentation/blocs/task/task_event.dart';
import 'package:todo_app/presentation/blocs/task/task_state.dart';
import 'package:bloc_test/bloc_test.dart';

import 'task_bloc_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  late TaskBloc taskBloc;
  late MockTaskRepository mockTaskRepository;

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    taskBloc = TaskBloc()..repository = mockTaskRepository;
  });

  tearDown(() {
    taskBloc.close();
  });

  group('TaskBloc', () {
    const tTask = Task(
      id: '1',
      title: 'Test Task',
      description: 'Test Description',
      priority: TaskPriority.low,
      category: 'Work',
      isCompleted: false,
      createdAt: DateTime(2025, 4, 27),
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskLoaded] when LoadTasks is added and repository returns data',
      build: () {
        when(mockTaskRepository.getTasks())
            .thenAnswer((_) async => dartz.Right([tTask]));
        return taskBloc;
      },
      act: (bloc) => bloc.add(const LoadTasks()),
      expect: () => [
        TaskLoading(),
        const TaskLoaded(tasks: [tTask], categoryFilter: null, isSortedAscending: false),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskError] when LoadTasks is added and repository fails',
      build: () {
        when(mockTaskRepository.getTasks())
            .thenAnswer((_) async => dartz.Left(CacheFailure('Failed to load tasks')));
        return taskBloc;
      },
      act: (bloc) => bloc.add(const LoadTasks()),
      expect: () => [
        TaskLoading(),
        const TaskError('Failed to load tasks'),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskLoaded] when AddTask is added and repository succeeds',
      build: () {
        when(mockTaskRepository.addTask(any))
            .thenAnswer((_) async => const dartz.Right(null));
        when(mockTaskRepository.getTasks())
            .thenAnswer((_) async => dartz.Right([tTask]));
        return taskBloc;
      },
      act: (bloc) => bloc.add(const AddTask(tTask)),
      expect: () => [
        TaskLoading(),
        const TaskLoaded(tasks: [tTask], categoryFilter: null, isSortedAscending: false),
      ],
    );

    // Аналогичные тесты для UpdateTask, DeleteTask, FilterTasks, SortTasks
  });
}
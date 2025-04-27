import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/injection.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:logger/logger.dart';
import 'package:todo_app/core/error/failures.dart';
import 'package:todo_app/domain/entities/task.dart';
import 'package:todo_app/domain/repositories/task_repository.dart';
import 'package:todo_app/presentation/blocs/task/task_event.dart';
import 'package:todo_app/presentation/blocs/task/task_state.dart';

/// BLoC для управления задачами (загрузка, добавление, обновление, удаление, фильтрация, сортировка).
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;
  final Logger _logger = Logger();
  List<Task> _allTasks = [];

  TaskBloc({TaskRepository? taskRepository}) 
      : _taskRepository = taskRepository ?? getIt<TaskRepository>(),
        super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<FilterTasks>(_onFilterTasks);
    on<SortTasks>(_onSortTasks);
  }

  /// Загружает задачи с учётом фильтра по категории.
  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    _logger.d('Loading tasks with filter: ${event.categoryFilter}');
    emit(TaskLoading());
    final result = await _taskRepository.getTasks();
    await result.fold(
      (failure) async => emit(TaskError(failure.message)),
      (List<Task> tasks) async {
        _allTasks = tasks;
        _logger.d('All tasks: ${tasks.map((task) => task.toString()).toList()}');
        _allTasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        final filteredTasks = event.categoryFilter != null
            ? _allTasks
                .where((task) => task.category?.toLowerCase() == event.categoryFilter?.toLowerCase())
                .toList()
            : _allTasks;
        _logger.d('Filtered tasks: ${filteredTasks.length}');
        emit(TaskLoaded(
          tasks: filteredTasks,
          categoryFilter: event.categoryFilter,
          isSortedAscending: state is TaskLoaded ? (state as TaskLoaded).isSortedAscending : false,
        ));
      },
    );
  }

  /// Добавляет новую задачу и обновляет список.
  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    _logger.d('Adding task: ${event.task.title}');
    final result = await _taskRepository.addTask(event.task);
    await result.fold(
      (failure) async => emit(TaskError(failure.message)),
      (_) async {
        _logger.d('Task added successfully');
        await _onLoadTasks(
          LoadTasks(categoryFilter: state is TaskLoaded ? (state as TaskLoaded).categoryFilter : null),
          emit,
        );
      },
    );
  }

  /// Обновляет существующую задачу и обновляет список.
  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    final result = await _taskRepository.updateTask(event.task);
    await result.fold(
      (failure) async => emit(TaskError(failure.message)),
      (_) async => await _onLoadTasks(
        LoadTasks(categoryFilter: state is TaskLoaded ? (state as TaskLoaded).categoryFilter : null),
        emit,
      ),
    );
  }

  /// Удаляет задачу по её идентификатору и обновляет список.
  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    final result = await _taskRepository.deleteTask(event.taskId);
    await result.fold(
      (failure) async => emit(TaskError(failure.message)),
      (_) async => await _onLoadTasks(
        LoadTasks(categoryFilter: state is TaskLoaded ? (state as TaskLoaded).categoryFilter : null),
        emit,
      ),
    );
  }

  /// Фильтрует задачи по категории.
  Future<void> _onFilterTasks(FilterTasks event, Emitter<TaskState> emit) async {
    _logger.d('Filtering tasks with filter: ${event.categoryFilter}');
    await _onLoadTasks(LoadTasks(categoryFilter: event.categoryFilter), emit);
  }

  /// Сортирует задачи по приоритету (по возрастанию или убыванию).
  Future<void> _onSortTasks(SortTasks event, Emitter<TaskState> emit) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      final tasks = List<Task>.from(currentState.tasks);
      if (event.ascending) {
        tasks.sort((a, b) => a.priority.index.compareTo(b.priority.index));
      } else {
        tasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
      }
      emit(TaskLoaded(
        tasks: tasks,
        categoryFilter: currentState.categoryFilter,
        isSortedAscending: event.ascending,
      ));
    }
  }
}
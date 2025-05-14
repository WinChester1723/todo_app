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
    await Future.delayed(const Duration(milliseconds: 100));
    final result = await _taskRepository.getTasks();
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (List<Task> tasks) {
        _allTasks = tasks;
        _logger.d('All tasks: ${tasks.map((task) => task.toString()).toList()}');
        _allTasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        final filteredTasks = event.categoryFilter != null
            ? _allTasks
                .where((task) => task.category?.toLowerCase() == event.categoryFilter?.toLowerCase())
                .toList()
            : _allTasks;
        _logger.d('Filtered tasks: ${filteredTasks.length}');
        print('Emitting TaskLoaded with tasks: ${filteredTasks.map((task) => task.title).toList()}');
        emit(TaskLoaded(
          tasks: filteredTasks,
          categoryFilter: event.categoryFilter,
          isSortedAscending: state is TaskLoaded ? (state as TaskLoaded).isSortedAscending : false,
        ));
      },
    );
  }

  /// Добавляет новую задачу без полной перезагрузки списка.
  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    _logger.d('Adding task: ${event.task.title}');
    final result = await _taskRepository.addTask(event.task);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) {
        _logger.d('Task added successfully');
        if (state is TaskLoaded) {
          final currentState = state as TaskLoaded;
          final updatedTasks = List<Task>.from(currentState.tasks)..add(event.task);
          _allTasks.add(event.task);
          if (currentState.isSortedAscending) {
            updatedTasks.sort((a, b) => a.priority.index.compareTo(b.priority.index));
          } else {
            updatedTasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
          }
          final filteredTasks = currentState.categoryFilter != null
              ? updatedTasks
                  .where((task) => task.category?.toLowerCase() == currentState.categoryFilter?.toLowerCase())
                  .toList()
              : updatedTasks;
          print('Emitting TaskLoaded with updated tasks: ${filteredTasks.map((task) => task.title).toList()}');
          emit(TaskLoaded(
            tasks: filteredTasks,
            categoryFilter: currentState.categoryFilter,
            isSortedAscending: currentState.isSortedAscending,
          ));
        } else {
          add(LoadTasks(categoryFilter: null));
        }
      },
    );
  }

  /// Обновляет существующую задачу без полной перезагрузки списка.
  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      final result = await _taskRepository.updateTask(event.task);
      result.fold(
        (failure) => emit(TaskError(failure.message)),
        (_) {
          if (state is TaskLoaded) {
            final currentState = state as TaskLoaded;
            final updatedTasks = currentState.tasks.map((task) {
              return task.id == event.task.id ? event.task : task;
            }).toList();
            _allTasks = _allTasks.map((task) {
              return task.id == event.task.id ? event.task : task;
            }).toList();
            if (currentState.isSortedAscending) {
              updatedTasks.sort((a, b) => a.priority.index.compareTo(b.priority.index));
            } else {
              updatedTasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
            }
            print('Emitting TaskLoaded with updated tasks: ${updatedTasks.map((task) => task.title).toList()}');
            emit(TaskLoaded(
              tasks: updatedTasks,
              categoryFilter: currentState.categoryFilter,
              isSortedAscending: currentState.isSortedAscending,
            ));
          }
        },
      );
    } catch (e, stackTrace) {
      _logger.e('Error while updating task: $e\n$stackTrace');
      emit(TaskError('Failed to update task: $e'));
    }
  }

  /// Удаляет задачу без полной перезагрузки списка.
  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      final result = await _taskRepository.deleteTask(event.taskId);
      result.fold(
        (failure) => emit(TaskError(failure.message)),
        (_) {
          if (state is TaskLoaded) {
            final currentState = state as TaskLoaded;
            final updatedTasks = currentState.tasks
                .where((task) => task.id != event.taskId)
                .toList();
            _allTasks = _allTasks
                .where((task) => task.id != event.taskId)
                .toList();
            if (currentState.isSortedAscending) {
              updatedTasks.sort((a, b) => a.priority.index.compareTo(b.priority.index));
            } else {
              updatedTasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
            }
            print('After deletion, remaining tasks: ${updatedTasks.map((task) => task.title).toList()}');
            print('After deletion, _allTasks: ${_allTasks.map((task) => task.title).toList()}');
            emit(TaskLoaded(
              tasks: updatedTasks,
              categoryFilter: currentState.categoryFilter,
              isSortedAscending: currentState.isSortedAscending,
            ));
          }
        },
      );
    } catch (e, stackTrace) {
      _logger.e('Error while deleting task: $e\n$stackTrace');
      emit(TaskError('Failed to delete task: $e'));
    }
  }

  /// Фильтрует задачи по категории.
  Future<void> _onFilterTasks(FilterTasks event, Emitter<TaskState> emit) async {
    _logger.d('Filtering tasks with filter: ${event.categoryFilter}');
    add(LoadTasks(categoryFilter: event.categoryFilter));
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
      print('Emitting TaskLoaded with sorted tasks: ${tasks.map((task) => task.title).toList()}');
      emit(TaskLoaded(
        tasks: tasks,
        categoryFilter: currentState.categoryFilter,
        isSortedAscending: event.ascending,
      ));
    }
  }
}
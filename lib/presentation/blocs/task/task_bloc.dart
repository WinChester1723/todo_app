import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/di/injection.dart';
import 'package:todo_app/domain/entities/task.dart';
import 'package:todo_app/domain/repositories/task_repository.dart';
import 'package:todo_app/presentation/blocs/task/task_event.dart';
import 'package:todo_app/presentation/blocs/task/task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository = getIt<TaskRepository>();
  List<Task> _allTasks = [];

  TaskBloc() : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<FilterTasks>(_onFilterTasks);
    on<SortTasks>(_onSortTasks);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    print('Loading tasks with filter: ${event.categoryFilter}');
    emit(TaskLoading());
    try {
      _allTasks = await _taskRepository.getTasks();
      print('All tasks: ${_allTasks.map((task) => task.toString()).toList()}');
      // Сортируем по приоритету (высокий приоритет вверху)
      _allTasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
      final filteredTasks = event.categoryFilter != null
          ? _allTasks.where((task) {
              final matches = task.category?.toLowerCase() == event.categoryFilter?.toLowerCase();
              print('Task: ${task.title}, Category: ${task.category}, Filter: ${event.categoryFilter}, Matches: $matches');
              return matches;
            }).toList()
          : _allTasks;
      print('Filtered tasks: ${filteredTasks.length}');
      emit(TaskLoaded(
        tasks: filteredTasks,
        categoryFilter: event.categoryFilter,
        isSortedAscending: state is TaskLoaded ? (state as TaskLoaded).isSortedAscending : false,
      ));
    } catch (e) {
      print('Error loading tasks: $e');
      emit(TaskError('Failed to load tasks: $e'));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    print('Adding task: ${event.task.title}');
    try {
      await _taskRepository.addTask(event.task);
      print('Task added successfully');
      await _onLoadTasks(
        LoadTasks(
          categoryFilter: state is TaskLoaded ? (state as TaskLoaded).categoryFilter : null,
        ),
        emit,
      );
    } catch (e) {
      print('Error adding task: $e');
      emit(TaskError('Failed to add task: $e'));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.updateTask(event.task);
      await _onLoadTasks(
        LoadTasks(
          categoryFilter: state is TaskLoaded ? (state as TaskLoaded).categoryFilter : null,
        ),
        emit,
      );
    } catch (e) {
      emit(TaskError('Failed to update task: $e'));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.deleteTask(event.taskId);
      await _onLoadTasks(
        LoadTasks(
          categoryFilter: state is TaskLoaded ? (state as TaskLoaded).categoryFilter : null,
        ),
        emit,
      );
    } catch (e) {
      emit(TaskError('Failed to delete task: $e'));
    }
  }

  Future<void> _onFilterTasks(FilterTasks event, Emitter<TaskState> emit) async {
    print('Filtering tasks with filter: ${event.categoryFilter}');
    await _onLoadTasks(LoadTasks(categoryFilter: event.categoryFilter), emit);
  }

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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/domain/entities/task.dart';
import 'package:todo_app/presentation/blocs/task/task_bloc.dart';
import 'package:todo_app/presentation/blocs/task/task_event.dart';
import 'package:todo_app/presentation/blocs/task/task_state.dart';
import 'package:todo_app/presentation/screens/task_add_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> categories = ['All', 'Work', 'Personal', 'Other'];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Task> _currentTasks = [];

  void _updateTaskList(List<Task> newTasks) {
    final oldTasks = List<Task>.from(_currentTasks);

    Future.microtask(() {
      // Удаляем задачи, которых нет в новом списке
      for (int i = oldTasks.length - 1; i >= 0; i--) {
        if (!newTasks.contains(oldTasks[i])) {
          _listKey.currentState?.removeItem(
            i,
            (context, animation) => _buildTaskTile(oldTasks[i], animation),
            duration: const Duration(milliseconds: 300),
          );
        }
      }

      // Обновляем текущий список
      _currentTasks = List<Task>.from(newTasks);

      // Добавляем новые задачи
      for (int i = 0; i < newTasks.length; i++) {
        if (!oldTasks.contains(newTasks[i])) {
          _listKey.currentState?.insertItem(
            i,
            duration: const Duration(milliseconds: 300),
          );
        }
      }
    });
  }

  Widget _buildTaskTile(Task task, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: ListTile(
        leading: Icon(
          task.category == 'Work'
              ? Icons.work
              : task.category == 'Personal'
              ? Icons.person
              : Icons.category,
          color: Colors.blue,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration:
                task.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Text(task.description),
        trailing: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            context.read<TaskBloc>().add(
              UpdateTask(task.copyWith(isCompleted: value ?? false)),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo List'),
        actions: [
          IconButton(
            icon: Icon(
              context.read<TaskBloc>().state is TaskLoaded &&
                      (context.read<TaskBloc>().state as TaskLoaded)
                          .isSortedAscending
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
            ),
            onPressed: () {
              final currentState = context.read<TaskBloc>().state;
              context.read<TaskBloc>().add(
                SortTasks(
                  ascending:
                      !(currentState is TaskLoaded &&
                          currentState.isSortedAscending),
                ),
              );
            },
          ),
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              String selectedCategory =
                  state is TaskLoaded ? (state.categoryFilter ?? 'All') : 'All';
              return DropdownButton<String>(
                value: selectedCategory,
                items:
                    categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    context.read<TaskBloc>().add(
                      FilterTasks(
                        categoryFilter: value == 'All' ? null : value,
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskLoaded) {
            _updateTaskList(state.tasks);
          }
        },
        child: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TaskLoaded) {
              return AnimatedList(
                key: _listKey,
                initialItemCount: _currentTasks.length,
                itemBuilder: (context, index, animation) {
                  final task = _currentTasks[index];
                  return _buildTaskTile(task, animation);
                },
              );
            } else if (state is TaskError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('No tasks yet'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskAddScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

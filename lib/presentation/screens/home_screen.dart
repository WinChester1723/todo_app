import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/domain/entities/task.dart';
import 'package:todo_app/presentation/blocs/task/task_bloc.dart';
import 'package:todo_app/presentation/blocs/task/task_event.dart';
import 'package:todo_app/presentation/blocs/task/task_state.dart';
import 'package:todo_app/presentation/screens/task_add_screen.dart';

/// Главный экран приложения для отображения списка задач.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildTaskTile(Task task, Animation<double> animation, BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Dismissible(
        key: Key(task.id),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (_) {
          context.read<TaskBloc>().add(DeleteTask(task.id));
        },
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
              decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskAddScreen(task: task),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const categories = ['All', 'Work', 'Personal', 'Other'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo List'),
        actions: [
          IconButton(
            icon: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                return Icon(
                  state is TaskLoaded && state.isSortedAscending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                );
              },
            ),
            onPressed: () {
              final currentState = context.read<TaskBloc>().state;
              context.read<TaskBloc>().add(
                SortTasks(
                  ascending: !(currentState is TaskLoaded && currentState.isSortedAscending),
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
                items: categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    context.read<TaskBloc>().add(
                      FilterTasks(categoryFilter: value == 'All' ? null : value),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoaded) {
            return AnimatedList(
              key: GlobalKey<AnimatedListState>(),
              initialItemCount: state.tasks.length,
              itemBuilder: (context, index, animation) {
                final task = state.tasks[index];
                return _buildTaskTile(task, animation, context);
              },
            );
          } else if (state is TaskError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No tasks yet'));
        },
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
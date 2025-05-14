import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/domain/entities/task.dart';
import 'package:todo_app/presentation/blocs/task/task_bloc.dart';
import 'package:todo_app/presentation/blocs/task/task_event.dart';
import 'package:todo_app/presentation/blocs/task/task_state.dart';
import 'package:todo_app/presentation/screens/task_add_screen.dart';

/// Главный экран приложения для отображения списка задач.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Task> _tasks = [];

  void _deleteTask(Task task, int index, BuildContext context) {
    // Удаляем задачу из списка с анимацией
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _TaskTile(
        task: task,
        animation: animation,
        onDelete: () {}, // Передаём пустую функцию, так как это анимация удаления
      ),
      duration: const Duration(milliseconds: 500),
    );

    // Обновляем локальный список задач
    setState(() {
      _tasks.removeAt(index);
    });

    // Вызываем DeleteTask для обновления состояния
    context.read<TaskBloc>().add(DeleteTask(task.id));
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
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskLoaded) {
            final oldTasks = _tasks;
            final newTasks = state.tasks;

            print('Old tasks: ${oldTasks.map((task) => task.title).toList()}');
            print('New tasks: ${newTasks.map((task) => task.title).toList()}');

            // Находим добавленные задачи
            for (int i = 0; i < newTasks.length; i++) {
              final newTask = newTasks[i];
              if (!oldTasks.any((task) => task.id == newTask.id)) {
                print('Inserting new task at index $i: ${newTask.title}');
                _listKey.currentState?.insertItem(i);
              }
            }

            // Находим удалённые задачи
            for (int i = 0; i < oldTasks.length; i++) {
              final oldTask = oldTasks[i];
              if (!newTasks.any((task) => task.id == oldTask.id)) {
                print('Removing task at index $i: ${oldTask.title}');
                _listKey.currentState?.removeItem(
                  i,
                  (context, animation) => _TaskTile(
                    task: oldTask,
                    animation: animation,
                    onDelete: () {}, // Передаём пустую функцию
                  ),
                  duration: const Duration(milliseconds: 500),
                );
              }
            }

            _tasks = List<Task>.from(newTasks);
            print('Updated _tasks: ${_tasks.map((task) => task.title).toList()}');
          }
        },
        builder: (context, state) {
          if (state is TaskLoading) {
            return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
          } else if (state is TaskLoaded) {
            if (state.tasks.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No tasks yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            return AnimatedList(
              key: _listKey,
              initialItemCount: _tasks.length,
              itemBuilder: (context, index, animation) {
                if (index >= _tasks.length) {
                  return const SizedBox.shrink();
                }
                final task = _tasks[index];
                return _TaskTile(
                  task: task,
                  animation: animation,
                  onDelete: () => _deleteTask(task, index, context),
                );
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
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const TaskAddScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
        },
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[700]!, Colors.blue[500]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          width: 56,
          height: 56,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

/// Виджет для отображения отдельной задачи с плавной анимацией.
class _TaskTile extends StatefulWidget {
  final Task task;
  final Animation<double> animation;
  final VoidCallback onDelete; // Callback для удаления задачи

  const _TaskTile({
    required this.task,
    required this.animation,
    this.onDelete = _defaultOnDelete, // Значение по умолчанию
  });

  static void _defaultOnDelete() {} // Пустая функция по умолчанию

  @override
  State<_TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<_TaskTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.task.isCompleted) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _TaskTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.task.isCompleted != oldWidget.task.isCompleted) {
      if (widget.task.isCompleted) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: widget.animation, curve: Curves.easeInOut),
        ),
        child: GestureDetector(
          onLongPress: widget.onDelete,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => TaskAddScreen(task: widget.task),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    AnimatedCrossFade(
                      firstChild: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      ),
                      secondChild: Icon(
                        widget.task.category == 'Work'
                            ? Icons.work
                            : widget.task.category == 'Personal'
                            ? Icons.person
                            : Icons.category,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      crossFadeState: widget.task.isCompleted
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 500),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 500),
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      decoration: widget.task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                      color: widget.task.isCompleted
                                          ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                                          : Theme.of(context).colorScheme.onSurface,
                                    ),
                                child: Text(widget.task.title),
                              ),
                              AnimatedOpacity(
                                opacity: widget.task.isCompleted ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 500),
                                child: ScaleTransition(
                                  scale: _scale,
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    height: 2,
                                    width: 50,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 500),
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: widget.task.isCompleted
                                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                ),
                            child: Text(widget.task.description),
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: widget.task.isCompleted,
                      onChanged: (value) {
                        context.read<TaskBloc>().add(
                          UpdateTask(widget.task.copyWith(isCompleted: value ?? false)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
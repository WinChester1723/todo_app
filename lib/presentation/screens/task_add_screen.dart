import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/domain/entities/task.dart';
import 'package:todo_app/presentation/blocs/task/task_bloc.dart';
import 'package:todo_app/presentation/blocs/task/task_event.dart';
import 'package:todo_app/presentation/blocs/task/task_state.dart';
import 'package:uuid/uuid.dart';

/// Экран для добавления или редактирования задачи.
class TaskAddScreen extends StatefulWidget {
  final Task? task;

  const TaskAddScreen({super.key, this.task});

  @override
  State<TaskAddScreen> createState() => _TaskAddScreenState();
}

class _TaskAddScreenState extends State<TaskAddScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final List<String> _categories = const ['Work', 'Personal', 'Other'];
  late String? _selectedCategory;
  late TaskPriority _selectedPriority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _selectedCategory = widget.task?.category ?? 'Work';
    _selectedPriority = widget.task?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedCategory,
                    items:
                        _categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<TaskPriority>(
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedPriority,
                    items:
                        TaskPriority.values
                            .map(
                              (priority) => DropdownMenuItem(
                                value: priority,
                                child: Text(
                                  priority.toString().split('.').last,
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedPriority = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final task = Task(
                            id: widget.task?.id ?? const Uuid().v4(),
                            title: _titleController.text,
                            description: _descriptionController.text,
                            priority: _selectedPriority,
                            category: _selectedCategory ?? 'Work',
                            isCompleted: widget.task?.isCompleted ?? false,
                            createdAt: widget.task?.createdAt ?? DateTime.now(),
                          );
                          if (widget.task == null) {
                            context.read<TaskBloc>().add(AddTask(task));
                          } else {
                            context.read<TaskBloc>().add(UpdateTask(task));
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: Text(widget.task == null ? 'Save' : 'Update'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

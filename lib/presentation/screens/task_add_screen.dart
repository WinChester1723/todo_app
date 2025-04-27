import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/domain/entities/task.dart';
import 'package:todo_app/presentation/blocs/task/task_bloc.dart';
import 'package:todo_app/presentation/blocs/task/task_event.dart';
import 'package:uuid/uuid.dart';

class TaskAddScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _categories = ['Work', 'Personal', 'Other'];
  String? _selectedCategory = 'Work'; // Значение по умолчанию
  TaskPriority _selectedPriority = TaskPriority.medium;

  TaskAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
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
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _selectedCategory = value;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskPriority>(
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedPriority,
                  items: TaskPriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(priority.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _selectedPriority = value;
                    }
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final task = Task(
                          id: const Uuid().v4(),
                          title: _titleController.text,
                          description: _descriptionController.text,
                          priority: _selectedPriority,
                          category: _selectedCategory ?? 'Work', // Значение по умолчанию
                          createdAt: DateTime.now(),
                        );
                        context.read<TaskBloc>().add(AddTask(task));
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(height: 16), // Дополнительное пространство внизу
              ],
            ),
          ),
        ),
      ),
    );
  }
}
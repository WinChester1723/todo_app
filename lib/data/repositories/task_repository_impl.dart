import 'package:hive/hive.dart';
import 'package:todo_app/data/models/task_model.dart';
import 'package:todo_app/domain/entities/task.dart';
import 'package:todo_app/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final Box<TaskModel> taskBox;

  TaskRepositoryImpl(this.taskBox);

  @override
  Future<List<Task>> getTasks() async {
    final tasks =
        taskBox.values.map((taskModel) => taskModel.toEntity()).toList();
    print('Retrieved tasks from Hive: ${tasks.length}'); // Отладка
    return tasks;
  }

  @override
  Future<void> addTask(Task task) async {
    print('Saving task to Hive: ${task.title}'); // Отладка
    final taskModel = TaskModel.fromEntity(task);
    await taskBox.put(task.id, taskModel);
    print('Task saved to Hive'); // Отладка
  }

  @override
  Future<void> updateTask(Task task) async {
    final taskModel = TaskModel.fromEntity(task);
    await taskBox.put(task.id, taskModel);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await taskBox.delete(taskId);
  }
}

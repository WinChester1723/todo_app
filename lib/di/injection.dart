import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/data/models/task_model.dart';
import 'package:todo_app/data/repositories/task_repository_impl.dart';
import 'package:todo_app/domain/repositories/task_repository.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Hive коробка
  final taskBox = await Hive.openBox<TaskModel>('tasks');
  
  // Репозиторий
  getIt.registerSingleton<TaskRepository>(
    TaskRepositoryImpl(taskBox),
  );
}
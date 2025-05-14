import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/data/models/task_model.dart';
import 'package:todo_app/data/repositories/task_repository_impl.dart';
import 'package:todo_app/domain/repositories/task_repository.dart';

/// Глобальный экземпляр GetIt для управления зависимостями.
final getIt = GetIt.instance;

/// Инициализирует зависимости приложения.
Future<void> initDependencies() async {
  // Открываем Hive box для хранения задач
  final taskBox = await Hive.openBox<TaskModel>('tasks');
  
  // Регистрируем TaskRepository как синглтон
  getIt.registerSingleton<TaskRepository>(
    TaskRepositoryImpl(taskBox),
  );
}
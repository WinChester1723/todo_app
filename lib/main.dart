import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/data/models/task_model.dart';
import 'package:todo_app/injection.dart';
import 'package:todo_app/presentation/blocs/task/task_bloc.dart';
import 'package:todo_app/presentation/blocs/task/task_event.dart';
import 'package:todo_app/presentation/screens/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

/// Инициализирует приложение, настраивает Hive и зависимости, затем запускает приложение.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskModelAdapter());
  await initDependencies();
  runApp(const TodoApp());
}

/// Корневое приложение ToDo с поддержкой BLoC и тем.
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskBloc()..add(LoadTasks()),
      child: MaterialApp(
        title: 'Corporate ToDo',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue[700]!,
            primary: Colors.blue[700],
            secondary: Colors.grey[300],
            surface: Colors.grey[50]!, // Мягкий светлый фон
            surfaceContainer: Colors.grey[100], // Для полей ввода
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue[700]!,
            brightness: Brightness.dark,
            surface: Colors.grey[900]!, // Тёмный фон
            surfaceContainer: Colors.grey[800], // Для полей ввода
            onSurface: Colors.white,
            primary: Colors.blue[700],
            onPrimary: Colors.white,
            secondary: Colors.grey[700],
            onSecondary: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
        ),
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}
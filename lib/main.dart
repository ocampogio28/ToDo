import 'dart:io';
import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart';
import 'controllers/todo_controller.dart';
import 'controllers/music_controller.dart';
import 'views/todo_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await DesktopWindow.setWindowSize(const Size(500, 900));
    await DesktopWindow.setMinWindowSize(const Size(500, 900));
  }

  // Pass the instances into the app so they aren't recreated on rebuilds
  runApp(
    TodoApp(
      todoController: TodoController(),
      musicManager: MusicManager(),
    ),
  );
}

class TodoApp extends StatelessWidget {
  final TodoController todoController;
  final MusicManager musicManager;

  const TodoApp({
    super.key,
    required this.todoController,
    required this.musicManager,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Desktop ToDo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color.fromARGB(255, 34, 20, 20),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: TodoView(
        controller: todoController,
        musicManager: musicManager,
      ),
    );
  }
}

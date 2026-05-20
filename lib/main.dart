import 'dart:io'; // Needed to check if running on Desktop safely
import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart'; // 👈 Import the package
import 'controllers/todo_controller.dart';
import 'views/todo_view.dart';

void main() async {
  // Ensure framework bindings are ready before triggering async window configs
  WidgetsFlutterBinding.ensureInitialized();

  // Apply resolution controls exclusively when running on Desktop environments
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // 📐 Set the primary initial launching size window
    await DesktopWindow.setWindowSize(const Size(500, 900));

    // 🔒 Establish boundaries so the UI layouts won't break from excessive shrinking
    await DesktopWindow.setMinWindowSize(const Size(500, 900));
  }

  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final todoController = TodoController();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Desktop ToDo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor:
            const Color.from(alpha: 1, red: 0.133, green: 0.078, blue: 0.078),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: TodoView(controller: todoController),
    );
  }
}

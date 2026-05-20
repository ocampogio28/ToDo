import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TodoController extends ChangeNotifier {
  // Navigation State
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  // Separate Lists for Storage
  final List<TodoItem> _tasks = [];
  final List<TodoItem> _reminders = [];

  List<TodoItem> get tasks => _tasks;
  List<TodoItem> get reminders => _reminders;

  TodoController() {
    _loadDataFromDisk();
  }

  // --- TAB NAVIGATION MANIPULATION ---
  void changeTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // --- TASKS MANAGEMENT METHODS ---
  void addTask(String title, {String? details, required DateTime dueDate}) {
    // 'required DateTime' means this method physically cannot run unless a date is handed to it.
    if (title.trim().isNotEmpty) {
      _tasks.add(
        TodoItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title.trim(),
          details: details,
          dueDate: dueDate,
        ),
      );
      notifyListeners();
      _saveListToDisk('my_tasks_storage.json', _tasks);
    }
  }

  // FIXED: Applied the identical date checking protection rules here for updating tasks
  String? updateTask(
    int index,
    String newTitle, {
    String? newDetails,
    DateTime? newDueDate,
  }) {
    if (newDueDate == null) {
      return 'A due date must be selected before updating a task.';
    }

    if (newTitle.trim().isEmpty) {
      return 'Task title cannot be empty.';
    }

    if (index >= 0 && index < _tasks.length) {
      _tasks[index] = TodoItem(
        id: _tasks[index].id,
        title: newTitle.trim(),
        details: newDetails,
        dueDate: newDueDate,
      );

      notifyListeners();
      _saveListToDisk('my_tasks_storage.json', _tasks);
      return null; // Success state
    }

    return 'Invalid task entry target.';
  }

  void deleteTask(int index) {
    if (index >= 0 && index < _tasks.length) {
      _tasks.removeAt(index);
      notifyListeners();
      _saveListToDisk('my_tasks_storage.json', _tasks);
    }
  }

  // --- REMINDERS MANAGEMENT METHODS ---
  void addReminder(String title, {String? details}) {
    if (title.trim().isNotEmpty) {
      _reminders.add(
        TodoItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title.trim(),
          details: details,
          dueDate: null,
        ),
      );
      notifyListeners();
      _saveListToDisk('my_reminders_storage.json', _reminders);
    }
  }

  void updateReminder(int index, String newTitle, {String? newDetails}) {
    if (newTitle.trim().isNotEmpty && index >= 0 && index < _reminders.length) {
      _reminders[index] = TodoItem(
        id: _reminders[index].id,
        title: newTitle.trim(),
        details: newDetails,
        dueDate: null,
      );
      notifyListeners();
      _saveListToDisk('my_reminders_storage.json', _reminders);
    }
  }

  void deleteReminder(int index) {
    if (index >= 0 && index < _reminders.length) {
      _reminders.removeAt(index);
      notifyListeners();
      _saveListToDisk('my_reminders_storage.json', _reminders);
    }
  }

  // --- HARD DRIVE DISK OPERATIONS ---
  Future<void> _saveListToDisk(String filename, List<TodoItem> list) async {
    try {
      final file = File(filename);
      final jsonString = jsonEncode(list.map((item) => item.toJson()).toList());
      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('Error writing to $filename: $e');
    }
  }

  Future<void> _loadDataFromDisk() async {
    try {
      // Load Tasks
      final taskFile = File('my_tasks_storage.json');
      if (await taskFile.exists()) {
        final content = await taskFile.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _tasks.clear();
        _tasks.addAll(
          jsonList.map(
            (json) => TodoItem.fromJson(json as Map<String, dynamic>),
          ),
        );
      }

      // Load Reminders
      final reminderFile = File('my_reminders_storage.json');
      if (await reminderFile.exists()) {
        final content = await reminderFile.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _reminders.clear();
        _reminders.addAll(
          jsonList.map(
            (json) => TodoItem.fromJson(json as Map<String, dynamic>),
          ),
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error reading files from disk: $e');
    }
  }
}

import 'package:flutter/material.dart';
import '../controllers/todo_controller.dart';
import 'widgets/todo_sidebar.dart';
import 'widgets/tab_calendar.dart';
import 'widgets/tab_tasks.dart';
import 'widgets/tab_reminders.dart';

class TodoView extends StatelessWidget {
  final TodoController controller;

  const TodoView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final activeIndex = controller.currentTabIndex;

        return Scaffold(
          backgroundColor: const Color(0xFFF9F6EF),
          body: Row(
            children: [
              // Left Column Nav
              TodoSidebar(
                activeIndex: activeIndex,
                onTabSelected: controller.changeTab,
              ),

              // Right Content Viewport
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: _buildActiveTab(activeIndex),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔄 REARRANGED: Calendar is now index 0 (Dashboard default)
  Widget _buildActiveTab(int index) {
    switch (index) {
      case 0:
        // ❌ BEFORE: return const TabCalendar();
        return TabCalendar(
          controller: controller,
        ); //  FIXED: Pass the required controller
      case 1:
        return TabTasks(controller: controller);
      case 2:
        return TabReminders(controller: controller);
      default:
        // ❌ BEFORE: return const TabCalendar();
        return TabCalendar(
          controller: controller,
        ); //  FIXED: Pass the required controller here too
    }
  }
}

import 'package:flutter/material.dart';
import '../controllers/todo_controller.dart';
import '../controllers/music_controller.dart'; // Added import
import 'widgets/todo_sidebar.dart';
import 'widgets/tab_calendar.dart';
import 'widgets/tab_tasks.dart';
import 'widgets/tab_reminders.dart';
import 'palette.dart';

class TodoView extends StatelessWidget {
  final TodoController controller;
  final MusicManager musicManager; // Added field

  const TodoView({
    super.key,
    required this.controller,
    required this.musicManager, // Added to constructor
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final activeIndex = controller.currentTabIndex;

        return ValueListenableBuilder<PaletteInstance>(
          valueListenable: ThemeManager.activePalette,
          builder: (context, palette, child) {
            final Color paperBackground = palette.sandstoneCream;
            final Color gridLineColor =
                palette.blueprintBlue.withValues(alpha: 0.12);

            return Scaffold(
              backgroundColor: paperBackground,
              body: Row(
                children: [
                  TodoSidebar(
                    activeIndex: activeIndex,
                    onTabSelected: controller.changeTab,
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: AnimatedBaseCanvas(
                            gridColor: gridLineColor,
                            backgroundColor: paperBackground,
                            gridSize: 24.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: _buildActiveTab(activeIndex),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActiveTab(int index) {
    switch (index) {
      case 0:
        return TabCalendar(controller: controller, musicManager: musicManager);
      case 1:
        return TabTasks(controller: controller);
      case 2:
        return TabReminders(controller: controller);
      default:
        return TabCalendar(controller: controller, musicManager: musicManager);
    }
  }
}

// --- ANIMATED WRAPPER FOR SMOOTH GRAPHICS TRANSITIONS ---
class AnimatedBaseCanvas extends StatelessWidget {
  final Color gridColor;
  final Color backgroundColor;
  final double gridSize;

  const AnimatedBaseCanvas({
    super.key,
    required this.gridColor,
    required this.backgroundColor,
    required this.gridSize,
  });

  @override
  Widget build(BuildContext context) {
    // Implicit animations smooth out the background shifts over 200ms
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: backgroundColor,
      child: CustomPaint(
        painter: CheckeredBackgroundPainter(
          gridColor: gridColor,
          gridSize: gridSize,
        ),
      ),
    );
  }
}

// --- SUBTLE HIGH-PERFORMANCE CHECKERED CANVAS PAINTER ---
class CheckeredBackgroundPainter extends CustomPainter {
  final Color gridColor;
  final double gridSize;

  CheckeredBackgroundPainter({required this.gridColor, this.gridSize = 24.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.6;

    // Draw vertical check lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal check lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CheckeredBackgroundPainter oldDelegate) =>
      oldDelegate.gridColor != gridColor || oldDelegate.gridSize != gridSize;
}

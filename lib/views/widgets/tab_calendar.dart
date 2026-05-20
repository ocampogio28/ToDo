import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/todo_controller.dart';
import '../../models/task_model.dart';

class TabCalendar extends StatefulWidget {
  final TodoController controller;

  const TabCalendar({super.key, required this.controller});

  @override
  State<TabCalendar> createState() => _TabCalendarState();
}

class _TabCalendarState extends State<TabCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<TodoItem> _getTasksForDay(DateTime day) {
    return widget.controller.tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == day.year &&
          task.dueDate!.month == day.month &&
          task.dueDate!.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final targetedTasks =
        _selectedDay != null ? _getTasksForDay(_selectedDay!) : [];

    // --- ARCHITECTURAL CUSTOM COLOR PALETTE ---
    const Color blueprintBlue = Color(0xFF2B77A4); // Accent & Ink text color
    const Color sandstoneCream = Color(0xFFF4F1EB); // Base surface paper color
    const double globalRadius = 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // --- 1. TRACKING TIME HEADER ---
        _ClipboardClock(
            inkColor: blueprintBlue,
            accentColor: blueprintBlue.withValues(alpha: 0.6)),
        const SizedBox(height: 24),

        // --- 2. CURVED CALENDAR SHEET ---
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 420,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: sandstoneCream, // Applied sandstone cream background
                borderRadius: BorderRadius.circular(globalRadius),
                border: Border.all(
                    color: blueprintBlue.withValues(alpha: 0.15), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: blueprintBlue.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: ListenableBuilder(
                listenable: widget.controller,
                builder: (context, child) {
                  return TableCalendar(
                    firstDay: DateTime.utc(2025, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    rowHeight: 38,
                    daysOfWeekHeight: 26,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    eventLoader: _getTasksForDay,
                    calendarBuilders: CalendarBuilders(
                      dowBuilder: (context, day) {
                        return Center(
                          child: Text(
                            DateFormat.E().format(day).toUpperCase(),
                            style: TextStyle(
                              color: blueprintBlue.withValues(alpha: 0.6),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      },
                      // Rounded blueprint indicator dot
                      markerBuilder: (context, date, events) {
                        if (events.isNotEmpty) {
                          return Positioned(
                            bottom: 4,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSameDay(_selectedDay, date)
                                    ? sandstoneCream
                                    : blueprintBlue.withValues(alpha: 0.5),
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: const TextStyle(
                          color: blueprintBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                      weekendTextStyle: TextStyle(
                          color: blueprintBlue.withValues(alpha: 0.5),
                          fontSize: 13),
                      outsideDaysVisible: false,

                      // Today: Sharp hollow ring outline
                      todayDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: blueprintBlue.withValues(alpha: 0.5),
                            width: 1.2),
                      ),
                      todayTextStyle: const TextStyle(
                          color: blueprintBlue, fontWeight: FontWeight.bold),

                      // Selected: Inverted solid deep slate blue circle
                      selectedDecoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: blueprintBlue,
                      ),
                      selectedTextStyle: const TextStyle(
                          color: sandstoneCream, fontWeight: FontWeight.bold),
                    ),
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      titleTextStyle: const TextStyle(
                        color: blueprintBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                      formatButtonVisible: false,
                      leftChevronIcon: const Icon(Icons.arrow_left_rounded,
                          color: blueprintBlue, size: 22),
                      rightChevronIcon: const Icon(Icons.arrow_right_rounded,
                          color: blueprintBlue, size: 22),
                      headerPadding: const EdgeInsets.symmetric(vertical: 2.0),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // --- 3. SECTION SUB-LABEL ---
        Row(
          children: [
            Container(
              width: 8,
              height: 4,
              decoration: BoxDecoration(
                color: blueprintBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _selectedDay == null
                  ? 'DAILY MANIFEST'
                  : 'LOG // ${DateFormat('yyyy_MM_dd').format(_selectedDay!).toUpperCase()}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: blueprintBlue,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // --- 4. CURVED TASK TILES ---
        Expanded(
          child: ListenableBuilder(
            listenable: widget.controller,
            builder: (context, child) {
              if (targetedTasks.isEmpty) {
                return Center(
                  child: Text(
                    '[ NO ENTRIES RECORDED ]',
                    style: TextStyle(
                        color: blueprintBlue.withValues(alpha: 0.4),
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                );
              }

              return ListView.builder(
                itemCount: targetedTasks.length,
                itemBuilder: (context, index) {
                  final task = targetedTasks[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          sandstoneCream, // Applied sandstone cream background
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: blueprintBlue.withValues(alpha: 0.12),
                          width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: blueprintBlue.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      title: Text(
                        task.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: blueprintBlue,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: task.details != null && task.details!.isNotEmpty
                          ? Text(
                              task.details!,
                              style: TextStyle(
                                color: blueprintBlue.withValues(alpha: 0.6),
                                fontSize: 11,
                              ),
                            )
                          : null,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ClipboardClock extends StatefulWidget {
  final Color inkColor;
  final Color accentColor;
  const _ClipboardClock({required this.inkColor, required this.accentColor});

  @override
  State<_ClipboardClock> createState() => _ClipboardClockState();
}

class _ClipboardClockState extends State<_ClipboardClock> {
  late DateTime _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeString = DateFormat('HH:mm').format(_currentTime);
    final secString = DateFormat(':ss').format(_currentTime);
    final dateString =
        DateFormat('EEE / MMM d / yyyy').format(_currentTime).toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              timeString,
              style: TextStyle(
                color: widget.inkColor,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              secString,
              style: TextStyle(
                color: widget.inkColor.withValues(alpha: 0.4),
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'RECORD DATE // $dateString',
          style: TextStyle(
            color: widget.inkColor.withValues(alpha: 0.55),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

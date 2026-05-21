import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/todo_controller.dart';
import '../../models/task_model.dart';
import 'package:todo_desktop/views/palette.dart';

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

    const double globalRadius = 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // --- 1. LIVE TIME & API WEATHER HEADER ---
        _ClipboardClock(
          inkColor: Palette.blueprintBlue,
          accentColor: Palette.blueprintBlue.withValues(alpha: 0.2),
        ),
        const SizedBox(height: 24),

        // --- 2. CURVED CALENDAR SHEET ---
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 420,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: Palette.sandstoneCream,
                borderRadius: BorderRadius.circular(globalRadius),
                border: Border.all(
                    color: Palette.blueprintBlue,
                    width: 1), // 🛠️ FIXED: Replaced non-existent key
                boxShadow: [
                  BoxShadow(
                    color: Palette.blueprintBlue.withValues(alpha: 0.1),
                    blurRadius: 16,
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
                              color: Palette
                                  .blueprintBlue, // 🛠️ FIXED: Replaced non-existent key
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        );
                      },
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
                                    ? Palette.sandstoneCream
                                    : Palette
                                        .blueprintBlue, // 🛠️ FIXED: Replaced non-existent key
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: TextStyle(
                          color: Palette.blueprintBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.w700),
                      weekendTextStyle: TextStyle(
                          color: Palette
                              .blueprintBlue, // 🛠️ FIXED: Replaced non-existent key
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                      outsideDaysVisible: false,
                      todayDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Palette.blueprintBlue,
                            width:
                                1), // 🛠️ FIXED: Resolved BorderSide type crash
                      ),
                      todayTextStyle: TextStyle(
                          color: Palette.blueprintBlue,
                          fontWeight: FontWeight
                              .bold), // 🛠️ FIXED: Replaced non-existent key
                      selectedDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Palette.blueprintBlue,
                      ),
                      selectedTextStyle: TextStyle(
                          color: Palette.sandstoneCream,
                          fontWeight: FontWeight.bold),
                    ),
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        color: Palette.blueprintBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                      formatButtonVisible: false,
                      leftChevronIcon: Icon(Icons.arrow_left_rounded,
                          color: Palette.blueprintBlue, size: 24),
                      rightChevronIcon: Icon(Icons.arrow_right_rounded,
                          color: Palette.blueprintBlue, size: 24),
                      headerPadding: EdgeInsets.symmetric(vertical: 2.0),
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
                color: Palette
                    .blueprintBlue, // 🛠️ FIXED: Replaced non-existent key
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _selectedDay == null
                  ? 'SELECT A DATE TO VIEW TASKS'
                  : 'Tasks due on : ${DateFormat('yyyy-MM-dd').format(_selectedDay!).toUpperCase()}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Palette
                    .blueprintBlue, // 🛠️ FIXED: Replaced non-existent key
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // --- 4. TASK TILES VIEW ---
        Expanded(
          child: ListenableBuilder(
            listenable: widget.controller,
            builder: (context, child) {
              if (targetedTasks.isEmpty) {
                return Center(
                  child: Text(
                    '[ NO ENTRIES RECORDED ]',
                    style: TextStyle(
                        color: Palette.blueprintBlue.withValues(
                            alpha: 0.6), // 🛠️ FIXED: Replaced non-existent key
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5),
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
                      color: Palette.sandstoneCream,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: Palette.blueprintBlue, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Palette.blueprintBlue.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Palette.blueprintBlue,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: task.details != null && task.details!.isNotEmpty
                          ? Text(
                              task.details!,
                              style: TextStyle(
                                color: Palette
                                    .blueprintBlue, // 🛠️ FIXED: Replaced non-existent key
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
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

// --- CLOCK AND WEATHER WIDGET WITH LIVE PARSING ---
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

  String _temperature = "--°C";
  String _condition = "LOADING WEATHER...";
  bool _isLoadingWeather = true;

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

    _fetchLiveWeather();
  }

  Future<void> _fetchLiveWeather() async {
    try {
      final url = Uri.parse('https://wttr.in/?format=j1');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final currentCondition = data['current_condition'][0];
        final tempC = currentCondition['temp_C'];
        final desc = currentCondition['weatherDesc'][0]['value']
            .toString()
            .toUpperCase();

        if (mounted) {
          setState(() {
            _temperature = "$tempC°C";
            _condition = desc;
            _isLoadingWeather = false;
          });
        }
      } else {
        throw Exception();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _temperature = "??°C";
          _condition = "WEATHER OFFLINE";
          _isLoadingWeather = false;
        });
      }
    }
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
                    height: 1.1,
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
            const SizedBox(height: 4),
            Text(
              'TODAY : $dateString',
              style: TextStyle(
                color: widget.inkColor.withValues(alpha: 0.55),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  _isLoadingWeather
                      ? Icons.wb_cloudy_rounded
                      : Icons.wb_sunny_rounded,
                  color: widget.inkColor,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  _temperature,
                  style: TextStyle(
                    color: widget.inkColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _condition,
              style: TextStyle(
                color: widget.inkColor.withValues(alpha: 0.55),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

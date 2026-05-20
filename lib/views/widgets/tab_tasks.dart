import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/todo_controller.dart';
import '../../models/task_model.dart';

class TabTasks extends StatefulWidget {
  final TodoController controller;

  const TabTasks({super.key, required this.controller});

  @override
  State<TabTasks> createState() => _TabTasksState();
}

class _TabTasksState extends State<TabTasks> {
  // --- COLOR PALETTE ---
  final Color blueprintBlue = const Color(0xFF2B77A4);
  final Color sandstoneCream = const Color(0xFFF4F1EB);

  // --- MODAL: TASK CREATION/EDITING ---
  void _showTaskModal(BuildContext context, {int? index, TodoItem? item}) {
    final TextEditingController titleController =
        TextEditingController(text: item?.title ?? '');
    final TextEditingController detailsController =
        TextEditingController(text: item?.details ?? '');
    DateTime selectedDate = item?.dueDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: sandstoneCream,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(index == null ? 'NEW MANIFEST' : 'MODIFY ENTRY',
                  style: TextStyle(
                      color: blueprintBlue, fontWeight: FontWeight.w900)),
              content: SizedBox(
                width: 450,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: blueprintBlue),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'TASK TITLE',
                        labelStyle: TextStyle(
                            color: blueprintBlue.withValues(alpha: 0.6)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: blueprintBlue.withValues(alpha: 0.3))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: blueprintBlue)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: detailsController,
                      style: TextStyle(color: blueprintBlue),
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'DETAILS',
                        labelStyle: TextStyle(
                            color: blueprintBlue.withValues(alpha: 0.6)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: blueprintBlue.withValues(alpha: 0.3))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: blueprintBlue)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(DateFormat('yyyy-MM-dd').format(selectedDate),
                          style: TextStyle(color: blueprintBlue)),
                      leading: Icon(Icons.calendar_today, color: blueprintBlue),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setModalState(() => selectedDate = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text('CANCEL',
                        style: TextStyle(
                            color: blueprintBlue.withValues(alpha: 0.5)))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: blueprintBlue,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      if (index == null) {
                        widget.controller.addTask(titleController.text,
                            details: detailsController.text,
                            dueDate: selectedDate);
                      } else {
                        widget.controller.updateTask(
                            index, titleController.text,
                            newDetails: detailsController.text,
                            newDueDate: selectedDate);
                      }
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('SAVE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- DELETE CONFIRMATION ---
  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: sandstoneCream,
        title: Text("DELETE ENTRY",
            style:
                TextStyle(color: blueprintBlue, fontWeight: FontWeight.w900)),
        content: Text("Are you sure you want to delete this task?",
            style: TextStyle(color: blueprintBlue.withValues(alpha: 0.7))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("CANCEL",
                style: TextStyle(color: blueprintBlue.withValues(alpha: 0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              widget.controller.deleteTask(index);
              Navigator.pop(ctx);
            },
            child: const Text("DELETE"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        final taskList = widget.controller.tasks;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('MY TASKS',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: blueprintBlue)),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: blueprintBlue)),
                    onPressed: () => _showTaskModal(context),
                    icon: Icon(Icons.add, color: blueprintBlue),
                    label: Text('NEW', style: TextStyle(color: blueprintBlue)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: taskList.isEmpty
                    ? Center(
                        child: Text('[ NO ENTRIES RECORDED ]',
                            style: TextStyle(
                                color: blueprintBlue.withValues(alpha: 0.4))))
                    : ListView.builder(
                        itemCount: taskList.length,
                        itemBuilder: (context, index) {
                          final item = taskList[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 2),
                            decoration: BoxDecoration(
                              color: sandstoneCream,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: blueprintBlue.withValues(alpha: 0.12)),
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        blueprintBlue.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4))
                              ],
                            ),
                            child: ListTile(
                              title: Text(item.title,
                                  style: TextStyle(
                                      color: blueprintBlue,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item.details != null &&
                                      item.details!.isNotEmpty)
                                    Text(item.details!,
                                        style: TextStyle(
                                            color: blueprintBlue.withValues(
                                                alpha: 0.7),
                                            fontSize: 12)),
                                  if (item.dueDate != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(children: [
                                        Icon(Icons.calendar_today,
                                            size: 11,
                                            color: blueprintBlue.withValues(
                                                alpha: 0.5)),
                                        const SizedBox(width: 4),
                                        Text(
                                            DateFormat('yyyy-MM-dd')
                                                .format(item.dueDate!),
                                            style: TextStyle(
                                                color: blueprintBlue.withValues(
                                                    alpha: 0.6),
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold)),
                                      ]),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      icon: Icon(Icons.edit,
                                          color: blueprintBlue, size: 18),
                                      onPressed: () => _showTaskModal(context,
                                          index: index, item: item)),
                                  IconButton(
                                      icon: Icon(Icons.delete,
                                          color:
                                              Colors.red.withValues(alpha: 0.7),
                                          size: 18),
                                      onPressed: () =>
                                          _confirmDelete(context, index)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

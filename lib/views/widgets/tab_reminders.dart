import 'package:flutter/material.dart';
import '../../controllers/todo_controller.dart';
import '../../models/task_model.dart';

class TabReminders extends StatefulWidget {
  final TodoController controller;

  const TabReminders({super.key, required this.controller});

  @override
  State<TabReminders> createState() => _TabRemindersState();
}

class _TabRemindersState extends State<TabReminders> {
  // --- COLOR PALETTE ---
  final Color blueprintBlue = const Color(0xFF2B77A4);
  final Color sandstoneCream = const Color(0xFFF4F1EB);

  // --- MODAL: DELETE CONFIRMATION ---
  void _confirmDelete(BuildContext context, int index, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: sandstoneCream,
        title: Text("DELETE REMINDER",
            style:
                TextStyle(color: blueprintBlue, fontWeight: FontWeight.w900)),
        content: Text("Are you sure you want to delete \"$title\"?",
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
                foregroundColor: Colors.white),
            onPressed: () {
              widget.controller.deleteReminder(index);
              Navigator.pop(ctx);
            },
            child: const Text("DELETE"),
          ),
        ],
      ),
    );
  }

  // --- MODAL: REMINDER CREATION/EDITING ---
  void _showReminderModal(BuildContext context, {int? index, TodoItem? item}) {
    final TextEditingController titleController =
        TextEditingController(text: item?.title ?? '');
    final TextEditingController detailsController =
        TextEditingController(text: item?.details ?? '');

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: sandstoneCream,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(index == null ? 'NEW REMINDER' : 'MODIFY REMINDER',
              style:
                  TextStyle(color: blueprintBlue, fontWeight: FontWeight.w900)),
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
                    labelText: 'REMINDER TITLE',
                    labelStyle:
                        TextStyle(color: blueprintBlue.withValues(alpha: 0.6)),
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
                    labelStyle:
                        TextStyle(color: blueprintBlue.withValues(alpha: 0.6)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: blueprintBlue.withValues(alpha: 0.3))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: blueprintBlue)),
                  ),
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
                    widget.controller.addReminder(titleController.text,
                        details: detailsController.text);
                  } else {
                    widget.controller.updateReminder(
                        index, titleController.text,
                        newDetails: detailsController.text);
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
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        final reminderList = widget.controller.reminders;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('REMINDERS',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: blueprintBlue)),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: blueprintBlue)),
                    onPressed: () => _showReminderModal(context),
                    icon: Icon(Icons.add, color: blueprintBlue),
                    label: Text('NEW', style: TextStyle(color: blueprintBlue)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: reminderList.isEmpty
                    ? Center(
                        child: Text('[ NO REMINDERS SET ]',
                            style: TextStyle(
                                color: blueprintBlue.withValues(alpha: 0.4))))
                    : ListView.builder(
                        itemCount: reminderList.length,
                        itemBuilder: (context, index) {
                          final item = reminderList[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 2),
                            decoration: BoxDecoration(
                              // 🔥 SPECIFIED DESIGN SYSTEM FRAME PROPERTIES APPLIED HERE 🔥
                              color: sandstoneCream,
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: blueprintBlue, width: 1),
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        blueprintBlue.withValues(alpha: 0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3))
                              ],
                            ),
                            child: ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              title: Text(item.title,
                                  style: TextStyle(
                                      color: blueprintBlue,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14)),
                              subtitle: item.details != null &&
                                      item.details!.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Text(item.details!,
                                          style: TextStyle(
                                              color: blueprintBlue.withValues(
                                                  alpha: 0.7),
                                              fontSize: 12)),
                                    )
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      icon: Icon(Icons.edit,
                                          color: blueprintBlue, size: 18),
                                      onPressed: () => _showReminderModal(
                                          context,
                                          index: index,
                                          item: item)),
                                  IconButton(
                                      icon: Icon(Icons.delete,
                                          color:
                                              Colors.red.withValues(alpha: 0.7),
                                          size: 18),
                                      onPressed: () => _confirmDelete(
                                          context, index, item.title)),
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

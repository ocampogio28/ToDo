import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../controllers/todo_controller.dart';
import '../../models/task_model.dart';
import 'package:todo_desktop/views/palette.dart'; // 🎨 FIXED: Added absolute global palette reference

class TabReminders extends StatefulWidget {
  final TodoController controller;

  const TabReminders({super.key, required this.controller});

  @override
  State<TabReminders> createState() => _TabRemindersState();
}

class _TabRemindersState extends State<TabReminders> {
  // --- AUDIO PIPELINE PLAYER ---
  final AudioPlayer _audioPlayer = AudioPlayer();

  void _playSFX(String fileName) async {
    try {
      await _audioPlayer.stop(); // Stops any ongoing sound immediately
      await _audioPlayer.play(AssetSource(fileName));
    } catch (e) {
      debugPrint("View sound effect error ($fileName): $e");
    }
  }

  // --- MODAL: DELETE CONFIRMATION ---
  void _confirmDelete(BuildContext context, int index, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            Palette.sandstoneCream, // 🎨 Centralized Palette integration
        title: Text("DELETE REMINDER",
            style: TextStyle(
                color: Palette.blueprintBlue,
                fontWeight:
                    FontWeight.w900)), // 🎨 Centralized Palette integration
        content: Text("Are you sure you want to delete \"$title\"?",
            style: TextStyle(
                color: Palette.blueprintBlue.withValues(
                    alpha: 0.7))), // 🎨 Centralized Palette integration
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("CANCEL",
                style: TextStyle(
                    color: Palette.blueprintBlue.withValues(
                        alpha: 0.5))), // 🎨 Centralized Palette integration
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor:
                    Palette.pureWhite), // 🎨 Swapped to Palette constant
            onPressed: () {
              _playSFX('delete.mp3'); // 🔥 Play deletion sound effect
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
          backgroundColor:
              Palette.sandstoneCream, // 🎨 Centralized Palette integration
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(index == null ? 'NEW REMINDER' : 'MODIFY REMINDER',
              style: TextStyle(
                  color: Palette.blueprintBlue,
                  fontWeight:
                      FontWeight.w900)), // 🎨 Centralized Palette integration
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: TextStyle(
                      color: Palette
                          .blueprintBlue), // 🎨 Centralized Palette integration
                  decoration: InputDecoration(
                    filled: true,
                    fillColor:
                        Palette.pureWhite, // 🎨 Swapped to Palette constant
                    labelText: 'REMINDER TITLE',
                    labelStyle: TextStyle(
                        color: Palette.blueprintBlue.withValues(
                            alpha: 0.6)), // 🎨 Centralized Palette integration
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Palette.blueprintBlue.withValues(
                                alpha:
                                    0.3))), // 🎨 Centralized Palette integration
                    focusedBorder: OutlineInputBorder(
                        // 🎯 FIXED: Correctly configured without compiler 'const' conflicts
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Palette
                                .blueprintBlue)), // 🎨 Centralized Palette integration
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: detailsController,
                  style: TextStyle(
                      color: Palette
                          .blueprintBlue), // 🎨 Centralized Palette integration
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor:
                        Palette.pureWhite, // 🎨 Swapped to Palette constant
                    labelText: 'DETAILS',
                    labelStyle: TextStyle(
                        color: Palette.blueprintBlue.withValues(
                            alpha: 0.6)), // 🎨 Centralized Palette integration
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Palette.blueprintBlue.withValues(
                                alpha:
                                    0.3))), // 🎨 Centralized Palette integration
                    focusedBorder: OutlineInputBorder(
                        // 🎯 FIXED: Correctly configured without compiler 'const' conflicts
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Palette
                                .blueprintBlue)), // 🎨 Centralized Palette integration
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
                        color: Palette.blueprintBlue.withValues(
                            alpha:
                                0.5)))), // 🎨 Centralized Palette integration
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Palette
                      .blueprintBlue, // 🎨 Centralized Palette integration
                  foregroundColor:
                      Palette.pureWhite), // 🎨 Swapped to Palette constant
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  _playSFX('add.mp3'); // 🔥 Play add sound effect when saved
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
  void dispose() {
    _audioPlayer.dispose(); // Cleans up native desktop resources
    super.dispose();
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
                          color: Palette
                              .blueprintBlue)), // 🎨 Centralized Palette integration
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Palette
                                .blueprintBlue)), // 🎨 Centralized Palette integration
                    onPressed: () => _showReminderModal(context),
                    icon: Icon(Icons.add,
                        color: Palette
                            .blueprintBlue), // 🎨 Centralized Palette integration
                    label: Text('NEW',
                        style: TextStyle(
                            color: Palette
                                .blueprintBlue)), // 🎨 Centralized Palette integration
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: reminderList.isEmpty
                    ? Center(
                        child: Text('[ NO REMINDERS SET ]',
                            style: TextStyle(
                                color: Palette.blueprintBlue.withValues(
                                    alpha:
                                        0.4)))) // 🎨 Centralized Palette integration
                    : ListView.builder(
                        itemCount: reminderList.length,
                        itemBuilder: (context, index) {
                          final item = reminderList[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 2),
                            decoration: BoxDecoration(
                              color: Palette
                                  .sandstoneCream, // 🎨 Centralized Palette integration
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Palette.blueprintBlue,
                                  width:
                                      1), // 🎨 Centralized Palette integration
                              boxShadow: [
                                BoxShadow(
                                    color: Palette.blueprintBlue.withValues(
                                        alpha:
                                            0.03), // 🎨 Centralized Palette integration
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
                                      color: Palette
                                          .blueprintBlue, // 🎨 Centralized Palette integration
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14)),
                              subtitle: item.details != null &&
                                      item.details!.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Text(item.details!,
                                          style: TextStyle(
                                              color: Palette.blueprintBlue
                                                  .withValues(
                                                      // 🎨 Centralized Palette integration
                                                      alpha: 0.7),
                                              fontSize: 12)),
                                    )
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      icon: Icon(Icons.edit,
                                          color: Palette.blueprintBlue,
                                          size:
                                              18), // 🎨 Centralized Palette integration
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

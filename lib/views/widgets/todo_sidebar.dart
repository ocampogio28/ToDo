import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:todo_desktop/views/palette.dart';

class TodoSidebar extends StatefulWidget {
  final int activeIndex;
  final ValueChanged<int> onTabSelected;

  const TodoSidebar({
    super.key,
    required this.activeIndex,
    required this.onTabSelected,
  });

  @override
  State<TodoSidebar> createState() => _TodoSidebarState();
}

class _TodoSidebarState extends State<TodoSidebar> {
  // --- INDEPENDENT UTILITY STATES ---
  bool _isPresentationActive = false;
  bool _isHealthTimerActive = false;

  Timer? _healthTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // --- SOUND EFFECTS PIPELINE ---

  // 🖱️ Audio track for regular UI button presses
  void _playClickSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('button.mp3'));
    } catch (e) {
      debugPrint("Click sound error: $e");
    }
  }

  // 🔔 Audio track for the health alerts
  void _playDingSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('ding.mp3'));
    } catch (e) {
      debugPrint("Ding sound error: $e");
    }
  }

  // --- TOGGLE 1: STAY AWAKE LINK ---
  void _togglePresentationMode() {
    _playClickSound(); // Play dynamic button click sound
    setState(() {
      _isPresentationActive = !_isPresentationActive;
    });

    if (_isPresentationActive) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  // --- TOGGLE 2: HEALTH TIMER LINK ---
  void _toggleHealthTimer() {
    _playClickSound(); // Play dynamic button click sound
    setState(() {
      _isHealthTimerActive = !_isHealthTimerActive;
    });

    if (_isHealthTimerActive) {
      _runHealthCycle();
    } else {
      _healthTimer?.cancel();
    }
  }

  // --- TOGGLE 3: NIGHT MODE LINK ---
  void _toggleNightMode() {
    _playClickSound(); // Play click noise on layout transformation
    ThemeManager.toggleTheme();
  }

  void _runHealthCycle() {
    _healthTimer?.cancel();

    if (mounted && _isHealthTimerActive) {
      _showHealthPopup(context);
    }

    _healthTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      if (mounted && _isHealthTimerActive) {
        _showHealthPopup(context);
      }
    });
  }

  void _showHealthPopup(BuildContext context) {
    _playDingSound(); // 🔥 Play the alert DING sound right here when popup opens!
    final palette = ThemeManager.activePalette.value;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: palette.sandstoneCream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: palette.blueprintBlue, width: 1.5),
        ),
        title: Row(
          children: [
            Icon(Icons.spa_rounded, color: palette.blueprintBlue),
            const SizedBox(width: 8),
            IconTheme(
              data: IconThemeData(color: palette.blueprintBlue),
              child: Text(
                "HEALTH REMINDER",
                style: TextStyle(
                    color: palette.blueprintBlue,
                    fontWeight: FontWeight.w900,
                    fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Time to stretch and hydrate!",
              style: TextStyle(
                  color: palette.blueprintBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              "• Take a sip of water \n• Stand up, roll your shoulders \n• Look away from the screen ",
              style: TextStyle(
                  color: palette.blueprintBlue.withValues(alpha: 0.8),
                  height: 1.5,
                  fontSize: 13),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: palette.blueprintBlue,
              foregroundColor: palette.sandstoneCream,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              _playClickSound(); // Click sound when closing modal
              Navigator.pop(ctx);
            },
            child: const Text("GOT IT",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _healthTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PaletteInstance>(
      valueListenable: ThemeManager.activePalette,
      builder: (context, palette, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 72,
          decoration: BoxDecoration(
            // 🛠️ FIXED: Now points strictly to the notifier object reference state
            color: palette.sidebarBg,
            border: Border(
              right: BorderSide(
                color: palette.blueprintBlue.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // --- TOP: NAVIGATION TABS ---
              _buildSidebarTile(
                  index: 0,
                  icon: Icons.calendar_month_rounded,
                  palette: palette),
              _buildSidebarTile(
                  index: 1, icon: Icons.layers_rounded, palette: palette),
              _buildSidebarTile(
                  index: 2,
                  icon: Icons.space_dashboard_rounded,
                  palette: palette),

              const Spacer(),

              // --- BOTTOM: UNIFORM UTILITY TILES ---
              _buildUtilityTile(
                isActive: _isHealthTimerActive,
                icon: Icons.spa_rounded,
                onTap: _toggleHealthTimer,
                description: _isHealthTimerActive
                    ? 'Health Alerts is ON'
                    : 'Turn ON Health Alerts',
                palette: palette,
              ),

              _buildUtilityTile(
                isActive: _isPresentationActive,
                icon: Icons.power_settings_new_rounded,
                onTap: _togglePresentationMode,
                description: _isPresentationActive
                    ? 'Stay Awake is ON'
                    : 'Turn ON Stay Awake Mode',
                palette: palette,
              ),

              _buildUtilityTile(
                isActive: ThemeManager.isDarkMode,
                icon: ThemeManager.isDarkMode
                    ? Icons.wb_sunny_rounded
                    : Icons.nightlight_round,
                onTap: _toggleNightMode,
                description: ThemeManager.isDarkMode
                    ? 'Switch to Light Mode'
                    : 'Switch to Dark Mode',
                palette: palette,
              ),
              const SizedBox(height: 14),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUtilityTile({
    required bool isActive,
    required IconData icon,
    required VoidCallback onTap,
    required String description,
    required PaletteInstance palette,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Tooltip(
        message: description,
        textStyle: TextStyle(
            color: ThemeManager.isDarkMode
                ? const Color(0xFF12151C)
                : const Color(0xFFF4F1EB),
            fontSize: 11,
            fontWeight: FontWeight.w500),
        decoration: BoxDecoration(
          color: palette.blueprintBlue,
          borderRadius: BorderRadius.circular(6),
        ),
        waitDuration: const Duration(milliseconds: 400),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            hoverColor: palette.blueprintBlue.withValues(alpha: 0.05),
            splashColor: palette.blueprintBlue.withValues(alpha: 0.1),
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isActive
                      ? palette.blueprintBlue.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isActive
                      ? palette.blueprintBlue
                      : palette.blueprintBlue.withValues(alpha: 0.3),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarTile({
    required int index,
    required IconData icon,
    required PaletteInstance palette,
  }) {
    final isSelected = index == widget.activeIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _playClickSound();
            widget.onTabSelected(index);
          },
          hoverColor: palette.blueprintBlue.withValues(alpha: 0.05),
          splashColor: palette.blueprintBlue.withValues(alpha: 0.1),
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? palette.blueprintBlue.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? palette.blueprintBlue
                    : palette.blueprintBlue.withValues(alpha: 0.3),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

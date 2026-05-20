import 'package:flutter/material.dart';

class TodoSidebar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTabSelected;

  // --- COLOR PALETTE ---
  final Color blueprintBlue = const Color(0xFF2B77A4);
  final Color sandstoneCream = const Color.fromARGB(255, 211, 209, 204);

  const TodoSidebar({
    super.key,
    required this.activeIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: sandstoneCream, // Match the paper background
        border: Border(
          right: BorderSide(
            color: blueprintBlue.withValues(alpha: 0.1), // Subtle blue border
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          _buildSidebarTile(index: 0, icon: Icons.calendar_month_rounded),
          _buildSidebarTile(index: 1, icon: Icons.layers_rounded),
          _buildSidebarTile(index: 2, icon: Icons.space_dashboard_rounded),
        ],
      ),
    );
  }

  Widget _buildSidebarTile({required int index, required IconData icon}) {
    final isSelected = index == activeIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTabSelected(index),
          hoverColor: blueprintBlue.withValues(alpha: 0.05),
          splashColor: blueprintBlue.withValues(alpha: 0.1),
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
                    ? blueprintBlue.withValues(
                        alpha: 0.12) // Subtle blue highlight
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? blueprintBlue // Active "ink"
                    : blueprintBlue.withValues(alpha: 0.3), // Inactive "ink"
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

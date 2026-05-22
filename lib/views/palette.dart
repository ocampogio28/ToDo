import 'package:flutter/material.dart';

abstract class AppTheme {
  Color get blueprintBlue;
  Color get sandstoneCream;
  Color get textPrimary;
  Color get sidebarBg;
}

class LightTheme implements AppTheme {
  @override
  Color get blueprintBlue => const Color(0xFF2B77A4);
  @override
  Color get sandstoneCream => const Color(0xFFF4F1EB);
  @override
  Color get textPrimary => const Color(0xFF1E5678);
  @override
  Color get sidebarBg => const Color(0xFFEAE7E0);
}

class DarkTheme implements AppTheme {
  @override
  Color get blueprintBlue => const Color(0xFFF4AE3F);
  @override
  Color get sandstoneCream => const Color(0xFF213058);
  @override
  Color get textPrimary => const Color(0xFFF0E6D7);
  @override
  Color get sidebarBg => const Color(0xFF1B2742);
}

// Static lookups for legacy areas of your code
class Palette {
  static Color get blueprintBlue => ThemeManager.currentTheme.blueprintBlue;
  static Color get sandstoneCream => ThemeManager.currentTheme.sandstoneCream;
  static Color get textPrimary => ThemeManager.currentTheme.textPrimary;
  static Color get sidebarBg => ThemeManager.currentTheme.sidebarBg;

  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color sidebarGray = Color(0xFFEAE7E0);
}

// Instance representation for reactive builders
class PaletteInstance {
  Color get blueprintBlue => ThemeManager.currentTheme.blueprintBlue;
  Color get sandstoneCream => ThemeManager.currentTheme.sandstoneCream;
  Color get textPrimary => ThemeManager.currentTheme.textPrimary;
  Color get sidebarBg => ThemeManager.currentTheme.sidebarBg;
}

class ThemeManager {
  static AppTheme _activeTheme = LightTheme();

  // Initialize with a fresh instance direct from the constructor
  static final ValueNotifier<PaletteInstance> activePalette =
      ValueNotifier<PaletteInstance>(PaletteInstance());

  static AppTheme get currentTheme => _activeTheme;
  static bool get isDarkMode => _activeTheme is DarkTheme;

  static void toggleTheme() {
    _activeTheme = isDarkMode ? LightTheme() : DarkTheme();

    // 💥 THE FIX: Instantiating a brand-new object forces ValueNotifier to notice
    // the reference change and fire updates to all listening widgets.
    activePalette.value = PaletteInstance();
  }
}

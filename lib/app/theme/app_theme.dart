import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light() => _buildTheme(Brightness.light);

  static ThemeData dark() => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    const navy = Color(0xFF0B1630);
    const darkCard = Color(0xFF13233F);
    const gold = Color(0xFFC9A64B);
    const lightGold = Color(0xFF9C7929);
    const cream = Color(0xFFF5F1E7);
    const lightBackground = Color(0xFFF5F3EC);
    const mutedDark = Color(0xFFB7C0CE);
    const mutedLight = Color(0xFF566276);

    final background = isDark ? navy : lightBackground;
    final cardColor = isDark ? darkCard : Colors.white;
    final textColor = isDark ? cream : navy;
    final mutedText = isDark ? mutedDark : mutedLight;
    final accent = isDark ? gold : navy;
    final lineColor = isDark ? gold : lightGold;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: isDark ? gold : navy,
      brightness: brightness,
      surface: cardColor,
    ).copyWith(
      primary: accent,
      onPrimary: isDark ? navy : Colors.white,
      secondary: gold,
      onSecondary: navy,
      surface: cardColor,
      onSurface: textColor,
      outline: lineColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: 'NotoSansMyanmar',
      scaffoldBackgroundColor: background,

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textColor,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: lineColor),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: accent,
        unselectedItemColor: mutedText,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        indicatorColor: isDark
            ? gold.withValues(alpha: 0.18)
            : gold.withValues(alpha: 0.25),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: accent);
          }
          return IconThemeData(color: mutedText);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: accent);
          }
          return TextStyle(color: mutedText);
        }),
      ),

      dividerColor: lineColor,

      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: lineColor),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: gold),
        ),
      ),
    );
  }
}

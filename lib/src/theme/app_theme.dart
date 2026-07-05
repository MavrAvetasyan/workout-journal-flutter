import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const shell = Color(0xFFF2F6FF);
  const paper = Color(0xFFFFFFFF);
  const ink = Color(0xFF172338);
  const muted = Color(0xFF6D7891);
  const line = Color(0xFFDCE4F3);
  const accent = Color(0xFF1D63FF);
  const accentSoft = Color(0xFFE9F0FF);
  const success = Color(0xFFDDF5E7);

  final scheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: Brightness.light,
    primary: accent,
    surface: paper,
  ).copyWith(
    secondary: const Color(0xFF44A37A),
    surfaceContainerHighest: accentSoft,
    onPrimary: Colors.white,
    onSurface: ink,
    outline: line,
  );

  OutlineInputBorder fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: shell,
    fontFamily: 'Segoe UI',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: ink, height: 1.05),
      headlineMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: ink, height: 1.08),
      titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ink, height: 1.1),
      titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: ink, height: 1.15),
      bodyLarge: TextStyle(fontSize: 15, color: ink, height: 1.4),
      bodyMedium: TextStyle(fontSize: 14, color: muted, height: 1.45),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.1),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: ink,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: ink),
    ),
    cardTheme: CardThemeData(
      color: paper.withValues(alpha: 0.96),
      elevation: 0,
      shadowColor: const Color(0x331D63FF),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: line),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        backgroundColor: paper.withValues(alpha: 0.9),
        foregroundColor: ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        side: const BorderSide(color: line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: paper,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: const TextStyle(color: muted),
      labelStyle: const TextStyle(color: muted),
      border: fieldBorder(line),
      enabledBorder: fieldBorder(line),
      focusedBorder: fieldBorder(accent, width: 1.6),
      errorBorder: fieldBorder(const Color(0xFFD34A54), width: 1.2),
      focusedErrorBorder: fieldBorder(const Color(0xFFD34A54), width: 1.5),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: paper.withValues(alpha: 0.75),
        side: const BorderSide(color: line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: paper.withValues(alpha: 0.96),
      height: 78,
      elevation: 0,
      indicatorColor: accent,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: states.contains(WidgetState.selected) ? Colors.white : muted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? Colors.white : muted,
        ),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? Colors.white : accentSoft,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? accent : muted,
        ),
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
        side: WidgetStateProperty.all(const BorderSide(color: line)),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      iconColor: ink,
      textColor: ink,
    ),
    dividerTheme: const DividerThemeData(color: line, thickness: 1, space: 1),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: ink,
      contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    extensions: const <ThemeExtension<dynamic>>[
      AppPalette(
        shell: shell,
        paper: paper,
        ink: ink,
        muted: muted,
        line: line,
        accent: accent,
        accentSoft: accentSoft,
        success: success,
      ),
    ],
  );
}

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.shell,
    required this.paper,
    required this.ink,
    required this.muted,
    required this.line,
    required this.accent,
    required this.accentSoft,
    required this.success,
  });

  final Color shell;
  final Color paper;
  final Color ink;
  final Color muted;
  final Color line;
  final Color accent;
  final Color accentSoft;
  final Color success;

  @override
  AppPalette copyWith({
    Color? shell,
    Color? paper,
    Color? ink,
    Color? muted,
    Color? line,
    Color? accent,
    Color? accentSoft,
    Color? success,
  }) {
    return AppPalette(
      shell: shell ?? this.shell,
      paper: paper ?? this.paper,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      line: line ?? this.line,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      success: success ?? this.success,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      shell: Color.lerp(shell, other.shell, t) ?? shell,
      paper: Color.lerp(paper, other.paper, t) ?? paper,
      ink: Color.lerp(ink, other.ink, t) ?? ink,
      muted: Color.lerp(muted, other.muted, t) ?? muted,
      line: Color.lerp(line, other.line, t) ?? line,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t) ?? accentSoft,
      success: Color.lerp(success, other.success, t) ?? success,
    );
  }
}

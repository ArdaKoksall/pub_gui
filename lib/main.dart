import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pub gui',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: ThemeMode.dark,
      home: const HomeScreen(),
    );
  }
}

ThemeData _theme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF0175C2),
          brightness: brightness,
          surface: dark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F3F3),
        ).copyWith(
          outline: dark ? const Color(0xFF3C3C3C) : const Color(0xFFD4D4D4),
        ),
    fontFamily: 'Segoe UI',
    scaffoldBackgroundColor: dark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFF3F3F3),
    dividerColor: dark ? const Color(0xFF3C3C3C) : const Color(0xFFD4D4D4),
    dividerTheme: DividerThemeData(
      color: dark ? const Color(0xFF3C3C3C) : const Color(0xFFD4D4D4),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 13),
      bodySmall: TextStyle(fontSize: 12),
      labelSmall: TextStyle(fontSize: 11),
      labelMedium: TextStyle(fontSize: 12),
    ),
  );
}

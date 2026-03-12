import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/timer_provider.dart';
import 'screens/timer_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'services/notification_service.dart';

/// The entry point of the app
/// Everything starts from here
void main() async {
  // WidgetsFlutterBinding.ensureInitialized() is REQUIRED before any
  // async calls in main() - it sets up the Flutter framework
  WidgetsFlutterBinding.ensureInitialized();

  // Lock screen orientation to portrait (vertical only)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize the notification service
  await NotificationService.initialize();

  // Run the app
  runApp(const PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Create ONE TimerProvider and make it available to all screens
      create: (_) => TimerProvider(),
      child: MaterialApp(
        title: 'Pomodoro Timer',
        debugShowCheckedModeBanner: false,

        // ── App Theme ──
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE53935), // tomato red
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'sans-serif',
          appBarTheme: const AppBarTheme(
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
        ),

        // ── Routes (screen navigation) ──
        // '/' is always the first screen shown
        initialRoute: '/',
        routes: {
          '/': (context) => const TimerScreen(),
          '/history': (context) => const HistoryScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}

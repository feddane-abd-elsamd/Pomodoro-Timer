import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../widgets/circular_timer.dart';
import '../widgets/timer_controls.dart';
import '../widgets/stats_row.dart';

/// The main screen — shows the big timer, controls, and daily stats
class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Consumer<TimerProvider>(
          // Consumer rebuilds the UI every time notifyListeners() is called
          builder: (context, timer, child) {
            return CustomScrollView(
              slivers: [
                // ── App Bar ──
                SliverAppBar(
                  backgroundColor: const Color(0xFFF8F9FA),
                  floating: true,
                  title: const Text(
                    '🍅 Pomodoro',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.history_rounded,
                          color: Color(0xFF1A1A2E)),
                      onPressed: () => Navigator.pushNamed(context, '/history'),
                      tooltip: 'Session History',
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_rounded,
                          color: Color(0xFF1A1A2E)),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/settings'),
                      tooltip: 'Settings',
                    ),
                  ],
                ),

                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // ── Session dots (shows progress in a set of 4) ──
                        _SessionDots(timer: timer),

                        // ── Big circular timer ──
                        CircularTimerWidget(timer: timer),

                        // ── Control buttons: Reset, Play/Pause, Skip ──
                        TimerControls(timer: timer),

                        // ── Stats card ──
                        StatsRow(timer: timer),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Shows dots indicating progress within a set (e.g., ●●○○ = 2 of 4 done)
class _SessionDots extends StatelessWidget {
  final TimerProvider timer;

  const _SessionDots({required this.timer});

  @override
  Widget build(BuildContext context) {
    final total = timer.sessionsBeforeLongBreak;
    // How many sessions completed in the CURRENT set (0-3)
    final completedInSet =
        timer.sessionsCompletedToday % timer.sessionsBeforeLongBreak;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(total, (index) {
            final isDone = index < completedInSet;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isDone ? 12 : 10,
              height: isDone ? 12 : 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? const Color(0xFFE53935) : Colors.grey[300],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          '$completedInSet / $total sessions until long break',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

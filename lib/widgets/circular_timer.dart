import 'package:flutter/material.dart';
import '../../providers/timer_provider.dart';

/// A beautiful circular progress indicator showing the timer
/// The ring fills up as time passes
class CircularTimerWidget extends StatelessWidget {
  final TimerProvider timer;

  const CircularTimerWidget({super.key, required this.timer});

  @override
  Widget build(BuildContext context) {
    // Decide colors based on work vs break
    final Color primaryColor = timer.isOnBreak
        ? const Color(0xFF4CAF50) // green for break
        : const Color(0xFFE53935); // red for work

    final Color bgColor = timer.isOnBreak
        ? const Color(0xFF4CAF50).withOpacity(0.1)
        : const Color(0xFFE53935).withOpacity(0.1);

    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Background circle (track) ──
          SizedBox(
            width: 260,
            height: 260,
            child: CircularProgressIndicator(
              value: 1.0, // full circle as background
              strokeWidth: 10,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(bgColor),
            ),
          ),

          // ── Progress arc ──
          SizedBox(
            width: 260,
            height: 260,
            child: CircularProgressIndicator(
              value: timer.progress, // 0.0 to 1.0
              strokeWidth: 10,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              // Makes it start from the top (12 o'clock position)
              strokeCap: StrokeCap.round,
            ),
          ),

          // ── Inner content ──
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Phase label (FOCUS / BREAK)
              Text(
                timer.isOnBreak ? '☕ BREAK' : '📚 FOCUS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: primaryColor,
                ),
              ),

              const SizedBox(height: 8),

              // Big timer display "25:00"
              Text(
                timer.formattedTime,
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -2,
                  color: Color(0xFF1A1A2E),
                ),
              ),

              const SizedBox(height: 4),

              // Status text
              Text(
                _getStatusText(timer.status),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusText(TimerStatus status) {
    switch (status) {
      case TimerStatus.idle:
        return 'Ready to focus';
      case TimerStatus.running:
        return 'Stay focused...';
      case TimerStatus.paused:
        return 'Paused';
      case TimerStatus.onBreak:
        return 'Relax and recharge';
      case TimerStatus.breakPaused:
        return 'Break paused';
    }
  }
}

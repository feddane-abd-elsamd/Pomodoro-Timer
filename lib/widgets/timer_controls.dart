import 'package:flutter/material.dart';
import '../../../../../providers/timer_provider.dart';

/// The row of control buttons: Start/Pause, Reset, Skip
class TimerControls extends StatelessWidget {
  final TimerProvider timer;

  const TimerControls({super.key, required this.timer});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ── RESET button ──
        _CircleButton(
          icon: Icons.refresh_rounded,
          color: Colors.grey[600]!,
          size: 52,
          onTap: timer.reset,
          tooltip: 'Reset',
        ),

        const SizedBox(width: 20),

        // ── MAIN button: Start / Pause ──
        _CircleButton(
          icon: _getMainIcon(timer.status),
          color: timer.isOnBreak
              ? const Color(0xFF4CAF50)
              : const Color(0xFFE53935),
          size: 72,
          onTap: _getMainAction(timer),
          tooltip: _getMainLabel(timer.status),
          isMain: true,
        ),

        const SizedBox(width: 20),

        // ── SKIP button ──
        _CircleButton(
          icon: Icons.skip_next_rounded,
          color: Colors.grey[600]!,
          size: 52,
          onTap: timer.skip,
          tooltip: 'Skip',
        ),
      ],
    );
  }

  // Returns the right icon for the main button based on current status
  IconData _getMainIcon(TimerStatus status) {
    switch (status) {
      case TimerStatus.running:
      case TimerStatus.onBreak:
        return Icons.pause_rounded;
      default:
        return Icons.play_arrow_rounded;
    }
  }

  // Returns the right label for the main button
  String _getMainLabel(TimerStatus status) {
    switch (status) {
      case TimerStatus.running:
      case TimerStatus.onBreak:
        return 'Pause';
      case TimerStatus.paused:
      case TimerStatus.breakPaused:
        return 'Resume';
      default:
        return 'Start';
    }
  }

  // Returns the right function to call when main button is tapped
  VoidCallback _getMainAction(TimerProvider timer) {
    switch (timer.status) {
      case TimerStatus.running:
      case TimerStatus.onBreak:
        return timer.pause;
      default:
        return timer.start;
    }
  }
}

/// A single circular button
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;
  final String tooltip;
  final bool isMain;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
    required this.tooltip,
    this.isMain = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMain ? color : color.withOpacity(0.1),
            boxShadow: isMain
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    )
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: isMain ? 36 : 24,
            color: isMain ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

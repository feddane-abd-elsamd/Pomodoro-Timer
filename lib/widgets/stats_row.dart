import 'package:flutter/material.dart';
import '../../providers/timer_provider.dart';

/// Shows today's stats: sessions done, minutes focused, weekly sessions
class StatsRow extends StatelessWidget {
  final TimerProvider timer;

  const StatsRow({super.key, required this.timer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            value: timer.sessionsCompletedToday.toString(),
            label: 'Today',
            icon: Icons.local_fire_department_rounded,
            color: const Color(0xFFE53935),
          ),
          _Divider(),
          _StatItem(
            value: '${timer.todayFocusedMinutes}m',
            label: 'Focused',
            icon: Icons.timer_rounded,
            color: const Color(0xFF1565C0),
          ),
          _Divider(),
          _StatItem(
            value: timer.weekSessions.toString(),
            label: 'This Week',
            icon: Icons.calendar_today_rounded,
            color: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey[200],
    );
  }
}

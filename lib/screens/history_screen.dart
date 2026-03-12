import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/timer_provider.dart';
import '../../../../models/session.dart';

/// Shows all past Pomodoro sessions with stats
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timer, child) {
        final sessions = timer.sessionHistory;
        // Only count work sessions for stats
        final workSessions = sessions.where((s) => s.type == 'work').toList();
        final totalMinutes =
            workSessions.fold(0, (sum, s) => sum + s.durationMinutes);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF8F9FA),
            elevation: 0,
            title: const Text(
              'Session History',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
            actions: [
              // Clear all button
              if (sessions.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded),
                  tooltip: 'Clear all history',
                  onPressed: () => _confirmClearAll(context, timer),
                ),
            ],
          ),
          body: sessions.isEmpty
              ? _EmptyState()
              : Column(
                  children: [
                    // ── Summary banner ──
                    _SummaryBanner(
                      totalSessions: workSessions.length,
                      totalMinutes: totalMinutes,
                    ),

                    // ── Session list ──
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          return _SessionCard(
                            session: sessions[index],
                            onDelete: () =>
                                timer.deleteSession(sessions[index].id!),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _confirmClearAll(BuildContext context, TimerProvider timer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text(
            'This will permanently delete all your session records.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              timer.clearAllHistory();
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

/// Shown when there are no sessions yet
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🍅', style: TextStyle(fontSize: 64)),
          SizedBox(height: 16),
          Text(
            'No sessions yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start your first Pomodoro to see\nyour history here',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// Banner at the top showing total stats
class _SummaryBanner extends StatelessWidget {
  final int totalSessions;
  final int totalMinutes;

  const _SummaryBanner({
    required this.totalSessions,
    required this.totalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    final timeStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFEF9A9A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BannerStat(
            value: totalSessions.toString(),
            label: 'Total Sessions',
          ),
          Container(width: 1, height: 40, color: Colors.white38),
          _BannerStat(
            value: timeStr,
            label: 'Total Focused',
          ),
        ],
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  final String value;
  final String label;

  const _BannerStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}

/// A single session card in the list
class _SessionCard extends StatelessWidget {
  final Session session;
  final VoidCallback onDelete;

  const _SessionCard({required this.session, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isWork = session.type == 'work';
    final color = isWork ? const Color(0xFFE53935) : const Color(0xFF4CAF50);
    final icon = isWork ? '📚' : '☕';

    return Dismissible(
      // Swipe to delete
      key: Key(session.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.red),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 20)),
              ),
            ),

            const SizedBox(width: 12),

            // Session info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isWork ? 'Work Session' : 'Break',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session.formattedDate,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Duration badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${session.durationMinutes}m',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),

            // Completed checkmark
            const SizedBox(width: 8),
            Icon(
              session.completed
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: session.completed ? Colors.green : Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

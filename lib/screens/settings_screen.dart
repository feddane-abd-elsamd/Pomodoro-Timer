import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local copies of ALL settings
  late int _workDuration;
  late int _shortBreak;
  late int _longBreak;
  late int _sessionsBeforeLong;

  // NEW: Local copies of sound settings
  late bool _soundEnabled;
  late bool _workCompleteSound;
  late bool _breakCompleteSound;
  late bool _tickingSound;

  @override
  void initState() {
    super.initState();
    final timer = context.read<TimerProvider>();
    // Load timer settings
    _workDuration = timer.workDurationMinutes;
    _shortBreak = timer.shortBreakMinutes;
    _longBreak = timer.longBreakMinutes;
    _sessionsBeforeLong = timer.sessionsBeforeLongBreak;
    // Load sound settings
    _soundEnabled = timer.soundEnabled;
    _workCompleteSound = timer.workCompleteSound;
    _breakCompleteSound = timer.breakCompleteSound;
    _tickingSound = timer.tickingSound;
  }

  void _saveAndClose() {
    final timer = context.read<TimerProvider>();
    // Apply timer settings
    timer.workDurationMinutes = _workDuration;
    timer.shortBreakMinutes = _shortBreak;
    timer.longBreakMinutes = _longBreak;
    timer.sessionsBeforeLongBreak = _sessionsBeforeLong;
    // Apply sound settings
    timer.soundEnabled = _soundEnabled;
    timer.workCompleteSound = _workCompleteSound;
    timer.breakCompleteSound = _breakCompleteSound;
    timer.tickingSound = _tickingSound;
    timer.saveSettings();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
        actions: [
          TextButton(
            onPressed: _saveAndClose,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── SECTION 1: Timer Durations ──
          _SectionHeader(title: '⏱ Timer Durations'),
          _SettingsCard(
            children: [
              _DurationTile(
                label: 'Work Duration',
                subtitle: 'How long each focus session lasts',
                value: _workDuration,
                min: 5,
                max: 60,
                onChanged: (v) => setState(() => _workDuration = v),
              ),
              const Divider(height: 1),
              _DurationTile(
                label: 'Short Break',
                subtitle: 'Break after each work session',
                value: _shortBreak,
                min: 1,
                max: 30,
                onChanged: (v) => setState(() => _shortBreak = v),
              ),
              const Divider(height: 1),
              _DurationTile(
                label: 'Long Break',
                subtitle: 'Extended break after several sessions',
                value: _longBreak,
                min: 5,
                max: 60,
                onChanged: (v) => setState(() => _longBreak = v),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── SECTION 2: Pomodoro Set ──
          _SectionHeader(title: '🔄 Pomodoro Set'),
          _SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sessions before Long Break',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'After $_sessionsBeforeLong sessions you get a long break',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [2, 3, 4, 5, 6].map((n) {
                        final isSelected = _sessionsBeforeLong == n;
                        return GestureDetector(
                          onTap: () => setState(() => _sessionsBeforeLong = n),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? const Color(0xFFE53935)
                                  : Colors.grey[200],
                            ),
                            child: Center(
                              child: Text(
                                n.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF1A1A2E),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── SECTION 3: Sound Settings (NEW) ──
          _SectionHeader(title: '🔊 Sound'),
          _SettingsCard(
            children: [
              // Master sound toggle
              _SoundToggleTile(
                icon: Icons.volume_up_rounded,
                iconColor: const Color(0xFFE53935),
                label: 'Sound Enabled',
                subtitle: 'Master switch for all sounds',
                value: _soundEnabled,
                onChanged: (v) => setState(() {
                  _soundEnabled = v;
                  // When master is OFF, turn all sub-toggles off too
                  if (!v) {
                    _workCompleteSound = false;
                    _breakCompleteSound = false;
                    _tickingSound = false;
                  }
                }),
              ),

              const Divider(height: 1, indent: 56),

              // Work complete sound toggle
              _SoundToggleTile(
                icon: Icons.notifications_rounded,
                iconColor: const Color(0xFF1565C0),
                label: 'Work Complete Sound',
                subtitle: 'Play sound when focus session ends',
                value: _workCompleteSound,
                // Disabled if master sound is off
                onChanged: _soundEnabled
                    ? (v) => setState(() => _workCompleteSound = v)
                    : null,
              ),

              const Divider(height: 1, indent: 56),

              // Break complete sound toggle
              _SoundToggleTile(
                icon: Icons.coffee_rounded,
                iconColor: const Color(0xFF4CAF50),
                label: 'Break Complete Sound',
                subtitle: 'Play sound when break ends',
                value: _breakCompleteSound,
                onChanged: _soundEnabled
                    ? (v) => setState(() => _breakCompleteSound = v)
                    : null,
              ),

              const Divider(height: 1, indent: 56),

              // Ticking sound toggle
              _SoundToggleTile(
                icon: Icons.timer_rounded,
                iconColor: const Color(0xFFFF9800),
                label: 'Ticking Sound',
                subtitle: 'Play a tick sound every second',
                value: _tickingSound,
                onChanged: _soundEnabled
                    ? (v) => setState(() => _tickingSound = v)
                    : null,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── SECTION 4: Data ──
          _SectionHeader(title: '⚠️ Data'),
          _SettingsCard(
            children: [
              Consumer<TimerProvider>(
                builder: (context, timer, _) => ListTile(
                  leading: const Icon(Icons.delete_forever_rounded,
                      color: Colors.red),
                  title: const Text(
                    'Clear All History',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: Text(
                    '${timer.sessionHistory.length} sessions stored',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () => _confirmClear(context, timer),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Center(
            child: Text(
              '🍅 Pomodoro Timer v1.0',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Built with Flutter',
              style: TextStyle(color: Colors.grey[400], fontSize: 11),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, TimerProvider timer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All History?'),
        content:
            const Text('All your session records will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              timer.clearAllHistory();
              Navigator.pop(ctx);
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Helper Widgets
// ─────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(children: children),
    );
  }
}

/// A toggle row for sound settings
class _SoundToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged; // null = disabled

  const _SoundToggleTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // If onChanged is null, the tile is disabled (greyed out)
    final isDisabled = onChanged == null;

    return Opacity(
      opacity: isDisabled ? 0.4 : 1.0, // grey out when disabled
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF1A1A2E),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFE53935),
        ),
      ),
    );
  }
}

/// A duration stepper tile (unchanged from before)
class _DurationTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _DurationTile({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _StepButton(
                icon: Icons.remove,
                onTap: value > min ? () => onChanged(value - 1) : null,
              ),
              SizedBox(
                width: 52,
                child: Text(
                  '$value min',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
              _StepButton(
                icon: Icons.add,
                onTap: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap != null
              ? const Color(0xFFE53935).withOpacity(0.1)
              : Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? const Color(0xFFE53935) : Colors.grey[400],
        ),
      ),
    );
  }
}

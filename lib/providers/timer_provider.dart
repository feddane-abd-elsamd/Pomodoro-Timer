import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session.dart';
import '../services/db_helper.dart';
import '../services/notification_service.dart';

/// The possible states of our timer
enum TimerStatus {
  idle, // App just opened, timer not started
  running, // Timer is actively counting down
  paused, // Timer is paused mid-session
  onBreak, // Work session done, now on break
  breakPaused, // Break timer paused
}

/// TimerProvider holds ALL the timer logic and state
/// It extends ChangeNotifier so the UI can listen to changes
class TimerProvider extends ChangeNotifier {
  // ─────────────────────────────────────────────
  // SETTINGS (saved to phone storage)
  // ─────────────────────────────────────────────
  int workDurationMinutes = 25;
  int shortBreakMinutes = 5;
  int longBreakMinutes = 15;
  int sessionsBeforeLongBreak = 4;

  // NEW: Sound settings
  bool soundEnabled = true; // master sound on/off
  bool workCompleteSound = true; // play sound when work session ends
  bool breakCompleteSound = true; // play sound when break ends
  bool tickingSound = false; // play ticking sound every second

  // ─────────────────────────────────────────────
  // CURRENT TIMER STATE
  // ─────────────────────────────────────────────
  int _secondsLeft = 25 * 60;
  TimerStatus status = TimerStatus.idle;
  int sessionsCompletedToday = 0;
  int totalSessionsCompleted = 0;

  Timer? _timer;
  DateTime? _sessionStartTime;

  // ─────────────────────────────────────────────
  // HISTORY
  // ─────────────────────────────────────────────
  List<Session> sessionHistory = [];

  // ─────────────────────────────────────────────
  // CONSTRUCTOR
  // ─────────────────────────────────────────────
  TimerProvider() {
    _init();
  }

  Future<void> _init() async {
    await loadSettings();
    await loadHistory();
  }

  // ─────────────────────────────────────────────
  // GETTERS
  // ─────────────────────────────────────────────

  int get secondsLeft => _secondsLeft;

  String get formattedTime {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  int get totalSeconds {
    if (status == TimerStatus.onBreak || status == TimerStatus.breakPaused) {
      if (sessionsCompletedToday % sessionsBeforeLongBreak == 0 &&
          sessionsCompletedToday > 0) {
        return longBreakMinutes * 60;
      }
      return shortBreakMinutes * 60;
    }
    return workDurationMinutes * 60;
  }

  double get progress {
    if (totalSeconds == 0) return 0.0;
    return 1.0 - (_secondsLeft / totalSeconds);
  }

  bool get isWorking =>
      status == TimerStatus.running || status == TimerStatus.paused;

  bool get isOnBreak =>
      status == TimerStatus.onBreak || status == TimerStatus.breakPaused;

  // ─────────────────────────────────────────────
  // TIMER CONTROLS
  // ─────────────────────────────────────────────

  void start() {
    if (status == TimerStatus.idle) {
      _secondsLeft = workDurationMinutes * 60;
      _sessionStartTime = DateTime.now();
    }

    if (status == TimerStatus.onBreak) {
      _sessionStartTime = DateTime.now();
    }

    if (status == TimerStatus.onBreak || status == TimerStatus.breakPaused) {
      status = TimerStatus.onBreak;
    } else {
      status = TimerStatus.running;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) {
        _secondsLeft--;
        // Play ticking sound every second if enabled
        if (soundEnabled && tickingSound) {
          NotificationService.playTickSound();
        }
        notifyListeners();
      } else {
        _onTimerFinished();
      }
    });

    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    if (status == TimerStatus.onBreak) {
      status = TimerStatus.breakPaused;
    } else {
      status = TimerStatus.paused;
    }
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    status = TimerStatus.idle;
    _secondsLeft = workDurationMinutes * 60;
    _sessionStartTime = null;
    notifyListeners();
  }

  void skip() {
    _timer?.cancel();
    if (isOnBreak) {
      status = TimerStatus.idle;
      _secondsLeft = workDurationMinutes * 60;
    } else {
      _startBreak();
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // INTERNAL LOGIC
  // ─────────────────────────────────────────────

  Future<void> _onTimerFinished() async {
    _timer?.cancel();

    if (isOnBreak) {
      // Play sound if enabled
      if (soundEnabled && breakCompleteSound) {
        await NotificationService.showBreakComplete(withSound: soundEnabled);
      } else {
        await NotificationService.showBreakComplete(withSound: false);
      }
      await _saveSession(type: 'break', completed: true);
      status = TimerStatus.idle;
      _secondsLeft = workDurationMinutes * 60;
    } else {
      sessionsCompletedToday++;
      totalSessionsCompleted++;
      // Play sound if enabled
      if (soundEnabled && workCompleteSound) {
        await NotificationService.showWorkComplete(withSound: soundEnabled);
      } else {
        await NotificationService.showWorkComplete(withSound: false);
      }
      await _saveSession(type: 'work', completed: true);
      _startBreak();
    }

    notifyListeners();
  }

  void _startBreak() {
    final isLongBreak = sessionsCompletedToday % sessionsBeforeLongBreak == 0 &&
        sessionsCompletedToday > 0;

    _secondsLeft = isLongBreak ? longBreakMinutes * 60 : shortBreakMinutes * 60;

    status = TimerStatus.onBreak;
    _sessionStartTime = null;
  }

  Future<void> _saveSession({
    required String type,
    required bool completed,
  }) async {
    final duration = type == 'work' ? workDurationMinutes : shortBreakMinutes;
    final session = Session(
      date: _sessionStartTime ?? DateTime.now(),
      durationMinutes: duration,
      completed: completed,
      type: type,
    );
    await DBHelper.insertSession(session);
    await loadHistory();
  }

  // ─────────────────────────────────────────────
  // SETTINGS: Save & Load
  // ─────────────────────────────────────────────

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('workDurationMinutes', workDurationMinutes);
    await prefs.setInt('shortBreakMinutes', shortBreakMinutes);
    await prefs.setInt('longBreakMinutes', longBreakMinutes);
    await prefs.setInt('sessionsBeforeLongBreak', sessionsBeforeLongBreak);
    // Save sound settings
    await prefs.setBool('soundEnabled', soundEnabled);
    await prefs.setBool('workCompleteSound', workCompleteSound);
    await prefs.setBool('breakCompleteSound', breakCompleteSound);
    await prefs.setBool('tickingSound', tickingSound);

    if (status == TimerStatus.idle) {
      _secondsLeft = workDurationMinutes * 60;
    }
    notifyListeners();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    workDurationMinutes = prefs.getInt('workDurationMinutes') ?? 25;
    shortBreakMinutes = prefs.getInt('shortBreakMinutes') ?? 5;
    longBreakMinutes = prefs.getInt('longBreakMinutes') ?? 15;
    sessionsBeforeLongBreak = prefs.getInt('sessionsBeforeLongBreak') ?? 4;
    // Load sound settings
    soundEnabled = prefs.getBool('soundEnabled') ?? true;
    workCompleteSound = prefs.getBool('workCompleteSound') ?? true;
    breakCompleteSound = prefs.getBool('breakCompleteSound') ?? true;
    tickingSound = prefs.getBool('tickingSound') ?? false;
    _secondsLeft = workDurationMinutes * 60;
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // HISTORY
  // ─────────────────────────────────────────────

  Future<void> loadHistory() async {
    sessionHistory = await DBHelper.getAllSessions();
    sessionsCompletedToday = await DBHelper.getTodayCompletedCount();
    notifyListeners();
  }

  Future<void> deleteSession(int id) async {
    await DBHelper.deleteSession(id);
    await loadHistory();
  }

  Future<void> clearAllHistory() async {
    await DBHelper.clearAllSessions();
    sessionsCompletedToday = 0;
    totalSessionsCompleted = 0;
    sessionHistory = [];
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // STATS
  // ─────────────────────────────────────────────

  int get todayFocusedMinutes {
    return sessionHistory
        .where((s) =>
            s.type == 'work' && s.completed && s.date.day == DateTime.now().day)
        .fold(0, (sum, s) => sum + s.durationMinutes);
  }

  int get weekSessions {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return sessionHistory
        .where(
            (s) => s.type == 'work' && s.completed && s.date.isAfter(weekAgo))
        .length;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

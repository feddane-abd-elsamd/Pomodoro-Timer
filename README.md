# 🍅 Pomodoro Study Timer

A complete Flutter app to run Pomodoro study sessions, track focused time, and stay productive.

---

## 📱 Features

- ✅ 25-minute focus timer with visual circular countdown
- ✅ Short break (5 min) and long break (15 min) support
- ✅ Session history saved to local database (SQLite)
- ✅ Local notifications when timer ends
- ✅ Configurable durations in Settings
- ✅ Daily stats (sessions done, minutes focused, weekly count)
- ✅ Swipe to delete sessions in history
- ✅ Clear all history option
- ✅ Works fully offline (no internet needed)

---

## 🗂️ Project Structure

```
lib/
├── main.dart                         ← App entry point, routing
│
├── models/
│   └── session.dart                  ← Session data class
│
├── providers/
│   └── timer_provider.dart           ← ALL timer logic + state (THE BRAIN)
│
├── screens/
│   ├── timer_screen.dart             ← Main screen with big timer
│   ├── history_screen.dart           ← Past sessions list
│   └── settings_screen.dart          ← Adjust durations
│
├── services/
│   ├── db_helper.dart                ← SQLite database operations
│   └── notification_service.dart     ← Local notifications
│
└── widgets/
    ├── circular_timer.dart           ← The circular progress ring
    ├── timer_controls.dart           ← Play/Pause/Reset/Skip buttons
    └── stats_row.dart                ← Today's stats card
```

---

## 🚀 How to Run

### Step 1: Install Flutter
Download Flutter from https://flutter.dev/docs/get-started/install

### Step 2: Get dependencies
```bash
cd pomodoro_timer
flutter pub get
```

### Step 3: Run on your device or emulator
```bash
# List available devices
flutter devices

# Run on a specific device
flutter run -d <device_id>

# Or simply run (picks first available)
flutter run
```

---

## 📦 Dependencies Explained

| Package | What it does |
|---------|-------------|
| `provider` | State management — shares data between screens |
| `shared_preferences` | Saves settings to phone storage (like a key-value store) |
| `sqflite` | SQLite database — stores session history |
| `path` | Helps find the right folder to store the database |
| `flutter_local_notifications` | Shows notifications when timer ends |
| `timezone` | Required by notifications for correct time scheduling |
| `intl` | Date/time formatting helpers |

---

## 🧠 How the Code Works

### The Provider Pattern
This app uses the **Provider** pattern for state management.

```
TimerProvider (brain)
    ↓ notifyListeners()
TimerScreen → CircularTimerWidget → shows updated time
```

When the timer ticks, `TimerProvider` updates `_secondsLeft` and calls `notifyListeners()`. Every widget wrapped in `Consumer<TimerProvider>` automatically rebuilds.

### The Timer
```dart
// Dart's Timer.periodic fires every 1 second
_timer = Timer.periodic(Duration(seconds: 1), (_) {
  secondsLeft--;
  notifyListeners(); // UI rebuilds
});
```

### Database Flow
```
User finishes session
    → TimerProvider._saveSession()
    → DBHelper.insertSession()
    → Written to pomodoro.db on device
    → DBHelper.getAllSessions() called
    → sessionHistory list updated
    → UI shows new session in history
```

---

## 🎮 How to Use the App

1. **Open the app** — you'll see the timer at 25:00
2. **Tap the red play button** — timer starts counting down
3. **Tap pause** (same button) to pause mid-session
4. **When timer hits 0** — notification appears, break starts automatically
5. **Tap play again** to start your break timer
6. **After 4 sessions** — you get a longer 15-minute break
7. **Check your history** by tapping the history icon in the top right
8. **Change durations** by tapping the settings icon

---

## 🔔 Notifications Setup (Android)

The `AndroidManifest.xml` already has the required permissions:
- `POST_NOTIFICATIONS` — show notifications
- `SCHEDULE_EXACT_ALARM` — precise timer notifications
- `WAKE_LOCK` — keep timer running with screen off

On Android 13+, the app will ask for notification permission on first launch.

---

## 🐛 Common Issues

**Timer stops when app is in background**
→ This is normal behavior. For true background timers, a foreground service is needed (advanced topic). For now, the notification will still show when you bring the app back.

**Notifications not showing on Android**
→ Make sure you granted notification permission when prompted. Check Settings > Apps > Pomodoro > Notifications.

**Database error on first run**
→ Delete the app and reinstall. The database is created fresh on first install.

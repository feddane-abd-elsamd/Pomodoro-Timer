import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../../models/session.dart';

/// DBHelper manages all database operations (save/load/delete sessions)
/// Uses Singleton pattern: only ONE instance exists at a time
class DBHelper {
  static Database? _db; // private, only accessible inside this class

  /// Get the database (creates it if it doesn't exist yet)
  static Future<Database> get database async {
    if (_db != null) return _db!; // already open, just return it
    _db = await _initDB();
    return _db!;
  }

  /// Create and open the database file on the device
  static Future<Database> _initDB() async {
    // getDatabasesPath() = the correct storage folder on Android/iOS
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pomodoro.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // This runs ONLY the first time the app is installed
        await db.execute('''
          CREATE TABLE sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            durationMinutes INTEGER NOT NULL,
            completed INTEGER NOT NULL,
            type TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Save a new session to the database
  /// Returns the new session's ID
  static Future<int> insertSession(Session session) async {
    final db = await database;
    return await db.insert('sessions', session.toMap());
  }

  /// Get ALL sessions, newest first
  static Future<List<Session>> getAllSessions() async {
    final db = await database;
    final maps = await db.query(
      'sessions',
      orderBy: 'date DESC', // newest first
    );
    // Convert each Map to a Session object
    return maps.map((map) => Session.fromMap(map)).toList();
  }

  /// Get only sessions from today
  static Future<List<Session>> getTodaySessions() async {
    final db = await database;
    final today = DateTime.now();
    // Match dates that start with today's date string (YYYY-MM-DD)
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final maps = await db.query(
      'sessions',
      where: 'date LIKE ?',
      whereArgs: ['$todayStr%'],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Session.fromMap(map)).toList();
  }

  /// Delete a single session by its ID
  static Future<void> deleteSession(int id) async {
    final db = await database;
    await db.delete('sessions', where: 'id = ?', whereArgs: [id]);
  }

  /// Delete ALL sessions (used in settings to clear history)
  static Future<void> clearAllSessions() async {
    final db = await database;
    await db.delete('sessions');
  }

  /// Get count of completed work sessions today
  static Future<int> getTodayCompletedCount() async {
    final sessions = await getTodaySessions();
    return sessions.where((s) => s.completed && s.type == 'work').length;
  }
}

/// Represents one completed Pomodoro study session
class Session {
  final int? id;
  final DateTime date;
  final int durationMinutes;
  final bool completed; // true = finished fully, false = stopped early
  final String type; // 'work' or 'break'

  Session({
    this.id,
    required this.date,
    required this.durationMinutes,
    required this.completed,
    required this.type,
  });

  /// Convert Session object → Map (for saving to database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'durationMinutes': durationMinutes,
      'completed': completed ? 1 : 0, // SQLite has no bool, use 0/1
      'type': type,
    };
  }

  /// Convert Map → Session object (for reading from database)
  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      date: DateTime.parse(map['date']),
      durationMinutes: map['durationMinutes'],
      completed: map['completed'] == 1,
      type: map['type'],
    );
  }

  /// Helper: returns a friendly date string like "Jan 15, 10:30 AM"
  String get formattedDate {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final hour = date.hour > 12 ? date.hour - 12 : date.hour == 0 ? 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '${months[date.month - 1]} ${date.day}, $hour:$minute $ampm';
  }
}

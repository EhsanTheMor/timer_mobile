/// Session record for display and DB mapping.
/// For DB rows, id is set when loaded from database.
class SessionRecord {
  SessionRecord({
    this.id,
    required this.startTime,
    required this.stopTime,
    required this.durationSeconds,
  });

  final int? id;
  final DateTime startTime;
  final DateTime stopTime;
  final int durationSeconds;

  Map<String, Object?> toMap({int? activityId}) {
    return <String, Object?>{
      if (id != null) 'id': id,
      'activity_id': activityId,
      'start_time': startTime.toIso8601String(),
      'stop_time': stopTime.toIso8601String(),
      'duration_seconds': durationSeconds,
    };
  }

  static SessionRecord fromMap(Map<String, Object?> map) {
    return SessionRecord(
      id: map['id'] as int?,
      startTime: DateTime.parse(map['start_time'] as String),
      stopTime: DateTime.parse(map['stop_time'] as String),
      durationSeconds: map['duration_seconds'] as int,
    );
  }
}

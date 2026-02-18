import 'session_record.dart';

class Activity {
  Activity({
    required this.id,
    required this.name,
    required this.records,
  });

  final int id;
  final String name;
  final List<SessionRecord> records;

  int get totalSeconds =>
      records.fold<int>(0, (sum, r) => sum + r.durationSeconds);
}

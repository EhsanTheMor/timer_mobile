import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/activity.dart';
import '../models/session_record.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'timer.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE session_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activity_id INTEGER NOT NULL,
        start_time TEXT NOT NULL,
        stop_time TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL,
        FOREIGN KEY (activity_id) REFERENCES activities (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<List<Activity>> getActivitiesWithRecords() async {
    final db = await database;
    final activityRows = await db.query('activities', orderBy: 'id ASC');
    final activities = <Activity>[];

    for (final row in activityRows) {
      final id = row['id'] as int;
      final name = row['name'] as String;
      final recordRows = await db.query(
        'session_records',
        where: 'activity_id = ?',
        whereArgs: [id],
        orderBy: 'start_time DESC',
      );
      final records = recordRows.map((r) => SessionRecord.fromMap(r)).toList();
      activities.add(Activity(id: id, name: name, records: records));
    }

    return activities;
  }

  Future<Activity> insertActivity(String name) async {
    final db = await database;
    final id = await db.insert('activities', {'name': name});
    return Activity(id: id, name: name, records: []);
  }

  Future<void> deleteActivity(int id) async {
    final db = await database;
    await db.delete('session_records', where: 'activity_id = ?', whereArgs: [id]);
    await db.delete('activities', where: 'id = ?', whereArgs: [id]);
  }

  Future<SessionRecord> insertSessionRecord({
    required int activityId,
    required SessionRecord record,
  }) async {
    final db = await database;
    final map = record.toMap(activityId: activityId)..remove('id');
    final id = await db.insert('session_records', map);
    return SessionRecord(
      id: id,
      startTime: record.startTime,
      stopTime: record.stopTime,
      durationSeconds: record.durationSeconds,
    );
  }
}

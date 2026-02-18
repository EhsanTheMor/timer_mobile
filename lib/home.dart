import 'package:flutter/material.dart';

import 'activity_list.dart';
import 'activity_timer_page.dart';
import 'add_activity.dart';
import 'data/database_helper.dart';
import 'models/activity.dart';
import 'models/session_record.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Activity> _activities = [];
  bool _isLoading = true;
  final _db = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      final activities = await _db.getActivitiesWithRecords();
      if (!mounted) return;
      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _activities = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load activities.')),
      );
    }
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    final parts = <String>[];
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0) parts.add('${minutes}m');
    parts.add('${secs}s');
    return parts.join(' ');
  }

  Future<void> _openAddActivity() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => const AddActivity()),
    );
    if (result == null || result.trim().isEmpty || !mounted) return;
    try {
      final activity = await _db.insertActivity(result.trim());
      if (!mounted) return;
      setState(() {
        _activities = [activity, ..._activities];
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create activity.')),
      );
    }
  }

  Future<void> _persistSession(int activityId, SessionRecord record) async {
    await _db.insertSessionRecord(activityId: activityId, record: record);
  }

  Future<void> _openActivity(int index, String name) async {
    final activity = _activities[index];
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => ActivityTimerPage(
          activityName: name,
          records: activity.records,
          onSessionRecorded: (record) => _persistSession(activity.id, record),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _confirmDelete(int index, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete activity'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _db.deleteActivity(_activities[index].id);
      if (!mounted) return;
      setState(() {
        _activities.removeAt(index);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete activity.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage your time',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ActivityList(
              activities: _activities
                  .map((a) => (a.name, _formatDuration(a.totalSeconds)))
                  .toList(),
              onDelete: _confirmDelete,
              onActivityTap: _openActivity,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddActivity,
        child: const Icon(Icons.add),
      ),
    );
  }
}

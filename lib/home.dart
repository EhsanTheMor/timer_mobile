import 'package:flutter/material.dart';

import 'activity_list.dart';
import 'activity_timer_page.dart';
import 'add_activity.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<(String name, List<SessionRecord> records)> _activities = [
    ('Work', []),
    ('Exercise', []),
    ('Reading', []),
    ('Study', []),
  ];

  int _totalSecondsFor(List<SessionRecord> records) =>
      records.fold<int>(0, (sum, r) => sum + r.durationSeconds);

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
    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        _activities.add((result.trim(), []));
      });
    }
  }

  Future<void> _openActivity(int index, String name) async {
    final records = _activities[index].$2;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => ActivityTimerPage(
          activityName: name,
          records: records,
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
    if (confirmed == true && mounted) {
      setState(() {
        _activities.removeAt(index);
      });
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
      body: ActivityList(
        activities: _activities
            .map((a) => (a.$1, _formatDuration(_totalSecondsFor(a.$2))))
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

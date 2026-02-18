import 'package:flutter/material.dart';
import 'activity_item.dart';

class ActivityList extends StatelessWidget {
  const ActivityList({
    super.key,
    required this.activities,
    required this.onDelete,
    this.onActivityTap,
  });

  final List<(String name, String timeSpent)> activities;
  final void Function(int index, String name) onDelete;
  final void Function(int index, String name)? onActivityTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final (name, timeSpent) = activities[index];
        return ActivityItem(
          name: name,
          timeSpent: timeSpent,
          onDelete: () => onDelete(index, name),
          onTap: onActivityTap != null ? () => onActivityTap!(index, name) : null,
        );
      },
    );
  }
}

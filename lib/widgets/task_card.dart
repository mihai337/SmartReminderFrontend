import 'package:flutter/material.dart';
import 'package:smartreminders/models/task.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onComplete;
  final Function(Duration) onSnooze;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onSnooze,
    required this.onDelete,
  });

  IconData _getTriggerIcon() {
    switch (task.triggerType) {
      case TriggerType.location:
        return Icons.location_on;
      case TriggerType.time:
        return Icons.access_time;
      case TriggerType.wifi:
        return Icons.wifi;
    }
  }

  String _getTriggerText() {
    switch (task.triggerType) {
      case TriggerType.location:
        final locationName = task.triggerConfig['locationName'] ?? 'Location';
        final stateChange = task.stateChange?.name ?? 'enter';
        return '$stateChange $locationName';
      case TriggerType.time:
        final timestamp = DateTime.tryParse(task.triggerConfig['dateTime'] ?? '');
        if (timestamp != null) {
          return DateFormat('MMM d, y h:mm a').format(timestamp);
        }
        return 'Time-based';
      case TriggerType.wifi:
        final ssid = task.triggerConfig['ssid'] ?? 'WiFi';
        final stateChange = task.stateChange?.name ?? 'connect';
        return '$stateChange to $ssid';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getCategoryIcon(), size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.primary),
                  onSelected: (value) {
                    if (value == 'complete') {
                      onComplete();
                    } else if (value == 'snooze_1h') {
                      onSnooze(const Duration(hours: 1));
                    } else if (value == 'snooze_1d') {
                      onSnooze(const Duration(days: 1));
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'complete', child: Text('Complete')),
                    const PopupMenuItem(value: 'snooze_1h', child: Text('Snooze 1 hour')),
                    const PopupMenuItem(value: 'snooze_1d', child: Text('Snooze 1 day')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                task.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(_getTriggerIcon(), size: 16, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  _getTriggerText(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            if (task.isSnoozed && task.snoozeUntil != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.snooze, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Snoozed until ${DateFormat('MMM d, h:mm a').format(task.snoozeUntil!)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (task.category) {
      case TaskCategory.home:
        return Icons.home;
      case TaskCategory.work:
        return Icons.work;
      case TaskCategory.school:
        return Icons.school;
      case TaskCategory.all:
        return Icons.all_inclusive;
    }
  }
}

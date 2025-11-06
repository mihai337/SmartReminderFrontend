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
    if (task.trigger is TimeTrigger) {
      return Icons.access_time;
    } else if (task.trigger is LocationTrigger) {
      return Icons.location_on;
    } else {
      return Icons.wifi;
    }
  }

  String _getTriggerText() {
    if (task.trigger is TimeTrigger) {
      final timeTrigger = task.trigger as TimeTrigger;
      return DateFormat('MMM d, h:mm a').format(timeTrigger.time);
    } else if (task.trigger is LocationTrigger) {
      final locationTrigger = task.trigger as LocationTrigger;
      final action = locationTrigger.onEnter ? 'enter' : 'exit';
      return 'Location (on $action)';
    } else {
      return 'WiFi trigger'; // Handle WiFi if you have it
    }
  }

  Color _getCategoryColor() {
    switch (task.profile) {
      case TaskProfile.HOME:
        return const Color(0xFF5B7FFF);
      case TaskProfile.WORK:
        return const Color(0xFF8B7FFF);
      case TaskProfile.SCHOOL:
        return const Color(0xFFFF7F7F);
    }
  }

  String _getCategoryLabel() {
    return task.profile.name[0].toUpperCase() +
        task.profile.name.substring(1).toLowerCase();
  }

  IconData _getCategoryIcon() {
    switch (task.profile) {
      case TaskProfile.HOME:
        return Icons.home;
      case TaskProfile.WORK:
        return Icons.work;
      case TaskProfile.SCHOOL:
        return Icons.school;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFCCCCCC), width: 2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getCategoryColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(_getCategoryIcon(), size: 14, color: _getCategoryColor()),
                          const SizedBox(width: 4),
                          Text(
                            _getCategoryLabel(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getCategoryColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(Icons.delete_outline, color: Color(0xFF999999), size: 20),
                    ),
                  ],
                ),
                if (task.description != null && task.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    task.description!,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(_getTriggerIcon(), size: 16, color: const Color(0xFF5B7FFF)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _getTriggerText(),
                        style: const TextStyle(fontSize: 14, color: Color(0xFF5B7FFF)),
                      ),
                    ),
                    TextButton(
                      onPressed: onComplete,
                      child: const Text(
                        'Test',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF5B7FFF)),
                      ),
                    ),
                  ],
                ),
                if (true) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.snooze, size: 16, color: Color(0xFF999999)),
                      const SizedBox(width: 6),
                      Text(
                        'Snoozed until ${DateFormat('MMM d, h:mm a').format(DateTime.now())}',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

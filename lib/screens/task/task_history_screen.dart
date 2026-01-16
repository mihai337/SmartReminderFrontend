import 'package:flutter/material.dart';
import 'package:smartreminders/services/auth_service.dart';
import 'package:smartreminders/services/task_service.dart';
import 'package:smartreminders/models/task_history.dart';
import 'package:intl/intl.dart';

class TaskHistoryScreen extends StatelessWidget {
  const TaskHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final taskService = TaskService();
    final userId = authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task History'),
      ),
      body: StreamBuilder<List<TaskHistory>>(
        stream: taskService.getTaskHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final history = snapshot.data![index];
              return _HistoryCard(history: history);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No history yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Your task actions will appear here',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final TaskHistory history;

  const _HistoryCard({required this.history});

  IconData _getActionIcon() {
    switch (history.action) {
      case HistoryAction.completed:
        return Icons.check_circle;
      case HistoryAction.snoozed:
        return Icons.snooze;
      case HistoryAction.triggered:
        return Icons.notifications_active;
    }
  }

  Color _getActionColor(BuildContext context) {
    switch (history.action) {
      case HistoryAction.completed:
        return Colors.green;
      case HistoryAction.snoozed:
        return Colors.orange;
      case HistoryAction.triggered:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _getActionLabel() {
    switch (history.action) {
      case HistoryAction.completed:
        return 'Completed';
      case HistoryAction.snoozed:
        return 'Snoozed';
      case HistoryAction.triggered:
        return 'Triggered';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(_getActionIcon(), color: _getActionColor(context), size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    history.taskTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getActionLabel(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _getActionColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, y • h:mm a').format(history.timestamp),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

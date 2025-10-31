import 'package:flutter/material.dart';
import 'package:smartreminders/services/auth_service.dart';
import 'package:smartreminders/services/task_service.dart';
import 'package:smartreminders/models/task.dart';
import 'package:smartreminders/screens/task/add_task_screen.dart';
import 'package:smartreminders/screens/task/task_history_screen.dart';
import 'package:smartreminders/screens/location/add_location_screen.dart';
import 'package:smartreminders/screens/auth/login_screen.dart';
import 'package:smartreminders/widgets/task_card.dart';
import 'package:smartreminders/widgets/category_chip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final TaskService _taskService = TaskService();
  TaskCategory _selectedCategory = TaskCategory.all;

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.primary),
            onSelected: (value) async {
              if (value == 'add_location') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddLocationScreen()),
                );
              } else if (value == 'history') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TaskHistoryScreen()),
                );
              } else if (value == 'logout') {
                await _authService.signOut();
                if (!mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_location',
                child: Row(
                  children: [
                    Icon(Icons.add_location),
                    SizedBox(width: 12),
                    Text('Add Location'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    Icon(Icons.history),
                    SizedBox(width: 12),
                    Text('Task History'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 12),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _taskService.getActiveTasks(
                userId,
                category: _selectedCategory == TaskCategory.all ? null : _selectedCategory,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final task = snapshot.data![index];
                    return TaskCard(
                      task: task,
                      onComplete: () => _taskService.completeTask(task),
                      onSnooze: (duration) {
                        final snoozeUntil = DateTime.now().add(duration);
                        _taskService.snoozeTask(task, snoozeUntil);
                      },
                      onDelete: () => _taskService.deleteTask(task.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: TaskCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CategoryChip(
                category: category,
                isSelected: _selectedCategory == category,
                onSelected: () => setState(() => _selectedCategory = category),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first reminder',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

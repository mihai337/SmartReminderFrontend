import 'package:flutter/material.dart';
import 'package:smartreminders/services/auth_service.dart';
import 'package:smartreminders/services/task_service.dart';
import 'package:smartreminders/models/task.dart';
import 'package:smartreminders/screens/task/add_task_screen.dart';
import 'package:smartreminders/screens/task/task_history_screen.dart';
import 'package:smartreminders/screens/location/add_location_screen.dart';
import 'package:smartreminders/screens/auth/login_screen.dart';
import 'package:smartreminders/widgets/task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final TaskService _taskService = TaskService();
  TaskProfile? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryTabs(),
            Expanded(
              child: StreamBuilder<List<Task>>(
                stream: _taskService.getActiveTasks(
                  userId,
                  profile:  _selectedCategory,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final task = snapshot.data![index];
                      return TaskCard(
                        task: task,
                        onComplete: () => _taskService.completeTask(task),
                        onSnooze: (duration) {
                          final snoozeUntil = DateTime.now().add(duration);
                         // _taskService.snoozeTask(task, snoozeUntil);
                        },
                        onDelete: () => _taskService.deleteTask(task.id!),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                    maxWidth: 600,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.85,
                        child: AddTaskScreen(isModal: true),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildHeader() {
    final userId = _authService.currentUser?.uid ?? '';
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF5B7FFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.notifications, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Reminders',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                StreamBuilder<List<Task>>(
                  stream: _taskService.getActiveTasks(userId),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.length ?? 0;
                    return Text(
                      '$count active',
                      style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
                    );
                  },
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Color(0xFF1A1A1A)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildCategoryTab(Icons.notifications, null),
          const SizedBox(width: 12),
          _buildCategoryTab(Icons.home, TaskProfile.HOME),
          const SizedBox(width: 12),
          _buildCategoryTab(Icons.work, TaskProfile.WORK),
          const SizedBox(width: 12),
          _buildCategoryTab(Icons.school, TaskProfile.SCHOOL),
          const SizedBox(width: 12),
          _buildCategoryTab(Icons.history, null, isHistory: true),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(IconData icon, TaskProfile? profile, {bool isHistory = false}) {
    final isSelected = !isHistory &&
        ((profile == null && _selectedCategory == null) ||
            (profile != null && profile == _selectedCategory));
    
    return GestureDetector(
      onTap: () {
        if (isHistory) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TaskHistoryScreen()),
          );
        } else {
          setState(() => _selectedCategory = profile);
        }
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B7FFF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF5B7FFF) : const Color(0xFFE8E8E8),
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : const Color(0xFF666666),
          size: 24,
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
            color: const Color(0xFF5B7FFF).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No tasks yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to create your first reminder',
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }
}

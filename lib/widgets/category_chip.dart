import 'package:flutter/material.dart';
import 'package:smartreminders/models/task.dart';

class CategoryChip extends StatelessWidget {
  final TaskProfile ? profile;
  final bool isSelected;
  final VoidCallback onSelected;

  const CategoryChip({
    super.key,
    required this.profile,
    required this.isSelected,
    required this.onSelected,
  });

  IconData _getCategoryIcon() {
    return switch (profile) {
      null => Icons.all_inclusive,
      TaskProfile.HOME => Icons.home,
      TaskProfile.WORK => Icons.work,
      TaskProfile.SCHOOL => Icons.school,
    };
  }

  String _getCategoryLabel() {
    if (profile == null) return 'All'; // Handle null for "All"
    final name = profile!.name;
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(),
            size: 16,
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            _getCategoryLabel(),
            style: TextStyle(
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:smartreminders/models/task.dart';

class CategoryChip extends StatelessWidget {
  final TaskCategory category;
  final bool isSelected;
  final VoidCallback onSelected;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onSelected,
  });

  IconData _getCategoryIcon() {
    switch (category) {
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

  String _getCategoryLabel() {
    return category.name[0].toUpperCase() + category.name.substring(1);
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

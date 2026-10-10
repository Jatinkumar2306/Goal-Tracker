
import 'package:flutter/material.dart';
import '../goal_provider.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: ListTile(
        leading: Checkbox(
          value: goal.doneToday,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          goal.title,
          style: TextStyle(
            decoration: goal.doneToday
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Delete goal',
          onPressed: onDelete,
        ),
      ),
    );
  }
}

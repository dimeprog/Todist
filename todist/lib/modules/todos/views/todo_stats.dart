import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todist/modules/todos/vms/todo_notifier.dart';





class TodoStatsBar extends ConsumerWidget {
  const TodoStatsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(todoStatsProvider);

    if (stats.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatChip(
            label: 'Total',
            count: stats['total'] ?? 0,
            color: Colors.blue,
          ),
          _StatChip(
            label: 'Active',
            count: stats['active'] ?? 0,
            color: Colors.orange,
          ),
          _StatChip(
            label: 'Done',
            count: stats['completed'] ?? 0,
            color: Colors.green,
          ),
          if ((stats['pending'] ?? 0) > 0)
            _StatChip(
              label: 'Syncing',
              count: stats['pending'] ?? 0,
              color: Colors.amber,
              icon: Icons.sync,
            ),
          if ((stats['failed'] ?? 0) > 0)
            _StatChip(
              label: 'Failed',
              count: stats['failed'] ?? 0,
              color: Colors.red,
              icon: Icons.error_outline,
            ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData? icon;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          Icon(icon, size: 14, color: color)
        else
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todist/models/enums/sync_status.dart';
import 'package:todist/models/todo_model.dart';


import '../vms/todo_notifier.dart';

class TodoItemTile extends ConsumerWidget {
  final TodoModel todo;

  const TodoItemTile({required this.todo, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) {
            ref.read(todoListProvider.notifier).toggleTodo(todo);
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: todo.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: _buildSubtitle(),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSyncStatusIcon(context),
            const SizedBox(width: 8),
            _buildMoreMenu(context, ref),
          ],
        ),
      ),
    );
  }

  Widget? _buildSubtitle() {
    if (todo.syncStatus == SyncStatus.failed) {
      return const Text(
        'Sync failed',
        style: TextStyle(color: Colors.red, fontSize: 12),
      );
    }
    return null;
  }

  Widget _buildSyncStatusIcon(BuildContext context) {
    return switch (todo.syncStatus) {
       SyncStatus.synced =>
         Icon(Icons.check_circle, size: 18, color: Colors.green[600]),
       SyncStatus.pending =>
         Icon(Icons.sync, size: 18, color: Colors.orange[700]),
       SyncStatus.failed =>
         Icon(Icons.error, size: 18, color: Colors.red[700]),
    };

  }

  Widget _buildMoreMenu(BuildContext context, WidgetRef ref) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
          onTap: () => _showEditDialog(context, ref),
        ),
        if (todo.syncStatus == SyncStatus.failed)
          PopupMenuItem(
            child: const Row(
              children: [
                Icon(Icons.refresh, size: 18),
                SizedBox(width: 8),
                Text('Retry sync'),
              ],
            ),
            onTap: () {
              ref.read(todoListProvider.notifier).retryFailed(todo);
            },
          ),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
          onTap: () {
            ref.read(todoListProvider.notifier).deleteTodo(todo);
          },
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    // Delay to avoid popup menu transition conflict
    Future.delayed(const Duration(milliseconds: 100), () {
      final controller = TextEditingController(text: todo.title);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Todo'),
          content: TextField(
             textCapitalization: TextCapitalization.sentences,
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter new title',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                ref
                    .read(todoListProvider.notifier)
                    .updateTitle(todo, value.trim());
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  ref
                      .read(todoListProvider.notifier)
                      .updateTitle(todo, controller.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    });
  }
}






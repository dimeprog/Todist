


import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todist/core/extensions.dart';
import 'package:todist/modules/todos/views/todo_sheet.dart';
import 'package:todist/modules/todos/vms/todo_notifier.dart';

import '../../../models/todo_model.dart';


class TodoDetails extends HookConsumerWidget {
  final TodoModel todo;

  const TodoDetails({super.key, required this.todo});

  static Future<void> show(
    BuildContext context, {
    required TodoModel todo,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TodoDetails(todo: todo),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Header with status and actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: todo.isCompleted == true
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            todo.isCompleted == true
                                ? Icons.check_circle
                                : Icons.pending,
                            size: 16,
                            color: todo.isCompleted == true
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            todo.isCompleted == true ? 'Completed' : 'Pending',
                            style: TextStyle(
                              color: todo.isCompleted == true
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        todo.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // Description
                      if (todo.description != null &&
                          todo.description!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                todo.description ?? "",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Details Section
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildDetailTile(
                              context,
                              icon: Icons.access_time,
                              label: 'Created',
                              // value: _formatDate(todo.createdAt),
                              value: todo.createdAt.timeAgoFormat,
                            ),
                            Divider(
                              height: 1,
                              color: Theme.of(context).dividerColor,
                            ),
                            _buildDetailTile(
                              context,
                              icon: Icons.update,
                              label: 'Last Updated',
                              // value: _formatDate(todo.updatedAt),
                              value: todo.updatedAt.timeAgoFormat,
                            ),
                            if (todo.dueDate != null) ...[
                              Divider(
                                height: 1,
                                color: Theme.of(context).dividerColor,
                              ),
                              _buildDetailTile(
                                context,
                                icon: Icons.event,
                                label: 'Due Date',
                                // value: _formatDate(todo.dueDate),
                                value: todo.dueDate?.timeAgoFormat ?? "",
                                color: _isOverdue(todo.dueDate)
                                    ? Colors.red
                                    : null,
                              ),
                            ],
                            if (todo.reminderAt != null) ...[
                              Divider(
                                height: 1,
                                color: Theme.of(context).dividerColor,
                              ),
                              _buildDetailTile(
                                context,
                                icon: Icons.notifications,
                                label: 'Reminder',
                                // value: _formatDate(todo.reminderAt),
                                value: todo.reminderAt?.timeAgoFormat ?? "",
                                color:
                                    _isOverdue(todo.reminderAt) &&
                                        !(todo.reminderSent ?? false)
                                    ? Colors.red
                                    : null,
                              ),
                              if (todo.reminderSent == true) ...[
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 48,
                                    bottom: 12,
                                  ),
                                  child: Text(
                                    '✓ Reminder sent',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green[600],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      
                      Row(
                        children: [
                          // Edit Button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final result = await TodoSheet.show(
                                  context,
                                  todo: todo,
                                );

                                if (result != null) {
                                  // ref
                                  //     .read(todoListProvider.notifier)
                                  //     .updateTodo(result);
                                  ref
                                      .read(todoActionsProvider.notifier)
                                      .updateTodo(result);
                                }
                              },
                              icon: Icon(
                                Icons.edit_rounded,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              label: Text(
                                'Edit',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                elevation: 0,
                                backgroundColor:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withOpacity(.04)
                                    : Colors.white,
                                side: BorderSide(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white.withOpacity(.08)
                                      : Colors.grey.shade300,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Delete Button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                // ref
                                //     .read(todoListProvider.notifier)
                                //     .deleteTodo(todo);
                                ref
                                    .read(todoActionsProvider.notifier)
                                    .deleteTodo(todo);
                              },
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                              ),
                              label: const Text(
                                'Delete',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF3A1E22)
                                    : Colors.red.shade500,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Complete/Uncomplete Button (if not completed)
                      if (todo.isCompleted != true) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                      
                              // ref
                              //     .read(todoListProvider.notifier)
                              //     .toggleTodo(todo);
                              ref
                                  .read(todoActionsProvider.notifier)
                                  .toggleTodo(todo);
                            },
                            icon: const Icon(
                              Icons.check_circle_rounded,
                              size: 20,
                            ),
                            label: const Text(
                              'Mark as Complete',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFF163323)
                                  : Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Option to reopen if completed
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // _markAsIncomplete(context, ref);
                              // ref
                              //     .read(todoListProvider.notifier)
                              //     .toggleTodo(todo);
                              ref
                                  .read(todoActionsProvider.notifier)
                                  .toggleTodo(todo);
                            },
                            icon: Icon(
                              Icons.refresh_rounded,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            label: Text(
                              'Mark as Incomplete',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              elevation: 0,
                              backgroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withOpacity(.04)
                                  : Colors.white,
                              side: BorderSide(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withOpacity(.08)
                                    : Colors.grey.shade300,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color ?? Theme.of(context).iconTheme.color,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        color ?? Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  

  bool _isOverdue(dynamic dateTime) {
    if (dateTime == null) return false;

    try {
      DateTime parsedDate;
      if (dateTime is DateTime) {
        parsedDate = dateTime;
      } else {
        parsedDate = DateTime.parse(dateTime);
      }
      return parsedDate.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }
}

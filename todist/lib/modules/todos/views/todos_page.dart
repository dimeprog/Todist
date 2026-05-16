import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todist/modules/auth/view_model/auth_state.dart';
import 'package:todist/modules/auth/views/login.dart';
import 'package:todist/modules/todos/views/todo_item.dart';
import 'package:todist/modules/todos/vms/todo_notifier.dart';

import '../../auth/view_model/auth_notifier.dart';
import '../vms/todolist_provider.dart';
import 'todo_sheet.dart';
import 'todo_stats.dart';

class TodosPage extends HookConsumerWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final controller = useTextEditingController();
    final todosAsync = ref.watch(filteredTodosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        elevation: 0,
        actions: [
          Consumer(
            builder: (_, WidgetRef ref, __) {
              ref.listen(authNotifierProvider, (p, n) {
                if (n is LogoutSuccess) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                    (_) => false,
                  );
                }
              });
              return IconButton(
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).logout();
                },
                icon: Icon(Icons.exit_to_app_sharp),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(children: [const TodoStatsBar(), _FilterChips()]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        child: const Icon(Icons.add),
        onPressed: () async {
          final todo = await TodoSheet.show(context);
          if (todo != null) {
            // ref.read(todoListProvider.notifier).createTodo(todo);
            ref.read(todoActionsProvider.notifier).createTodo(todo);
          }
        },
      ),
      body: Column(
        children: [
          // ── Add todo input ─────────────────────────────────
          // Consumer(
          //   builder: (_, WidgetRef ref, __) {
          //     final filter = ref.watch(todoFilterProvider);
          //     return filter == TodoFilter.active
          //         ? Padding(
          //             padding: const EdgeInsets.all(16.0),
          //             child: Row(
          //               children: [
          //                 Expanded(
          //                   child: TextField(
          //                     textCapitalization: TextCapitalization.sentences,
          //                     controller: controller,
          //                     decoration: const InputDecoration(
          //                       hintText: 'What needs to be done?',
          //                       border: OutlineInputBorder(),
          //                       contentPadding: EdgeInsets.symmetric(
          //                         horizontal: 16,
          //                         vertical: 12,
          //                       ),
          //                     ),
          //                     onSubmitted: (value) {
          //                       // if (value.trim().isNotEmpty) {
          //                       //   ref
          //                       //       .read(todoListProvider.notifier)
          //                       //       .createTodo(value.trim());
          //                       //   controller.clear();
          //                       // }
          //                     },
          //                   ),
          //                 ),
          //                 const SizedBox(width: 8),
          //                 IconButton.filled(
          //                   onPressed: () {
          //                     // if (controller.text.trim().isNotEmpty) {
          //                     //   ref
          //                     //       .read(todoListProvider.notifier)
          //                     //       .createTodo(controller.text.trim());
          //                     //   controller.clear();
          //                     // }
          //                   },
          //                   icon: const Icon(Icons.add),
          //                 ),
          //               ],
          //             ),
          //           )
          //         : SizedBox.shrink();
          //   },
          // ),

          // ── Todo list ──────────────────────────────────────
          SizedBox(height: 10),
          Expanded(
            child: todosAsync.when(
              data: (todos) {
                if (todos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No todos yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    return TodoItemTile(todo: todos[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(todoFilterProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildChip(
            context,
            ref,
            label: 'Active',
            filter: TodoFilter.active,
            isSelected: filter == TodoFilter.active,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            ref,
            label: 'Completed',
            filter: TodoFilter.completed,
            isSelected: filter == TodoFilter.completed,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required TodoFilter filter,
    required bool isSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        ref.read(todoFilterProvider.notifier).state = filter;
      },
    );
  }
}

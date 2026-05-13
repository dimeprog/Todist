import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todist/modules/todos/views/todo_item.dart';

import '../../auth/view_model/auth_notifier.dart';
import '../vms/todo_notifier.dart';
import 'todo_stats.dart';

// class TodosPage extends HookConsumerWidget {
//   const TodosPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final controller = useTextEditingController();
//     final todosAsync = ref.watch(filteredTodosProvider);

//     return Scaffold(
//       appBar: AppBar(
//         scrolledUnderElevation: 0,
//         backgroundColor: Colors.black,
//         surfaceTintColor: Colors.black,
//         shadowColor: Colors.black,
//         title: const Text('Tasks'),
//         elevation: 0,
//         actions: [
//           IconButton(
//             onPressed: () {
//               ref.read(authNotifierProvider.notifier).logout();
//             },
//             icon: Icon(Icons.exit_to_app_sharp),
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(100),
//           child: Column(
//             children: [
//               const TodoStatsBar(),
//               _FilterChips(),
//             ],
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           // ── Add todo input ─────────────────────────────────
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextFormField(
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
//                     onFieldSubmitted: (value) {
//                       if (value.trim().isNotEmpty) {
//                         ref
//                             .read(todoListProvider.notifier)
//                             .createTodo(value.trim());
//                         controller.clear();
//                       }
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton.filled(
//                   onPressed: () {
//                     if (controller.text.trim().isNotEmpty) {
//                       ref
//                           .read(todoListProvider.notifier)
//                           .createTodo(controller.text.trim());
//                       controller.clear();
//                     }
//                   },
//                   icon: const Icon(Icons.add),
//                 ),
//               ],
//             ),
//           ),

//           // ── Todo list ──────────────────────────────────────
//           Expanded(
//             child: todosAsync.when(
//               data: (todos) {
//                 if (todos.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.check_circle_outline,
//                           size: 64,
//                           color: Colors.grey[400],
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No todos yet',
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 return ListView.builder(
//                   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   itemCount: todos.length,
//                   itemBuilder: (context, index) {
//                     return TodoItemTile(todo: todos[index]);
//                   },
//                 );
//               },
//               loading: () => const Center(child: CircularProgressIndicator()),
//               error: (error, stack) => Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(
//                       Icons.error_outline,
//                       size: 48,
//                       color: Colors.red,
//                     ),
//                     const SizedBox(height: 16),
//                     Text('Error: $error'),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _FilterChips extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final filter = ref.watch(todoFilterProvider);

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         children: [
//           // _buildChip(
//           //   context,
//           //   ref,
//           //   label: 'All',
//           //   filter: TodoFilter.all,
//           //   isSelected: filter == TodoFilter.all,
//           // ),
//           // const SizedBox(width: 8),
//           _buildChip(
//             context,
//             ref,
//             label: 'Active',
//             filter: TodoFilter.active,
//             isSelected: filter == TodoFilter.active,
//           ),
//           const SizedBox(width: 8),
//           _buildChip(
//             context,
//             ref,
//             label: 'Completed',
//             filter: TodoFilter.completed,
//             isSelected: filter == TodoFilter.completed,
//           ),
//         ],
// //       ),
// //     );
// //   }

//   Widget _buildChip(
//     BuildContext context,
//     WidgetRef ref, {
//     required String label,
//     required TodoFilter filter,
//     required bool isSelected,
//   }) {
//     return FilterChip(
//       label: Text(label),
//       selected: isSelected,
//       onSelected: (_) {
//         ref.read(todoFilterProvider.notifier).state = filter;
//       },
//     );
//   }
// }

class TodosPage extends HookConsumerWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final todosAsync = ref.watch(filteredTodosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
            },
            icon: Icon(Icons.exit_to_app_sharp),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(children: [const TodoStatsBar(), _FilterChips()]),
        ),
      ),
      body: Column(
        children: [
          // ── Add todo input ─────────────────────────────────
          Consumer(
            builder: (_, WidgetRef ref, __) {
              final filter = ref.watch(todoFilterProvider);
              return filter == TodoFilter.active
                  ?
               Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                               textCapitalization: TextCapitalization.sentences,
                              controller: controller,
                              decoration: const InputDecoration(
                                hintText: 'What needs to be done?',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onSubmitted: (value) {
                                if (value.trim().isNotEmpty) {
                                  ref
                                      .read(todoListProvider.notifier)
                                      .createTodo(value.trim());
                                  controller.clear();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: () {
                              if (controller.text.trim().isNotEmpty) {
                                ref
                                    .read(todoListProvider.notifier)
                                    .createTodo(controller.text.trim());
                                controller.clear();
                              }
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink();
            },
          ),

          // ── Todo list ──────────────────────────────────────
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

                return ListView.builder(
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

// class TodosPage extends HookConsumerWidget {
//   const TodosPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final controller = useTextEditingController();
//     final scrollController = useScrollController();
//     final currentFilter = ref.watch(todoFilterProvider);

//     // Listen for scroll to load more
//     useEffect(() {
//       void onScroll() {
//         if (scrollController.position.pixels >=
//             scrollController.position.maxScrollExtent - 200) {
//           // Trigger load more when 200px from bottom
//           if (currentFilter == TodoFilter.active) {
//             ref.read(activeTodosProvider.notifier).loadMore();
//           } else {
//             ref.read(completedTodosProvider.notifier).loadMore();
//           }
//         }
//       }

//       scrollController.addListener(onScroll);
//       return () => scrollController.removeListener(onScroll);
//     }, [scrollController, currentFilter]);

//     final todosAsync = ref.watch(currentTodosProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Tasks'),
//         elevation: 0,
//         actions: [
//           IconButton(
//             onPressed: () {
//               ref.read(authNotifierProvider.notifier).logout();
//             },
//             icon: Icon(Icons.exit_to_app_sharp),
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(100),
//           child: Column(children: [const TodoStatsBar(), _FilterChips()]),
//         ),
//       ),
//       body: Column(
//         children: [
//           // ── Add todo input (only show on Active tab) ───────
//           if (currentFilter == TodoFilter.active)
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: controller,
//                       decoration: const InputDecoration(
//                         hintText: 'What needs to be done?',
//                         border: OutlineInputBorder(),
//                         contentPadding: EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 12,
//                         ),
//                       ),
//                       onSubmitted: (value) {
//                         if (value.trim().isNotEmpty) {
//                           ref
//                               .read(todoActionsProvider)
//                               .createTodo(value.trim());
//                           controller.clear();
//                         }
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   IconButton.filled(
//                     onPressed: () {
//                       if (controller.text.trim().isNotEmpty) {
//                         ref
//                             .read(todoActionsProvider)
//                             .createTodo(controller.text.trim());
//                         controller.clear();
//                       }
//                     },
//                     icon: const Icon(Icons.add),
//                   ),
//                 ],
//               ),
//             ),

//           // ── Todo list ──────────────────────────────────────
//           Expanded(
//             child: todosAsync.when(
//               data: (paginatedState) {
//                 if (paginatedState.items.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           currentFilter == TodoFilter.active
//                               ? Icons.check_circle_outline
//                               : Icons.inbox_outlined,
//                           size: 64,
//                           color: Colors.grey[400],
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           currentFilter == TodoFilter.active
//                               ? 'No active todos'
//                               : 'No completed todos',
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 return ListView.builder(
//                   controller: scrollController,
//                   padding: const EdgeInsets.symmetric(horizontal: 8).copyWith(bottom: 30),
//                   itemCount:
//                       paginatedState.items.length +
//                       (paginatedState.hasMore ? 1 : 0),
//                   itemBuilder: (context, index) {
//                     // Loading indicator at the end
//                     if (index == paginatedState.items.length) {
//                       return Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Center(
//                           child: paginatedState.isLoadingMore
//                               ? const CircularProgressIndicator()
//                               : TextButton(
//                                   onPressed: () {
//                                     if (currentFilter == TodoFilter.active) {
//                                       ref
//                                           .read(activeTodosProvider.notifier)
//                                           .loadMore();
//                                     } else {
//                                       ref
//                                           .read(completedTodosProvider.notifier)
//                                           .loadMore();
//                                     }
//                                   },
//                                   child: const Text('Load more'),
//                                 ),
//                         ),
//                       );
//                     }

//                     return TodoItemTile(todo: paginatedState.items[index]);
//                   },
//                 );
//               },
//               loading: () => const Center(child: CircularProgressIndicator()),
//               error: (error, stack) => Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(
//                       Icons.error_outline,
//                       size: 48,
//                       color: Colors.red,
//                     ),
//                     const SizedBox(height: 16),
//                     Text('Error: $error'),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _FilterChips extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final filter = ref.watch(todoFilterProvider);

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         children: [
//           _buildChip(
//             context,
//             ref,
//             label: 'Active',
//             filter: TodoFilter.active,
//             isSelected: filter == TodoFilter.active,
//           ),
//           const SizedBox(width: 8),
//           _buildChip(
//             context,
//             ref,
//             label: 'Completed',
//             filter: TodoFilter.completed,
//             isSelected: filter == TodoFilter.completed,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildChip(
//     BuildContext context,
//     WidgetRef ref, {
//     required String label,
//     required TodoFilter filter,
//     required bool isSelected,
//   }) {
//     return FilterChip(
//       label: Text(label),
//       selected: isSelected,
//       onSelected: (_) {
//         ref.read(todoFilterProvider.notifier).state = filter;
//       },
//     );
//   }
// }

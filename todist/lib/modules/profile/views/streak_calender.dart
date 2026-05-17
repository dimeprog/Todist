// lib/widgets/streak_calendar.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todist/models/streak_model.dart';

import '../vms/streak_history_provider.dart';

class StreakCalendar extends ConsumerWidget {
  final String userId;
  const StreakCalendar({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(streakHistoryProvider(userId));

    return historyAsync.when(
      data: (logs) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last 30 Days',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: 30,
              itemBuilder: (context, index) {
                final date = DateTime.now().subtract(
                  Duration(days: 29 - index),
                );
                final log = logs.firstWhere(
                  (l) =>
                      l.streakDate.year == date.year &&
                      l.streakDate.month == date.month &&
                      l.streakDate.day == date.day,
                  orElse: () => StreakLog(
                    id: '',
                    userId: '',
                    streakDate: date,
                    tasksCompleted: 0,
                    streakValue: 0,
                    createdAt: DateTime.now(),
                  ),
                );

                final hasTask = log.tasksCompleted > 0;
                final isToday =
                    date.year == DateTime.now().year &&
                    date.month == DateTime.now().month &&
                    date.day == DateTime.now().day;

                return Container(
                  decoration: BoxDecoration(
                    color: hasTask
                        ? Colors.green.shade400
                        : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(color: Colors.orange, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: hasTask ? Colors.white : Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Failed to load history')),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todist/core/di.dart';
import 'package:todist/modules/todos/data/todo_providers.dart';
import 'package:todist/todist.dart';

import 'modules/todos/data/sources/local_todo_source.dart';

Future<void> main() async {
  await setUp();
  final localStore = LocalTodoStore();
  await localStore.init();
  runApp(
    ProviderScope(
      overrides: [localStoreProvider.overrideWithValue(localStore)],
      child: const Todist(),
    ),
  );
}

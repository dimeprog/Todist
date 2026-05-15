import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todist/core/di.dart';
import 'package:todist/core/notification_service.dart';
import 'package:todist/firebase_options.dart';
import 'package:todist/modules/todos/data/todo_providers.dart';
import 'package:todist/todist.dart';

import 'modules/todos/data/sources/local_todo_source.dart';

Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setUp();
    await configureFirebase();

  final localStore = LocalTodoStore();
  await localStore.init();
  runApp(
    ProviderScope(
      overrides: [localStoreProvider.overrideWithValue(localStore)],
      child: const Todist(),
    ),
  );
}

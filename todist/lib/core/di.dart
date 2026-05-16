import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todist/keys.dart';

import '../modules/todos/data/sources/local_todo_source.dart';

final getIt = GetIt.instance;

Future<void> setUp() async {
  await Hive.initFlutter();
  await Hive.openBox<dynamic>('app_hive');
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseannonKey,
    debug: kDebugMode,
  );
  getIt.registerSingleton<LocalTodoStore>(LocalTodoStore()..init());

  // // Local Notifications
  // final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // Notification Service
  // getIt.registerSingleton<NotificationsController>(
  //   NotificationsController(
  //     firebaseMessaging: FirebaseMessaging.instance,
  //     flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
  //   ),
  // );
}

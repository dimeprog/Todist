// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:todist/core/app_local_prefs.dart';
import 'package:todist/core/logger.dart';
import 'package:todist/main.dart';
import 'package:todist/modules/todos/data/todo_providers.dart';

import '../modules/todos/views/todo_details.dart';

final NotificationsController notificationController =
    NotificationsController();

final parentKey = GlobalKey<NavigatorState>();

class NotificationsController {
  static final NotificationsController _instance =
      NotificationsController._internal();

  factory NotificationsController() {
    return _instance;
  }

  NotificationsController._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  bool _isInitialized = false;
  final Set<int> _processedNotificationIds = {};
  final Duration _deduplicationWindow = const Duration(seconds: 5);

  Future<void> initialize() async {
    if (_isInitialized) {
      log.d("NotificationsController already initialized");
      return;
    }

    _isInitialized = true;

    // // Initialize plugins
    // flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    // firebaseMessaging = FirebaseMessaging.instance;

    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize notification plugins
    await _initLocalNotifications();
    await requestPermission();
    await getToken();
    setupInteractMessage();

    log.d("NotificationsController initialized successfully");
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );
  }

  void _onNotificationResponse(NotificationResponse response) {
    log.d("Notification response: ${response.payload}");
    // Handle navigation based on payload
    if (response.payload != null) {
      _handleNavigation(response.payload!);
    }
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    // Handle background notification tap
    log.d("Background notification tapped: ${response.payload}");
    
  }

  Future<void> getToken() async {
    try {
      String? token;

      if (Platform.isIOS || Platform.isAndroid) {
        await firebaseMessaging.requestPermission(
          alert: true,
          announcement: true,
          badge: true,
          carPlay: false,
          criticalAlert: true,
          provisional: false,
          sound: true,
        );
        token = await firebaseMessaging.getToken();
      } else {
        token = await firebaseMessaging.getToken();
      }

      if (token != null && token.isNotEmpty) {
        AppLocalPrefs.fcm = token;
        log.d(
          "FCM Token obtained: ${token.substring(0, math.min(20, token.length))}...",
        );
        log.d("FCM Token from storage: ${AppLocalPrefs.fcm}");
      } else {
        log.w("Failed to get FCM token");
      }
    } catch (e, s) {
      log.e(e, stackTrace: s);
    }
  }

  Future<void> messageHandler(RemoteMessage message) async {
    try {
      // Check for duplicate processing
      final messageId =
          message.messageId ??
          message.data['google.message_id'] ??
          DateTime.now().millisecondsSinceEpoch.toString();

      if (_isDuplicateNotification(messageId)) {
        log.d("Duplicate notification detected, skipping: $messageId");
        return;
      }

      log.d("Processing message: ${message.notification?.title}");

      final notification = message.notification;
      if (notification == null) {
        log.d("No notification in message");
        return;
      }

      // For iOS, let FCM handle the notification (don't show local duplicate)
      if (Platform.isIOS) {
        log.d("iOS: Letting FCM handle notification natively");
        return;
      }

      // For Android, only show local notification if it's not already shown by FCM
      // Check if this is a data-only message or if we should show local notification
      // final shouldShowLocal =
      //     message.data['show_local'] == 'true' ||
      //     message.notification?.android == null;

      // if (shouldShowLocal) {
        await _showLocalNotification(
          id: _generateNotificationId(message),
          title: notification.title ?? "Reminder",
          body: notification.body ?? "",
        payload: message.data['local_id'],
        );
      // } else {
      //   log.d("Android: FCM will show notification natively");
      // }
    } on Exception catch (e, s) {
      log.e(e, stackTrace: s);
    }
  }

  bool _isDuplicateNotification(String messageId) {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Clean up old entries (older than deduplication window)
    _processedNotificationIds.removeWhere((id) {
      // This is simplified - you might want to store timestamps
      return false;
    });

    if (_processedNotificationIds.contains(messageId.hashCode)) {
      return true;
    }

    _processedNotificationIds.add(messageId.hashCode);

    // Schedule cleanup after deduplication window
    Future.delayed(_deduplicationWindow, () {
      _processedNotificationIds.remove(messageId.hashCode);
    });

    return false;
  }

  int _generateNotificationId(RemoteMessage message) {
    // Generate consistent ID from message to avoid duplicates
    final idString =
        message.messageId ??
        message.data['todo_id'] ??
        DateTime.now().millisecondsSinceEpoch.toString();
    return idString.hashCode.abs();
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'reminder_channel',
          'Reminder Notifications',
          channelDescription: 'Notifications for todo reminders',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(''),
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );

    log.d("Local notification shown: $id - $title");
  }

  Future<void> requestPermission() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      log.d("Notification permission granted");
    } else {
      log.w("Notification permission denied");
    }
  }

  Future<void> setupInteractMessage() async {
    // Handle when app is terminated and opened via notification
    RemoteMessage? initialMessage = await firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      log.d("App opened from terminated state via notification");
      _handleNavigation(initialMessage.data['local_id']);
    }

    // Handle when app is in background and opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage event) {
      log.d("App opened from background via notification");
      _handleNavigation(event.data['local_id']);
    });

    // Handle messages while app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      log.d("Message received while app in foreground");
      messageHandler(event);
    });
  }

  void _handleNavigation(String? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      log.d("Navigating with payload: $payload");
  
      // Get the current context
      final context = parentKey.currentContext;
      if (context == null) {
        log.d("Context not found");
        return;
      }

      // Method 1: If payload is a todo ID, fetch from provider
      // Find the todo by ID from your todo list
      final todo = container.read(localStoreProvider).getByLocalId(payload);

      if (todo != null) {
        // Open TodoDetails bottom sheet
        TodoDetails.show(context, todoId: todo.localId);
      } else {
        // Handle error - todo not found
        log.e("Todo not found with ID: $payload");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Todo not found')));
      }
    } catch (e) {
      log.e(e);
    }
  }

  /// Schedule a local notification for reminder (NOT for FCM messages)
  Future<void> scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Cancel any existing notification with same ID
    // await cancelNotification(id);

    final tz.TZDateTime scheduledTz = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'reminder_channel',
          'Reminder Notifications',
          channelDescription: 'Notifications for todo reminders',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(''),
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTz,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime,
    );

    log.d("Local reminder scheduled for: $scheduledTime (ID: $id)");
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    log.d("Notification cancelled: $id");
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    log.d("All notifications cancelled");
  }
}

// Helper functions
Future<String> downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

Future<String> getLogoPath() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/xpressuser';
  final ByteData data = await rootBundle.load('assets/logo/logo.png');
  final List<int> bytes = data.buffer.asUint8List();
  final File file = File(filePath);
  await file.writeAsBytes(bytes);
  return filePath;
}

@pragma('vm:entry-point')
void background(NotificationResponse res) {
  // Handle background notification
  print("Background notification response: ${res.payload}");
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize dependencies for background isolate
  WidgetsFlutterBinding.ensureInitialized();

  // Only process if we need to (avoid duplicate)
  if (message.notification != null) {
    print("Background message received: ${message.notification?.title}");
    // Don't show local notification in background as FCM will handle it
  }
}

Future<void> configureFirebase() async {
  // Only initialize once
  await notificationController.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

class PushNotification extends Equatable {
  final String id;
  final String title;
  final String body;

  const PushNotification({
    required this.id,
    required this.title,
    required this.body,
  });

  @override
  List<Object?> get props => [id, title, body];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'title': title, 'body': body};
  }

  factory PushNotification.fromMap(Map<String, dynamic> map) {
    return PushNotification(
      id: map['id'] ?? (math.Random().nextInt(100000) * 1000).toString(),
      title: map['title'] ?? "",
      body: map['body'] ?? "",
    );
  }
}

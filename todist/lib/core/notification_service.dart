// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:todist/core/app_local_prefs.dart';
import 'package:todist/core/di.dart';
import 'package:todist/core/extensions.dart';
import 'package:todist/core/logger.dart';

final NotificationsController notificationController =
    getIt<NotificationsController>();
// NotificationsController();

class NotificationsController {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  FirebaseMessaging firebaseMessaging;

  NotificationsController({
    required this.flutterLocalNotificationsPlugin,
    required this.firebaseMessaging,
  }) {
    initialize();
  }

  Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();
    await requestPermission();
    await getToken();
    setupInteractMessage();
    // Request permissions
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> getToken() async {
    try {
      String? token;
      if (Platform.isIOS) {
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
      } else if (Platform.isAndroid) {
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
      // AppLoc.fcmToken = token ?? '';
      AppLocalPrefs.fcm = token ?? "";
      log.d("fcm_token is $token");
      log.d("fcm_token is from storage ${AppLocalPrefs.fcm}");
    } catch (e, s) {
      log.e(e, stackTrace: s);
    }
  }

  Future<void> messageHandler(RemoteMessage message) async {
    try {
      // // log.d(message.notification?.toMap());
      await setupNotificationPlugin(message);
      // // log.d(message.notification?.toMap());
      final remote = message.notification?.toMap();
      final remoteNotification = PushNotification.fromMap(remote ?? {});

      log.d(remoteNotification.toMap());

      final notificationTitle = remoteNotification.title;
      final notificationBody = remoteNotification.body;

      StyleInformation notificationStyle = BigTextStyleInformation(
        notificationBody,
        contentTitle: '<b>${(notificationTitle)}</b>',
        htmlFormatContentTitle: true,
        summaryText: notificationBody,
        htmlFormatSummaryText: false,
      );
      if (Platform.isIOS) return;
      await showNotification(
        style: notificationStyle,
        id: int.parse(remoteNotification.id),
        title: remoteNotification.title.capitalize,
        body: remoteNotification.body.capitalize,
      );
    } on Exception catch (e, s) {
      log.e(e, stackTrace: s);
    }
  }

  Future<void> showNotification({
    required StyleInformation style,
    required int id,
    required String title,
    required String body,
  }) async {
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          styleInformation: style,
          // icon: '',
        ),
        iOS: const DarwinNotificationDetails(
          presentSound: true,
          sound: 'default',
        ),
      ),
    );
  }

  Future<void> requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> setupNotificationPlugin(RemoteMessage message) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings(
          notificationCategories: [
            DarwinNotificationCategory(
              'demoCategory',
              actions: <DarwinNotificationAction>[
                DarwinNotificationAction.plain(
                  'id_2',
                  'Action 2',
                  options: <DarwinNotificationActionOption>{
                    DarwinNotificationActionOption.foreground,
                  },
                ),
              ],
              options: <DarwinNotificationCategoryOption>{
                DarwinNotificationCategoryOption.allowAnnouncement,
                DarwinNotificationCategoryOption.allowInCarPlay,
              },
            ),
          ],
        );

    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: darwinInitializationSettings,
    );
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // messageHandler(details as RemoteMessage);
        handleMessage(message);
      },
      onDidReceiveBackgroundNotificationResponse: background,
    );
  }

  Future<void> setupInteractMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(event);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      messageHandler(event);
    });
  }

  /// handle notification tap
  Future<void> handleMessage(RemoteMessage message) async {
    log.d('handle press notification');
    // try {
    //   final context = AppRouter.parentNavigatorKey.currentContext!;
    //   final dataBodyMap = message.data;
    //   final push = PushNotification.fromMap(dataBodyMap);
    //   if (push.jsonAlert != null) {
    //     final alert = AlertModel.fromJson(push.jsonAlert!);
    //     alert.gotoPage(context);
    //   }
    // } catch (e, s) {
    //   LoggerService.logError(
    //     error: e,
    //     stackTrace: s,
    //     reason: 'Unable to route notification',
    //   );
    //     }
    //  Schedule a local notification
   
  }

   Future<void> scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Convert to TZDateTime for timezone support
    final tz.TZDateTime scheduledTz = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    // Android details
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'reminder_channel',
          'Reminder Notifications',
          channelDescription: 'Notifications for todo reminders',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          // sound: RawResourceAndroidNotificationSound('notification'),
          enableVibration: true,
          styleInformation: BigTextStyleInformation(''),
            icon: '@mipmap/ic_launcher', // Explicitly set icon
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        );

    // iOS details
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // sound: 'default.wav',
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
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      // androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );

    // print('✅ Local notification scheduled for: $scheduledTime');
  }

  // Simplified version that avoids exact alarms entirely
  

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    print('❌ Notification cancelled: $id');
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print('❌ All notifications cancelled');
  }
}

Future<String> downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

/// get file logo from assets
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
  configureFirebase();
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // final notificationController = NotificationsController();
  await notificationController.messageHandler(message);
  notificationController.handleMessage(message);
}

Future<void> configureFirebase() async {
  // final NotificationsController notificationController =
  //     NotificationsController();
  await notificationController.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

///////////////////  -- PushNotification  model--  //////
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

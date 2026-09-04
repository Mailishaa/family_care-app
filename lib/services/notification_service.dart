import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
      NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz.initializeTimeZones();

    // We will handle browser notifications separately.
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(
        settings: initializationSettings,
      );

      _initialized = true;

      debugPrint(
        'Notifications initialized successfully.',
      );
    } catch (e) {
      debugPrint(
        'Notification initialization failed: $e',
      );
    }
  }

  Future<void> requestPermission() async {
    if (kIsWeb) {
      debugPrint(
        'Web notification permission will be handled separately.',
      );
      return;
    }

    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await android?.requestNotificationsPermission();

      final ios = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint(
        'Notification permission error: $e',
      );
    }
  }

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    // Browser notifications will be handled separately.
    if (kIsWeb) {
      debugPrint(
        'Web local scheduling skipped: $title',
      );
      return;
    }

    try {
      final scheduledDate = tz.TZDateTime.from(
        when,
        tz.local,
      );

      final now = tz.TZDateTime.now(
        tz.local,
      );

      if (scheduledDate.isBefore(now)) {
        debugPrint(
          'Notification date is in the past.',
        );
        return;
      }

      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'family_care_reminders',
          'Family Care reminders',
          channelDescription:
              'Care appointment and medication reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode:
            AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'family-care:$id',
      );

      debugPrint(
        'Notification scheduled: $title',
      );
    } catch (e) {
      debugPrint(
        'Could not schedule notification: $e',
      );
    }
  }

  Future<void> cancel(int id) async {
    if (kIsWeb) {
      return;
    }

    try {
      await _plugin.cancel(
        id: id,
      );

      debugPrint(
        'Notification $id cancelled.',
      );
    } catch (e) {
      debugPrint(
        'Could not cancel notification: $e',
      );
    }
  }

  Future<void> cancelAll() async {
    if (kIsWeb) {
      return;
    }

    try {
      await _plugin.cancelAll();

      debugPrint(
        'All notifications cancelled.',
      );
    } catch (e) {
      debugPrint(
        'Could not cancel notifications: $e',
      );
    }
  }

  Future<List<PendingNotificationRequest>>
      pendingNotifications() async {
    if (kIsWeb) {
      return [];
    }

    try {
      return await _plugin.pendingNotificationRequests();
    } catch (e) {
      debugPrint(
        'Could not get pending notifications: $e',
      );

      return [];
    }
  }
}
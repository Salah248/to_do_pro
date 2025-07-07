import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:to_do_pro/ui/pages/notification_screen.dart';

// in this class NotifyHelper we will handle all the notification related tasks
// such as requesting permissions, initializing notifications, showing notifications,
// scheduling notifications, and handling notification responses.
class NotifyHelper {
  // المتغير الرئيسي للإشعارات
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // طلب أذونات iOS
  Future<void> requestIOSPermissions() async {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // تهيئة الإشعارات
  Future<void> initializeNotification() async {
    // تهيئة التايم زون
    tz.initializeTimeZones();
    // tz.setLocalLocation(tz.getLocation('Africa/Cairo')); // أو حسب منطقتك

    // إعدادات الأندرويد
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('appicon');

    // إعدادات iOS و macOS
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    // إعدادات لينكس
    // ممش محتاجين اعدادات  لينكس او الويندوز حاليا
    // final LinuxInitializationSettings initializationSettingsLinux =
    //     LinuxInitializationSettings(defaultActionName: 'Open notification');
    // إعدادات ويندوز
    // final WindowsInitializationSettings initializationSettingsWindows =
    //     WindowsInitializationSettings(
    //       appName: 'Flutter Local Notifications Example',
    //       appUserModelId: 'com.example.app',
    //       guid: 'd49b0314-ee7a-4626-bf79-97cdb8a991bb',
    //     );

    // التجميع
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
          // linux: initializationSettingsLinux,
          // windows: initializationSettingsWindows,
        );

    // التهيئة النهائية
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  // عرض إشعار فوري
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          channelDescription: 'your_channel_description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: 'item_x',
    );
  }

  // جدولة إشعار بعد وقت معين
  Future<void> scheduleNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Scheduled Title',
      'Scheduled Body',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          channelDescription: 'your_channel_description',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }

  // التعامل مع الرد عند الضغط على الإشعار
  void onDidReceiveNotificationResponse(NotificationResponse response) async {
    final String? payload = response.payload;
    if (payload != null) {
      debugPrint('Notification payload: $payload');
    }
    await Get.to(NotificationScreen(payload: payload!));
  }
}

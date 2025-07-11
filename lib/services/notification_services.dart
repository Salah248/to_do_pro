import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone_2025/flutter_native_timezone_2025.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:to_do_pro/models/task.dart';
import 'package:to_do_pro/ui/pages/notification_screen.dart';

// in this class NotifyHelper we will handle all the notification related tasks
// such as requesting permissions, initializing notifications, showing notifications,
// scheduling notifications, and handling notification responses.
class NotifyHelper {
  // المتغير الرئيسي للإشعارات
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // this selectNotificationSubject is used to send a payload to the UI when a notification is tapped
  final BehaviorSubject<String> selectNotificationSubject =
      BehaviorSubject<String>();

  // ⬅️ متغير احتياطي لتخزين الـ payload (اختياري)
  String selectedNotificationPayload = '';

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
    _configureSelectNotificationSubject();
    await _configureLocalTimeZone();
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

  // ✅ تهيئة التايم زون تلقائيًا حسب الجهاز
  // we use _configureLocalTimeZone to set the local time zone based on the device's location
  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
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
  Future<void> scheduleNotification(int hour, int minutes, Task task) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id!,
      task.title,
      task.note,
      //tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      _nextInstanceOfTime(hour, minutes),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          channelDescription: 'your_channel_description',
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '${task.title}|${task.note}|${task.startTime}|',
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }

  // ✅ حساب أقرب توقيت قادم بناءً على الساعة والدقيقة
  // we use _nextInstanceOfTime to calculate the nearest time to schedule the notification
  // based on the provided hour and minutes parameters and the current time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minutes) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minutes,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // التعامل مع الرد عند الضغط على الإشعار
  void onDidReceiveNotificationResponse(NotificationResponse response) async {
    final String? payload = response.payload;
    if (payload != null) {
      debugPrint('Notification payload: $payload');
    }
    await Get.to(NotificationScreen(payload: payload!));
  }

  // ✅ تهيئة الاستماع للـ payload من الإشعارات
  // we use _configureSelectNotificationSubject to listen to the selectNotificationSubject stream
  // and handle the notification selection
  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      debugPrint('My payload is $payload');
      await Get.to(() => NotificationScreen(payload: payload));
    });
  }
}

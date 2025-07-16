import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone_2025/flutter_native_timezone_2025.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
    // طلب صلاحية الاشعارات
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();
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
    String? payload, // أضف الـ payload parameter
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
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload ?? 'default_payload', // استخدم الـ payload المرسل
    );
  }

  // جدولة إشعار بعد وقت معين
  // first we use ZonedSchedule to schedule the notification based on the provided hour, minutes, remind, repeat, and date
  // then we use _nextInstanceOfTime to calculate the next instance of time based on the provided hour, minutes, remind, repeat, and
  //
  Future<void> scheduleNotification(int hour, int minutes, Task task) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id!,
      task.title,
      task.note,
      // tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      _nextInstanceOfTime(
        hour,
        minutes,
        task.remind!,
        task.repeat!,
        task.date!,
      ),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          channelDescription: 'your_channel_description',
        ),
      ),
      payload: '${task.title}|${task.note}|${task.startTime}|',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ✅ حساب أقرب توقيت قادم بناءً على الساعة والدقيقة
  // we use _nextInstanceOfTime to calculate the nearest time to schedule the notification
  // based on the provided hour and minutes parameters and the current time
  tz.TZDateTime _nextInstanceOfTime(
    int hour,
    int minutes,
    int remind,
    String repeat,
    String date,
  ) {
    final now = tz.TZDateTime.now(tz.local);
    log('Now: $now');
    final formatedDate = DateFormat.yMd().parse(date);
    log('Formated Date: $formatedDate');
    final fd = tz.TZDateTime.from(formatedDate, tz.local);
    log('Local Formatted Date: $fd');
    var scheduledDate = tz.TZDateTime(
      tz.local,
      fd.year,
      fd.month,
      fd.day,
      hour,
      minutes,
    );

    log('first scheduledDate: $scheduledDate');

    scheduledDate = afterRemind(remind, scheduledDate);
    // إذا كان الوقت المحدد قد مضى اليوم
    if (scheduledDate.isBefore(now)) {
      if (repeat == 'Daily') {
        scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          (formatedDate.day) + 1,
          hour,
          minutes,
        );
      }
      if (repeat == 'Weekly') {
        scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          (formatedDate.day) + 7,
          hour,
          minutes,
        );
      }
      if (repeat == 'Monthly') {
        scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          (formatedDate.day) + 1,
          formatedDate.day,
          hour,
          minutes,
        );
      }
      scheduledDate = afterRemind(remind, scheduledDate);
    }

    // إذا كان الوقت المحدد لم يحن بعد اليوم أو لم يتحقق أي شرط أعلاه

    log('final scheduledDate: $scheduledDate');
    return scheduledDate;
  }

  tz.TZDateTime afterRemind(int remind, tz.TZDateTime scheduledDate) {
    switch (remind) {
      case 5:
        scheduledDate = scheduledDate.subtract(const Duration(minutes: 5));
      case 10:
        scheduledDate = scheduledDate.subtract(const Duration(minutes: 10));
      case 15:
        scheduledDate = scheduledDate.subtract(const Duration(minutes: 15));
      case 20:
        scheduledDate = scheduledDate.subtract(const Duration(minutes: 20));
        break;
    }
    return scheduledDate;
  }

  // التعامل مع الرد عند الضغط على الإشعار
  void onDidReceiveNotificationResponse(NotificationResponse response) async {
    final String? payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      await Get.to(() => NotificationScreen(payload: payload));
    }
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

  void cancelScheduledNotification(Task task) async {
    await flutterLocalNotificationsPlugin.cancel(task.id!);
  }

  void cancelAllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

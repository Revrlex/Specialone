import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'dart:io';

class NotificationHelper {
    static final NotificationHelper _instance = NotificationHelper._internal();
    factory NotificationHelper() => _instance;
    NotificationHelper._internal();

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();

    static const channelId = 'specialone_channel';
    static const channelName = 'SpecialOne Task Notifications';
    static const channelDescription = 'Notifications for SpecialOne task reminders';

    Future<void> initialize() async {
        tz.initializeTimeZones();

        // Initialization settings for Android
        const AndroidInitializationSettings initializationSettingsAndroid =
                AndroidInitializationSettings('@mipmap/ic_launcher');

        // Initialization settings for iOS
        final DarwinInitializationSettings initializationSettingsIOS =
                DarwinInitializationSettings(
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true,
            onDidReceiveLocalNotification: onDidReceiveLocalNotification,
        );

        // Combined initialization settings
        final InitializationSettings initializationSettings = InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
        );

        // Initialize plugin
        await flutterLocalNotificationsPlugin.initialize(
            initializationSettings,
            onDidReceiveNotificationResponse: onNotificationTapped,
        );
    }

    // Request notification permissions
    Future<void> requestPermissions() async {
        if (Platform.isIOS) {
            await flutterLocalNotificationsPlugin
                    .resolvePlatformSpecificImplementation<
                            IOSFlutterLocalNotificationsPlugin>()
                    ?.requestPermissions(
                        alert: true,
                        badge: true,
                        sound: true,
                    );
        } else if (Platform.isAndroid) {
            await flutterLocalNotificationsPlugin
                    .resolvePlatformSpecificImplementation<
                            AndroidFlutterLocalNotificationsPlugin>()
                    ?.requestPermission();
        }
    }

    // Handle notification tap
    void onNotificationTapped(NotificationResponse response) {
        // Handle notification tap here
        // You can navigate to specific screen based on payload
        if (response.payload != null) {
            debugPrint('Notification payload: ${response.payload}');
            // Navigate to specific screen using payload
        }
    }

    // Handle iOS notification when app is in foreground
    void onDidReceiveLocalNotification(
            int id, String? title, String? body, String? payload) async {
        // Display a dialog when notification is received
        // Helper method to get color based on category
        Color _getCategoryColor(String category) {
            switch (category.toLowerCase()) {
                case 'work':
                    return Colors.blue;
                case 'personal':
                    return Colors.green;
                case 'shopping':
                    return Colors.orange;
                case 'health':
                    return Colors.red;
                case 'education':
                    return Colors.purple;
                default:
                    return Colors.grey;
            }
        }
    }
    }

    // Schedule task notification
    Future<void> scheduleTaskNotification({
        required int taskId,
        required String title,
        required String body,
        required DateTime scheduledDate,
        required String category,
        String? payload,
    }) async {
        // Android notification details
        final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            color: _getCategoryColor(category),
            styleInformation: BigTextStyleInformation(
                body,
                htmlFormatBigText: true,
                contentTitle: title,
                htmlFormatContentTitle: true,
            ),
        );

        // iOS notification details
        final DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
            badgeNumber: 1,
        );

        final NotificationDetails notificationDetails = NotificationDetails(
            android: androidDetails,
            iOS: iOSDetails,
        );

        // Schedule notification
        await flutterLocalNotificationsPlugin.zonedSchedule(
            taskId,
            title,
            body,
            tz.TZDateTime.from(scheduledDate, tz.local),
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                    UILocalNotificationDateInterpretation.absoluteTime,
            payload: payload,
        );
    }

    // Cancel specific notification
    Future<void> cancelNotification(int taskId) async {
        await flutterLocalNotificationsPlugin.cancel(taskId);
    }

    //
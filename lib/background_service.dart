import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wystaw_smieci/events/events.dart';
import 'package:wystaw_smieci/utils/constants.dart';
import 'package:wystaw_smieci/utils/convert.dart';
import 'package:wystaw_smieci/utils/language.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:http/http.dart' as http;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void initializeBackgroundService() {
  FlutterBackgroundService().configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

void onStart(ServiceInstance service) async {
  // Initialize the plugin
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    linux: LinuxInitializationSettings(
      defaultActionName: 'Open',
    ),
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  _initializeNotifications();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  fetchEvents();
  var prefs = await SharedPreferences.getInstance();
  while (true) {
    prefs.reload();
    var enabledCitiesRaw =
        prefs.getStringList(Constants.sharedPrefnotificationsEnabledKey);

    var notificationsSent = await processNotifications(enabledCitiesRaw!);
    if (notificationsSent) {
      await Future.delayed(Duration(hours: 1));
    } else {
      await Future.delayed(Constants.notificationCheckBackoff);
    }
  }
}

void fetchEvents() async {
  while (true) {
    try {
      var citiesResponse =
          await http.get(Uri.parse("${Constants.apiBaseUrl}/cities"));
      if (citiesResponse.statusCode != 200) {
        print("Failed to load cities: ${citiesResponse.statusCode}");
        await Future.delayed(Constants.fetchEventsDelay);
        continue;
      }
      var cities =
          List<String>.from(jsonDecode(utf8.decode(citiesResponse.bodyBytes)));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList(Constants.sharedPrefEventCitiesKey, cities);

      for (var city in cities) {
        var eventsResponse = await http
            .get(Uri.parse("${Constants.apiBaseUrl}/events/${toCityID(city)}"));
        if (eventsResponse.statusCode != 200) {
          print("Failed to load events: ${eventsResponse.statusCode}");
          continue;
        }
        var events = List<Map<String, dynamic>>.from(
            jsonDecode(utf8.decode(eventsResponse.bodyBytes)));
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setStringList(
            '${Constants.sharedPrefEventsKeyPrefix}_${toCityID(city)}',
            events.map((e) => jsonEncode(e)).toList());
      }
    } on SocketException catch (e) {
      print(
          "Failed to update events in shared preferences due to http error: $e");
    }
    await Future.delayed(Constants.fetchEventsDelay);
  }
}

Future<bool> processNotifications(List<String> enabledCitiesRaw) async {
  print("processing notifications");
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  var notificationsSent = false;

  for (var city in enabledCitiesRaw) {
    final eventsToNotify = (await getEventsForCity(city)).where((event) {
      final eventDate = DateTime.parse(event['date']!)
          .add(Duration(hours: Constants.notificationsHour));
      return eventDate.year == tomorrow.year &&
          eventDate.month == tomorrow.month &&
          eventDate.day == tomorrow.day &&
          eventDate.hour == now.hour &&
          eventDate.minute == now.minute;
    }).toList();

    for (var event in eventsToNotify) {
      print("sending notification with event: '${event['name']}'");

      if (Platform.isLinux) {
        return false;
      }

      try {
        flutterLocalNotificationsPlugin.show(
          "$city-${event['name']}-${event['date']}".hashCode,
          "$city: ${LangPL.prepareForTomorrow}",
          event['name'],
          NotificationDetails(
            android: AndroidNotificationDetails(
              Constants.androidNotificationChannelID,
              Constants.androidNotificationName,
              channelDescription:
                  Constants.androidNotificationChannelDescription,
            ),
            linux: LinuxNotificationDetails(),
          ),
        );
        print(
            "Notification sent successfully for event: ${event['name']}, city: $city");
        notificationsSent = true;
      } catch (e) {
        print(
            "Error sending notification for event: ${event['name']}, Error: $e");
      }
    }
  }
  return notificationsSent;
}

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

void _initializeNotifications() {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    linux: LinuxInitializationSettings(
      defaultActionName: 'Open',
    ),
  );

  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  tz.initializeTimeZones();
}

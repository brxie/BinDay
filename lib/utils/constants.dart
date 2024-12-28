import 'package:flutter/material.dart';

class Constants {
  static var notificationsHour = 16;

  static const List<Color> backgroundGradientColors = [
    Color.fromARGB(255, 239, 250, 244),
    Color.fromARGB(255, 228, 253, 240),
  ];
  static const String androidNotificationChannelID = "default_channel";
  static const String androidNotificationName = "Calendar Events Notifications";
  static const String androidNotificationChannelDescription = "";

  static const Duration notificationCheckBackoff = Duration(seconds: 1);

  static var locale = "pl_PL";

  static const String sharedPrefEventCitiesKey = "eventCities";
  static const String sharedPrefnotificationsEnabledKey =
      "notificationsEnabled";
}

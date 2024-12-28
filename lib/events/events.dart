import 'package:shared_preferences/shared_preferences.dart';
import 'package:wystaw_smieci/events/data.dart';
import 'package:wystaw_smieci/utils/constants.dart';
import 'dart:convert';

List<String> getCities() {
  SharedPreferences.getInstance().then((prefs) {
    prefs.reload();
    final cities = prefs.getStringList(Constants.sharedPrefEventCitiesKey);
    if (cities != null && cities.isNotEmpty) {
      return cities;
    }
  });
  return cities;
}

List<Map<String, String>> getEventsForCity(String city) {
  SharedPreferences.getInstance().then((prefs) {
    prefs.reload();
    final eventsJson =
        prefs.getStringList('${Constants.sharedPrefEventsKeyPrefix}_$city');
    if (eventsJson != null && eventsJson.isNotEmpty) {
      return eventsJson
          .map((e) => Map<String, String>.from(json.decode(e)))
          .toList();
    }
  });
  return events;
}

List<Map<String, String>> getNearestEventsForCity(String city) {
  final now =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final events = getEventsForCity(city);

  // Find the nearest date
  DateTime? nearestDate;
  Duration? minDiff;

  for (var event in events) {
    final eventDate = DateTime.parse(event['date']!);
    final diff = eventDate.difference(now).abs();

    if (minDiff == null || diff < minDiff) {
      minDiff = diff;
      nearestDate = eventDate;
    }
  }

  // Return all events from the nearest date
  return events
      .where((event) =>
          DateTime.parse(event['date']!).isAtSameMomentAs(nearestDate!))
      .toList();
}
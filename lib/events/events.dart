import 'package:shared_preferences/shared_preferences.dart';
import 'package:wystaw_smieci/events/data.dart';
import 'package:wystaw_smieci/utils/constants.dart';
import 'dart:convert';

Future<List<String>> getCities() async {
  List<String> result = citiesData;
  final prefs = await SharedPreferences.getInstance();
  var citiesList = prefs.getStringList(Constants.sharedPrefEventCitiesKey);
  if (citiesList != null && citiesList.isNotEmpty) {
    result = citiesList;
  }

  return result;
}

Future<List<Map<String, String>>> getEventsForCity(String city) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final eventsJson =
      prefs.getStringList('${Constants.sharedPrefEventsKeyPrefix}_$city');
  if (eventsJson != null && eventsJson.isNotEmpty) {
    return eventsJson
        .map((e) => Map<String, String>.from(json.decode(e)))
        .toList();
  }
  return eventsData;
}

Future<List<Map<String, String>>> getNearestEventsForCity(String city) async {
  final now =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final events = await getEventsForCity(city);

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

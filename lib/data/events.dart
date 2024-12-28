import 'package:shared_preferences/shared_preferences.dart';
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
  return [
    'Baranówka',
    'Czulice',
    'Dojazdów',
    'Głęboka',
    'Goszcza',
    'Goszyce',
    'Karniów',
    'Kocmyrzów',
    'Krzysztoforzyce',
    'Łosokowice',
    'Luborzyca',
    'Łuczyce (część I Krakowska)',
    'Łuczyce (część II Prądnik)',
    'Maciejowice',
    'Marszowice',
    'Pietrzejowice',
    'Prusy',
    'Rawałowice',
    'Sadowie',
    'Skrzeszowice',
    'Sulechów',
    'Wiktorowice',
    'Wilków',
    'Wola Luborzycka',
    'Wysiołek Luborzycki',
    'Zastów'
  ];
}

List<Map<String, String>> getEventsForCity(String city) {
  // Example events data
  return [
    {"date": "2024-12-24", "name": "odpady BIO"},
    {"date": "2024-12-24", "name": "odpady zmieszane"},
    {"date": "2024-12-24", "name": "odpady segregowane"},
    {"date": "2024-12-25", "name": "odpady BIO"},
    {"date": "2024-12-25", "name": "odpady zmieszane"},
    {"date": "2024-12-25", "name": "odpady segregowane"},
    {"date": "2024-12-26", "name": "odpady BIO"},
    {"date": "2024-12-26", "name": "odpady zmieszane"},
    {"date": "2024-12-26", "name": "odpady segregowane"},
    {"date": "2024-12-27", "name": "odpady BIO"},
    {"date": "2024-12-27", "name": "odpady zmieszane"},
    {"date": "2024-12-27", "name": "odpady segregowane"},
    {"date": "2024-12-28", "name": "odpady BIO"},
    {"date": "2024-12-28", "name": "odpady zmieszane"},
    {"date": "2024-12-28", "name": "odpady segregowane"},
    {"date": "2024-12-29", "name": "odpady BIO"},
    {"date": "2024-12-29", "name": "odpady zmieszane"},
    {"date": "2024-12-29", "name": "odpady segregowane"},
    {"date": "2024-12-30", "name": "odpady zmieszane"},
    {"date": "2024-12-30", "name": "odpady segregowane"},
    {"date": "2024-12-31", "name": "odpady BIO"},
    {"date": "2024-12-31", "name": "odpady zmieszane"},
    {"date": "2024-12-31", "name": "odpady segregowanee"}
  ];
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

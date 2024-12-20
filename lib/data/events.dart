List<Map<String, String>> getEventsForCity(String city) {
  // Example events data
  return [
    {'date': '2024-12-20', 'name': 'Trash Pickup'},
    {'date': '2024-12-20', 'name': 'Some other event'},
    {'date': '2024-12-21', 'name': 'Trash Pickup'},
    {'date': '2024-12-21', 'name': 'Some other event'},
    {'date': '2024-12-21', 'name': 'Some yet another event'},
    {'date': '2024-12-21', 'name': 'Recycling Collection'},
    {'date': '2024-12-22', 'name': 'Trash Pickup'},
    {'date': '2024-12-23', 'name': 'Trash Pickup'},
    {'date': '2024-12-24', 'name': 'Trash Pickup'},
    {'date': '2024-12-25', 'name': 'Trash Pickup'},
    {'date': '2024-12-26', 'name': 'Trash Pickup'},
    {'date': '2024-12-27', 'name': 'Trash Pickup'},
    {'date': '2024-12-28', 'name': 'Trash Pickup'},
    {'date': '2024-12-29', 'name': 'Trash Pickup'},
    {'date': '2024-12-30', 'name': 'Trash Pickup'},
    {'date': '2024-12-31', 'name': 'Trash Pickup'},
    // Add more events as needed
  ];
}

List<Map<String, String>> getNearestEventsForCity(String city) {
  final now = DateTime.now();
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

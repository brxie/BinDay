import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../data/events.dart';
import 'city_selection_page.dart';

class SchedulePage extends StatelessWidget {
  final List<String> selectedCities;

  const SchedulePage({super.key, required this.selectedCities});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash Collection Schedules'),
        backgroundColor: Colors.green[700],
      ),
      body: ListView(
        children: selectedCities.map((city) {
          return Column(
            children: <Widget>[
              // Event List
              _buildEventList(context, city),
              // Calendar
              TableCalendar(
                availableCalendarFormats: {
                  CalendarFormat.month: 'Month',
                },
                firstDay: DateTime(DateTime.now().year, 1, 1),
                lastDay: DateTime.now().add(const Duration(days: 30)),
                focusedDay: DateTime.now(),
                onDaySelected: (selectedDay, focusedDay) {
                  print('Selected day: $selectedDay');
                },
                eventLoader: (day) {
                  final events = getEventsForCity(city);
                  final matchingEvents = events
                      .where((event) {
                        final eventDate = DateTime.parse(event['date']!);
                        return DateTime(
                                eventDate.year, eventDate.month, eventDate.day)
                            .isAtSameMomentAs(
                                DateTime(day.year, day.month, day.day));
                      })
                      .map((event) => event['name']!)
                      .toList();
                  return matchingEvents;
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.green[300],
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.green[700],
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const CitySelectionPage()),
            (Route<dynamic> route) => false,
          );
        },
        backgroundColor: Colors.green[700],
        tooltip: 'Back to City Selection',
        child: const Icon(Icons.home),
      ),
    );
  }
}

Widget _buildEventList(BuildContext context, String city) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                Icon(Icons.location_city, color: Colors.green[700]),
                const SizedBox(width: 12),
                Text(
                  city,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.green[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Upcoming Events',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.green[900],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...getEventsForCity(city).map((event) {
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                leading: Icon(
                  event['name']?.contains('Recycling') ?? false
                      ? Icons.recycling
                      : Icons.delete,
                  color: Colors.green[700],
                ),
                title: Text(
                  event['name'] ?? '',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  event['date'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
              ),
            );
          }),
        ],
      ),
    );
  }
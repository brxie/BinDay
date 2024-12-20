import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../data/events.dart';
import 'city_selection_page.dart';

class SchedulePage extends StatefulWidget {
  final List<String> selectedCities;

  const SchedulePage({super.key, required this.selectedCities});

  @override
  SchedulePageState createState() => SchedulePageState();
}

class SchedulePageState extends State<SchedulePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash Collection Schedules'),
        backgroundColor: Colors.green[700],
      ),
      body: ListView(
        children: widget.selectedCities.map((city) {
          final eventsToday = getEventsForCity(city).where((event) {
            final eventDate = DateTime.parse(event['date']!);
            return eventDate.year == _selectedDay!.year &&
                eventDate.month == _selectedDay!.month &&
                eventDate.day == _selectedDay!.day;
          });
          return Column(
            children: <Widget>[
              // Event List
              _buildEventHeaderList(context, city),
              // Calendar
              _buildCalendar(context, city),
              // Fancy Text for Selected Date
              if (_selectedDay != null && eventsToday.isNotEmpty)
                _buildSelectedDateText(eventsToday),
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

  Widget _buildSelectedDateText(Iterable<Map<String, String>> eventsToday) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.calendar_today, color: Colors.green[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                eventsToday.map((event) => '• ${event['name']}').join('\n'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, String city) {
    return TableCalendar(
      availableCalendarFormats: {
        CalendarFormat.month: 'Month',
      },
      firstDay: DateTime(DateTime.now().year, 1, 1),
      lastDay: DateTime.now().add(const Duration(days: 30)),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      eventLoader: (day) {
        final events = getEventsForCity(city);
        final matchingEvents = events
            .where((event) {
              final eventDate = DateTime.parse(event['date']!);
              return DateTime(eventDate.year, eventDate.month, eventDate.day)
                  .isAtSameMomentAs(DateTime(day.year, day.month, day.day));
            })
            .map((event) => event['name']!)
            .toList();
        return matchingEvents;
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.green[300],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 2,
            ),
          ],
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.green[700],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.5),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        markerDecoration: BoxDecoration(
          color: Colors.green[500],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 3,
              spreadRadius: 1,
            ),
          ],
        ),
        weekendTextStyle: const TextStyle(color: Colors.redAccent),
        holidayTextStyle: TextStyle(color: Colors.green[900]),
        outsideTextStyle: TextStyle(color: Colors.grey[400]),
        defaultTextStyle: const TextStyle(fontWeight: FontWeight.w500),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.green[700]),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.green[700]),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Colors.green[700],
          fontWeight: FontWeight.bold,
        ),
        weekendStyle: TextStyle(
          color: Colors.green[300],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEventHeaderList(BuildContext context, String city) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
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
          ...getNearestEventsForCity(city).map((event) {
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
              ),
            );
          }),
        ],
      ),
    );
  }
}

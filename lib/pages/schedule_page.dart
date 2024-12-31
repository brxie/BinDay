import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wystaw_smieci/utils/constants.dart';
import 'package:wystaw_smieci/utils/language.dart';
import '../events/events.dart';
import 'city_selection_page.dart';
import '../utils/date_utils.dart';
import 'dart:async';

class SchedulePage extends StatefulWidget {
  final List<String> selectedCities;

  const SchedulePage({super.key, required this.selectedCities});

  @override
  SchedulePageState createState() => SchedulePageState();
}

class SchedulePageState extends State<SchedulePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  List<String> _enabledCities = [];
  Map<String, List<Map<String, String>>> _eventsByCity = {};
  List<Map<String, String>> _nearestEvents = [];

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
    _loadEvents();
    _loadNearestEvents();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enabledCities =
          prefs.getStringList(Constants.sharedPrefnotificationsEnabledKey) ??
              [];
    });
  }

  Future<void> _saveNotificationPreference(String city, bool active) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> enabledCities =
        prefs.getStringList(Constants.sharedPrefnotificationsEnabledKey) ?? [];
    if (active) {
      if (!enabledCities.contains(city)) {
        enabledCities.add(city);
      }
    } else {
      enabledCities.remove(city);
    }
    prefs.setStringList(
        Constants.sharedPrefnotificationsEnabledKey, enabledCities);
  }

  Future<void> _loadEvents() async {
    for (var city in widget.selectedCities) {
      final events = await getEventsForCity(city);
      setState(() {
        _eventsByCity[city] = events;
      });
    }
  }

  Future<void> _loadNearestEvents() async {
    for (var city in widget.selectedCities) {
      final events = await getNearestEventsForCity(city);
      setState(() {
        _nearestEvents = events;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(LangPL.appName),
        backgroundColor: Colors.green[700],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Constants.backgroundGradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          children: widget.selectedCities.map((city) {
            final events = _eventsByCity[city];
            if (events == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final eventsToday = events.where((event) {
              final eventDate = DateTime.parse(event['date']!);
              return eventDate.year == _selectedDay!.year &&
                  eventDate.month == _selectedDay!.month &&
                  eventDate.day == _selectedDay!.day;
            }).toList();

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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const CitySelectionPage()),
            (Route<dynamic> route) => false,
          );
        },
        backgroundColor: Colors.green[200],
        tooltip: LangPL.backToCitySelection,
        child: const Icon(Icons.home),
      ),
    );
  }

  Widget _buildEventHeaderList(BuildContext context, String city) {
    if (_nearestEvents.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

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
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.green[900],
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Text(
                  LangPL.getNotifications,
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: _enabledCities.contains(city),
                  onChanged: (value) {
                    setState(() {
                      if (value) {
                        _enabledCities.add(city);
                      } else {
                        _enabledCities.remove(city);
                      }
                      _saveNotificationPreference(city, value);
                    });
                  },
                  activeColor: Colors.green[700],
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey[300],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            LangPL.upcomingEvents,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.green[900],
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 2),
          ..._nearestEvents.map((event) {
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 2.0),
              child: ListTile(
                leading: _getEventIcon(event),
                title: Text(
                  event['name'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                subtitle: Text(
                  '${event['date'] ?? ''} - ${getDayOfWeek(DateTime.parse(event['date'] ?? ''))}',
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

  Icon _getEventIcon(Map<String, String> event) {
    final name = event['name']?.toLowerCase();
    final (icon, color) = switch (name) {
      final n
          when (n != null &&
              (n.contains('zmieszane') || n.contains('komunalne'))) =>
        (Icons.delete, const Color.fromARGB(255, 73, 75, 75)),
      final n when n?.contains('bio') ?? false => (
          Icons.compost,
          const Color.fromARGB(255, 98, 73, 64)
        ),
      final n when n?.contains('segregowane') ?? false => (
          Icons.recycling,
          const Color.fromARGB(255, 173, 161, 54)
        ),
      _ => (Icons.delete, Colors.green[700]),
    };
    return Icon(icon, color: color);
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
              color: Colors.green.withAlpha((0.1 * 255).toInt()),
              blurRadius: 1,
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
      locale: Constants.locale,
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
        final events = _eventsByCity[city] ?? [];
        return events
            .where((event) {
              final eventDate = DateTime.parse(event['date']!);
              return DateTime(eventDate.year, eventDate.month, eventDate.day)
                  .isAtSameMomentAs(DateTime(day.year, day.month, day.day));
            })
            .map((event) => event['name']!)
            .toList();
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.green[300],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withAlpha((0.3 * 255).toInt()),
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
              color: Colors.green.withAlpha((0.5 * 255).toInt()),
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
              color: Colors.green.withAlpha((0.3 * 255).toInt()),
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
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wystaw_smieci/utils/constants.dart';
import 'package:wystaw_smieci/utils/language.dart';
import '../data/events.dart';
import 'city_selection_page.dart';
import '../utils/date_utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class SchedulePage extends StatefulWidget {
  final List<String> selectedCities;

  const SchedulePage({super.key, required this.selectedCities});

  @override
  SchedulePageState createState() => SchedulePageState();
}

class SchedulePageState extends State<SchedulePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _notificationsEnabled = true;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
    _initializeNotifications();
    _scheduleDailyNotifications();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> _saveNotificationPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('notificationsEnabled', value);
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      linux: LinuxInitializationSettings(
        defaultActionName: 'Open',
      ),
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  void _scheduleDailyNotifications() async {
    await requestNotificationPermission();
    if (_notificationsEnabled) {
      _scheduleNotifications();
    }
  }

  void _scheduleNotifications() async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final city = widget.selectedCities[0];
    final eventsToNotify = getEventsForCity(city).where((event) {
      final eventDate = DateTime.parse(event['date']!);
      return eventDate.year == tomorrow.year &&
          eventDate.month == tomorrow.month &&
          eventDate.day == tomorrow.day;
    }).toList();

    if (eventsToNotify.isNotEmpty) {
      for (var event in eventsToNotify) {
        final eventDate = DateTime.parse(event['date']!);
        final eventID =
            '${city}_${event['name']}_${eventDate.day}/${eventDate.month}/${eventDate.year}';
        print("scheduling event with id: '$eventID' for '$tomorrow'");

        if (Platform.isLinux) {
          return;
        }

        try {
          await flutterLocalNotificationsPlugin.show(
            eventID.hashCode,
            LangPL.prepareForTomorrow,
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
              "Notification scheduled successfully for event: \\${event['name']}");
        } catch (e) {
          print(
              "Error scheduling notification for event: \\${event['name']}, Error: \\${e}");
        }
      }
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
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                      _saveNotificationPreference(value);
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
          ...getNearestEventsForCity(city).map((event) {
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 2.0),
              child: ListTile(
                leading: Icon(
                  event['name']?.contains('Recycling') ?? false
                      ? Icons.recycling
                      : Icons.delete,
                  color: Colors.green[700],
                ),
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

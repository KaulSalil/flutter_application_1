import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late SharedPreferences _prefs;
  late CalendarController _calendarController;
  List<DateTime> _events = [];

  @override
  void initState() {
    super.initState();
    _initializeCalendar();
  }

  Future<void> _initializeCalendar() async {
    _prefs = await SharedPreferences.getInstance();
    _calendarController = CalendarController();
    _loadSavedEvents();
  }

  void _loadSavedEvents() {
    final List<String>? savedEvents = _prefs.getStringList('events');
    if (savedEvents != null) {
      setState(() {
        _events = savedEvents.map((e) => DateTime.parse(e)).toList();
      });
    }
  }

  void _saveEvent(DateTime selectedDate) {
    setState(() {
      _events.add(selectedDate);
    });

    _prefs.setStringList(
      'events',
      _events.map((e) => e.toIso8601String()).toList(),
    );
  }

  void _removeEvent(DateTime selectedDate) {
    setState(() {
      _events.remove(selectedDate);
    });

    _prefs.setStringList(
      'events',
      _events.map((e) => e.toIso8601String()).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scheduling App'),
      ),
      body: Column(
        children: <Widget>[
          TableCalendar(
            calendarController: _calendarController,
            events: {for (var event in _events) event: []},
            onDaySelected: (date, events, holidays) {
              if (events.isNotEmpty) {
                // Remove the event if it already exists
                _removeEvent(date);
              } else {
                // Add the event if it doesn't exist
                _saveEvent(date);
              }
              setState(() {
                _calendarController.setSelectedDay(date);
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final eventDate = _events[index];
                return ListTile(
                  title: Text('Scheduled on ${eventDate.toLocal()}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Scheduling App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScheduleScreen(),
    );
  }
}

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
      });
  }

  Future<void> _saveSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('scheduled_date', DateFormat('yyyy-MM-dd').format(selectedDate));
    await prefs.setString('scheduled_time', selectedTime.format(context));
  }

  Future<void> _loadSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('scheduled_date') ?? '';
    final savedTime = prefs.getString('scheduled_time') ?? '';
    if (savedDate.isNotEmpty && savedTime.isNotEmpty) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').parse(savedDate);
        final timeParts = savedTime.split(':');
        selectedTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Scheduling App'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text('Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
              trailing: Icon(Icons.keyboard_arrow_down),
              onTap: () => _selectDate(context),
            ),
            ListTile(
              title: Text('Time: ${selectedTime.format(context)}'),
              trailing: Icon(Icons.keyboard_arrow_down),
              onTap: () => _selectTime(context),
            ),
            ElevatedButton(
              onPressed: _saveSchedule,
              child: Text('Save Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}

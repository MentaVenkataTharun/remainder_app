import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final List<String> activities = [
    'Wake up',
    'Go to gym',
    'Breakfast',
    'Meetings',
    'Lunch',
    'Quick nap',
    'Go to library',
    'Dinner',
    'Go to sleep'
  ];

  String selectedDay = 'Monday';
  TimeOfDay selectedTime = TimeOfDay(hour: 7, minute: 0);
  String selectedActivity = 'Wake up';

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final initSettings = InitializationSettings(android: android, iOS: iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> scheduleNotification(TimeOfDay time, String activity) async {
    final android = AndroidNotificationDetails(
      'channel id',
      'channel name',
      'channel description',
      importance: Importance.max,
      priority: Priority.high,
    );
    final iOS = IOSNotificationDetails();
    final platform = NotificationDetails(android: android, iOS: iOS);

    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    await flutterLocalNotificationsPlugin.schedule(
      0,
      'Reminder',
      activity,
      scheduledTime,
      platform,
    );
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedDay,
              onChanged: (String newValue) {
                setState(() {
                  selectedDay = newValue;
                });
              },
              items: daysOfWeek.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => selectTime(context),
              child: Text('Select Time: ${selectedTime.format(context)}'),
            ),
            SizedBox(height: 16.0),
            DropdownButton<String>(
              value: selectedActivity,
              onChanged: (String newValue) {
                setState(() {
                  selectedActivity = newValue;
                });
              },
              items: activities.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                scheduleNotification(selectedTime, selectedActivity);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Reminder Set for $selectedActivity at ${selectedTime.format(context)}')),
                );
              },
              child: Text('Set Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
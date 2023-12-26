import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:training_journal_app/models/training.dart';
import 'package:training_journal_app/services/journal_database.dart';
import 'package:training_journal_app/services/training_service.dart';
import 'package:timezone/timezone.dart' as tz;

class AddNotificationScreen extends StatefulWidget {
  const AddNotificationScreen({super.key});

  @override
  _AddNotificationScreenState createState() => _AddNotificationScreenState();
}

class _AddNotificationScreenState extends State<AddNotificationScreen> {
  TimeOfDay? selectedTime;
  List<Training> trainings = [];
  Training? selectedTraining;
  int selectedDay = 1;
  int maxId = 0;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    final instance = JournalDatabase.instance;
    final trainingList = await TrainingService(instance).readAllTrainings() ?? [];
    if(trainingList.isNotEmpty) {
      setState(() {
        trainings = trainingList;
        selectedTraining = trainings[0];
      });
    }
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()!.requestNotificationsPermission();

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    final List<PendingNotificationRequest> pendingNotificationRequests =
    await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    if(pendingNotificationRequests.isNotEmpty){
      for(int i = 0; i < pendingNotificationRequests.length; i++){
        if(maxId == pendingNotificationRequests[i].id){
          maxId += 1;
        }
      }
    }
  }

  int getNextDay(DateTime currentDate, int selectedDay) {
    int difference = (selectedDay - currentDate.weekday + 7) % 7;
    DateTime nextDay = currentDate.add(Duration(days: difference));

    return nextDay.day;
  }

  Future<void> _scheduleNotification() async {
    final String trainingName = await _getTrainingName(selectedTraining!.id!);

    final DateTime now = DateTime.now();
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      getNextDay(now, selectedDay),
      selectedTime!.hour,
      selectedTime!.minute,
    );
    if (now.isAfter(scheduledDate)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'training_journal_channel',
      'Training Journal Channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final tz.TZDateTime scheduledDateTZ = tz.TZDateTime(
      tz.getLocation('Europe/Warsaw'),
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledDate.hour,
      scheduledDate.minute,
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(
      maxId,
      'Training Reminder',
      'Training: $trainingName',
      scheduledDateTZ,
      platformChannelSpecifics,
      payload: '${selectedTraining!.id!.toString()}, ${selectedDay.toString()}, ${scheduledDateTZ.hour.toString()}:${scheduledDateTZ.minute.toString()}',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Notification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTrainingDropdown(),
            const SizedBox(height: 16.0),
            _buildDayDropdown(),
            const SizedBox(height: 16.0),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingDropdown() {
    return DropdownButtonFormField<Training>(
      value: trainings.isNotEmpty ? trainings[0] : null,
      hint: const Text('Select Training'),
      items: trainings
          .map((training) => DropdownMenuItem(
                value: training,
                child: Text(training.name),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedTraining = value;
        });
      },
    );
  }

  Widget _buildDayDropdown() {
    return DropdownButtonFormField<int>(
      value: selectedDay,
      hint: const Text('Select Day'),
      items: const [
        DropdownMenuItem(value: 1, child: Text('Monday')),
        DropdownMenuItem(value: 2, child: Text('Tuesday')),
        DropdownMenuItem(value: 3, child: Text('Wednesday')),
        DropdownMenuItem(value: 4, child: Text('Thursday')),
        DropdownMenuItem(value: 5, child: Text('Friday')),
        DropdownMenuItem(value: 6, child: Text('Saturday')),
        DropdownMenuItem(value: 7, child: Text('Sunday')),
      ],
      onChanged: (value) {
        setState(() {
          selectedDay = value!;
        });
      },
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () async {
        await _saveNotification();
      },
      child: const Text('Save Notification'),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _saveNotification() async {
    await _selectTime(context);
    if (selectedTime == null) {
      return;
    }
    if (selectedTraining == null) {
      return;
    } else {
      await _scheduleNotification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification saved successfully'),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<String> _getTrainingName(int trainingId) async {
    final instance = JournalDatabase.instance;
    final trainingService = TrainingService(instance);
    final training = await trainingService.readTrainingById(trainingId);
    return training.name;
  }
}

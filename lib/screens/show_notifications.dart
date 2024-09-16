import 'package:flutter/material.dart';
import 'package:training_journal_app/services/journal_database.dart';
import '../models/training.dart';
import '../services/training_service.dart';
import 'add_notification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/training_notification.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Training> trainings = [];
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  List<TrainingNotification> notifications = [];

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  void _loadData() async {
    final instance = JournalDatabase.instance;
    final trainingList = await TrainingService(instance).readAllTrainings() ?? [];
    if(trainingList.isNotEmpty) {
      setState(() {
        trainings = trainingList;
      });
    }
    else{
      setState(() {
        trainings = [];
      });
    }
    List<TrainingNotification> loadedNotifications = [];
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
      debugPrint('Masz ${pendingNotificationRequests.length} powiadomień.');
      for(int i = 0; i < pendingNotificationRequests.length; i++){
        loadedNotifications.add(TrainingNotification.fromNotificationRequest(pendingNotificationRequests[i]));
      }
      for(int i = 0; i < loadedNotifications.length; i++){
        debugPrint(i.toString());
        debugPrint(loadedNotifications[i].toString());
      }
    }
    setState(() {
      notifications = loadedNotifications;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body:_buildNotificationsList(notifications),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNotificationScreen()),
          ).then((_) {
            _loadData();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNotificationsList(List<TrainingNotification> notifications) {
    return ListView(
      children: List.generate(7, (index) {
        final dayNotifications = notifications.where((n) => n.day == index + 1).toList();
        final dayName = _getDayName(index + 1);

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(dayName),
              ),
              if (dayNotifications.isNotEmpty)
                Column(
                  children: dayNotifications.map((notification) {
                    return ListTile(
                      title: Text('Training: ${notification.trainingName}'),
                      subtitle: Text('Time: ${notification.time.format(context)}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          // Usuń powiadomienie z urządzenia po naciśnięciu guzika
                          await _cancelNotification(notification.id);
                          // Załaduj dane ponownie po usunięciu powiadomienia
                          _loadData();
                        },
                      ),
                    );
                  }).toList(),
                )
            ],
          ),
        );
      }),
    );
  }

  Future<void> _cancelNotification(int notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }


  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }
}

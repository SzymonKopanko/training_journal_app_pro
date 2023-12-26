import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/show_exercises.dart';
import 'screens/show_notifications.dart';
import 'screens/show_trainings.dart';
import 'services/journal_database.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const [
        Locale('en', 'GB'),
      ],
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green.shade900,
          brightness: MediaQuery.platformBrightnessOf(context),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Data?'),
          content: const Text(
              'This action will delete all entries and exercises. Are you sure'
              ' you want to proceed?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteAllData(context);
                Navigator.of(context).pop();
              },
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAllData(BuildContext context) async {
    final database = JournalDatabase.instance;
    await database.deleteDB();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('All data has been deleted.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Journal Pro'),
      ),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ShowExercises()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(185.0, 80.0),
                          padding: const EdgeInsets.all(16.0),
                        ),
                        child: const Text(
                          'Exercises',
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                      const SizedBox(height: 50.0),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const NotificationsScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(185.0, 80.0),
                          padding: const EdgeInsets.all(16.0),
                        ),
                        child: const Text(
                          'Notifications',
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ShowTrainingsScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(185.0, 80.0),
                          padding: const EdgeInsets.all(16.0),
                        ),
                        child: const Text(
                          'Trainings',
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                      const SizedBox(height: 50.0),
                      ElevatedButton(
                        onPressed: () {
                          //TODO
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(185.0, 80.0),
                          padding: const EdgeInsets.all(16.0),
                        ),
                        child: const Text(
                          'Body Entries',
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 50.0),
              ElevatedButton(
                onPressed: () {
                  _showDeleteConfirmationDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(185.0, 80.0),
                  padding: const EdgeInsets.all(16.0),
                  backgroundColor: MediaQuery.platformBrightnessOf(context) !=
                          Brightness.light
                      ? const Color.fromARGB(100, 70, 40, 46)
                      : const Color.fromARGB(255, 252, 234, 234),
                ),
                child: Text(
                  'Delete All',
                  style: TextStyle(
                    fontSize: 25,
                    color: MediaQuery.platformBrightnessOf(context) !=
                            Brightness.light
                        ? const Color.fromARGB(255, 255, 146, 146)
                        : const Color.fromARGB(255, 183, 0, 0),
                  ),
                ),
              ),
              const SizedBox(height: 50.0),
              const Text(
                'by Szymon Kopańko',
              )
            ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:training_journal_app/screens/show_body_entries.dart';

import 'constants/app_constants.dart';
import 'screens/settings_screen.dart';
import 'screens/show_exercises.dart';
import 'screens/show_notifications.dart';
import 'screens/show_trainings.dart';

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
          seedColor: AppColors.seed,
          brightness: MediaQuery.platformBrightnessOf(context),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ShowExercises()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: AppSizing.buttonSize0,
                    padding: const EdgeInsets.all(AppSizing.padding2),
                  ),
                  child: const Text(
                    'Exercises',
                    style: TextStyle(fontSize: AppSizing.fontSize1),
                  ),
                ),
                const SizedBox(width: AppSizing.padding2),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ShowTrainingsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: AppSizing.buttonSize0,
                    padding: const EdgeInsets.all(AppSizing.padding2),
                  ),
                  child: const Text(
                    'Trainings',
                    style: TextStyle(fontSize: AppSizing.fontSize1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizing.padding),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ShowBodyEntriesScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: AppSizing.buttonSize0,
                    padding: const EdgeInsets.all(AppSizing.padding2),
                  ),
                  child: const Text(
                    'Body Entries',
                    style: TextStyle(fontSize: AppSizing.fontSize1),
                  ),
                ),
                const SizedBox(width: AppSizing.padding2),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: AppSizing.buttonSize0,
                    padding: const EdgeInsets.all(AppSizing.padding2),
                  ),
                  child: const Text(
                    'Notifications',
                    style: TextStyle(fontSize: AppSizing.fontSize1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizing.padding),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: AppSizing.buttonSize0,
                    padding: const EdgeInsets.all(AppSizing.padding2),
                  ),
                  child: const Text(
                    'Settings',
                    style: TextStyle(fontSize: AppSizing.fontSize1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizing.padding),
            const Text(
              'by Szymon Kopańko',
            )
          ],
        ),
      ),
    );
  }
}

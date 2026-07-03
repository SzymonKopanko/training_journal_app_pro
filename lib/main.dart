import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'constants/app_constants.dart';
import 'l10n/app_localizations.dart';
import 'providers/settings_controller.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  tz.initializeTimeZones();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: settings.locale,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.seed,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.seed,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: settings.themeMode,
      home: const MainScreen(),
    );
  }
}

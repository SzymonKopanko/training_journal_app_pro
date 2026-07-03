import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../providers/body_entries_provider.dart';
import '../providers/database_providers.dart';
import '../providers/exercises_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/settings_controller.dart';
import '../providers/trainings_provider.dart';
import '../providers/weekly_plans_provider.dart';
import '../theme/app_spacing.dart';
import 'show_weekly_plans.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: Text(l10n.settingsAddStarter),
            onTap: () {
              _addStarterExercises(context, ref, l10n);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.settingsLanguage),
            subtitle: Text(l10n.settingsLanguageDescription),
            onTap: () {
              _changeLanguage(context, ref, l10n);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: Text(l10n.settingsMeasurement),
            subtitle: Text(l10n.settingsMeasurementDescription),
            onTap: () {
              _changeMeasurementSystem(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: Text(l10n.settingsTheme),
            subtitle: Text(l10n.settingsThemeDescription),
            onTap: () {
              _changeTheme(context, ref, l10n);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: Text(l10n.settingsWeeklyPlans),
            subtitle: Text(l10n.settingsWeeklyPlansDescription),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ShowWeeklyPlansScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: Text(l10n.settingsExportData),
            subtitle: Text(l10n.settingsExportDataDescription),
            onTap: () => _exportData(context, ref, l10n),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.download),
            title: Text(l10n.settingsImportData),
            subtitle: Text(l10n.settingsImportDataDescription),
            onTap: () => _confirmImportData(context, ref, l10n),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete),
            title: Text(l10n.settingsDeleteAll),
            onTap: () {
              _showDeleteConfirmationDialog(context, ref, l10n);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addStarterExercises(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    await ref
        .read(bodyPartServiceProvider)
        .createStarterExercisesAndBodyPartsWithRelationsWithSomeEdits();
    ref.invalidate(exercisesProvider);
    ref.invalidate(trainingsProvider);
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.settingsAddStarterDoneTitle),
          content: Text(l10n.settingsAddStarterDoneBody),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.commonOk),
            ),
          ],
        );
      },
    );
  }

  void _changeLanguage(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final current = ref.read(settingsControllerProvider).locale?.languageCode;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(l10n.settingsLanguage),
          children: [
            RadioListTile<String?>(
              title: Text(l10n.languageSystem),
              value: null,
              groupValue: current,
              onChanged: (_) {
                ref.read(settingsControllerProvider.notifier).setLocale(null);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String?>(
              title: Text(l10n.languagePolish),
              value: 'pl',
              groupValue: current,
              onChanged: (_) {
                ref
                    .read(settingsControllerProvider.notifier)
                    .setLocale(const Locale('pl'));
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String?>(
              title: Text(l10n.languageEnglish),
              value: 'en',
              groupValue: current,
              onChanged: (_) {
                ref
                    .read(settingsControllerProvider.notifier)
                    .setLocale(const Locale('en'));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _changeTheme(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final current = ref.read(settingsControllerProvider).themeMode;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(l10n.settingsTheme),
          children: [
            RadioListTile<ThemeMode>(
              title: Text(l10n.themeSystem),
              value: ThemeMode.system,
              groupValue: current,
              onChanged: (_) {
                ref
                    .read(settingsControllerProvider.notifier)
                    .setThemeMode(ThemeMode.system);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.themeLight),
              value: ThemeMode.light,
              groupValue: current,
              onChanged: (_) {
                ref
                    .read(settingsControllerProvider.notifier)
                    .setThemeMode(ThemeMode.light);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.themeDark),
              value: ThemeMode.dark,
              groupValue: current,
              onChanged: (_) {
                ref
                    .read(settingsControllerProvider.notifier)
                    .setThemeMode(ThemeMode.dark);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _changeMeasurementSystem(BuildContext context) {
    // TODO(F-later): wybór jednostek metryczne/imperialne (poza zakresem Fazy 1).
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.settingsDeleteAllConfirmTitle),
          content: Text(l10n.settingsDeleteAllConfirmBody),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () {
                _deleteAllData(context, ref, l10n);
                Navigator.of(context).pop();
              },
              child: Text(l10n.settingsDeleteAllConfirmAction),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportData(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final json = await ref.read(dataBackupServiceProvider).exportToJson();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/training_journal_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(json);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: l10n.settingsExportData,
      );
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsExportDone)));
    } catch (_) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsExportError)));
    }
  }

  void _confirmImportData(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsImportConfirmTitle),
        content: Text(l10n.settingsImportConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _importData(context, ref, l10n);
            },
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
  }

  Future<void> _importData(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.single.path == null) return;

      final json = await File(result.files.single.path!).readAsString();
      await ref.read(dataBackupServiceProvider).importFromJson(json);
      ref.invalidate(exercisesProvider);
      ref.invalidate(trainingsProvider);
      ref.invalidate(bodyEntriesProvider);
      ref.invalidate(notificationsProvider);
      ref.invalidate(weeklyPlansProvider);
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsImportDone)));
    } catch (_) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsImportError)));
    }
  }

  void _deleteAllData(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(journalDatabaseProvider).deleteDB();
    ref.invalidate(exercisesProvider);
    ref.invalidate(trainingsProvider);
    ref.invalidate(bodyEntriesProvider);
    ref.invalidate(notificationsProvider);
    ref.invalidate(weeklyPlansProvider);
    messenger.showSnackBar(SnackBar(
      content: Text(l10n.settingsDeleteAllDone),
    ));
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Training Journal Pro'**
  String get appTitle;

  /// No description provided for @byAuthor.
  ///
  /// In en, this message translates to:
  /// **'by Szymon Kopańko'**
  String get byAuthor;

  /// No description provided for @navExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get navExercises;

  /// No description provided for @navTrainings.
  ///
  /// In en, this message translates to:
  /// **'Trainings'**
  String get navTrainings;

  /// No description provided for @navBodyEntries.
  ///
  /// In en, this message translates to:
  /// **'Body Entries'**
  String get navBodyEntries;

  /// No description provided for @navNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get commonSuccess;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAddStarter.
  ///
  /// In en, this message translates to:
  /// **'Add Starter Exercises'**
  String get settingsAddStarter;

  /// No description provided for @settingsAddStarterDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Starter Exercises'**
  String get settingsAddStarterDoneTitle;

  /// No description provided for @settingsAddStarterDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Starter exercises have been added.'**
  String get settingsAddStarterDoneBody;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose application language'**
  String get settingsLanguageDescription;

  /// No description provided for @settingsMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Change Measurement System'**
  String get settingsMeasurement;

  /// No description provided for @settingsMeasurementDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose metric or imperial units'**
  String get settingsMeasurementDescription;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Change Colors'**
  String get settingsTheme;

  /// No description provided for @settingsThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose application theme'**
  String get settingsThemeDescription;

  /// No description provided for @settingsDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get settingsDeleteAll;

  /// No description provided for @settingsDeleteAllConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data?'**
  String get settingsDeleteAllConfirmTitle;

  /// No description provided for @settingsDeleteAllConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This action will delete all entries and exercises. Are you sure you want to proceed?'**
  String get settingsDeleteAllConfirmBody;

  /// No description provided for @settingsDeleteAllConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get settingsDeleteAllConfirmAction;

  /// No description provided for @settingsDeleteAllDone.
  ///
  /// In en, this message translates to:
  /// **'All data has been deleted.'**
  String get settingsDeleteAllDone;

  /// No description provided for @settingsExportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get settingsExportData;

  /// No description provided for @settingsExportDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Save all data to a JSON file'**
  String get settingsExportDataDescription;

  /// No description provided for @settingsExportDone.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully.'**
  String get settingsExportDone;

  /// No description provided for @settingsExportError.
  ///
  /// In en, this message translates to:
  /// **'Export failed.'**
  String get settingsExportError;

  /// No description provided for @settingsImportData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get settingsImportData;

  /// No description provided for @settingsImportDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Restore data from a JSON backup file'**
  String get settingsImportDataDescription;

  /// No description provided for @settingsImportConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Data?'**
  String get settingsImportConfirmTitle;

  /// No description provided for @settingsImportConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Existing data will be merged with the backup (matching IDs will be replaced). Continue?'**
  String get settingsImportConfirmBody;

  /// No description provided for @settingsImportDone.
  ///
  /// In en, this message translates to:
  /// **'Data imported successfully.'**
  String get settingsImportDone;

  /// No description provided for @settingsImportError.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Check file format.'**
  String get settingsImportError;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @languagePolish.
  ///
  /// In en, this message translates to:
  /// **'Polski'**
  String get languagePolish;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @weightWord.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightWord;

  /// No description provided for @repsWord.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get repsWord;

  /// No description provided for @rirWord.
  ///
  /// In en, this message translates to:
  /// **'RIR'**
  String get rirWord;

  /// No description provided for @oneRmWord.
  ///
  /// In en, this message translates to:
  /// **'1RM'**
  String get oneRmWord;

  /// No description provided for @setsWord.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get setsWord;

  /// No description provided for @chartWord.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get chartWord;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @exerciseNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercise Name'**
  String get exerciseNameLabel;

  /// No description provided for @trainingNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Training Name'**
  String get trainingNameLabel;

  /// No description provided for @defaultWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Default weight'**
  String get defaultWeightLabel;

  /// No description provided for @enterWeightHint.
  ///
  /// In en, this message translates to:
  /// **'Enter weight'**
  String get enterWeightHint;

  /// No description provided for @enterDefaultWeightHint.
  ///
  /// In en, this message translates to:
  /// **'Enter default weight'**
  String get enterDefaultWeightHint;

  /// No description provided for @weightKgLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKgLabel;

  /// No description provided for @mainWeightKgLabel.
  ///
  /// In en, this message translates to:
  /// **'Main Weight (kg)'**
  String get mainWeightKgLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time:'**
  String get timeLabel;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @selectExerciseLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Exercise'**
  String get selectExerciseLabel;

  /// No description provided for @selectedBodyParts.
  ///
  /// In en, this message translates to:
  /// **'Selected Body Parts:'**
  String get selectedBodyParts;

  /// No description provided for @availableBodyParts.
  ///
  /// In en, this message translates to:
  /// **'Available Body Parts:'**
  String get availableBodyParts;

  /// No description provided for @selectedExercises.
  ///
  /// In en, this message translates to:
  /// **'Selected Exercises:'**
  String get selectedExercises;

  /// No description provided for @availableExercises.
  ///
  /// In en, this message translates to:
  /// **'Available Exercises:'**
  String get availableExercises;

  /// No description provided for @defaultRestTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Default Rest Time:'**
  String get defaultRestTimeLabel;

  /// No description provided for @bodyweightLiftedLabel.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight Lifted:'**
  String get bodyweightLiftedLabel;

  /// No description provided for @labelNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes: {notes}'**
  String labelNotes(String notes);

  /// No description provided for @labelDate.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String labelDate(String date);

  /// No description provided for @pastValue.
  ///
  /// In en, this message translates to:
  /// **'Past: {value}'**
  String pastValue(String value);

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'{weight} kg'**
  String weightKg(String weight);

  /// No description provided for @hintDate.
  ///
  /// In en, this message translates to:
  /// **'Hint Date: {date}'**
  String hintDate(String date);

  /// No description provided for @changePastHint.
  ///
  /// In en, this message translates to:
  /// **'Change Past Entry Hint ({number}.)'**
  String changePastHint(int number);

  /// No description provided for @exercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercisesTitle;

  /// No description provided for @exercisesSearch.
  ///
  /// In en, this message translates to:
  /// **'Search Exercises'**
  String get exercisesSearch;

  /// No description provided for @exercisesNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No matching exercises found.'**
  String get exercisesNoMatch;

  /// No description provided for @exercisesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No exercises found, add some.'**
  String get exercisesEmpty;

  /// No description provided for @exercisesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get exercisesAdd;

  /// No description provided for @exercisesEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Exercise'**
  String get exercisesEdit;

  /// No description provided for @exercisesEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit “{name}” exercise'**
  String exercisesEditTitle(String name);

  /// No description provided for @exercisesNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an exercise name.'**
  String get exercisesNameRequired;

  /// No description provided for @exercisesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Exercise?'**
  String get exercisesDeleteTitle;

  /// No description provided for @exercisesDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This action will delete all entries for this exercise ({name}) with it. Are you sure you want to proceed?'**
  String exercisesDeleteBody(String name);

  /// No description provided for @exercisesDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Exercise'**
  String get exercisesDeleteConfirm;

  /// No description provided for @exercisesOneRepMax.
  ///
  /// In en, this message translates to:
  /// **'One Rep Max: {oneRM} kg ({weight} kg x {reps} reps)'**
  String exercisesOneRepMax(String oneRM, String weight, int reps);

  /// No description provided for @exercisesDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date and time: {date}'**
  String exercisesDateTime(String date);

  /// No description provided for @exercisesBodyParts.
  ///
  /// In en, this message translates to:
  /// **'Body Parts: {parts}'**
  String exercisesBodyParts(String parts);

  /// No description provided for @exercisesDefaultRestTime.
  ///
  /// In en, this message translates to:
  /// **'Default rest time: {time}'**
  String exercisesDefaultRestTime(String time);

  /// No description provided for @exercisesBodyweightLifted.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight lifted: {percentage} %'**
  String exercisesBodyweightLifted(int percentage);

  /// No description provided for @tooltipAddEntry.
  ///
  /// In en, this message translates to:
  /// **'Add Entry'**
  String get tooltipAddEntry;

  /// No description provided for @tooltipShowEntries.
  ///
  /// In en, this message translates to:
  /// **'Show Entries'**
  String get tooltipShowEntries;

  /// No description provided for @restTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Rest Time'**
  String get restTimeTitle;

  /// No description provided for @restMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes: {count}'**
  String restMinutes(int count);

  /// No description provided for @restSeconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds: {count}'**
  String restSeconds(int count);

  /// No description provided for @restMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String restMinutesLabel(int count);

  /// No description provided for @restSecondsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} seconds'**
  String restSecondsLabel(int count);

  /// No description provided for @bodyweightPctTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Bodyweight Percentage'**
  String get bodyweightPctTitle;

  /// No description provided for @selectTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTimeTitle;

  /// No description provided for @trainingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trainings'**
  String get trainingsTitle;

  /// No description provided for @trainingsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search Trainings'**
  String get trainingsSearch;

  /// No description provided for @trainingsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No matching trainings found.'**
  String get trainingsNoMatch;

  /// No description provided for @trainingsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No trainings found, add some.'**
  String get trainingsEmpty;

  /// No description provided for @trainingsNoExercises.
  ///
  /// In en, this message translates to:
  /// **'No exercises found, add some before creating trainings.'**
  String get trainingsNoExercises;

  /// No description provided for @trainingsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Training'**
  String get trainingsAdd;

  /// No description provided for @trainingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save Training'**
  String get trainingsSave;

  /// No description provided for @trainingsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit “{name}” training'**
  String trainingsEditTitle(String name);

  /// No description provided for @trainingsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Training?'**
  String get trainingsDeleteTitle;

  /// No description provided for @trainingsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This action will delete all entries for this training ({name}) with it. Are you sure you want to proceed?'**
  String trainingsDeleteBody(String name);

  /// No description provided for @trainingsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Training'**
  String get trainingsDeleteConfirm;

  /// No description provided for @trainingsAddEntries.
  ///
  /// In en, this message translates to:
  /// **'Add Training Entries'**
  String get trainingsAddEntries;

  /// No description provided for @trainingsNameTaken.
  ///
  /// In en, this message translates to:
  /// **'This training name is already taken.'**
  String get trainingsNameTaken;

  /// No description provided for @trainingsNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Training name cannot be empty.'**
  String get trainingsNameEmpty;

  /// No description provided for @trainingsSelectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Select at least one exercise for the training.'**
  String get trainingsSelectAtLeastOne;

  /// No description provided for @trainingsNoBodyPartsAssigned.
  ///
  /// In en, this message translates to:
  /// **'No body parts assigned'**
  String get trainingsNoBodyPartsAssigned;

  /// No description provided for @trainingExerciseWithParts.
  ///
  /// In en, this message translates to:
  /// **'{name} ({parts})'**
  String trainingExerciseWithParts(String name, String parts);

  /// No description provided for @entryAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add “{name}” entry'**
  String entryAddTitle(String name);

  /// No description provided for @entryAddEntriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Add “{name}” entries'**
  String entryAddEntriesTitle(String name);

  /// No description provided for @entryEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit “{name}” entry'**
  String entryEditTitle(String name);

  /// No description provided for @entriesHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'“{name}” history'**
  String entriesHistoryTitle(String name);

  /// No description provided for @entriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add some entries to see some data here.'**
  String get entriesEmpty;

  /// No description provided for @entryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted successfully'**
  String get entryDeleted;

  /// No description provided for @tooltipEditEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit Entry'**
  String get tooltipEditEntry;

  /// No description provided for @tooltipDeleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry'**
  String get tooltipDeleteEntry;

  /// No description provided for @showChart.
  ///
  /// In en, this message translates to:
  /// **'Show Chart'**
  String get showChart;

  /// No description provided for @timerEnded.
  ///
  /// In en, this message translates to:
  /// **'Timer ended!'**
  String get timerEnded;

  /// No description provided for @valInvalidMainWeight.
  ///
  /// In en, this message translates to:
  /// **'Invalid main weight value.'**
  String get valInvalidMainWeight;

  /// No description provided for @valTooBigMainWeight.
  ///
  /// In en, this message translates to:
  /// **'Too big main weight value.'**
  String get valTooBigMainWeight;

  /// No description provided for @valInvalidReps.
  ///
  /// In en, this message translates to:
  /// **'Invalid reps value in set {number}.'**
  String valInvalidReps(int number);

  /// No description provided for @valTooManyReps.
  ///
  /// In en, this message translates to:
  /// **'Too many reps value in set {number}.'**
  String valTooManyReps(int number);

  /// No description provided for @valEmptyReps.
  ///
  /// In en, this message translates to:
  /// **'Empty reps controller and no historical set available at set {number} in chosen historical entry.'**
  String valEmptyReps(int number);

  /// No description provided for @valInvalidWeight.
  ///
  /// In en, this message translates to:
  /// **'Invalid weight value in set {number}.'**
  String valInvalidWeight(int number);

  /// No description provided for @valTooBigWeight.
  ///
  /// In en, this message translates to:
  /// **'Too big weight value in set {number}.'**
  String valTooBigWeight(int number);

  /// No description provided for @valBothWeightsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Both main weight value and weight value in set {number} are empty.'**
  String valBothWeightsEmpty(int number);

  /// No description provided for @valBothWeightsEmptyEdit.
  ///
  /// In en, this message translates to:
  /// **'Both last and current weight values in set {number} are empty.'**
  String valBothWeightsEmptyEdit(int number);

  /// No description provided for @valInvalidRir.
  ///
  /// In en, this message translates to:
  /// **'Invalid RIR value in set {number}.'**
  String valInvalidRir(int number);

  /// No description provided for @valTooBigRir.
  ///
  /// In en, this message translates to:
  /// **'Too big RIR value in set {number}.'**
  String valTooBigRir(int number);

  /// No description provided for @valNoSets.
  ///
  /// In en, this message translates to:
  /// **'Add some sets, what are you trying to save?'**
  String get valNoSets;

  /// No description provided for @valTooManySets.
  ///
  /// In en, this message translates to:
  /// **'Way too many sets, please finish this workout or stop playing with the app.'**
  String get valTooManySets;

  /// No description provided for @bodyEntriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Body Entries'**
  String get bodyEntriesTitle;

  /// No description provided for @bodyEntriesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading body entries.'**
  String get bodyEntriesLoadError;

  /// No description provided for @bodyEntriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No body entries found.'**
  String get bodyEntriesEmpty;

  /// No description provided for @bodyEntriesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Body Entry'**
  String get bodyEntriesAdd;

  /// No description provided for @bodyEntriesAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add New Entry'**
  String get bodyEntriesAddNew;

  /// No description provided for @bodyEntryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry'**
  String get bodyEntryDeleteTitle;

  /// No description provided for @bodyEntryDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this entry?'**
  String get bodyEntryDeleteBody;

  /// No description provided for @bodyEntryEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Body Entry'**
  String get bodyEntryEditTitle;

  /// No description provided for @bodyEntrySave.
  ///
  /// In en, this message translates to:
  /// **'Save Body Entry'**
  String get bodyEntrySave;

  /// No description provided for @bodyEntriesChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Body Entries Chart'**
  String get bodyEntriesChartTitle;

  /// No description provided for @invalidInputTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid input'**
  String get invalidInputTitle;

  /// No description provided for @provideValidWeight.
  ///
  /// In en, this message translates to:
  /// **'Please provide a valid weight.'**
  String get provideValidWeight;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Notification'**
  String get notificationsAdd;

  /// No description provided for @notificationsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading notifications.'**
  String get notificationsLoadError;

  /// No description provided for @weeklyPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly plans'**
  String get weeklyPlansTitle;

  /// No description provided for @weeklyPlansAdd.
  ///
  /// In en, this message translates to:
  /// **'Add weekly plan'**
  String get weeklyPlansAdd;

  /// No description provided for @weeklyPlansEmpty.
  ///
  /// In en, this message translates to:
  /// **'No weekly plans yet.'**
  String get weeklyPlansEmpty;

  /// No description provided for @weeklyPlansLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading weekly plans.'**
  String get weeklyPlansLoadError;

  /// No description provided for @weeklyPlanNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan name'**
  String get weeklyPlanNameLabel;

  /// No description provided for @weeklyPlanNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a plan name.'**
  String get weeklyPlanNameEmpty;

  /// No description provided for @weeklyPlanNameTaken.
  ///
  /// In en, this message translates to:
  /// **'A plan with this name already exists.'**
  String get weeklyPlanNameTaken;

  /// No description provided for @weeklyPlanSave.
  ///
  /// In en, this message translates to:
  /// **'Save plan'**
  String get weeklyPlanSave;

  /// No description provided for @weeklyPlanEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit weekly plan'**
  String get weeklyPlanEditTitle;

  /// No description provided for @weeklyPlanDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete weekly plan?'**
  String get weeklyPlanDeleteTitle;

  /// No description provided for @weeklyPlanDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This will remove the plan and its schedule.'**
  String get weeklyPlanDeleteBody;

  /// No description provided for @weeklyPlanRestDay.
  ///
  /// In en, this message translates to:
  /// **'Rest day'**
  String get weeklyPlanRestDay;

  /// No description provided for @weeklyPlanNoTrainings.
  ///
  /// In en, this message translates to:
  /// **'No trainings assigned'**
  String get weeklyPlanNoTrainings;

  /// No description provided for @weeklyPlanNoTrainingsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Create trainings first to build a weekly plan.'**
  String get weeklyPlanNoTrainingsAvailable;

  /// No description provided for @settingsWeeklyPlans.
  ///
  /// In en, this message translates to:
  /// **'Weekly plans'**
  String get settingsWeeklyPlans;

  /// No description provided for @settingsWeeklyPlansDescription.
  ///
  /// In en, this message translates to:
  /// **'Assign trainings to days of the week'**
  String get settingsWeeklyPlansDescription;

  /// No description provided for @notificationTraining.
  ///
  /// In en, this message translates to:
  /// **'Training: {name}'**
  String notificationTraining(String name);

  /// No description provided for @notificationTime.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String notificationTime(String time);

  /// No description provided for @selectTraining.
  ///
  /// In en, this message translates to:
  /// **'Select Training'**
  String get selectTraining;

  /// No description provided for @selectDay.
  ///
  /// In en, this message translates to:
  /// **'Select Day'**
  String get selectDay;

  /// No description provided for @notificationSave.
  ///
  /// In en, this message translates to:
  /// **'Save Notification'**
  String get notificationSave;

  /// No description provided for @notificationSaved.
  ///
  /// In en, this message translates to:
  /// **'Notification saved successfully'**
  String get notificationSaved;

  /// No description provided for @notificationReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Training Reminder'**
  String get notificationReminderTitle;

  /// No description provided for @chartTitle.
  ///
  /// In en, this message translates to:
  /// **'“{name}” chart'**
  String chartTitle(String name);

  /// No description provided for @chartLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get chartLoadError;

  /// No description provided for @chartOneRm.
  ///
  /// In en, this message translates to:
  /// **'1RM: {value} kg'**
  String chartOneRm(String value);

  /// No description provided for @chartWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight: {value} kg'**
  String chartWeight(String value);

  /// No description provided for @chartReps.
  ///
  /// In en, this message translates to:
  /// **'Reps: {value}'**
  String chartReps(int value);

  /// No description provided for @chartRir.
  ///
  /// In en, this message translates to:
  /// **'Reps in reserve: {value}'**
  String chartRir(int value);

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get daySunday;

  /// No description provided for @bodyPartFrontNeck.
  ///
  /// In en, this message translates to:
  /// **'Front Neck'**
  String get bodyPartFrontNeck;

  /// No description provided for @bodyPartBackNeck.
  ///
  /// In en, this message translates to:
  /// **'Back Neck'**
  String get bodyPartBackNeck;

  /// No description provided for @bodyPartTraps.
  ///
  /// In en, this message translates to:
  /// **'Traps'**
  String get bodyPartTraps;

  /// No description provided for @bodyPartFrontDelts.
  ///
  /// In en, this message translates to:
  /// **'Front Delts'**
  String get bodyPartFrontDelts;

  /// No description provided for @bodyPartSideDelts.
  ///
  /// In en, this message translates to:
  /// **'Side Delts'**
  String get bodyPartSideDelts;

  /// No description provided for @bodyPartRearDelts.
  ///
  /// In en, this message translates to:
  /// **'Rear Delts'**
  String get bodyPartRearDelts;

  /// No description provided for @bodyPartUpperBack.
  ///
  /// In en, this message translates to:
  /// **'Upper Back'**
  String get bodyPartUpperBack;

  /// No description provided for @bodyPartLowerBack.
  ///
  /// In en, this message translates to:
  /// **'Lower Back'**
  String get bodyPartLowerBack;

  /// No description provided for @bodyPartMiddleBack.
  ///
  /// In en, this message translates to:
  /// **'Middle Back'**
  String get bodyPartMiddleBack;

  /// No description provided for @bodyPartLats.
  ///
  /// In en, this message translates to:
  /// **'Lats'**
  String get bodyPartLats;

  /// No description provided for @bodyPartChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get bodyPartChest;

  /// No description provided for @bodyPartAbs.
  ///
  /// In en, this message translates to:
  /// **'Abs'**
  String get bodyPartAbs;

  /// No description provided for @bodyPartBiceps.
  ///
  /// In en, this message translates to:
  /// **'Biceps'**
  String get bodyPartBiceps;

  /// No description provided for @bodyPartTriceps.
  ///
  /// In en, this message translates to:
  /// **'Triceps'**
  String get bodyPartTriceps;

  /// No description provided for @bodyPartForearmFlexors.
  ///
  /// In en, this message translates to:
  /// **'Forearm Flexors'**
  String get bodyPartForearmFlexors;

  /// No description provided for @bodyPartForearmExtensors.
  ///
  /// In en, this message translates to:
  /// **'Forearm Extensors'**
  String get bodyPartForearmExtensors;

  /// No description provided for @bodyPartGlutes.
  ///
  /// In en, this message translates to:
  /// **'Glutes'**
  String get bodyPartGlutes;

  /// No description provided for @bodyPartQuads.
  ///
  /// In en, this message translates to:
  /// **'Quads'**
  String get bodyPartQuads;

  /// No description provided for @bodyPartHamstrings.
  ///
  /// In en, this message translates to:
  /// **'Hamstrings'**
  String get bodyPartHamstrings;

  /// No description provided for @bodyPartCalves.
  ///
  /// In en, this message translates to:
  /// **'Calves'**
  String get bodyPartCalves;

  /// No description provided for @bodyPartTibialis.
  ///
  /// In en, this message translates to:
  /// **'Tibialis'**
  String get bodyPartTibialis;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

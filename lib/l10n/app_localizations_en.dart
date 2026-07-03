// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Training Journal Pro';

  @override
  String get byAuthor => 'by Szymon Kopańko';

  @override
  String get navExercises => 'Exercises';

  @override
  String get navTrainings => 'Trainings';

  @override
  String get navBodyEntries => 'Body Entries';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navSettings => 'Settings';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonOk => 'OK';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonBack => 'Back';

  @override
  String get commonClose => 'Close';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'Error';

  @override
  String get commonSuccess => 'Success';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAddStarter => 'Add Starter Exercises';

  @override
  String get settingsAddStarterDoneTitle => 'Add Starter Exercises';

  @override
  String get settingsAddStarterDoneBody => 'Starter exercises have been added.';

  @override
  String get settingsLanguage => 'Change Language';

  @override
  String get settingsLanguageDescription => 'Choose application language';

  @override
  String get settingsMeasurement => 'Change Measurement System';

  @override
  String get settingsMeasurementDescription =>
      'Choose metric or imperial units';

  @override
  String get settingsTheme => 'Change Colors';

  @override
  String get settingsThemeDescription => 'Choose application theme';

  @override
  String get settingsDeleteAll => 'Delete All Data';

  @override
  String get settingsDeleteAllConfirmTitle => 'Delete All Data?';

  @override
  String get settingsDeleteAllConfirmBody =>
      'This action will delete all entries and exercises. Are you sure you want to proceed?';

  @override
  String get settingsDeleteAllConfirmAction => 'Delete All';

  @override
  String get settingsDeleteAllDone => 'All data has been deleted.';

  @override
  String get settingsExportData => 'Export Data';

  @override
  String get settingsExportDataDescription => 'Save all data to a JSON file';

  @override
  String get settingsExportDone => 'Data exported successfully.';

  @override
  String get settingsExportError => 'Export failed.';

  @override
  String get settingsImportData => 'Import Data';

  @override
  String get settingsImportDataDescription =>
      'Restore data from a JSON backup file';

  @override
  String get settingsImportConfirmTitle => 'Import Data?';

  @override
  String get settingsImportConfirmBody =>
      'Existing data will be merged with the backup (matching IDs will be replaced). Continue?';

  @override
  String get settingsImportDone => 'Data imported successfully.';

  @override
  String get settingsImportError => 'Import failed. Check file format.';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get languagePolish => 'Polski';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSystem => 'System';

  @override
  String get weightWord => 'Weight';

  @override
  String get repsWord => 'Reps';

  @override
  String get rirWord => 'RIR';

  @override
  String get oneRmWord => '1RM';

  @override
  String get setsWord => 'Sets';

  @override
  String get chartWord => 'Chart';

  @override
  String get notesLabel => 'Notes';

  @override
  String get exerciseNameLabel => 'Exercise Name';

  @override
  String get trainingNameLabel => 'Training Name';

  @override
  String get defaultWeightLabel => 'Default weight';

  @override
  String get enterWeightHint => 'Enter weight';

  @override
  String get enterDefaultWeightHint => 'Enter default weight';

  @override
  String get weightKgLabel => 'Weight (kg)';

  @override
  String get mainWeightKgLabel => 'Main Weight (kg)';

  @override
  String get dateLabel => 'Date:';

  @override
  String get timeLabel => 'Time:';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectTime => 'Select Time';

  @override
  String get selectExerciseLabel => 'Select Exercise';

  @override
  String get selectedBodyParts => 'Selected Body Parts:';

  @override
  String get availableBodyParts => 'Available Body Parts:';

  @override
  String get selectedExercises => 'Selected Exercises:';

  @override
  String get availableExercises => 'Available Exercises:';

  @override
  String get defaultRestTimeLabel => 'Default Rest Time:';

  @override
  String get bodyweightLiftedLabel => 'Bodyweight Lifted:';

  @override
  String labelNotes(String notes) {
    return 'Notes: $notes';
  }

  @override
  String labelDate(String date) {
    return 'Date: $date';
  }

  @override
  String pastValue(String value) {
    return 'Past: $value';
  }

  @override
  String weightKg(String weight) {
    return '$weight kg';
  }

  @override
  String hintDate(String date) {
    return 'Hint Date: $date';
  }

  @override
  String changePastHint(int number) {
    return 'Change Past Entry Hint ($number.)';
  }

  @override
  String get exercisesTitle => 'Exercises';

  @override
  String get exercisesSearch => 'Search Exercises';

  @override
  String get exercisesNoMatch => 'No matching exercises found.';

  @override
  String get exercisesEmpty => 'No exercises found, add some.';

  @override
  String get exercisesAdd => 'Add Exercise';

  @override
  String get exercisesEdit => 'Edit Exercise';

  @override
  String exercisesEditTitle(String name) {
    return 'Edit “$name” exercise';
  }

  @override
  String get exercisesNameRequired => 'Please enter an exercise name.';

  @override
  String get exercisesDeleteTitle => 'Delete Exercise?';

  @override
  String exercisesDeleteBody(String name) {
    return 'This action will delete all entries for this exercise ($name) with it. Are you sure you want to proceed?';
  }

  @override
  String get exercisesDeleteConfirm => 'Delete Exercise';

  @override
  String exercisesOneRepMax(String oneRM, String weight, int reps) {
    return 'One Rep Max: $oneRM kg ($weight kg x $reps reps)';
  }

  @override
  String exercisesDateTime(String date) {
    return 'Date and time: $date';
  }

  @override
  String exercisesBodyParts(String parts) {
    return 'Body Parts: $parts';
  }

  @override
  String exercisesDefaultRestTime(String time) {
    return 'Default rest time: $time';
  }

  @override
  String exercisesBodyweightLifted(int percentage) {
    return 'Bodyweight lifted: $percentage %';
  }

  @override
  String get tooltipAddEntry => 'Add Entry';

  @override
  String get tooltipShowEntries => 'Show Entries';

  @override
  String get restTimeTitle => 'Select Rest Time';

  @override
  String restMinutes(int count) {
    return 'Minutes: $count';
  }

  @override
  String restSeconds(int count) {
    return 'Seconds: $count';
  }

  @override
  String restMinutesLabel(int count) {
    return '$count minutes';
  }

  @override
  String restSecondsLabel(int count) {
    return '$count seconds';
  }

  @override
  String get bodyweightPctTitle => 'Select Bodyweight Percentage';

  @override
  String get selectTimeTitle => 'Select Time';

  @override
  String get trainingsTitle => 'Trainings';

  @override
  String get trainingsSearch => 'Search Trainings';

  @override
  String get trainingsNoMatch => 'No matching trainings found.';

  @override
  String get trainingsEmpty => 'No trainings found, add some.';

  @override
  String get trainingsNoExercises =>
      'No exercises found, add some before creating trainings.';

  @override
  String get trainingsAdd => 'Add Training';

  @override
  String get trainingsSave => 'Save Training';

  @override
  String trainingsEditTitle(String name) {
    return 'Edit “$name” training';
  }

  @override
  String get trainingsDeleteTitle => 'Delete Training?';

  @override
  String trainingsDeleteBody(String name) {
    return 'This action will delete all entries for this training ($name) with it. Are you sure you want to proceed?';
  }

  @override
  String get trainingsDeleteConfirm => 'Delete Training';

  @override
  String get trainingsAddEntries => 'Add Training Entries';

  @override
  String get trainingsNameTaken => 'This training name is already taken.';

  @override
  String get trainingsNameEmpty => 'Training name cannot be empty.';

  @override
  String get trainingsSelectAtLeastOne =>
      'Select at least one exercise for the training.';

  @override
  String get trainingsNoBodyPartsAssigned => 'No body parts assigned';

  @override
  String trainingExerciseWithParts(String name, String parts) {
    return '$name ($parts)';
  }

  @override
  String entryAddTitle(String name) {
    return 'Add “$name” entry';
  }

  @override
  String entryAddEntriesTitle(String name) {
    return 'Add “$name” entries';
  }

  @override
  String entryEditTitle(String name) {
    return 'Edit “$name” entry';
  }

  @override
  String entriesHistoryTitle(String name) {
    return '“$name” history';
  }

  @override
  String get entriesEmpty => 'Add some entries to see some data here.';

  @override
  String get entryDeleted => 'Entry deleted successfully';

  @override
  String get tooltipEditEntry => 'Edit Entry';

  @override
  String get tooltipDeleteEntry => 'Delete Entry';

  @override
  String get showChart => 'Show Chart';

  @override
  String get timerEnded => 'Timer ended!';

  @override
  String get valInvalidMainWeight => 'Invalid main weight value.';

  @override
  String get valTooBigMainWeight => 'Too big main weight value.';

  @override
  String valInvalidReps(int number) {
    return 'Invalid reps value in set $number.';
  }

  @override
  String valTooManyReps(int number) {
    return 'Too many reps value in set $number.';
  }

  @override
  String valEmptyReps(int number) {
    return 'Empty reps controller and no historical set available at set $number in chosen historical entry.';
  }

  @override
  String valInvalidWeight(int number) {
    return 'Invalid weight value in set $number.';
  }

  @override
  String valTooBigWeight(int number) {
    return 'Too big weight value in set $number.';
  }

  @override
  String valBothWeightsEmpty(int number) {
    return 'Both main weight value and weight value in set $number are empty.';
  }

  @override
  String valBothWeightsEmptyEdit(int number) {
    return 'Both last and current weight values in set $number are empty.';
  }

  @override
  String valInvalidRir(int number) {
    return 'Invalid RIR value in set $number.';
  }

  @override
  String valTooBigRir(int number) {
    return 'Too big RIR value in set $number.';
  }

  @override
  String get valNoSets => 'Add some sets, what are you trying to save?';

  @override
  String get valTooManySets =>
      'Way too many sets, please finish this workout or stop playing with the app.';

  @override
  String get bodyEntriesTitle => 'Body Entries';

  @override
  String get bodyEntriesLoadError => 'Error loading body entries.';

  @override
  String get bodyEntriesEmpty => 'No body entries found.';

  @override
  String get bodyEntriesAdd => 'Add Body Entry';

  @override
  String get bodyEntriesAddNew => 'Add New Entry';

  @override
  String get bodyEntryDeleteTitle => 'Delete Entry';

  @override
  String get bodyEntryDeleteBody =>
      'Are you sure you want to delete this entry?';

  @override
  String get bodyEntryEditTitle => 'Edit Body Entry';

  @override
  String get bodyEntrySave => 'Save Body Entry';

  @override
  String get bodyEntriesChartTitle => 'Body Entries Chart';

  @override
  String get invalidInputTitle => 'Invalid input';

  @override
  String get provideValidWeight => 'Please provide a valid weight.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsAdd => 'Add Notification';

  @override
  String notificationTraining(String name) {
    return 'Training: $name';
  }

  @override
  String notificationTime(String time) {
    return 'Time: $time';
  }

  @override
  String get selectTraining => 'Select Training';

  @override
  String get selectDay => 'Select Day';

  @override
  String get notificationSave => 'Save Notification';

  @override
  String get notificationSaved => 'Notification saved successfully';

  @override
  String get notificationReminderTitle => 'Training Reminder';

  @override
  String chartTitle(String name) {
    return '“$name” chart';
  }

  @override
  String get chartLoadError => 'Error loading data';

  @override
  String chartOneRm(String value) {
    return '1RM: $value kg';
  }

  @override
  String chartWeight(String value) {
    return 'Weight: $value kg';
  }

  @override
  String chartReps(int value) {
    return 'Reps: $value';
  }

  @override
  String chartRir(int value) {
    return 'Reps in reserve: $value';
  }

  @override
  String get dayMonday => 'Monday';

  @override
  String get dayTuesday => 'Tuesday';

  @override
  String get dayWednesday => 'Wednesday';

  @override
  String get dayThursday => 'Thursday';

  @override
  String get dayFriday => 'Friday';

  @override
  String get daySaturday => 'Saturday';

  @override
  String get daySunday => 'Sunday';

  @override
  String get bodyPartFrontNeck => 'Front Neck';

  @override
  String get bodyPartBackNeck => 'Back Neck';

  @override
  String get bodyPartTraps => 'Traps';

  @override
  String get bodyPartFrontDelts => 'Front Delts';

  @override
  String get bodyPartSideDelts => 'Side Delts';

  @override
  String get bodyPartRearDelts => 'Rear Delts';

  @override
  String get bodyPartUpperBack => 'Upper Back';

  @override
  String get bodyPartLowerBack => 'Lower Back';

  @override
  String get bodyPartMiddleBack => 'Middle Back';

  @override
  String get bodyPartLats => 'Lats';

  @override
  String get bodyPartChest => 'Chest';

  @override
  String get bodyPartAbs => 'Abs';

  @override
  String get bodyPartBiceps => 'Biceps';

  @override
  String get bodyPartTriceps => 'Triceps';

  @override
  String get bodyPartForearmFlexors => 'Forearm Flexors';

  @override
  String get bodyPartForearmExtensors => 'Forearm Extensors';

  @override
  String get bodyPartGlutes => 'Glutes';

  @override
  String get bodyPartQuads => 'Quads';

  @override
  String get bodyPartHamstrings => 'Hamstrings';

  @override
  String get bodyPartCalves => 'Calves';

  @override
  String get bodyPartTibialis => 'Tibialis';
}

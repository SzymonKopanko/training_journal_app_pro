// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Training Journal Pro';

  @override
  String get byAuthor => 'autor: Szymon Kopańko';

  @override
  String get navExercises => 'Ćwiczenia';

  @override
  String get navTrainings => 'Treningi';

  @override
  String get navBodyEntries => 'Pomiary ciała';

  @override
  String get navNotifications => 'Powiadomienia';

  @override
  String get navSettings => 'Ustawienia';

  @override
  String get commonSave => 'Zapisz';

  @override
  String get commonCancel => 'Anuluj';

  @override
  String get commonDelete => 'Usuń';

  @override
  String get commonEdit => 'Edytuj';

  @override
  String get commonAdd => 'Dodaj';

  @override
  String get commonOk => 'OK';

  @override
  String get commonYes => 'Tak';

  @override
  String get commonNo => 'Nie';

  @override
  String get commonConfirm => 'Potwierdź';

  @override
  String get commonBack => 'Wstecz';

  @override
  String get commonClose => 'Zamknij';

  @override
  String get commonLoading => 'Ładowanie...';

  @override
  String get commonError => 'Błąd';

  @override
  String get commonSuccess => 'Sukces';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsAddStarter => 'Dodaj ćwiczenia startowe';

  @override
  String get settingsAddStarterDoneTitle => 'Dodaj ćwiczenia startowe';

  @override
  String get settingsAddStarterDoneBody => 'Ćwiczenia startowe zostały dodane.';

  @override
  String get settingsLanguage => 'Zmień język';

  @override
  String get settingsLanguageDescription => 'Wybierz język aplikacji';

  @override
  String get settingsMeasurement => 'Zmień system miar';

  @override
  String get settingsMeasurementDescription =>
      'Wybierz jednostki metryczne lub imperialne';

  @override
  String get settingsTheme => 'Zmień motyw';

  @override
  String get settingsThemeDescription => 'Wybierz motyw aplikacji';

  @override
  String get settingsDeleteAll => 'Usuń wszystkie dane';

  @override
  String get settingsDeleteAllConfirmTitle => 'Usunąć wszystkie dane?';

  @override
  String get settingsDeleteAllConfirmBody =>
      'Ta operacja usunie wszystkie wpisy i ćwiczenia. Czy na pewno chcesz kontynuować?';

  @override
  String get settingsDeleteAllConfirmAction => 'Usuń wszystko';

  @override
  String get settingsDeleteAllDone => 'Wszystkie dane zostały usunięte.';

  @override
  String get settingsExportData => 'Eksport danych';

  @override
  String get settingsExportDataDescription =>
      'Zapisz wszystkie dane do pliku JSON';

  @override
  String get settingsExportDone => 'Dane wyeksportowane pomyślnie.';

  @override
  String get settingsExportError => 'Eksport nie powiódł się.';

  @override
  String get settingsImportData => 'Import danych';

  @override
  String get settingsImportDataDescription =>
      'Przywróć dane z kopii zapasowej JSON';

  @override
  String get settingsImportConfirmTitle => 'Importować dane?';

  @override
  String get settingsImportConfirmBody =>
      'Istniejące dane zostaną scalone z kopią (pasujące ID zostaną zastąpione). Kontynuować?';

  @override
  String get settingsImportDone => 'Dane zaimportowane pomyślnie.';

  @override
  String get settingsImportError =>
      'Import nie powiódł się. Sprawdź format pliku.';

  @override
  String get themeLight => 'Jasny';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get themeSystem => 'Systemowy';

  @override
  String get languagePolish => 'Polski';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSystem => 'Systemowy';

  @override
  String get weightWord => 'Waga';

  @override
  String get repsWord => 'Powt.';

  @override
  String get rirWord => 'RIR';

  @override
  String get oneRmWord => '1RM';

  @override
  String get setsWord => 'Serie';

  @override
  String get chartWord => 'Wykres';

  @override
  String get notesLabel => 'Notatki';

  @override
  String get exerciseNameLabel => 'Nazwa ćwiczenia';

  @override
  String get trainingNameLabel => 'Nazwa treningu';

  @override
  String get defaultWeightLabel => 'Domyślna waga';

  @override
  String get enterWeightHint => 'Podaj wagę';

  @override
  String get enterDefaultWeightHint => 'Podaj domyślną wagę';

  @override
  String get weightKgLabel => 'Waga (kg)';

  @override
  String get mainWeightKgLabel => 'Waga główna (kg)';

  @override
  String get dateLabel => 'Data:';

  @override
  String get timeLabel => 'Godzina:';

  @override
  String get selectDate => 'Wybierz datę';

  @override
  String get selectTime => 'Wybierz godzinę';

  @override
  String get selectExerciseLabel => 'Wybierz ćwiczenie';

  @override
  String get selectedBodyParts => 'Wybrane partie ciała:';

  @override
  String get availableBodyParts => 'Dostępne partie ciała:';

  @override
  String get selectedExercises => 'Wybrane ćwiczenia:';

  @override
  String get availableExercises => 'Dostępne ćwiczenia:';

  @override
  String get defaultRestTimeLabel => 'Domyślny czas przerwy:';

  @override
  String get bodyweightLiftedLabel => 'Podnoszona masa ciała:';

  @override
  String labelNotes(String notes) {
    return 'Notatki: $notes';
  }

  @override
  String labelDate(String date) {
    return 'Data: $date';
  }

  @override
  String pastValue(String value) {
    return 'Poprzednio: $value';
  }

  @override
  String weightKg(String weight) {
    return '$weight kg';
  }

  @override
  String hintDate(String date) {
    return 'Data podpowiedzi: $date';
  }

  @override
  String changePastHint(int number) {
    return 'Zmień podpowiedź z poprzedniego wpisu ($number.)';
  }

  @override
  String get exercisesTitle => 'Ćwiczenia';

  @override
  String get exercisesSearch => 'Szukaj ćwiczeń';

  @override
  String get exercisesNoMatch => 'Nie znaleziono pasujących ćwiczeń.';

  @override
  String get exercisesEmpty => 'Brak ćwiczeń, dodaj jakieś.';

  @override
  String get exercisesAdd => 'Dodaj ćwiczenie';

  @override
  String get exercisesEdit => 'Edytuj ćwiczenie';

  @override
  String exercisesEditTitle(String name) {
    return 'Edytuj ćwiczenie „$name”';
  }

  @override
  String get exercisesNameRequired => 'Podaj nazwę ćwiczenia.';

  @override
  String get exercisesDeleteTitle => 'Usunąć ćwiczenie?';

  @override
  String exercisesDeleteBody(String name) {
    return 'Ta operacja usunie także wszystkie wpisy dla tego ćwiczenia ($name). Czy na pewno chcesz kontynuować?';
  }

  @override
  String get exercisesDeleteConfirm => 'Usuń ćwiczenie';

  @override
  String exercisesOneRepMax(String oneRM, String weight, int reps) {
    return 'Ciężar maksymalny: $oneRM kg ($weight kg x $reps powt.)';
  }

  @override
  String exercisesDateTime(String date) {
    return 'Data i godzina: $date';
  }

  @override
  String exercisesBodyParts(String parts) {
    return 'Partie ciała: $parts';
  }

  @override
  String exercisesDefaultRestTime(String time) {
    return 'Domyślny czas przerwy: $time';
  }

  @override
  String exercisesBodyweightLifted(int percentage) {
    return 'Podnoszona masa ciała: $percentage %';
  }

  @override
  String get tooltipAddEntry => 'Dodaj wpis';

  @override
  String get tooltipShowEntries => 'Pokaż wpisy';

  @override
  String get restTimeTitle => 'Wybierz czas przerwy';

  @override
  String restMinutes(int count) {
    return 'Minuty: $count';
  }

  @override
  String restSeconds(int count) {
    return 'Sekundy: $count';
  }

  @override
  String restMinutesLabel(int count) {
    return '$count min';
  }

  @override
  String restSecondsLabel(int count) {
    return '$count s';
  }

  @override
  String get bodyweightPctTitle => 'Wybierz procent masy ciała';

  @override
  String get selectTimeTitle => 'Wybierz czas';

  @override
  String get trainingsTitle => 'Treningi';

  @override
  String get trainingsSearch => 'Szukaj treningów';

  @override
  String get trainingsNoMatch => 'Nie znaleziono pasujących treningów.';

  @override
  String get trainingsEmpty => 'Brak treningów, dodaj jakieś.';

  @override
  String get trainingsNoExercises =>
      'Brak ćwiczeń — dodaj jakieś przed utworzeniem treningów.';

  @override
  String get trainingsAdd => 'Dodaj trening';

  @override
  String get trainingsSave => 'Zapisz trening';

  @override
  String trainingsEditTitle(String name) {
    return 'Edytuj trening „$name”';
  }

  @override
  String get trainingsDeleteTitle => 'Usunąć trening?';

  @override
  String trainingsDeleteBody(String name) {
    return 'Ta operacja usunie także wszystkie wpisy dla tego treningu ($name). Czy na pewno chcesz kontynuować?';
  }

  @override
  String get trainingsDeleteConfirm => 'Usuń trening';

  @override
  String get trainingsAddEntries => 'Dodaj wpisy treningu';

  @override
  String get trainingsNameTaken => 'Ta nazwa treningu jest już zajęta.';

  @override
  String get trainingsNameEmpty => 'Nazwa treningu nie może być pusta.';

  @override
  String get trainingsSelectAtLeastOne =>
      'Wybierz co najmniej jedno ćwiczenie do treningu.';

  @override
  String get trainingsNoBodyPartsAssigned => 'brak przypisanych partii ciała';

  @override
  String trainingExerciseWithParts(String name, String parts) {
    return '$name ($parts)';
  }

  @override
  String entryAddTitle(String name) {
    return 'Dodaj wpis „$name”';
  }

  @override
  String entryAddEntriesTitle(String name) {
    return 'Dodaj wpisy „$name”';
  }

  @override
  String entryEditTitle(String name) {
    return 'Edytuj wpis „$name”';
  }

  @override
  String entriesHistoryTitle(String name) {
    return 'Historia „$name”';
  }

  @override
  String get entriesEmpty => 'Dodaj wpisy, aby zobaczyć tutaj dane.';

  @override
  String get entryDeleted => 'Wpis został usunięty';

  @override
  String get tooltipEditEntry => 'Edytuj wpis';

  @override
  String get tooltipDeleteEntry => 'Usuń wpis';

  @override
  String get showChart => 'Pokaż wykres';

  @override
  String get timerEnded => 'Koniec czasu!';

  @override
  String get valInvalidMainWeight => 'Nieprawidłowa wartość wagi głównej.';

  @override
  String get valTooBigMainWeight => 'Zbyt duża wartość wagi głównej.';

  @override
  String valInvalidReps(int number) {
    return 'Nieprawidłowa liczba powtórzeń w serii $number.';
  }

  @override
  String valTooManyReps(int number) {
    return 'Zbyt duża liczba powtórzeń w serii $number.';
  }

  @override
  String valEmptyReps(int number) {
    return 'Puste pole powtórzeń i brak historycznej serii w serii $number w wybranym wpisie historycznym.';
  }

  @override
  String valInvalidWeight(int number) {
    return 'Nieprawidłowa wartość wagi w serii $number.';
  }

  @override
  String valTooBigWeight(int number) {
    return 'Zbyt duża wartość wagi w serii $number.';
  }

  @override
  String valBothWeightsEmpty(int number) {
    return 'Zarówno waga główna, jak i waga w serii $number są puste.';
  }

  @override
  String valBothWeightsEmptyEdit(int number) {
    return 'Zarówno poprzednia, jak i obecna wartość wagi w serii $number są puste.';
  }

  @override
  String valInvalidRir(int number) {
    return 'Nieprawidłowa wartość RIR w serii $number.';
  }

  @override
  String valTooBigRir(int number) {
    return 'Zbyt duża wartość RIR w serii $number.';
  }

  @override
  String get valNoSets => 'Dodaj jakieś serie — co próbujesz zapisać?';

  @override
  String get valTooManySets =>
      'Zdecydowanie za dużo serii — dokończ ten trening albo przestań bawić się aplikacją.';

  @override
  String get bodyEntriesTitle => 'Pomiary ciała';

  @override
  String get bodyEntriesLoadError => 'Błąd ładowania pomiarów ciała.';

  @override
  String get bodyEntriesEmpty => 'Brak pomiarów ciała.';

  @override
  String get bodyEntriesAdd => 'Dodaj pomiar ciała';

  @override
  String get bodyEntriesAddNew => 'Dodaj nowy wpis';

  @override
  String get bodyEntryDeleteTitle => 'Usuń wpis';

  @override
  String get bodyEntryDeleteBody => 'Czy na pewno chcesz usunąć ten wpis?';

  @override
  String get bodyEntryEditTitle => 'Edytuj pomiar ciała';

  @override
  String get bodyEntrySave => 'Zapisz pomiar ciała';

  @override
  String get bodyEntriesChartTitle => 'Wykres pomiarów ciała';

  @override
  String get invalidInputTitle => 'Nieprawidłowe dane';

  @override
  String get provideValidWeight => 'Podaj prawidłową wagę.';

  @override
  String get notificationsTitle => 'Powiadomienia';

  @override
  String get notificationsAdd => 'Dodaj powiadomienie';

  @override
  String get notificationsLoadError => 'Błąd ładowania powiadomień.';

  @override
  String get weeklyPlansTitle => 'Plany tygodniowe';

  @override
  String get weeklyPlansAdd => 'Dodaj plan tygodniowy';

  @override
  String get weeklyPlansEmpty => 'Brak planów tygodniowych.';

  @override
  String get weeklyPlansLoadError => 'Błąd ładowania planów tygodniowych.';

  @override
  String get weeklyPlanNameLabel => 'Nazwa planu';

  @override
  String get weeklyPlanNameEmpty => 'Podaj nazwę planu.';

  @override
  String get weeklyPlanNameTaken => 'Plan o tej nazwie już istnieje.';

  @override
  String get weeklyPlanSave => 'Zapisz plan';

  @override
  String get weeklyPlanEditTitle => 'Edytuj plan tygodniowy';

  @override
  String get weeklyPlanDeleteTitle => 'Usunąć plan tygodniowy?';

  @override
  String get weeklyPlanDeleteBody =>
      'Plan i jego harmonogram zostaną usunięte.';

  @override
  String get weeklyPlanRestDay => 'Dzień wolny';

  @override
  String get weeklyPlanNoTrainings => 'Brak przypisanych treningów';

  @override
  String get weeklyPlanNoTrainingsAvailable =>
      'Najpierw utwórz treningi, aby zbudować plan tygodniowy.';

  @override
  String get settingsWeeklyPlans => 'Plany tygodniowe';

  @override
  String get settingsWeeklyPlansDescription =>
      'Przypisz treningi do dni tygodnia';

  @override
  String notificationTraining(String name) {
    return 'Trening: $name';
  }

  @override
  String notificationTime(String time) {
    return 'Godzina: $time';
  }

  @override
  String get selectTraining => 'Wybierz trening';

  @override
  String get selectDay => 'Wybierz dzień';

  @override
  String get notificationSave => 'Zapisz powiadomienie';

  @override
  String get notificationSaved => 'Powiadomienie zostało zapisane';

  @override
  String get notificationReminderTitle => 'Przypomnienie o treningu';

  @override
  String chartTitle(String name) {
    return 'Wykres „$name”';
  }

  @override
  String get chartLoadError => 'Błąd ładowania danych';

  @override
  String chartOneRm(String value) {
    return '1RM: $value kg';
  }

  @override
  String chartWeight(String value) {
    return 'Waga: $value kg';
  }

  @override
  String chartReps(int value) {
    return 'Powtórzenia: $value';
  }

  @override
  String chartRir(int value) {
    return 'Powtórzenia w zapasie: $value';
  }

  @override
  String get dayMonday => 'Poniedziałek';

  @override
  String get dayTuesday => 'Wtorek';

  @override
  String get dayWednesday => 'Środa';

  @override
  String get dayThursday => 'Czwartek';

  @override
  String get dayFriday => 'Piątek';

  @override
  String get daySaturday => 'Sobota';

  @override
  String get daySunday => 'Niedziela';

  @override
  String get bodyPartFrontNeck => 'Przód szyi';

  @override
  String get bodyPartBackNeck => 'Tył szyi';

  @override
  String get bodyPartTraps => 'Kaptury';

  @override
  String get bodyPartFrontDelts => 'Przednie aktony barków';

  @override
  String get bodyPartSideDelts => 'Boczne aktony barków';

  @override
  String get bodyPartRearDelts => 'Tylne aktony barków';

  @override
  String get bodyPartUpperBack => 'Górna część pleców';

  @override
  String get bodyPartLowerBack => 'Dolna część pleców';

  @override
  String get bodyPartMiddleBack => 'Środkowa część pleców';

  @override
  String get bodyPartLats => 'Najszersze grzbietu';

  @override
  String get bodyPartChest => 'Klatka piersiowa';

  @override
  String get bodyPartAbs => 'Brzuch';

  @override
  String get bodyPartBiceps => 'Biceps';

  @override
  String get bodyPartTriceps => 'Triceps';

  @override
  String get bodyPartForearmFlexors => 'Zginacze przedramion';

  @override
  String get bodyPartForearmExtensors => 'Prostowniki przedramion';

  @override
  String get bodyPartGlutes => 'Pośladki';

  @override
  String get bodyPartQuads => 'Czworogłowe ud';

  @override
  String get bodyPartHamstrings => 'Dwugłowe ud';

  @override
  String get bodyPartCalves => 'Łydki';

  @override
  String get bodyPartTibialis => 'Piszczelowe';
}

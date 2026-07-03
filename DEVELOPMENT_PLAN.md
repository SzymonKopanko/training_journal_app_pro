# Plan rozwoju: Training Journal Pro (Flutter) jako aplikacja docelowa

Dokument porównuje dwie aplikacje o tej samej domenie (dziennik treningowy) i opisuje,
co przenieść do wersji Flutter (aplikacja docelowa) z wersji React Native
(`TrainingJournalApp`), jak załatać własne braki Fluttera oraz w jakiej kolejności to robić.

- **Aplikacja docelowa:** Training Journal Pro (Flutter, MVC + SQLite)
- **Aplikacja źródłowa (do zapożyczeń):** TrainingJournalApp (React Native, WatermelonDB)

**Legenda statusów:** `[ZROBIONE]` — zweryfikowane w kodzie · `[W TOKU]` — częściowo · `[DO ZROBIENIA]` — brak w kodzie.

> Aktualizacja: Faza 0 (bugfixy C1 + mechanizm migracji C3) została ukończona i zweryfikowana
> w bieżącym kodzie. Szczegóły przy poszczególnych punktach poniżej.

> **Postęp — Faza 1 — [ZROBIONE]:** i18n PL/EN, motyw light/dark/system, fundament Riverpod.
> - B1/B2: wszystkie ekrany na `AppLocalizations`, wybór języka i motywu w Settings (reaktywnie + `shared_preferences`).
> - B3: `database_providers.dart` (serwisy), `exercises_provider`, `trainings_provider`,
>   `body_entries_provider`; zmigrowane listy: `show_exercises`, `show_trainings`, `show_body_entries`.
> - Naprawa race condition w `JournalDatabase` (współdzielony `_openingDatabase`).
> - C5 (częściowo): usunięto `duration_picker`, debug `print` w DB/seed, ujednolicono `Glute` w seedzie.
> - Weryfikacja: `flutter pub get`, `gen-l10n`, `flutter analyze`, uruchomienie na urządzeniu Android.
>
> **Następna faza (Faza 3):** C4 plany tygodniowe, B4 role grup mięśniowych.

---

## A. Punkt wyjścia — co Flutter już ma dobrze

Zostawiamy bez zmian (to przewaga Fluttera):

- Powiadomienia tygodniowe (recurring, per dzień tygodnia)
- Timer przerwy z dźwiękiem + font cyfrowy DSEG7
- Zaawansowany kalkulator 1RM (mapa % dla 1–30 powtórzeń) + korekta bodyweight
- Podpowiedzi z ostatnich 7 sesji (rotacja)
- Domyślny czas przerwy i % masy ciała per ćwiczenie
- Interaktywne wykresy (biblioteka)
- Cross-platform DB (Android + Windows FFI)

---

## B. Co przenieść z React Native → Flutter

### B1. Pełne i18n (PL/EN) — priorytet wysoki — **[ZROBIONE]**

RN ma gotowe słowniki `Translations.ts` (PL) i `EnglishTranslations.ts` (EN).
We Flutterze teksty są hardcoded po angielsku, a w Settings jest tylko pusty placeholder `_changeLanguage`.

Do zrobienia:

- Wdrożyć `flutter_localizations` + pliki `.arb` (`app_en.arb`, `app_pl.arb`).
- Przenieść treść tłumaczeń z plików RN (są kompletne — przepisać klucze do formatu ARB).
- Podpiąć wybór języka w `settings_screen.dart` + zapis preferencji (`shared_preferences`).
- Zlokalizować locale w date/time pickerach (obecnie sztywno `en_GB`).

Uwaga: w RN i18n dla grup mięśniowych było niedokończone (enumy zawsze po polsku) —
we Flutterze zrobić od razu poprawnie (21 partii ciała jako klucze tłumaczeń).

### B2. Przełącznik motywu light/dark/system — priorytet średni — **[ZROBIONE]**

RN ma pełny `ThemeContext` (light/dark/system + zapis w AsyncStorage).
Flutter adaptuje się tylko automatycznie do systemu, a w Settings `_changeColors` to placeholder.

Do zrobienia:

- Dodać enum trybu motywu i zapis w `shared_preferences`.
- Podpiąć przełącznik w Settings (wzór 3-opcyjny jak w RN).
- Owinąć `MaterialApp` reaktywnym stanem motywu (patrz B3 — state management).

### B3. Architektura: state management + reaktywność — priorytet wysoki (fundament) — **[W TOKU]** (fundament + listy główne; pozostałe ekrany nadal wołają serwisy bezpośrednio)

Flutter woła serwisy bezpośrednio z ekranów przez `setState`, bez globalnego stanu
i bez reaktywności między ekranami. RN pokazuje wzorzec: konteksty + custom hooki + fasada serwisów.

Do zrobienia (odpowiednik Flutter):

- Wprowadzić **Riverpod** (rekomendacja — czystszy, testowalny) lub Provider.
- Wydzielić providery per domena: exercises, trainings, entries, body entries, settings (motyw + język).
- Zachować istniejące serwisy jako warstwę repozytorium pod providerami.

### B4. Rozdzielenie roli grup mięśniowych (Primary/Secondary) — priorytet niski — **[DO ZROBIENIA]**

RN rozróżnia rolę grupy mięśniowej w ćwiczeniu (Primary/Secondary),
Flutter ma płaskie M:N bez roli.

Do zrobienia:

- Dodać kolumnę `role` do `exercise_body_part_relations` (wymaga migracji — patrz C3).
- Zaktualizować UI edycji ćwiczenia i kolorowanie chipów wg roli.

### B5. Testy — priorytet średni — **[DO ZROBIENIA]**

RN ma 17 plików testów (serwisy, schema, utils). Flutter ma pusty `widget_test.dart`.

Do zrobienia:

- Dodać testy jednostkowe warstwy serwisów (CRUD, `calculateOneRM`).
- Następnie widget/integration testy kluczowych flow.

---

## C. Załatanie własnych braków Fluttera (niezależnie od RN)

### C1. Naprawa istniejących bugów — priorytet krytyczny (najpierw) — **[ZROBIONE]**

Wszystkie cztery bugi zostały naprawione i zweryfikowane w kodzie:

- **[ZROBIONE]** `add_entry.dart` (linia 292): warunek to teraz
  `widget.chosenTrainingWithExercises.exercises.length == 1` — poprawnie odwołuje się
  do listy ćwiczeń treningu, a nie do stałej string. (Wcześniej: `exercises.length == 1`
  na stałej string.)
- **[ZROBIONE]** `deleteExerciseFromBodyPart` w `ExerciseService` — usuwa z
  `exercise_body_part_relations` (poprawna tabela).
- **[ZROBIONE]** `readAllExercisesByTraining` — zawiera `ORDER BY r.placement ASC`,
  kolejność ćwiczeń w planie jest respektowana przy odczycie.
- **[ZROBIONE]** `BodyEntry.dateTime` — migracja v2 przebudowała kolumnę z `INTEGER`
  na `TEXT`, spójnie z ISO8601 string w modelu (patrz C3).

### C2. Export / import / backup danych — priorytet wysoki (brak w obu apkach) — **[ZROBIONE]**

- **[ZROBIONE]** `DataBackupService` — eksport/import JSON (wszystkie tabele).
- **[ZROBIONE]** UI w Settings: eksport (share sheet) + import (file picker) z walidacją formatu.
- Do rozważenia później: surowy backup pliku `training.db`.

### C3. Migracje bazy — priorytet wysoki (fundament pod resztę) — **[ZROBIONE]**

Mechanizm migracji jest wdrożony i zweryfikowany w `journal_database.dart`:

- **[ZROBIONE]** `_databaseVersion = 2`, `openDatabase` z `onCreate` + `onUpgrade`
  + `onConfigure` (wymuszenie `PRAGMA foreign_keys = ON` przy każdym otwarciu).
- **[ZROBIONE]** `_onUpgrade` uruchamia migracje kolejno wg wersji startowej
  (`if (oldVersion < 2) _migrateToV2`).
- **[ZROBIONE]** Strategia zachowawcza: `_migrateToV2` przebudowuje `body_entries`
  (INTEGER→TEXT dla `date_time`) z zachowaniem danych, bez destrukcyjnych zmian
  na tabelach z przychodzącymi kluczami obcymi.

Do zrobienia przy kolejnych zmianach schematu (B4 `role`, C4 plany tygodniowe):
dopisać `if (oldVersion < 3) ...` z addytywnymi `ALTER TABLE`.

### C4. Plany tygodniowe — priorytet średni (planowane w obu, w żadnej nie zrobione) — **[DO ZROBIENIA]**

Z dokumentu `baza danych trening.txt`: brakuje `weekly_plans`
i `trainings_to_weekly_plan_relation`.

- Dodać tabele (przez migrację z C3).
- Ekran tworzenia planu tygodniowego (przypisanie treningów do dni).
- Integracja z powiadomieniami (spięcie planu tygodniowego z recurring notifications).

### C5. Porządki — priorytet niski — **[DO ZROBIENIA]**

- **[ZROBIONE]** `duration_picker` usunięty z `pubspec.yaml` (nieużywany).
- **[ZROBIONE]** Debug `print` w `_createDB`, `readExerciseByName`, `readBodyPartByName` → `debugPrint` lub usunięte.
- **[ZROBIONE]** Niespójność `Glute`/`Glutes` w seedzie — kanoniczna nazwa `'Glute'`, helper mapuje oba warianty.

---

## D. Proponowana kolejność wdrożenia (fazy)

**Faza 0 — Stabilizacja — [ZROBIONE]:**

- C1 (bugfixy) + C3 (mechanizm migracji). Ukończone i zweryfikowane w kodzie.
  Fundament pod kolejne fazy jest gotowy. **Kolejny krok: Faza 1.**

**Faza 1 — Fundament architektury — [ZROBIONE]:**

- B3-min (kontroler ustawień) + B1 (i18n) + B2 (motyw) + B3 (providery list głównych).
- **Kolejny krok: Faza 2 (C2 export/import).**

**Faza 2 — Wartość dla użytkownika:**

- B1 (i18n PL/EN), B2 (motyw), C2 (export/import).

**Faza 3 — Nowe funkcje:**

- C4 (plany tygodniowe + spięcie z powiadomieniami), B4 (role grup mięśniowych).

**Faza 4 — Jakość:**

- B5 (testy), C5 (porządki, edycja powiadomień).

---

## F. Faza 1 — szczegółowy rozpis (fundament stanu + i18n + motyw)

Kolejność wewnątrz fazy: **B3-min → B1 → B2**. Zaczynamy od minimalnego fundamentu
stanu (tylko ustawienia: język + motyw), bo to jedyne, czego B1 i B2 naprawdę wymagają.
Pełną migrację warstwy danych na Riverpod (providery per encja) robimy przyrostowo później —
nie blokuje i18n ani motywu.

### F0. Zależności i konfiguracja

- `pubspec.yaml`:
  - dodać `flutter_riverpod`, `shared_preferences`,
  - włączyć generację l10n: sekcja `flutter: generate: true`,
  - (porządek C5) rozważyć usunięcie nieużywanego `duration_picker`.
- `l10n.yaml` w katalogu głównym:
  - `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`,
  - `output-localization-file: app_localizations.dart`, `output-class: AppLocalizations`,
  - `output-dir: lib/l10n`, `synthetic-package: false`, `nullable-getter: false`.
- Po pobraniu SDK: `flutter pub get` → `flutter gen-l10n` (albo zwykły build,
  który wywoła generację). Wygeneruje `lib/l10n/app_localizations*.dart`.

### F1. B3-min — kontroler ustawień (Riverpod + shared_preferences)

- Nowy plik `lib/providers/settings_controller.dart`:
  - enum `ThemeMode` (użyć wbudowanego `ThemeMode`),
  - klasa stanu `AppSettings { ThemeMode themeMode; Locale? locale; }`
    (`locale == null` = język systemu),
  - `SettingsController extends StateNotifier<AppSettings>` z metodami
    `setThemeMode(...)`, `setLocale(...)`, odczyt/zapis do `shared_preferences`
    (klucze np. `theme_mode`, `locale`),
  - `settingsControllerProvider = StateNotifierProvider<SettingsController, AppSettings>`,
  - wczytanie zapisanych ustawień przy starcie (async init + `runApp` po odczycie
    lub `AsyncValue`/`FutureProvider` na starcie).
- Owinąć aplikację w `ProviderScope` (w `main`).

### F2. B1 — i18n PL/EN (ARB)

- Utworzyć `lib/l10n/app_en.arb` i `lib/l10n/app_pl.arb`
  (treść przeniesiona z RN `EnglishTranslations.ts` / `Translations.ts`
  + klucze specyficzne dla Fluttera: powiadomienia, timer przerwy, kalkulator 1RM,
  wpisy masy ciała).
- Klucze partii ciała: 21 pozycji jako klucze tłumaczeń
  (`frontNeck, backNeck, traps, frontDelts, sideDelts, rearDelts, upperBack,
  lowerBack, middleBack, lats, chest, abs, biceps, triceps, forearmFlexors,
  forearmExtensors, glute, quads, hamstrings, calves, tibialis`).
- Wzorzec tłumaczenia partii ciała: DB trzyma **kanoniczną nazwę angielską**
  (jak dziś), a wyświetlanie mapuje nazwę → tekst zlokalizowany przez helper
  `localizedBodyPart(context, canonicalName)` (`lib/l10n/l10n_helpers.dart`).
  Dzięki temu nie ruszamy danych/relacji, tłumaczymy tylko warstwę widoku.
- `main.dart`: dodać `AppLocalizations.localizationsDelegates`,
  `supportedLocales: [Locale('en'), Locale('pl')]`, spiąć `locale`
  z `settingsControllerProvider`. Zlikwidować sztywne `Locale('en','GB')`
  w date/time pickerach (dziedziczyć z `MaterialApp.locale`).
- Migracja tekstów w ekranach: przyrostowo, ekran po ekranie
  (`main.dart` i `settings_screen.dart` jako pierwsze — reszta później).
  Pozostałe `const Text('...')` nadal się kompilują, więc migracja nie jest atomowa.

Uwaga: nazwy ćwiczeń (starter + tworzone przez użytkownika) to **dane**, nie UI —
nie tłumaczymy ich w tej fazie (tylko partie ciała, które są zamkniętym zbiorem).

### F3. B2 — motyw light/dark/system

- W `main.dart`: `MaterialApp(theme: <light>, darkTheme: <dark>, themeMode:
  settings.themeMode)` — oba `ThemeData` z `ColorScheme.fromSeed(seedColor: AppColors.seed,
  brightness: ...)`. Usunąć obecne sztywne `brightness: platformBrightnessOf`
  (zastępuje je `themeMode`).
- W `settings_screen.dart`: zamienić placeholder `_changeColors` na realny wybór
  3-opcyjny (Jasny/Ciemny/Systemowy) wywołujący `setThemeMode`.

### F4. Podpięcie języka w Settings

- Zamienić placeholder `_changeLanguage` na wybór PL/EN/System wywołujący `setLocale`.
- `settings_screen.dart` przerobić na `ConsumerWidget` (dostęp do providera).

**Kryteria ukończenia Fazy 1:**

- Zmiana języka i motywu w Settings działa natychmiast (reaktywnie) i przeżywa restart.
- `main.dart` i `settings_screen.dart` używają `AppLocalizations` zamiast literałów.
- Data/time pickery dziedziczą locale z aplikacji.

---

## E. Czego NIE przenosić z RN

- Wykresy custom (RN pisał je ręcznie) — Flutter ma lepsze przez bibliotekę, zostaw.
- Legacy/martwy kod RN (`ExerciseEntryScreen`, nieużywany modal, nieużywany `Timer`) — nie replikować.
- WatermelonDB — Flutter zostaje przy SQLite/sqflite, spójnie z resztą.

---

## Załącznik: porównanie funkcji

| Funkcja | React Native (TrainingJournal) | Flutter (Pro) |
|---|---|---|
| Architektura / warstwa danych | Lepsza — WatermelonDB, serwisy, hooki, testy, konteksty | Prostsza — MVC + raw SQL, `setState`, brak testów |
| Zarządzanie ćwiczeniami | grupy mięśniowe + rola (Primary/Secondary) | 21 partii ciała (M:N) |
| 1RM | Brzycki + hipotetyczne 1RM z RIR | mapa % 1–30 reps |
| RIR | tak | tak |
| Timer odpoczynku | wizualny (bez dźwięku) | z dźwiękiem + font DSEG7 |
| Powiadomienia o treningu | brak | tygodniowe, recurring |
| Motyw jasny/ciemny | light/dark/system | tylko auto wg systemu |
| i18n (PL/EN) | tak (częściowa) | brak (hardcoded EN) |
| Wykresy | custom (1RM, waga) | biblioteka, interaktywne |
| Export/Import danych | brak (kod bez UI) | brak |
| Plany tygodniowe | brak | brak (planowane) |
| Migracje bazy | brak | **tak (v2, onUpgrade + onConfigure)** |
| Testy | 17 plików | pusty szkielet |

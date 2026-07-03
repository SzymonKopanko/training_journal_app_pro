import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// Tłumaczy kanoniczną (angielską) nazwę partii ciała przechowywaną w bazie
/// na tekst zlokalizowany. Baza pozostaje w jednym, stałym języku (angielskim),
/// a lokalizujemy wyłącznie warstwę widoku — dzięki temu relacje i dane
/// pozostają nienaruszone.
///
/// Nieznane nazwy (np. ćwiczenia dodane przez użytkownika) zwracamy bez zmian.
String localizedBodyPart(BuildContext context, String canonicalName) {
  final l10n = AppLocalizations.of(context);
  switch (canonicalName) {
    case 'Front Neck':
      return l10n.bodyPartFrontNeck;
    case 'Back Neck':
      return l10n.bodyPartBackNeck;
    case 'Traps':
      return l10n.bodyPartTraps;
    case 'Front Delts':
      return l10n.bodyPartFrontDelts;
    case 'Side Delts':
      return l10n.bodyPartSideDelts;
    case 'Rear Delts':
      return l10n.bodyPartRearDelts;
    case 'Upper Back':
      return l10n.bodyPartUpperBack;
    case 'Lower Back':
      return l10n.bodyPartLowerBack;
    case 'Middle Back':
      return l10n.bodyPartMiddleBack;
    case 'Lats':
      return l10n.bodyPartLats;
    case 'Chest':
      return l10n.bodyPartChest;
    case 'Abs':
      return l10n.bodyPartAbs;
    case 'Biceps':
      return l10n.bodyPartBiceps;
    case 'Triceps':
      return l10n.bodyPartTriceps;
    case 'Forearm Flexors':
      return l10n.bodyPartForearmFlexors;
    case 'Forearm Extensors':
      return l10n.bodyPartForearmExtensors;
    // 'Glute' i 'Glutes' współistnieją w seedzie (patrz plan C5) — mapujemy oba.
    case 'Glute':
    case 'Glutes':
      return l10n.bodyPartGlutes;
    case 'Quads':
      return l10n.bodyPartQuads;
    case 'Hamstrings':
      return l10n.bodyPartHamstrings;
    case 'Calves':
      return l10n.bodyPartCalves;
    case 'Tibialis':
      return l10n.bodyPartTibialis;
    default:
      return canonicalName;
  }
}

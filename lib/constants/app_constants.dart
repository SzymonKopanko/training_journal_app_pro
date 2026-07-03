import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Kolory marki — seed pozostaje tutaj; kolory przycisków kart idą przez [ColorScheme].
class AppColors {
  static const Color seed = Color(0xFF1B5E20);
}

/// @deprecated Używaj [AppSpacing] i [Theme.of(context).textTheme].
/// Aliasy zachowane na czas migracji formularzy.
class AppSizing {
  static const double padding = AppSpacing.xxl;
  static const double padding1 = AppSpacing.xl;
  static const double padding2 = AppSpacing.md;
  static const double padding3 = AppSpacing.md;
  static const double padding4 = AppSpacing.sm;
  static const double padding5 = AppSpacing.xs + 2;
  static const double padding6 = AppSpacing.xs + 1;
  static const double padding7 = AppSpacing.xs;

  static const Size buttonSize3 = Size(140, 40);
  static const Size buttonSize4 = Size(280, 40);

  static const double boxSize1 = 60.0;
  static const double boxSize2 = 35.0;
  static const double boxSize3 = 55.0;
  static const double boxSize4 = 50.0;

  static const double headingRowH = 30.0;
  static const double dataRowMaxH = 25.0;
  static const double dataRowMinH = 20.0;
  static const double dataRowSpace = 2.0;

  static const double fontSize1 = 25.0;
  static const double fontSize2 = 20.0;
  static const double fontSize3 = 18.0;
  static const double fontSize4 = 16.0;
}

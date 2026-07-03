import 'package:flutter/material.dart';

/// Siatka odstępów oparta o wielokrotności 4 dp.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const EdgeInsets screen = EdgeInsets.all(md);
  static const EdgeInsets card = EdgeInsets.all(md);
  static const EdgeInsets listItem = EdgeInsets.all(sm);

  static const SizedBox gapXs = SizedBox(width: xs, height: xs);
  static const SizedBox gapSm = SizedBox(width: sm, height: sm);
  static const SizedBox gapMd = SizedBox(width: md, height: md);
  static const SizedBox gapLg = SizedBox(width: lg, height: lg);
  static const SizedBox gapXl = SizedBox(width: xl, height: xl);

  /// Wymiary DataTable w formularzach wpisów treningowych.
  static const double dtHeadingRowH = 30;
  static const double dtDataRowMaxH = 25;
  static const double dtDataRowMinH = 20;
  static const double dtColumnSpacing = 2;
  static const double dtHorizontalMargin = 6;

  /// Szerokości kolumn siatki serii (numer, reps, waga, RIR).
  static const double setColNumber = 60;
  static const double setColReps = 35;
  static const double setColWeight = 55;
  static const double setColRir = 50;
}

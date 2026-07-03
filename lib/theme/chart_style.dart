import 'package:charts_flutter_maintained/charts_flutter_maintained.dart'
    as charts;
import 'package:flutter/material.dart';

/// Style osi wykresów zsynchronizowane z motywem aplikacji.
abstract final class ChartStyle {
  static double axisLabelFontSize(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall?.fontSize ?? 12;

  static charts.TextStyleSpec axisLabelStyle(BuildContext context) =>
      charts.TextStyleSpec(
        fontSize: axisLabelFontSize(context).round(),
        color: charts.ColorUtil.fromDartColor(
          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
        ),
      );

  static charts.LineStyleSpec axisLineStyle(BuildContext context) =>
      charts.LineStyleSpec(
        thickness: 1,
        color: charts.ColorUtil.fromDartColor(
          Theme.of(context).colorScheme.outline,
        ),
      );

  static charts.LineStyleSpec gridLineStyle(BuildContext context) =>
      charts.LineStyleSpec(
        thickness: 0,
        color: charts.ColorUtil.fromDartColor(
          Theme.of(context).colorScheme.outlineVariant,
        ),
      );
}

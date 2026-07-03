import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:training_journal_app/services/journal_database.dart';
import 'package:training_journal_app/services/set_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/chart_style.dart';
import '../models/set.dart';
import '../models/exercise.dart';
import '../services/entry_service.dart';
import 'package:charts_flutter_maintained/charts_flutter_maintained.dart' as charts;

class OneRepMaxData {
  final DateTime date;
  final Set set;

  OneRepMaxData(this.date, this.set);
}

class ExerciseChartScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseChartScreen({super.key, required this.exercise});

  @override
  _ExerciseChartScreenState createState() => _ExerciseChartScreenState();
}

class _ExerciseChartScreenState extends State<ExerciseChartScreen> {
  late Future<void> dataFuture;
  List<OneRepMaxData> data = [];

  @override
  void initState() {
    dataFuture = _generateData();
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _generateData() async {
    final instance = JournalDatabase.instance;
    final setService = SetService(instance);
    final allEntries =
    await EntryService(instance).readAllEntriesByExercise(widget.exercise);
    final List<OneRepMaxData> newData = [];
    for (final entry in allEntries!) {
      final set = await setService.readBestSetFromEntry(entry);
      newData.add(OneRepMaxData(entry.date, set));
    }
    newData.sort((a, b) => a.date.compareTo(b.date));
    setState(() {
      data = newData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chartTitle(widget.exercise.name)),
      ),
      body: FutureBuilder<void>(
        future: dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(l10n.chartLoadError));
          } else {
            return charts.TimeSeriesChart(
              _createData(),
              animate: true,
              dateTimeFactory: const charts.LocalDateTimeFactory(),
              primaryMeasureAxis: createNumericAxis(context),
              domainAxis: createDateTimeAxis(context),
              defaultRenderer: charts.LineRendererConfig(
                customRendererId: 'customPoint',
                includePoints: true,
              ),
              customSeriesRenderers: [
                charts.PointRendererConfig(
                  customRendererId: 'customPoint',
                  radiusPx: 5,
                ),
              ],
              behaviors: [
                charts.LinePointHighlighter(
                  showHorizontalFollowLine:
                  charts.LinePointHighlighterFollowLineType.nearest,
                  showVerticalFollowLine:
                  charts.LinePointHighlighterFollowLineType.nearest,
                ),
              ],
              selectionModels: [
                charts.SelectionModelConfig(
                  changedListener: (charts.SelectionModel model) {
                    _onSelectionChanged(model, context);
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void _onSelectionChanged(charts.SelectionModel model, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedDatum = model.selectedDatum;

    if (selectedDatum.isNotEmpty) {
      final oneRepMaxData = selectedDatum.first.datum as OneRepMaxData;
      final formattedDate = DateFormat('dd.MM.yyyy, HH:mm').format(oneRepMaxData.date);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                l10n.chartOneRm(oneRepMaxData.set.oneRM.toStringAsFixed(2))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.labelDate(formattedDate)),
                Text(l10n.chartWeight(
                    oneRepMaxData.set.weight.toStringAsFixed(2))),
                Text(l10n.chartReps(oneRepMaxData.set.reps)),
                if(oneRepMaxData.set.rir != -1)
                  Text(l10n.chartRir(oneRepMaxData.set.rir)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(l10n.commonClose),
              ),
            ],
          );
        },
      );
    }
  }

  List<charts.Series<OneRepMaxData, DateTime>> _createData() {
    return [
      charts.Series<OneRepMaxData, DateTime>(
        id: 'One Rep Max',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (OneRepMaxData data, _) => data.date,
        measureFn: (OneRepMaxData data, _) => data.set.oneRM,
        data: data,
      ),
    ];
  }

  int calculateDayIncrement(DateTime startDate, DateTime endDate) {
    if (startDate.isAfter(endDate)) {
      final temp = startDate;
      startDate = endDate;
      endDate = temp;
    }
    final difference = endDate.difference(startDate).inDays;
    if(difference < 1){
      return 1;
    }
    return (difference / 8).ceil();
  }
  
  charts.DateTimeAxisSpec createDateTimeAxis(BuildContext context) {
    int increment = calculateDayIncrement(data[0].date, data[data.length-1].date);
    return  charts.DateTimeAxisSpec(
      tickProviderSpec: charts.DayTickProviderSpec(increments: [increment]),
      renderSpec: charts.SmallTickRendererSpec(
        labelStyle: ChartStyle.axisLabelStyle(context),
        lineStyle: ChartStyle.gridLineStyle(context),
        tickLengthPx: 3,
        axisLineStyle: ChartStyle.axisLineStyle(context),
      ),
    );
  }

  charts.NumericAxisSpec createNumericAxis(BuildContext context) {
    return charts.NumericAxisSpec(
      tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
            (num? value) {
          return value != null ? '$value kg' : '';
        },
      ),
      renderSpec:  charts.GridlineRendererSpec(
        labelStyle: ChartStyle.axisLabelStyle(context),
        lineStyle: ChartStyle.gridLineStyle(context),
        tickLengthPx: 3,
        axisLineStyle: ChartStyle.axisLineStyle(context),
      ),
      showAxisLine: true
    );
  }
}

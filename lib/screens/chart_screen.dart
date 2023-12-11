import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:training_journal_app/services/journal_database.dart';
import 'package:training_journal_app/services/set_service.dart';
import '../models/set.dart';
import '../models/exercise.dart';
import '../services/exercise_service.dart';
import '../services/entry_service.dart';
import 'package:charts_flutter_maintained/charts_flutter_maintained.dart' as charts;

class OneRepMaxData {
  final DateTime date;
  final Set set;

  OneRepMaxData(this.date, this.set);
}

class ExerciseChartScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseChartScreen({Key? key, required this.exercise})
      : super(key: key);

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
      debugPrint(set.toString());
      newData.add(OneRepMaxData(entry.date, set));
    }
    newData.sort((a, b) => a.date.compareTo(b.date));
    setState(() {
      data = newData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('\'${widget.exercise.name}\' Chart'),
      ),
      body: FutureBuilder<void>(
        future: dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else {
            return charts.TimeSeriesChart(
              _createData(),
              animate: true,
              dateTimeFactory: const charts.LocalDateTimeFactory(), // For DateTime values
              primaryMeasureAxis: createNumericAxis(),
              domainAxis: createDateTimeAxis(),
              defaultRenderer: charts.LineRendererConfig(
                customRendererId: 'customPoint',
                includePoints: true, // Dodaj tę linię
              ),
              customSeriesRenderers: [
                charts.PointRendererConfig(
                  customRendererId: 'customPoint',
                  radiusPx: 5, // Ustaw rozmiar punktu na dowolną wartość większą niż zero
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
    final selectedDatum = model.selectedDatum;

    if (selectedDatum.isNotEmpty) {
      final oneRepMaxData = selectedDatum.first.datum as OneRepMaxData;
      final formattedDate = DateFormat('dd.MM.yyyy, HH:mm').format(oneRepMaxData.date);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('1RM: ${oneRepMaxData.set.oneRM.toStringAsFixed(2)} kg'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: $formattedDate'),
                Text('Weight: ${oneRepMaxData.set.weight.toStringAsFixed(2)} kg'),
                Text('Reps: ${oneRepMaxData.set.reps}'),
                if(oneRepMaxData.set.rir != -1)
                  Text('Reps in reserve: ${oneRepMaxData.set.rir}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
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
    return (difference / 8).ceil();
  }
  
  charts.DateTimeAxisSpec createDateTimeAxis() {
    int increment = calculateDayIncrement(data[0].date, data[data.length-1].date);
    return  charts.DateTimeAxisSpec(
      tickProviderSpec: charts.DayTickProviderSpec(increments: [increment]),
      renderSpec: charts.SmallTickRendererSpec(
        labelStyle: const charts.TextStyleSpec(
          fontSize: 12,
        ),
        lineStyle: charts.LineStyleSpec(
          thickness: 1, // Grubość linii osi Y
          color: charts.MaterialPalette.gray.shade800, // Kolor linii osi Y
        ),
        tickLengthPx: 3, // Długość kresek na osi Y
        axisLineStyle: charts.LineStyleSpec(
          thickness: 1, // Grubość linii osi X
          color: charts.MaterialPalette.gray.shade400, // Kolor linii osi X
        ),
      ),
    );
  }

  charts.NumericAxisSpec createNumericAxis() {
    return charts.NumericAxisSpec(
      tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
            (num? value) {
          return value != null ? '$value kg' : '';
        },
      ),
      renderSpec:  charts.GridlineRendererSpec(
        labelStyle: const charts.TextStyleSpec(
          fontSize: 12,
        ),
        lineStyle: charts.LineStyleSpec(
          thickness: 0, // Grubość linii osi Y
          color: charts.MaterialPalette.gray.shade800, // Kolor linii osi Y
        ),
        tickLengthPx: 3,
        axisLineStyle: charts.LineStyleSpec(
          thickness: 1, // Grubość linii osi X
          color: charts.MaterialPalette.gray.shade400, // Kolor linii osi X
        ),
      ),
      showAxisLine: true // Rysuj linie osi Y po lewej stronie
    );
  }
}

import 'package:charts_flutter_maintained/charts_flutter_maintained.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:training_journal_app/models/body_entry.dart';
import 'package:training_journal_app/services/body_entry_service.dart';
import 'package:training_journal_app/services/journal_database.dart';

class BodyEntryChartScreen extends StatefulWidget {
  const BodyEntryChartScreen({super.key});

  @override
  _BodyEntryChartScreenState createState() => _BodyEntryChartScreenState();
}

class _BodyEntryChartScreenState extends State<BodyEntryChartScreen> {
  late Future<void> dataFuture;
  List<BodyEntry> data = [];

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
    final bodyEntryService = BodyEntryService(JournalDatabase.instance);
    final allEntries = await bodyEntryService.readAllBodyEntries();
    List<BodyEntry> newData = [];
    if (allEntries != null) {
      for (final entry in allEntries) {
        newData.add(BodyEntry(dateTime: entry.dateTime, weight: entry.weight));
      }
      newData.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    } else {
      setState(() {
        data = allEntries!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Entries Chart'),
      ),
      body: FutureBuilder<void>(
        future: dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('No body entries found.'));
          } else {
            return charts.TimeSeriesChart(
              _createData(),
              animate: true,
              dateTimeFactory: const charts.LocalDateTimeFactory(),
              primaryMeasureAxis: createNumericAxis(),
              domainAxis: createDateTimeAxis(),
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
    final selectedDatum = model.selectedDatum;

    if (selectedDatum.isNotEmpty) {
      final bodyEntry = selectedDatum.first.datum as BodyEntry;
      final formattedDate =
          DateFormat('dd.MM.yyyy, HH:mm').format(bodyEntry.dateTime);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('${bodyEntry.weight.toStringAsFixed(2)} kg'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: $formattedDate'),
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

  List<charts.Series<BodyEntry, DateTime>> _createData() {
    return [
      charts.Series<BodyEntry, DateTime>(
        id: 'Body Weight',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (BodyEntry data, _) => data.dateTime,
        measureFn: (BodyEntry data, _) => data.weight,
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
    if (difference < 1) {
      return 1;
    }
    return (difference / 8).ceil();
  }

  charts.DateTimeAxisSpec createDateTimeAxis() {
    if (data.isEmpty) {
      return charts.DateTimeAxisSpec(
        tickProviderSpec: const charts.DayTickProviderSpec(increments: [1]),
        renderSpec: charts.SmallTickRendererSpec(
          labelStyle: const charts.TextStyleSpec(
            fontSize: 12,
          ),
          lineStyle: charts.LineStyleSpec(
            thickness: 1,
            color: charts.MaterialPalette.gray.shade800,
          ),
          tickLengthPx: 3,
          axisLineStyle: charts.LineStyleSpec(
            thickness: 1,
            color: charts.MaterialPalette.gray.shade400,
          ),
        ),
      );
    }
    int increment =
        calculateDayIncrement(data[0].dateTime, data[data.length - 1].dateTime);
    return charts.DateTimeAxisSpec(
      tickProviderSpec: charts.DayTickProviderSpec(increments: [increment]),
      renderSpec: charts.SmallTickRendererSpec(
        labelStyle: const charts.TextStyleSpec(
          fontSize: 12,
        ),
        lineStyle: charts.LineStyleSpec(
          thickness: 1,
          color: charts.MaterialPalette.gray.shade800,
        ),
        tickLengthPx: 3,
        axisLineStyle: charts.LineStyleSpec(
          thickness: 1,
          color: charts.MaterialPalette.gray.shade400,
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
      renderSpec: charts.GridlineRendererSpec(
        labelStyle: const charts.TextStyleSpec(
          fontSize: 12,
        ),
        lineStyle: charts.LineStyleSpec(
          thickness: 0,
          color: charts.MaterialPalette.gray.shade800,
        ),
        tickLengthPx: 3,
        axisLineStyle: charts.LineStyleSpec(
          thickness: 1,
          color: charts.MaterialPalette.gray.shade400,
        ),
      ),
      showAxisLine: true,
    );
  }
}

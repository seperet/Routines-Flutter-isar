import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../collections/category.dart';
import '../collections/routine.dart';
import '../main.dart';
import '../services/color_schemes.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationSupportDirectory();
  final isar = await Isar.open(
    [RoutineSchema, CategorySchema],
    directory: dir.path,
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'routing app',
    theme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
    home: HomePage(isar: isar),
  ));
}

class ChartScreen extends StatefulWidget {
  const ChartScreen(BuildContext context, {super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class SalesData {
  String date = "";
  double productivity = 0.0;
  SalesData(this.date, this.productivity);
}

class _ChartScreenState extends State<ChartScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            title: ChartTitle(text: 'Efficiency Report in Daily Routines'),
            legend: Legend(isVisible: true),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <LineSeries<SalesData, String>>[
              LineSeries<SalesData, String>(
                name: 'Routines',
                dataSource: <SalesData>[
                  SalesData('sunday', 10),
                  SalesData('monday', 8),
                  SalesData('wednesday', 9),
                  SalesData('thursday', 12),
                  SalesData('friday', 10),
                  SalesData('saturday', 8)
                ],
                xValueMapper: (SalesData sales, _) => sales.date,
                yValueMapper: (SalesData sales, _) => sales.productivity,
                // Enable data label
                dataLabelSettings: DataLabelSettings(isVisible: true),
              ),
              LineSeries<SalesData, String>(
                name: 'Inefficient',
                dataSource: <SalesData>[
                  SalesData('sunday', 5),
                  SalesData('monday', 5),
                  SalesData('wednesday', 3),
                  SalesData('thursday', 6),
                  SalesData('friday', 7),
                  SalesData('saturday', 8)
                ],
                xValueMapper: (SalesData sales, _) => sales.date,
                yValueMapper: (SalesData sales, _) => sales.productivity,
                // Enable data label
                dataLabelSettings: DataLabelSettings(isVisible: true),
              )
            ]),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class EmissionChart extends StatefulWidget {
  const EmissionChart({Key? key}) : super(key: key);

  @override
  _EmissionChartState createState() => _EmissionChartState();
}

class _EmissionChartState extends State<EmissionChart> {
  List<FlSpot> emissionsData = [];
  List<String> dates = [];
  double maxYValue = 0;

  @override
  void initState() {
    super.initState();
    _fetchEmissionsData();
  }

  Future<void> _fetchEmissionsData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('activities')
          .orderBy('timestamp')
          .get();

      Map<DateTime, double> dailyEmissions = {};

      for (var doc in snapshot.docs) {
        double emissions = doc['emissions']?.toDouble() ?? 0.0;
        Timestamp timestamp = doc['timestamp'];
        DateTime date = timestamp.toDate();
        DateTime dateOnly = DateTime(date.year, date.month, date.day);

        if (dailyEmissions.containsKey(dateOnly)) {
          dailyEmissions[dateOnly] = dailyEmissions[dateOnly]! + emissions;
        } else {
          dailyEmissions[dateOnly] = emissions;
        }
      }

      List<FlSpot> spots = [];
      List<String> dateLabels = [];
      double maxValue = 0;

      int index = 0;
      dailyEmissions.entries.forEach((entry) {
        double value = entry.value;
        spots.add(FlSpot(index.toDouble(), value));
        dateLabels.add(DateFormat('MM/dd').format(entry.key));
        maxValue = value > maxValue ? value : maxValue;
        index++;
      });

      setState(() {
        emissionsData = spots;
        dates = dateLabels;
        maxYValue = maxValue + 25;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Daily Emissions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < dates.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              dates[index],
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: emissionsData.isNotEmpty ? emissionsData.length - 1.0 : 0,
                minY: 0,
                maxY: maxYValue,
                lineBarsData: [
                  LineChartBarData(
                    spots: emissionsData,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Colors.blueAccent, Colors.cyan],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent.withOpacity(0.2),
                          Colors.cyan.withOpacity(0.1)
                        ],
                      ),
                    ),
                    dotData: FlDotData(show: true, checkToShowDot: (spot, barData) {
                      return true; // Set to true to show the dot
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
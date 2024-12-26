import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class EmissionPercentChangeChart extends StatefulWidget {
  const EmissionPercentChangeChart({Key? key}) : super(key: key);

  @override
  _EmissionPercentChangeChartState createState() => _EmissionPercentChangeChartState();
}

class _EmissionPercentChangeChartState extends State<EmissionPercentChangeChart> {
  Map<String, double> currentEmissionsByCategory = {};
  Map<String, double> previousEmissionsByCategory = {};
  Map<String, double> percentChangeByCategory = {};
  double maxYValue = 0;

  @override
  void initState() {
    super.initState();
    _fetchCategoryEmissions();
  }

  Future<void> _fetchCategoryEmissions() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get current emissions (most recent timestamp)
      QuerySnapshot currentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('activities')
          .orderBy('timestamp', descending: true)
          .get();

      // Get previous emissions (timestamp before current one)
      QuerySnapshot previousSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('activities')
          .orderBy('timestamp', descending: false)
          .get();

      Map<String, double> currentEmissions = {};
      Map<String, double> previousEmissions = {};

      // Aggregating current emissions data by category
      print("Current Emissions Data:");
      for (var doc in currentSnapshot.docs) {
        String category = doc['category'] ?? 'Unknown';
        double emissions = double.tryParse(doc['emissions'].toString()) ?? 0.0;
        currentEmissions[category] = (currentEmissions[category] ?? 0.0) + emissions;  // Aggregate values
        print("Category: $category, Emissions: $emissions, Aggregated Emissions: ${currentEmissions[category]}");
      }

      // Aggregating previous emissions data by category
      print("Previous Emissions Data:");
      for (var doc in previousSnapshot.docs) {
        String category = doc['category'] ?? 'Unknown';
        double emissions = double.tryParse(doc['emissions'].toString()) ?? 0.0;
        previousEmissions[category] = (previousEmissions[category] ?? 0.0) + emissions;  // Aggregate values
        print("Category: $category, Emissions: $emissions, Aggregated Emissions: ${previousEmissions[category]}");
      }

      // Calculate percent change for each category
      Map<String, double> percentChange = {};
      print("Percent Change Calculations:");
      currentEmissions.forEach((category, currentEmission) {
        double previousEmission = previousEmissions[category] ?? 0.0;
        double percentChangeValue = 0.0;

        if (previousEmission != 0.0) {
          percentChangeValue = ((currentEmission - previousEmission) / previousEmission) * 100;
        }

        percentChange[category] = percentChangeValue;
        print("Category: $category, Current Emissions: $currentEmission, Previous Emissions: $previousEmission, Percent Change: $percentChangeValue");
      });

      setState(() {
        currentEmissionsByCategory = currentEmissions;
        previousEmissionsByCategory = previousEmissions;
        percentChangeByCategory = percentChange;
        maxYValue = percentChange.values.isNotEmpty
            ? percentChange.values.reduce((a, b) => a > b ? a : b) + 50
            : 100;
      });

      // Log the final results
      print("Final Percent Change Data: $percentChangeByCategory");
      print("Max Y Value: $maxYValue");
    }
  }

  String _wrapText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    List<String> chunks = [];
    for (int i = 0; i < text.length; i += maxLength) {
      int end = (i + maxLength < text.length) ? i + maxLength : text.length;
      chunks.add(text.substring(i, end));
    }
    return chunks.join('\n');
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
          const SizedBox(height: 12),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxYValue,
                barGroups: percentChangeByCategory.entries.map((entry) {
                  int index = percentChangeByCategory.keys.toList().indexOf(entry.key);
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: entry.value > 0 ? Colors.greenAccent : Colors.redAccent,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < percentChangeByCategory.keys.length) {
                          String label = percentChangeByCategory.keys.elementAt(index);
                          String wrappedLabel = _wrapText(label, 10); // Wrap text every 10 characters
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              wrappedLabel,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                gridData: FlGridData(show: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

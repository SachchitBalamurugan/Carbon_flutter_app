import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class EmissionChartByCategory2 extends StatefulWidget {
  const EmissionChartByCategory2({Key? key}) : super(key: key);

  @override
  _EmissionChartByCategory2State createState() => _EmissionChartByCategory2State();
}

class _EmissionChartByCategory2State extends State<EmissionChartByCategory2> {
  Map<String, double> categoryEmissions = {};
  double maxYValue = 0;

  @override
  void initState() {
    super.initState();
    _fetchCategoryEmissions();
  }

  Future<void> _fetchCategoryEmissions() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('activities')
          .orderBy('timestamp', descending: true)
          .get();

      Map<String, double> emissionsByCategory = {};

      DateTime now = DateTime.now();

      for (var doc in snapshot.docs) {
        DateTime timestamp = (doc['timestamp'] as Timestamp).toDate();
        if (timestamp.day == now.day &&
            timestamp.month == now.month &&
            timestamp.year == now.year) {
          String category = doc['category'] ?? 'Unknown';
          double emissions = double.tryParse(doc['emissions'].toString()) ?? 0.0;

          emissionsByCategory[category] =
              (emissionsByCategory[category] ?? 0) + emissions;
        }
      }

      setState(() {
        categoryEmissions = emissionsByCategory;
        maxYValue = emissionsByCategory.values.isNotEmpty
            ? emissionsByCategory.values.reduce((a, b) => a > b ? a : b) + 50
            : 0;
      });
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
    return chunks.join('\n'); // Join chunks with newline characters
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
                barGroups: categoryEmissions.entries.map((entry) {
                  int index = categoryEmissions.keys.toList().indexOf(entry.key);
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: Colors.greenAccent,
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
                        if (index >= 0 && index < categoryEmissions.keys.length) {
                          String label = categoryEmissions.keys.elementAt(index);
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

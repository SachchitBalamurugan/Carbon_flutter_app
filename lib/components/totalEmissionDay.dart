import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmissionsSummaryWidget extends StatelessWidget {
  const EmissionsSummaryWidget({Key? key}) : super(key: key);

  Future<Map<String, double>> _fetchEmissionValues() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {"today": 0.0, "lastDate": 0.0};
    }

    // Fetch activities for the current user, ordered by timestamp
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .get();

    if (snapshot.docs.isEmpty) {
      return {"today": 0.0, "lastDate": 0.0};
    }

    double todayEmissions = 0.0;
    double lastDateEmissions = 0.0;
    DateTime? lastDate;

    for (var doc in snapshot.docs) {
      double emissions = doc['emissions']?.toDouble() ?? 0.0;
      DateTime timestamp = (doc['timestamp'] as Timestamp).toDate();

      if (DateTime
          .now()
          .difference(timestamp)
          .inDays == 0) {
        // Add to today's total
        todayEmissions += emissions;
      } else if (lastDate == null || timestamp.isBefore(lastDate)) {
        // Update the last date's emissions if it's the first or earlier date
        lastDateEmissions = emissions;
        lastDate = timestamp;
      }
    }

    return {"today": todayEmissions, "lastDate": lastDateEmissions};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: _fetchEmissionValues(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: Text(
              "No data available.",
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        final double todayEmissions = snapshot.data!["today"]!;
        final double lastDateEmissions = snapshot.data!["lastDate"]!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          // Space on the sides
          child: Container(
            width: double.infinity, // Fill available width
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Total Emissions for Today",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  "${todayEmissions.toStringAsFixed(2)} kg CO2",
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                ),
                const SizedBox(height: 16.0),
                Text(
                  "Last Recorded Emissions",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  "${lastDateEmissions.toStringAsFixed(2)} kg CO2",
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
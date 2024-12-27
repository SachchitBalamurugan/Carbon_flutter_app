import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'home.dart';

void main() => runApp(LeaderboardApp());

class LeaderboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LeaderboardScreen(),
    );
  }
}

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> leaderboardData = [];

  @override
  void initState() {
    super.initState();
    _fetchLeaderboardData();
  }

  // Fetch activities and calculate total emissions for each user
  Future<void> _fetchLeaderboardData() async {
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

    List<Map<String, dynamic>> data = [];

    for (var userDoc in usersSnapshot.docs) {
      String userId = userDoc.id;
      QuerySnapshot activitiesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('activities')
          .get();

      double totalEmissions = 0;
      activitiesSnapshot.docs.forEach((doc) {
        // Ensure emissions and quantity are converted to double
        double emissions = double.tryParse(doc['emissions'].toString()) ?? 0.0;
        double quantity = double.tryParse(doc['quantity'].toString()) ?? 1.0;  // Default quantity 1 if missing

        totalEmissions += emissions;
      });

      data.add({
        'userId': userId,
        'name': userDoc['name'] ?? 'Unknown',  // Replace with actual name field if available
        'totalEmissions': totalEmissions,
      });
    }

    // Sort users by total emissions (lowest first)
    data.sort((a, b) => a['totalEmissions'].compareTo(b['totalEmissions']));

    // Add rank to the sorted data
    for (int i = 0; i < data.length; i++) {
      data[i]['rank'] = i + 1;
    }

    setState(() {
      leaderboardData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ensure there are at least 3 users for the top 3 section
    while (leaderboardData.length < 3) {
      leaderboardData.add({
        'userId': 'dummy',
        'name': 'Dummy User',
        'totalEmissions': 0.0,
        'rank': leaderboardData.length + 1,
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Navigate to the ActivityTracker screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ActivityTracker()),
            );
          },
        ),
      ),
      body: leaderboardData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Top 3 Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTopCard(leaderboardData[1]),
                _buildTopCard(leaderboardData[0], isCrown: true),
                _buildTopCard(leaderboardData[2]),
              ],
            ),
          ),
          // Remaining Leaderboard
          Expanded(
            child: ListView.builder(
              itemCount: leaderboardData.length - 3,
              itemBuilder: (context, index) {
                return _buildListCard(leaderboardData[index + 3]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCard(Map<String, dynamic> data, {bool isCrown = false}) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: isCrown ? 40 : 35,
              backgroundColor: Colors.grey.shade200,
              child: Text(
                data['name'][0],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            if (isCrown)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Icon(Icons.emoji_events, color: Colors.amber, size: 24),
              ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          data['name'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          '${data['totalEmissions'].toStringAsFixed(1)} emissions',  // Rounded to one decimal place
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildListCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: Text(
            data['rank'].toString(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(data['name']),
        trailing: Padding(
          padding: const EdgeInsets.only(right: 5.5),  // Add padding to the right to prevent overflow
          child: Text(
            '${data['totalEmissions'].toStringAsFixed(1)} emissions',  // Rounded to one decimal place
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

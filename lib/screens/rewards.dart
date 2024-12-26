import 'dart:math';

import 'package:flutter/material.dart';
import 'package:untitled/screens/home.dart';

void main() {
  runApp(RewardPageApp());
}

class RewardPageApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RewardPage(),
    );
  }
}

class RewardPage extends StatelessWidget {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Get Rewarded',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose one of these rewards',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  RewardCard(
                    color: Colors.red[400]!,
                    imagePath: 'assets/apple_logo.png', // Replace with your image path
                    rewardText: 'Amazon Gift Card - \$20',
                    points: totalPoints == 0 ? 0 : (100 - totalPoints) / 100 < 0 ? 1 : (100 - totalPoints) / 100,
                  ),
                  RewardCard(
                    color: Colors.blue[400]!,
                    imagePath: 'assets/apple_logo.png', // Replace with your image path
                    rewardText: 'Amazon Gift Card - \$40',
                    points: totalPoints == 0 ? 0 : (150 - totalPoints) / 150 < 0 ? 1 : (150 - totalPoints) / 150,
                  ),
                  RewardCard(
                    color: Colors.green[400]!,
                    imagePath: 'assets/apple_logo.png', // Replace with your image path
                    rewardText: 'Amazon Gift Card - \$60',
                    points: totalPoints == 0 ? 0 : (200 - totalPoints) / 200 < 0 ? 1 : (200 - totalPoints) / 200,
                  ),
                  RewardCard(
                    color: Colors.purple[400]!,
                    imagePath: 'assets/apple_logo.png', // Replace with your image path
                    rewardText: 'Amazon Gift Card - \$80',
                    points: totalPoints == 0 ? 0 : (250 - totalPoints) / 250 < 0 ? 1 : (250 - totalPoints) / 250,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RewardCard extends StatelessWidget {
  final Color color;
  final String imagePath;
  final String rewardText;
  final double points;

  const RewardCard({
    required this.color,
    required this.imagePath,
    required this.rewardText,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360, // Adjusted width for smaller card
      height: 200, // Adjusted height for shorter card
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top half with the image
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover, // Makes the image fill the top half
              ),
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              value: points,
              backgroundColor: Colors.white,
              color: Colors.orangeAccent,
            ),
          ),
          // Bottom half with the details
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    rewardText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    ),
                    child: Text(
                      'Redeem',
                      style: TextStyle(color: color),
                    ),
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

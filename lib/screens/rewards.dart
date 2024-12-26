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
                'Earn Points to Earn More Rewards!',
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
                    points: totalPoints == 100
                        ? 1
                        : (totalPoints == 0
                        ? 0
                        : (100 - totalPoints) / 100 < 0
                        ? 1
                        : (100 - totalPoints) / 100),
                    redeemMessage: 'dasajsadksal', // First card message
                  ),
                  RewardCard(
                    color: Colors.blue[400]!,
                    imagePath: 'assets/apple_logo.png', // Replace with your image path
                    rewardText: 'Amazon Gift Card - \$40',
                    points: totalPoints == 150
                        ? 1
                        : (totalPoints == 0
                        ? 0
                        : (150 - totalPoints) / 150 < 0
                        ? 1
                        : (150 - totalPoints) / 150),
                    redeemMessage: 'jsasijfasioasfijo', // Second card message
                  ),
                  RewardCard(
                    color: Colors.green[400]!,
                    imagePath: 'assets/apple_logo.png', // Replace with your image path
                    rewardText: 'Amazon Gift Card - \$60',
                    points: totalPoints == 200
                        ? 1
                        : (totalPoints == 0
                        ? 0
                        : (200 - totalPoints) / 200 < 0
                        ? 1
                        : (200 - totalPoints) / 200),
                    redeemMessage: 'aijsaojdsioajiods', // Third card message
                  ),
                  RewardCard(
                    color: Colors.purple[400]!,
                    imagePath: 'assets/apple_logo.png', // Replace with your image path
                    rewardText: 'Amazon Gift Card - \$80',
                    points: totalPoints == 250
                        ? 1
                        : (totalPoints == 0
                        ? 0
                        : (250 - totalPoints) / 250 < 0
                        ? 1
                        : (250 - totalPoints) / 250),
                    redeemMessage: 'asijfsajoiasisos', // Fourth card message
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

class RewardCard extends StatefulWidget {
  final Color color;
  final String imagePath;
  final String rewardText;
  final double points;
  final String redeemMessage;

  const RewardCard({
    required this.color,
    required this.imagePath,
    required this.rewardText,
    required this.points,
    required this.redeemMessage,
  });

  @override
  _RewardCardState createState() => _RewardCardState();
}

class _RewardCardState extends State<RewardCard> {
  String? _redeemMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360, // Adjusted width for smaller card
      height: 200, // Adjusted height for shorter card
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: widget.color,
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
                widget.imagePath,
                fit: BoxFit.cover, // Makes the image fill the top half
              ),
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              value: widget.points,
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
                    widget.rewardText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: widget.points == 1
                        ? () {
                      setState(() {
                        // Show the redeem message when button is clicked
                        _redeemMessage = widget.redeemMessage;
                      });
                    }
                        : null, // Disable the button if points != 1
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    ),
                    child: Text(
                      'Redeem',
                      style: TextStyle(
                        color: widget.points == 1 ? widget.color : Colors.grey, // Adjust color based on state
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  if (_redeemMessage != null)
                    Text(
                      _redeemMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
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

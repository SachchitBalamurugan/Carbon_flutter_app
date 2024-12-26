import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/todayBarGraph.dart';
import 'barGraph.dart';
import 'chart.dart';
import 'firebase_options.dart';
import 'package:fl_chart/fl_chart.dart';

import 'home.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(
    home: Analyze(),
  ));
}

class Analyze extends StatefulWidget {
  const Analyze({Key? key}) : super(key: key);

  @override
  _Analyze createState() => _Analyze();
}

class _Analyze extends State<Analyze> {
  final List<Map<String, dynamic>> addedActivities = [];
  String username = ''; // Initially empty username

  // Variables for total points and emissions
  int totalPoints = 0;
  double totalEmissions = 0.0;
  int _currentIndex = 1;

  // Define the screen widgets
  final List<Widget> _screens = [
    ActivityTracker(),
    Analyze(),
    // You can define your Settings widget here
  ];


  // Map for categories with their specific activities and emissions
  final Map<String, List<Map<String, dynamic>>> categoryActivities = {
    'Transportation': [
      {'name': 'Driving a car', 'emissions': 20.0},
      {'name': 'Public transport', 'emissions': 5.0},
      {'name': 'Cycling', 'emissions': 1.0},
    ],
    'Food': [
      {'name': 'Eating meat', 'emissions': 15.0},
      {'name': 'Vegetarian meal', 'emissions': 5.0},
      {'name': 'Vegan meal', 'emissions': 3.0},
    ],
    'Household': [
      {'name': 'Using air conditioning', 'emissions': 10.0},
      {'name': 'Using heater', 'emissions': 8.0},
      {'name': 'Washing clothes', 'emissions': 2.0},
    ],
    'Manufacturing': [
      {'name': 'Making clothes', 'emissions': 25.0},
      {'name': 'Building a car', 'emissions': 100.0},
      {'name': 'Electronics production', 'emissions': 50.0},
    ],
    'Environmental': [
      {'name': 'Planting a tree', 'emissions': -2.0}, // Reduces CO2
      {'name': 'Recycling', 'emissions': -1.0},
      {'name': 'Using renewable energy', 'emissions': -5.0},
    ],
  };

  String? selectedCategory;
  String? selectedActivity;
  List<Map<String, dynamic>> filteredActivities = [];
  double emissions = 0.0;

  @override
  void initState() {
    super.initState();
    _getUsername(); // Get the username when the widget initializes
    _fetchActivitiesFromFirestore(); // Fetch activities from Firebase
  }

  // Function to get the username from Firestore
  Future<void> _getUsername() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the current logged-in user
    if (user != null) {
      // Fetch the user's document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users') // Replace with your Firestore collection name
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          username = userDoc['name'] ?? 'Username'; // Assuming 'name' is the field in Firestore
        });
      } else {
        setState(() {
          username = 'Username'; // Default if no name found
        });
      }
    }
  }

  // Function to fetch activities from Firestore and display them
  // Function to fetch activities from Firestore and calculate total emissions
  Future<void> _fetchActivitiesFromFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users') // Users collection
          .doc(user.uid) // The user's UID as the document ID
          .collection('activities') // Subcollection for activities
          .orderBy('timestamp', descending: true) // Order activities by timestamp
          .get();

      double totalEmissionsFromFirestore = 0.0;

      // Iterate over the fetched activities to sum emissions
      for (var doc in snapshot.docs) {
        double emissions = doc['emissions']?.toDouble() ?? 0.0; // Ensure it's a double
        totalEmissionsFromFirestore += emissions;
      }

      // Print total emissions to the console
      print("Total emissions: $totalEmissionsFromFirestore kg CO2");

      setState(() {
        addedActivities.clear();
        addedActivities.addAll(snapshot.docs.map((doc) {
          return {
            'activity': doc['activity'],
            'quantity': doc['quantity'],
            'emissions': doc['emissions'].toString(),
            'category': doc['category'],
          };
        }).toList());

        // Update the total emissions in the UI
        totalEmissions = totalEmissionsFromFirestore;
      });
    }
  }


  // Function to filter activities based on the selected category
  void _filterActivities(String? category) {
    if (category != null && categoryActivities.containsKey(category)) {
      setState(() {
        filteredActivities = categoryActivities[category]!; // Update activities
        selectedActivity = null; // Reset the activity when the category changes
      });
    }
  }

  // Function to add a new activity
  // Function to add a new activity
  Future<void> _addActivity() async {
    String quantity = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Activity'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Select Category'),
                    value: selectedCategory,
                    items: categoryActivities.keys
                        .map((category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                        _filterActivities(selectedCategory); // Update activities
                      });
                      print('Selected category: $selectedCategory');
                    },
                  ),
                  const SizedBox(height: 10),
                  // Activity Dropdown (dynamic based on selected category)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Select Activity'),
                    value: selectedActivity,
                    items: filteredActivities
                        .map((activity) => DropdownMenuItem<String>(
                      value: activity['name'],
                      child: Text(activity['name']),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedActivity = value;
                        emissions = filteredActivities
                            .firstWhere((activity) =>
                        activity['name'] == value)['emissions'];
                      });
                      print('Selected activity: $selectedActivity');
                    },
                  ),
                  const SizedBox(height: 10),
                  // Quantity Input
                  TextField(
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => quantity = value,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedActivity != null && quantity.isNotEmpty) {
                      final double totalEmissionsForActivity =
                          emissions * double.parse(quantity); // Calculate total emissions

                      setState(() {
                        addedActivities.add({
                          'activity': selectedActivity,
                          'quantity': quantity,
                          'emissions': totalEmissionsForActivity.toStringAsFixed(2),
                          'category': selectedCategory,
                          'color': _getCategoryColor(selectedCategory),
                        });

                        // Update total emissions
                        totalEmissions += totalEmissionsForActivity; // Add the emissions of the new activity
                        totalPoints += 10; // Placeholder points per activity
                      });

                      // Save activity to Firestore under the current user's document
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await FirebaseFirestore.instance
                            .collection('users') // Users collection
                            .doc(user.uid) // The user's UID as the document ID
                            .collection('activities') // Subcollection for activities
                            .add({
                          'activity': selectedActivity,
                          'quantity': quantity,
                          'emissions': totalEmissionsForActivity,
                          'category': selectedCategory,
                          'timestamp': FieldValue.serverTimestamp(), // Save the current timestamp
                        });
                      }

                      Navigator.pop(context);
                      setState(() {}); // Trigger a rebuild after the dialog closes
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Function to get color based on category
  // Function to get color based on category
  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Transportation':
        return Colors.green;
      case 'Food':
        return Colors.orange;
      case 'Household':
        return Colors.blue;
      case 'Manufacturing':
        return Colors.red;
      case 'Environmental':
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting and username
              Text(
                'Carbon Tracker Dashboard',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Understand your impact.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              // Total Points and Emissions Saved

              const Text(
                'Total Emissions by Category',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const EmissionChartByCategory(), // This will display the chart
              const Text(
                'Today\'s Emissions by Category',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const EmissionChartByCategory2(), // This will display the chart
            ],
          ),
        ),
      ),

    );
  }
}

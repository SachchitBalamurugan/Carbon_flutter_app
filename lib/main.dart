import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(
    home: ActivityTracker(),
  ));
}

class ActivityTracker extends StatefulWidget {
  const ActivityTracker({Key? key}) : super(key: key);

  @override
  _ActivityTrackerState createState() => _ActivityTrackerState();
}

class _ActivityTrackerState extends State<ActivityTracker> {
  final List<Map<String, dynamic>> addedActivities = [];
  String username = 'Username'; // Placeholder username

  // Variables for total points and emissions
  int totalPoints = 0;
  double totalEmissions = 0.0;

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

  // Function to filter activities based on the selected category
  void _filterActivities(String? category) {
    if (category != null && categoryActivities.containsKey(category)) {
      setState(() {
        filteredActivities = categoryActivities[category]!;
        selectedActivity = null; // Reset the activity when the category changes
      });
    }
  }

  // Function to add a new activity
  void _addActivity() {
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
                            .firstWhere((activity) => activity['name'] == value)['emissions'];
                      });
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
                  onPressed: () {
                    if (selectedActivity != null && quantity.isNotEmpty) {
                      final double totalEmissionsForActivity =
                          emissions * double.parse(quantity); // Calculate total emissions

                      setState(() {
                        addedActivities.add({
                          'activity': selectedActivity,
                          'quantity': quantity,
                          'emissions': totalEmissionsForActivity.toStringAsFixed(2), // Add total emissions
                          'category': selectedCategory,
                          'color': _getCategoryColor(selectedCategory),
                        });
                        // Update total emissions and points
                        totalEmissions += totalEmissionsForActivity; // Update total emissions
                        totalPoints += 10; // Placeholder points per activity
                      });
                      Navigator.pop(context);
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
      appBar: AppBar(
        title: const Text('Eco Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Handle logout logic here
            },
          ),
        ],
        backgroundColor: Colors.lightGreenAccent[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting and username
            Text(
              'Good day, $username',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explore your progress and eco-footprint for a sustainable future.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Total Points and Emissions Saved
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Earned Points', style: TextStyle(fontSize: 14)),
                    Text(
                      '$totalPoints',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Emissions Saved', style: TextStyle(fontSize: 14)),
                    Text(
                      '$totalEmissions kg CO2',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Add Activity Button
            ElevatedButton(
              onPressed: _addActivity,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreenAccent[400],
              ),
              child: const Text('Add New Activity'),
            ),

            const SizedBox(height: 20),

            // List of Activities
            Expanded(
              child: ListView.builder(
                itemCount: addedActivities.length,
                itemBuilder: (context, index) {
                  final activity = addedActivities[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: activity['color'] ?? Colors.grey,
                        radius: 8,
                      ),
                      title: Text(activity['activity'] ?? ''),
                      subtitle: Text(
                        'Quantity: ${activity['quantity']} CO2 Emissions: ${activity['emissions']} kg',
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: Text(
                        activity['category'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // Handle bottom navigation here
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

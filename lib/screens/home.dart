import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled2/screens/rewards.dart';
import 'package:untitled2/screens/statistics.dart';
import '../components/chart.dart';
import '../firebase_options.dart';
import 'package:fl_chart/fl_chart.dart';

import 'ai.dart';
import 'community.dart';
int totalPoints = 0;

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
  String username = ''; // Initially empty username

  // Variables for total points and emissions

  double totalEmissions = 0.0;
  int _currentIndex = 0;

  // Define the screen widgets
  final List<Widget> _screens = [
    ActivityTracker(),
    Analyze(),
    RewardPageApp(),
    FeedbackScreen(),
    PostsScreen()
    // You can define your Settings widget here
  ];


  // Map for categories with their specific activities and emissions
  final Map<String, List<Map<String, dynamic>>> categoryActivities = {
    'Transportation': [
      {'name': 'Driving a car (gasoline) 1 km', 'emissions': 0.192},
      {'name': 'Driving a car (diesel) 1 km', 'emissions': 0.220},
      {'name': 'Driving a motorcycle 1 km', 'emissions': 0.075},
      {'name': 'Driving a bus 1 km', 'emissions': 0.098},
      {'name': 'Flying (economy class) 1 km', 'emissions': 0.115},
      {'name': 'Flying (business class) 1 km', 'emissions': 0.230},
      {'name': 'Taking a bus ride (per km)', 'emissions': 0.090},
      {'name': 'Taking a train ride (per km)', 'emissions': 0.041},
      {'name': 'Taking a metro ride (per km)', 'emissions': 0.035},
      {'name': 'Driving a truck 1 km', 'emissions': 0.170},
      {'name': 'Cycling 1 km', 'emissions': 0.000},
      {'name': 'Walking 1 km', 'emissions': 0.000},
      {'name': 'Using a ferry (per km)', 'emissions': 0.250},
      {'name': 'Electric scooter 1 km', 'emissions': 0.020},
      {'name': 'Electric bike 1 km', 'emissions': 0.005},
      {'name': 'Electric car (per km)', 'emissions': 0.080},
      {'name': 'Carpooling (per km)', 'emissions': 0.070},
      {'name': 'Driving an electric bus (per km)', 'emissions': 0.050},
      {'name': 'Electric tram (per km)', 'emissions': 0.030},
      {'name': 'Taking an electric ferry (per km)', 'emissions': 0.040},
      {'name': 'Electric train ride (per km)', 'emissions': 0.020},
      {'name': 'Riding a horse (per km)', 'emissions': 0.010},
      {'name': 'Shipping freight (per ton-km)', 'emissions': 0.020},
      {'name': 'Using an electric skateboard (per km)', 'emissions': 0.015},
      {'name': 'Driving a hybrid car (per km)', 'emissions': 0.140},
      {'name': 'Car sharing (per km)', 'emissions': 0.060},
      {'name': 'Renting a car (per km)', 'emissions': 0.100},
      {'name': 'Driving a van (per km)', 'emissions': 0.200},
      {'name': 'Driving a SUV (per km)', 'emissions': 0.250},
      {'name': 'Driving a convertible (per km)', 'emissions': 0.180},
      {'name': 'Driving a pickup truck (per km)', 'emissions': 0.210},
      {'name': 'Driving a campervan (per km)', 'emissions': 0.300},
      {'name': 'Driving a minivan (per km)', 'emissions': 0.220},
      {'name': 'Driving a luxury car (per km)', 'emissions': 0.250},
      {'name': 'Driving a sports car (per km)', 'emissions': 0.280},
      {'name': 'Driving a compact car (per km)', 'emissions': 0.150},
      {'name': 'Using a motorboat (per km)', 'emissions': 0.300},
      {'name': 'Using a sailboat (per km)', 'emissions': 0.150},
      {'name': 'Using a jet ski (per km)', 'emissions': 0.350},
      {'name': 'Taking a ferry (per km)', 'emissions': 0.250},
      {'name': 'Using a helicopter (per km)', 'emissions': 1.000},
      {'name': 'Using a private jet (per km)', 'emissions': 1.500},
      {'name': 'Using a commercial jet (per km)', 'emissions': 0.500},
      {'name': 'Driving a taxi (per km)', 'emissions': 0.180},
      {'name': 'Using a ride-sharing service (per km)', 'emissions': 0.170},
      {'name': 'Driving an electric van (per km)', 'emissions': 0.060},
      {'name': 'Driving an electric SUV (per km)', 'emissions': 0.080},
      {'name': 'Driving a hybrid bus (per km)', 'emissions': 0.090},
      {'name': 'Driving an electric motorcycle (per km)', 'emissions': 0.040},
      {'name': 'Using an electric ferry (per km)', 'emissions': 0.050},
      {'name': 'Using a cable car (per km)', 'emissions': 0.020},
      {'name': 'Using a monorail (per km)', 'emissions': 0.040},
      {'name': 'Driving an autonomous car (per km)', 'emissions': 0.160},
      {'name': 'Taking a luxury bus (per km)', 'emissions': 0.120},
      {'name': 'Using an electric scooter (per km)', 'emissions': 0.020},
      {'name': 'Using an electric bike (per km)', 'emissions': 0.010},
      {'name': 'Taking a ride-sharing bike (per km)', 'emissions': 0.015},
      {'name': 'Using a bicycle (per km)', 'emissions': 0.000},
      {'name': 'Using a scooter (per km)', 'emissions': 0.025},
      {'name': 'Driving a classic car (per km)', 'emissions': 0.250},
      {'name': 'Driving a vintage car (per km)', 'emissions': 0.280},
      {'name': 'Driving a small car (per km)', 'emissions': 0.140},
      {'name': 'Driving a large car (per km)', 'emissions': 0.220},
      {'name': 'Driving a compact SUV (per km)', 'emissions': 0.200},
      {'name': 'Using a motorized skateboard (per km)', 'emissions': 0.030},
      {'name': 'Driving a car with a trailer (per km)', 'emissions': 0.300},
      {'name': 'Using a golf cart (per km)', 'emissions': 0.010},
      {'name': 'Using an electric scooter (per km)', 'emissions': 0.020},
      {'name': 'Driving a luxury SUV (per km)', 'emissions': 0.260},
      {'name': 'Using a hoverboard (per km)', 'emissions': 0.015},
      {'name': 'Taking an intercity bus (per km)', 'emissions': 0.110},
      {'name': 'Driving a delivery van (per km)', 'emissions': 0.230},
      {'name': 'Using a tram (per km)', 'emissions': 0.025},
      {'name': 'Driving a minibus (per km)', 'emissions': 0.180},
      {'name': 'Using an electric car sharing service (per km)', 'emissions': 0.050},
      {'name': 'Using a drone for delivery (per km)', 'emissions': 0.200},
      {'name': 'Using a bike-sharing service (per km)', 'emissions': 0.015},
      {'name': 'Using a hybrid taxi (per km)', 'emissions': 0.120},
      {'name': 'Using a motorized rickshaw (per km)', 'emissions': 0.100},
      {'name': 'Using a funicular (per km)', 'emissions': 0.040},
      {'name': 'Driving a fuel cell vehicle (per km)', 'emissions': 0.070},
      {'name': 'Driving a LNG vehicle (per km)', 'emissions': 0.080},
      {'name': 'Driving a CNG vehicle (per km)', 'emissions': 0.060},
      {'name': 'Driving a LPG vehicle (per km)', 'emissions': 0.050},
      {'name': 'Using a passenger ferry (per km)', 'emissions': 0.200},
      {'name': 'Using a high-speed train (per km)', 'emissions': 0.030},
      {'name': 'Using a regular train (per km)', 'emissions': 0.040},
      {'name': 'Using a light rail (per km)', 'emissions': 0.035},
      {'name': 'Using an autonomous shuttle (per km)', 'emissions': 0.050},
      {'name': 'Driving a refrigerated truck (per km)', 'emissions': 0.250},
      {'name': 'Using a hybrid freight truck (per km)', 'emissions': 0.150},
      {'name': 'Using an electric delivery bike (per km)', 'emissions': 0.010},
      {'name': 'Using a hydrogen bus (per km)', 'emissions': 0.070},
      {'name': 'Driving an electric truck (per km)', 'emissions': 0.080},
      {'name': 'Using a robotic delivery vehicle (per km)', 'emissions': 0.020}
    ],
    'Food': [
      {'name': 'Eating 1 kg of beef', 'emissions': 27.0},
      {'name': 'Eating 1 kg of chicken', 'emissions': 6.9},
      {'name': 'Eating 1 kg of pork', 'emissions': 12.1},
      {'name': 'Eating 1 kg of lamb', 'emissions': 39.2},
      {'name': 'Eating 1 kg of cheese', 'emissions': 13.5},
      {'name': 'Drinking 1 liter of milk', 'emissions': 1.2},
      {'name': 'Producing 1 kg of rice', 'emissions': 2.7},
      {'name': 'Eating 1 kg of potatoes', 'emissions': 0.4},
      {'name': 'Eating 1 kg of eggs', 'emissions': 4.8},
      {'name': 'Drinking 1 liter of almond milk', 'emissions': 0.6},
      {'name': 'Drinking 1 liter of soy milk', 'emissions': 0.9},
      {'name': 'Eating 1 kg of fish (farmed)', 'emissions': 5.0},
      {'name': 'Eating 1 kg of lentils', 'emissions': 0.9},
      {'name': 'Eating 1 kg of broccoli', 'emissions': 0.2},
      {'name': 'Drinking 1 cup of coffee', 'emissions': 0.02},
      {'name': 'Eating 1 kg of tofu', 'emissions': 3.2},
      {'name': 'Drinking 1 liter of orange juice', 'emissions': 0.9},
      {'name': 'Eating 1 kg of chocolate', 'emissions': 19.0},
      {'name': 'Eating 1 kg of avocados', 'emissions': 2.0},
      {'name': 'Drinking 1 liter of beer', 'emissions': 1.5},
      {'name': 'Eating 1 kg of bananas', 'emissions': 0.5},
      {'name': 'Eating 1 kg of peanuts', 'emissions': 2.6},
      {'name': 'Eating 1 kg of soybeans', 'emissions': 2.1},
      {'name': 'Eating 1 kg of apples', 'emissions': 0.3},
      {'name': 'Drinking 1 liter of wine', 'emissions': 1.2},
      {'name': 'Eating 1 kg of pasta', 'emissions': 1.1},
      {'name': 'Eating 1 kg of duck', 'emissions': 16.0},
      {'name': 'Eating 1 kg of turkey', 'emissions': 8.0},
      {'name': 'Eating 1 kg of lamb shank', 'emissions': 35.0},
      {'name': 'Eating 1 kg of venison', 'emissions': 14.0},
      {'name': 'Eating 1 kg of tofu stir-fry', 'emissions': 3.5},
      {'name': 'Eating 1 kg of quinoa', 'emissions': 1.2},
      {'name': 'Eating 1 kg of kale', 'emissions': 0.6},
      {'name': 'Eating 1 kg of mushrooms', 'emissions': 1.0},
      {'name': 'Eating 1 kg of spinach', 'emissions': 0.4},
      {'name': 'Eating 1 kg of chickpeas', 'emissions': 1.5},
      {'name': 'Eating 1 kg of yogurt', 'emissions': 1.0},
      {'name': 'Eating 1 kg of hummus', 'emissions': 1.8},
      {'name': 'Eating 1 kg of sauerkraut', 'emissions': 1.0},
      {'name': 'Eating 1 kg of tempeh', 'emissions': 4.0},
      {'name': 'Eating 1 kg of cauliflower', 'emissions': 0.5},
      {'name': 'Eating 1 kg of carrots', 'emissions': 0.3},
      {'name': 'Eating 1 kg of cabbage', 'emissions': 0.3},
      {'name': 'Eating 1 kg of tomatoes', 'emissions': 0.8},
      {'name': 'Eating 1 kg of blueberries', 'emissions': 1.0},
      {'name': 'Eating 1 kg of grapes', 'emissions': 1.2},
      {'name': 'Eating 1 kg of strawberries', 'emissions': 1.5},
      {'name': 'Eating 1 kg of raspberries', 'emissions': 1.8},
      {'name': 'Eating 1 kg of cherries', 'emissions': 2.0},
      {'name': 'Eating 1 kg of peaches', 'emissions': 1.2},
      {'name': 'Eating 1 kg of plums', 'emissions': 1.4},
      {'name': 'Eating 1 kg of pears', 'emissions': 1.0},
      {'name': 'Eating 1 kg of apples (organic)', 'emissions': 0.4},
      {'name': 'Eating 1 kg of avocados (organic)', 'emissions': 1.5},
      {'name': 'Eating 1 kg of nuts', 'emissions': 2.5},
      {'name': 'Eating 1 kg of seeds', 'emissions': 1.0},
      {'name': 'Eating 1 kg of olives', 'emissions': 0.8},
      {'name': 'Eating 1 kg of yogurt (plant-based)', 'emissions': 0.9},
      {'name': 'Eating 1 kg of almond butter', 'emissions': 2.5},
      {'name': 'Eating 1 kg of peanut butter', 'emissions': 3.0},
      {'name': 'Eating 1 kg of pasta (whole grain)', 'emissions': 1.0},
      {'name': 'Eating 1 kg of rice (brown)', 'emissions': 2.5},
      {'name': 'Eating 1 kg of bread (whole grain)', 'emissions': 1.2},
      {'name': 'Eating 1 kg of bread (white)', 'emissions': 1.5},
      {'name': 'Eating 1 kg of pizza', 'emissions': 3.0},
      {'name': 'Eating 1 kg of burgers', 'emissions': 2.0},
      {'name': 'Eating 1 kg of fried chicken', 'emissions': 4.0},
      {'name': 'Eating 1 kg of ice cream', 'emissions': 2.5},
      {'name': 'Eating 1 kg of chocolate (dark)', 'emissions': 18.0},
      {'name': 'Eating 1 kg of chocolate (milk)', 'emissions': 20.0},
      {'name': 'Eating 1 kg of candies', 'emissions': 15.0},
      {'name': 'Eating 1 kg of popcorn', 'emissions': 2.0},
      {'name': 'Eating 1 kg of pastries', 'emissions': 3.5},
      {'name': 'Eating 1 kg of cheese (vegan)', 'emissions': 6.0},
      {'name': 'Eating 1 kg of tofu (extra firm)', 'emissions': 4.0},
      {'name': 'Eating 1 kg of seitan', 'emissions': 4.5},
      {'name': 'Eating 1 kg of tempeh (fermented)', 'emissions': 3.8}
    ],
    'Household': [
      {'name': 'Heating a home with natural gas (per hour)', 'emissions': 1.91},
      {'name': 'Using a 60W incandescent light bulb for 1 hour', 'emissions': 0.042},
      {'name': 'Watching TV for 1 hour', 'emissions': 0.088},
      {'name': 'Using a laptop for 1 hour', 'emissions': 0.015},
      {'name': 'Boiling a kettle (1 time)', 'emissions': 0.015},
      {'name': 'Cooking with electric oven (1 hour)', 'emissions': 1.15},
      {'name': 'Running a washing machine (per load)', 'emissions': 0.6},
      {'name': 'Taking a 10-minute shower', 'emissions': 0.8},
      {'name': 'Using a dishwasher (per load)', 'emissions': 1.2},
      {'name': 'Charging an electric vehicle (per kWh)', 'emissions': 0.3},
      {'name': 'Running a vacuum cleaner (per hour)', 'emissions': 0.4},
      {'name': 'Using an electric blanket (per hour)', 'emissions': 0.1},
      {'name': 'Using an air conditioner (per hour)', 'emissions': 0.6},
      {'name': 'Using a space heater (per hour)', 'emissions': 0.4},
      {'name': 'Using a refrigerator (per day)', 'emissions': 1.0},
      {'name': 'Using a freezer (per day)', 'emissions': 1.5},
      {'name': 'Using a hairdryer (per use)', 'emissions': 0.05},
      {'name': 'Running a tumble dryer (per load)', 'emissions': 2.0},
      {'name': 'Using a microwave (per minute)', 'emissions': 0.02},
      {'name': 'Running an electric stove (per hour)', 'emissions': 1.2},
      {'name': 'Charging a smartphone (1 full charge)', 'emissions': 0.005},
      {'name': 'Using a fan (per hour)', 'emissions': 0.03},
      {'name': 'Running a blender (per minute)', 'emissions': 0.015},
      {'name': 'Using a clothes iron (per hour)', 'emissions': 1.2},
      {'name': 'Using a dehumidifier (per hour)', 'emissions': 0.5},
      {'name': 'Using a slow cooker (per hour)', 'emissions': 0.6},
      {'name': 'Using an electric kettle (per use)', 'emissions': 0.015},
      {'name': 'Using a toaster (per use)', 'emissions': 0.03},
      {'name': 'Using a coffee machine (per use)', 'emissions': 0.05},
      {'name': 'Using an electric grill (per hour)', 'emissions': 1.0},
      {'name': 'Using a hot water heater (per hour)', 'emissions': 2.0},
      {'name': 'Using a clothes dryer (per load)', 'emissions': 2.0},
      {'name': 'Using an oven (per hour)', 'emissions': 1.5},
      {'name': 'Using a dishwasher (per load)', 'emissions': 1.2},
      {'name': 'Using a microwave (per minute)', 'emissions': 0.02},
      {'name': 'Using a refrigerator (per day)', 'emissions': 1.0},
      {'name': 'Using a freezer (per day)', 'emissions': 1.5},
      {'name': 'Using a hairdryer (per use)', 'emissions': 0.05},
      {'name': 'Using a fan (per hour)', 'emissions': 0.03},
      {'name': 'Using a clothes iron (per hour)', 'emissions': 1.2},
      {'name': 'Using a blender (per minute)', 'emissions': 0.015},
      {'name': 'Using a vacuum cleaner (per hour)', 'emissions': 0.4},
      {'name': 'Using an air purifier (per hour)', 'emissions': 0.04},
      {'name': 'Using a space heater (per hour)', 'emissions': 0.4},
      {'name': 'Using a dehumidifier (per hour)', 'emissions': 0.5},
      {'name': 'Using an electric blanket (per hour)', 'emissions': 0.1},
      {'name': 'Using a toaster oven (per hour)', 'emissions': 0.6},
      {'name': 'Using a steam cleaner (per hour)', 'emissions': 0.5},
      {'name': 'Using a pizza oven (per hour)', 'emissions': 1.5},
      {'name': 'Using a slow cooker (per hour)', 'emissions': 0.6},
      {'name': 'Using a sous vide machine (per hour)', 'emissions': 0.4},
      {'name': 'Using a food processor (per minute)', 'emissions': 0.015},
      {'name': 'Using a popcorn maker (per use)', 'emissions': 0.1},
      {'name': 'Using a coffee grinder (per use)', 'emissions': 0.01},
      {'name': 'Using a bread maker (per hour)', 'emissions': 0.5},
      {'name': 'Using a waffle maker (per use)', 'emissions': 0.05},
      {'name': 'Using a meat grinder (per use)', 'emissions': 0.02},
      {'name': 'Using a rice cooker (per hour)', 'emissions': 0.5},
      {'name': 'Using a deep fryer (per hour)', 'emissions': 1.0},
      {'name': 'Using a kitchen scale (per use)', 'emissions': 0.01},
      {'name': 'Using a food dehydrator (per hour)', 'emissions': 0.3},
      {'name': 'Using an espresso machine (per use)', 'emissions': 0.1},
      {'name': 'Using a milk frother (per use)', 'emissions': 0.01},
      {'name': 'Using an electric kettle (per use)', 'emissions': 0.015},
      {'name': 'Using a meat thermometer (per use)', 'emissions': 0.005},
      {'name': 'Using a popcorn maker (per use)', 'emissions': 0.05},
      {'name': 'Using a milk frother (per use)', 'emissions': 0.02},
      {'name': 'Using a fruit juicer (per use)', 'emissions': 0.05},
      {'name': 'Using a nut grinder (per use)', 'emissions': 0.01},
      {'name': 'Using an electric can opener (per use)', 'emissions': 0.02},
      {'name': 'Using an ice maker (per use)', 'emissions': 0.03},
      {'name': 'Using an egg cooker (per use)', 'emissions': 0.02}
    ],
    'Manufacturing': [
      {'name': 'Producing 1 kg of plastic', 'emissions': 6.0},
      {'name': 'Producing 1 kg of steel', 'emissions': 2.0},
      {'name': 'Producing 1 kg of aluminum', 'emissions': 11.0},
      {'name': 'Producing 1 kg of cement', 'emissions': 0.930},
      {'name': 'Producing 1 kg of glass', 'emissions': 0.75},
      {'name': 'Manufacturing 1 kg of textile', 'emissions': 5.0},
      {'name': 'Manufacturing 1 car', 'emissions': 6000},
      {'name': 'Producing 1 pair of shoes', 'emissions': 14},
      {'name': 'Producing 1 kg of paper', 'emissions': 1.5},
      {'name': 'Producing 1 smartphone', 'emissions': 85},
      {'name': 'Manufacturing 1 computer', 'emissions': 300},
      {'name': 'Producing 1 kg of bricks', 'emissions': 0.45},
      {'name': 'Producing 1 pair of jeans', 'emissions': 25},
      {'name': 'Producing 1 kg of rubber', 'emissions': 2.4},
      {'name': 'Producing 1 kg of glass bottles', 'emissions': 0.8},
      {'name': 'Producing 1 car tire', 'emissions': 24},
      {'name': 'Producing 1 steel beam (1 meter)', 'emissions': 15},
      {'name': 'Producing 1 kg of fertilizer', 'emissions': 6.8},
      {'name': 'Producing 1 kg of paint', 'emissions': 4.0},
      {'name': 'Producing 1 kg of batteries', 'emissions': 15},
      {'name': 'Producing 1 solar panel', 'emissions': 50},
      {'name': 'Producing 1 wind turbine blade', 'emissions': 100},
      {'name': 'Producing 1 kg of copper wire', 'emissions': 2.5},
      {'name': 'Producing 1 kg of styrofoam', 'emissions': 6.0},
      {'name': 'Producing 1 kg of ceramic tiles', 'emissions': 0.9},
      {'name': 'Producing 1 kg of rubber', 'emissions': 2.4},
      {'name': 'Producing 1 kg of textiles', 'emissions': 5.0},
      {'name': 'Producing 1 kg of electronic components', 'emissions': 8.0},
      {'name': 'Producing 1 kg of batteries', 'emissions': 15.0},
      {'name': 'Manufacturing 1 smartphone', 'emissions': 85.0},
      {'name': 'Producing 1 kg of cardboard', 'emissions': 1.0},
      {'name': 'Producing 1 kg of paper', 'emissions': 1.5},
      {'name': 'Producing 1 kg of paint', 'emissions': 4.0},
      {'name': 'Manufacturing 1 laptop', 'emissions': 300.0},
      {'name': 'Manufacturing 1 tablet', 'emissions': 150.0},
      {'name': 'Manufacturing 1 refrigerator', 'emissions': 200.0},
      {'name': 'Manufacturing 1 washing machine', 'emissions': 100.0},
      {'name': 'Manufacturing 1 dishwasher', 'emissions': 120.0},
      {'name': 'Manufacturing 1 microwave', 'emissions': 50.0},
      {'name': 'Manufacturing 1 oven', 'emissions': 150.0},
      {'name': 'Manufacturing 1 air conditioner', 'emissions': 250.0},
      {'name': 'Manufacturing 1 TV', 'emissions': 80.0},
      {'name': 'Manufacturing 1 printer', 'emissions': 30.0},
      {'name': 'Producing 1 kg of steel beams', 'emissions': 3.0},
      {'name': 'Producing 1 kg of copper wire', 'emissions': 2.5},
      {'name': 'Producing 1 kg of solar panels', 'emissions': 50.0},
      {'name': 'Producing 1 kg of wind turbine blades', 'emissions': 100.0},
      {'name': 'Producing 1 kg of aluminum cans', 'emissions': 0.8},
      {'name': 'Producing 1 kg of ceramic tiles', 'emissions': 0.9},
      {'name': 'Producing 1 kg of fiberglass', 'emissions': 1.5},
      {'name': 'Manufacturing 1 bicycle', 'emissions': 20.0},
      {'name': 'Manufacturing 1 skateboard', 'emissions': 5.0},
      {'name': 'Manufacturing 1 kayak', 'emissions': 30.0},
      {'name': 'Manufacturing 1 surfboard', 'emissions': 20.0},
      {'name': 'Producing 1 kg of wool', 'emissions': 4.0},
      {'name': 'Producing 1 kg of leather', 'emissions': 15.0},
      {'name': 'Manufacturing 1 pair of shoes', 'emissions': 14.0},
      {'name': 'Manufacturing 1 handbag', 'emissions': 5.0},
      {'name': 'Manufacturing 1 suitcase', 'emissions': 8.0},
      {'name': 'Manufacturing 1 belt', 'emissions': 2.0},
      {'name': 'Manufacturing 1 pair of gloves', 'emissions': 1.5},
      {'name': 'Manufacturing 1 scarf', 'emissions': 2.0},
      {'name': 'Manufacturing 1 hat', 'emissions': 1.0},
      {'name': 'Manufacturing 1 coat', 'emissions': 10.0},
      {'name': 'Producing 1 kg of synthetic fabric', 'emissions': 5.0},
      {'name': 'Producing 1 kg of organic fabric', 'emissions': 2.0},
      {'name': 'Producing 1 kg of recycled plastic', 'emissions': 3.0},
      {'name': 'Manufacturing 1 electric guitar', 'emissions': 4.0},
      {'name': 'Manufacturing 1 drum set', 'emissions': 15.0},
      {'name': 'Manufacturing 1 violin', 'emissions': 5.0},
      {'name': 'Manufacturing 1 piano', 'emissions': 200.0},
      {'name': 'Manufacturing 1 camera', 'emissions': 30.0},
      {'name': 'Manufacturing 1 drone', 'emissions': 50.0},
      {'name': 'Manufacturing 1 television', 'emissions': 80.0},
      {'name': 'Manufacturing 1 stereo system', 'emissions': 60.0},
      {'name': 'Manufacturing 1 microwave oven', 'emissions': 50.0},
      {'name': 'Manufacturing 1 hairdryer', 'emissions': 5.0}
    ],
    'Environmental': [
      {'name': 'Recycling 1 kg of paper', 'emissions': -0.91},
      {'name': 'Planting a tree (per tree)', 'emissions': -0.25},
      {'name': 'Growing a Christmas tree (cutting)', 'emissions': 2.6},
      {'name': 'Using a wind turbine (per kWh)', 'emissions': 0.012},
      {'name': 'Using a solar panel (per kWh)', 'emissions': 0.020},
      {'name': 'Using a geothermal plant (per kWh)', 'emissions': 0.009},
      {'name': 'Using a hydropower plant (per kWh)', 'emissions': 0.015},
      {'name': 'Using a biomass heater (per hour)', 'emissions': 0.5},
      {'name': 'Using a nuclear power plant (per kWh)', 'emissions': 0.01},
      {'name': 'Recycling 1 kg of aluminum', 'emissions': -8.0},
      {'name': 'Recycling 1 kg of steel', 'emissions': -1.4},
      {'name': 'Composting 1 kg of organic waste', 'emissions': -0.2},
      {'name': 'Using a fusion reactor (per kWh)', 'emissions': 0.0},
      {'name': 'Using a tidal generator (per kWh)', 'emissions': 0.01},
      {'name': 'Using a wave generator (per kWh)', 'emissions': 0.02},
      {'name': 'Using a smart thermostat (per hour)', 'emissions': 0.01},
      {'name': 'Offsetting carbon footprint (per ton)', 'emissions': -1000},
      {'name': 'Growing organic produce (per kg)', 'emissions': -0.5},
      {'name': 'Producing biogas (per kWh)', 'emissions': -0.1},
      {'name': 'Capturing CO2 through direct air capture (per ton)', 'emissions': -500},
      {'name': 'Recycling plastic (per kg)', 'emissions': -1.7},
      {'name': 'Using geothermal energy (per kWh)', 'emissions': 0.02},
      {'name': 'Using a heat pump (per hour)', 'emissions': 0.03},
      {'name': 'Using a solar water heater (per hour)', 'emissions': 0.02},
      {'name': 'Recycling glass (per kg)', 'emissions': -0.5},
      {'name': 'Composting 1 kg of food waste', 'emissions': -0.5},
      {'name': 'Recycling 1 kg of plastic bottles', 'emissions': -1.0},
      {'name': 'Recycling 1 kg of aluminum cans', 'emissions': -1.5},
      {'name': 'Recycling 1 kg of glass bottles', 'emissions': -0.7},
      {'name': 'Recycling 1 kg of electronic waste', 'emissions': -2.0},
      {'name': 'Using a geothermal heating system (per kWh)', 'emissions': 0.015},
      {'name': 'Using hydroelectric power (per kWh)', 'emissions': 0.010},
      {'name': 'Recycling 1 kg of metal scrap', 'emissions': -1.2},
      {'name': 'Recycling 1 kg of cardboard', 'emissions': -0.8},
      {'name': 'Recycling 1 kg of textiles', 'emissions': -1.0},
      {'name': 'Recycling 1 kg of rubber tires', 'emissions': -1.5},
      {'name': 'Recycling 1 kg of batteries', 'emissions': -2.5},
      {'name': 'Planting 1 square meter of garden', 'emissions': -0.1},
      {'name': 'Using a rainwater harvesting system (per liter)', 'emissions': -0.01},
      {'name': 'Using a water-efficient toilet (per use)', 'emissions': -0.05},
      {'name': 'Installing energy-efficient windows (per square meter)', 'emissions': -0.1},
      {'name': 'Installing insulation (per square meter)', 'emissions': -0.2},
      {'name': 'Using an electric vehicle (per kWh)', 'emissions': 0.05},
      {'name': 'Using a hybrid vehicle (per kWh)', 'emissions': 0.03},
      {'name': 'Using a carbon offset program (per ton)', 'emissions': -1.0},
      {'name': 'Participating in a reforestation project (per ton)', 'emissions': -2.0},
      {'name': 'Participating in a clean energy project (per ton)', 'emissions': -3.0},
      {'name': 'Participating in a waste reduction program (per ton)', 'emissions': -1.5},
      {'name': 'Participating in a biodiversity conservation program (per ton)', 'emissions': -2.5},
      {'name': 'Recycling 1 kg of construction debris', 'emissions': -1.8},
      {'name': 'Recycling 1 kg of hazardous waste', 'emissions': -2.0},
      {'name': 'Participating in a carbon capture program (per ton)', 'emissions': -4.0},
      {'name': 'Using a low-flow showerhead (per use)', 'emissions': -0.02},
      {'name': 'Using a low-flow faucet (per use)', 'emissions': -0.01},
      {'name': 'Using an energy-efficient appliance (per kWh)', 'emissions': -0.05},
      {'name': 'Using a programmable thermostat (per month)', 'emissions': -0.1},
      {'name': 'Participating in a zero-waste lifestyle program (per year)', 'emissions': -5.0},
      {'name': 'Participating in a community recycling program (per year)', 'emissions': -1.0},
      {'name': 'Using a sustainable fashion product (per item)', 'emissions': -0.2},
      {'name': 'Using a plant-based cleaning product (per liter)', 'emissions': -0.1},
      {'name': 'Participating in a community garden (per square meter)', 'emissions': -0.2},
      {'name': 'Installing solar panels (per square meter)', 'emissions': -0.3},
      {'name': 'Using a green roof (per square meter)', 'emissions': -0.4},
      {'name': 'Participating in a green building certification program (per square meter)', 'emissions': -0.5},
      {'name': 'Using a composting toilet (per use)', 'emissions': -0.1},
      {'name': 'Using an energy-efficient lighting system (per hour)', 'emissions': -0.05},
      {'name': 'Using a smart thermostat (per year)', 'emissions': -0.6},
      {'name': 'Using a smart irrigation system (per liter)', 'emissions': -0.01},
      {'name': 'Participating in a carbon neutral program (per year)', 'emissions': -10.0},
      {'name': 'Using a low-carbon transportation method (per km)', 'emissions': -0.05},
      {'name': 'Using a sustainable travel program (per trip)', 'emissions': -2.0},
      {'name': 'Participating in a carbon footprint reduction program (per year)', 'emissions': -3.0},
      {'name': 'Using a renewable energy source (per kWh)', 'emissions': -0.02}
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
    User? user = FirebaseAuth.instance
        .currentUser; // Get the current logged-in user
    if (user != null) {
      // Fetch the user's document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users') // Replace with your Firestore collection name
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          username = userDoc['name'] ??
              'Username'; // Assuming 'name' is the field in Firestore
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
      try {
        // Fetch activities from Firestore, ordered by timestamp
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users') // Users collection
            .doc(user.uid) // The user's UID as the document ID
            .collection('activities') // Subcollection for activities
            .orderBy('timestamp', descending: true) // Order by timestamp
            .get();

        double totalEmissionsFromFirestore = 0.0;
        double lastDayEmissions = 0.0;
        double todayEmissions = 0.0;

        if (snapshot.docs.isNotEmpty) {
          DateTime mostRecentTimestamp = (snapshot.docs[0]['timestamp'] as Timestamp).toDate();

          // Calculate today's total emissions
          snapshot.docs.forEach((doc) {
            DateTime timestamp = (doc['timestamp'] as Timestamp).toDate();
            if (timestamp.day == mostRecentTimestamp.day &&
                timestamp.month == mostRecentTimestamp.month &&
                timestamp.year == mostRecentTimestamp.year) {
              double emissions = (doc['emissions'] as num?)?.toDouble() ?? 0.0;
              todayEmissions += emissions;
            }
          });

          // Calculate emissions from the previous day
          DateTime previousDay = mostRecentTimestamp.subtract(Duration(days: 1));
          snapshot.docs.forEach((doc) {
            DateTime timestamp = (doc['timestamp'] as Timestamp).toDate();
            if (timestamp.day == previousDay.day &&
                timestamp.month == previousDay.month &&
                timestamp.year == previousDay.year) {
              double emissions = (doc['emissions'] as num?)?.toDouble() ?? 0.0;
              lastDayEmissions += emissions;
            }
          });

          // Sum up total emissions from Firestore
          snapshot.docs.forEach((doc) {
            double emissions = (doc['emissions'] as num?)?.toDouble() ?? 0.0;
            totalEmissionsFromFirestore += emissions;
          });
        }

        print("Total emissions: $totalEmissionsFromFirestore kg CO2");

        setState(() {
          addedActivities.clear();
          addedActivities.addAll(snapshot.docs.map((doc) {
            return {
              'activity': doc['activity'] ?? 'Unknown Activity',
              'quantity': doc['quantity'] ?? 0,
              'emissions': doc['emissions']?.toString() ?? '0.0',
              'category': doc['category'] ?? 'Uncategorized',
            };
          }).toList());

          totalEmissions = totalEmissionsFromFirestore;

          double difference = todayEmissions - lastDayEmissions;
          double percentChange = ((difference / lastDayEmissions) * 100) * -1;

          totalPoints = percentChange.toInt();

          print("Percent Change: $percentChange% today $todayEmissions last $lastDayEmissions");

          // Check if we already have data for today in Firestore
          FirebaseFirestore.instance
              .collection('users') // Users collection
              .doc(user.uid) // The user's UID as the document ID
              .collection('points') // Subcollection for points
              .where('timestamp', isGreaterThanOrEqualTo: DateTime.now().toUtc().subtract(Duration(days: 1))) // Check for points within the last 24 hours
              .get()
              .then((snapshot) {
            if (snapshot.docs.isEmpty) {
              // No points for today, save the new data and update totalPoints
              FirebaseFirestore.instance
                  .collection('users') // Users collection
                  .doc(user.uid) // The user's UID as the document ID
                  .collection('points') // Subcollection for points
                  .doc('current') // Store under 'current' document
                  .set({
                'percentChange': percentChange,
                'lastDayEmissions': lastDayEmissions,
                'todayEmissions': todayEmissions,
                'timestamp': FieldValue.serverTimestamp(),
              });

              // Add the new percentChange to totalPoints
              totalPoints += percentChange.toInt();
            } else {
              // Points for today already exist, fetch the existing data
              double storedPercentChange = snapshot.docs[0]['percentChange']?.toDouble() ?? 0.0;
              DateTime storedTimestamp = (snapshot.docs[0]['timestamp'] as Timestamp).toDate();

              // If the stored data is from today, update it
              if (storedTimestamp.day == DateTime.now().day) {
                FirebaseFirestore.instance
                    .collection('users') // Users collection
                    .doc(user.uid) // The user's UID as the document ID
                    .collection('points') // Subcollection for points
                    .doc('current') // Store under 'current' document
                    .set({
                  'percentChange': percentChange,
                  'lastDayEmissions': lastDayEmissions,
                  'todayEmissions': todayEmissions,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                // Add the new percentChange to totalPoints
                totalPoints += percentChange.toInt();
              } else {
                // If the stored percentChange is higher, keep the existing one
                if (storedPercentChange > percentChange) {
                  totalPoints += storedPercentChange.toInt();
                } else {
                  totalPoints += percentChange.toInt();
                }
              }
            }
          });
        });
      } catch (e) {
        print("Error fetching activities: $e");
      }
    } else {
      print("No user is currently logged in.");
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
                    decoration: const InputDecoration(
                        labelText: 'Select Category'),
                    value: selectedCategory,
                    items: categoryActivities.keys
                        .map((category) =>
                        DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                        _filterActivities(
                            selectedCategory); // Update activities
                      });
                      print('Selected category: $selectedCategory');
                    },
                  ),
                  const SizedBox(height: 10),
                  // Activity Dropdown (dynamic based on selected category)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        labelText: 'Select Activity'),
                    value: selectedActivity,
                    items: filteredActivities
                        .map((activity) =>
                        DropdownMenuItem<String>(
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
                          emissions * double.parse(
                              quantity); // Calculate total emissions

                      setState(() {
                        addedActivities.add({
                          'activity': selectedActivity,
                          'quantity': quantity,
                          'emissions': totalEmissionsForActivity
                              .toStringAsFixed(2),
                          'category': selectedCategory,
                          'color': _getCategoryColor(selectedCategory),
                        });

                        // Update total emissions
                        totalEmissions +=
                            totalEmissionsForActivity; // Add the emissions of the new activity
                        totalPoints += 10; // Placeholder points per activity
                      });

                      // Save activity to Firestore under the current user's document
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await FirebaseFirestore.instance
                            .collection('users') // Users collection
                            .doc(user.uid) // The user's UID as the document ID
                            .collection(
                            'activities') // Subcollection for activities
                            .add({
                          'activity': selectedActivity,
                          'quantity': quantity,
                          'emissions': totalEmissionsForActivity,
                          'category': selectedCategory,
                          'timestamp': FieldValue.serverTimestamp(),
                          // Save the current timestamp
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
      body: _currentIndex == 0
          ? SingleChildScrollView(
        child: Padding(
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
                      const Text(
                          'Earned Points', style: TextStyle(fontSize: 14)),
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
                      const Text(
                          'Total Emissions', style: TextStyle(fontSize: 14)),
                      Text(
                        '${(totalEmissions).toStringAsFixed(1)} kg CO2',
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
              Container(
                height: 300, // Set a fixed height for the scrollable space
                child: SingleChildScrollView(
                  child: Column(
                    children: addedActivities.map((activity) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getCategoryColor(
                                activity['category']),
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
                    }).toList(),
                  ),
                ),
              ),
              const Text(
                'Daily Emission Usage',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const EmissionChart(), // This will display the chart
            ],
          ),
        ),
      )
          : _screens[_currentIndex],
      // Switch to another screen based on the index (for Analyze or other screens)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        // Bind the index to the current selected screen
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the index to navigate
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analyze',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stars_rounded),
            label: 'Rewards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rocket_launch),
            label: 'AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Community',
          ),
        ],
        selectedItemColor: Colors.greenAccent, // Color of the icon and label when selected
        unselectedItemColor: Colors.blueGrey, // Color of the icon and label when unselected
        showUnselectedLabels: true, // Show unselected labels
        selectedLabelStyle: TextStyle(color: Colors.greenAccent), // Set label color when selected
        unselectedLabelStyle: TextStyle(color: Colors.blueGrey), // Set label color when unselected
      )
    );
  }
}

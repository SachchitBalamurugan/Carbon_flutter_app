import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Ensure you have initialized Firebase in your project and added the necessary configurations.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // For demonstration, we'll sign in anonymously.
  // Replace this with your actual authentication logic.
  await FirebaseAuth.instance.signInAnonymously();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Screen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: CommunityScreen(),
    );
  }
}

class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String currentUserId;
  String currentUserName = 'Loading...';

  @override
  void initState() {
    super.initState();
    // Get current user ID
    User? user = _auth.currentUser;
    if (user != null) {
      currentUserId = user.uid;
      fetchCurrentUserName();
    } else {
      // Handle user not logged in
      // For simplicity, we'll navigate back or show a message
      // In a real app, you might redirect to a login screen
      currentUserId = '';
      currentUserName = 'Unknown User';
    }
  }

  Future<void> fetchCurrentUserName() async {
    try {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(currentUserId).get();
      setState(() {
        currentUserName = userDoc['name'] ?? 'Unnamed User';
      });
    } catch (e) {
      setState(() {
        currentUserName = 'Error fetching name';
      });
      print('Error fetching user name: $e');
    }
  }

  Future<double> calculateTotalEmissions(String userId) async {
    try {
      QuerySnapshot activitiesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('activities')
          .get();

      double totalEmissions = 0;
      for (var doc in activitiesSnapshot.docs) {
        double emissions = double.tryParse(doc['emissions'].toString()) ?? 0.0;
        double quantity = double.tryParse(doc['quantity'].toString()) ?? 1.0;
        totalEmissions += emissions;
      }
      return totalEmissions;
    } catch (e) {
      print('Error calculating emissions for $userId: $e');
      return 0.0;
    }
  }

  Future<void> createCommunity(String communityName) async {
    if (communityName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Community name cannot be empty.')),
      );
      return;
    }

    try {
      DocumentReference newCommunityRef =
      _firestore.collection('communities').doc();

      await newCommunityRef.set({
        'name': communityName,
        'members': [currentUserId],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Community "$communityName" created successfully!')),
      );
    } catch (e) {
      print('Error creating community: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create community. Please try again.')),
      );
    }
  }

  Future<void> joinCommunity(String communityId) async {
    try {
      DocumentReference communityRef =
      _firestore.collection('communities').doc(communityId);

      await communityRef.update({
        'members': FieldValue.arrayUnion([currentUserId]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joined the community successfully!')),
      );
    } catch (e) {
      print('Error joining community: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to join community. Please try again.')),
      );
    }
  }

  Future<void> showCommunityDetails(String communityId, String communityName) async {
    try {
      DocumentSnapshot communityDoc =
      await _firestore.collection('communities').doc(communityId).get();

      List members = communityDoc['members'];

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('$communityName Members'),
            content: members.isEmpty
                ? Text('No members in this community.')
                : FutureBuilder<List<String>>(
              future: Future.wait(members.map((userId) async {
                try {
                  DocumentSnapshot userDoc =
                  await _firestore.collection('users').doc(userId).get();
                  String userName = userDoc['name'] ?? 'Unnamed User';
                  double emissions = await calculateTotalEmissions(userId);
                  return '$userName: ${emissions.toStringAsFixed(2)} kg';
                } catch (e) {
                  print('Error fetching member data: $e');
                  return 'Unknown User: 0.00 kg';
                }
              }).toList()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error loading members.');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No members in this community.');
                } else {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: snapshot.data!
                          .map((memberInfo) => ListTile(
                        leading: Icon(Icons.person),
                        title: Text(memberInfo),
                      ))
                          .toList(),
                    ),
                  );
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
              // Optionally, allow users to leave the community
              TextButton(
                onPressed: () {
                  leaveCommunity(communityId);
                  Navigator.pop(context);
                },
                child: Text(
                  'Leave',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error showing community details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load community details.')),
      );
    }
  }

  Future<void> leaveCommunity(String communityId) async {
    try {
      DocumentReference communityRef =
      _firestore.collection('communities').doc(communityId);

      await communityRef.update({
        'members': FieldValue.arrayRemove([currentUserId]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Left the community successfully!')),
      );
    } catch (e) {
      print('Error leaving community: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to leave community. Please try again.')),
      );
    }
  }

  void showCreateCommunityDialog() {
    TextEditingController communityNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Community'),
          content: TextField(
            controller: communityNameController,
            decoration: InputDecoration(
              hintText: 'Enter community name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String communityName = communityNameController.text.trim();
                createCommunity(communityName);
                Navigator.pop(context); // Close dialog
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void showJoinCommunityDialog() {
    TextEditingController communityIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Join Community'),
          content: TextField(
            controller: communityIdController,
            decoration: InputDecoration(
              hintText: 'Enter community ID',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String communityId = communityIdController.text.trim();
                if (communityId.isNotEmpty) {
                  joinCommunity(communityId);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Community ID cannot be empty.')),
                  );
                }
                Navigator.pop(context); // Close dialog
              },
              child: Text('Join'),
            ),
          ],
        );
      },
    );
  }

  Widget buildCommunityList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('communities').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Expanded(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Expanded(
            child: Center(child: Text('Error loading communities.')),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Expanded(
            child: Center(child: Text('No communities available.')),
          );
        }

        return Expanded(
          child: ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot communityDoc = snapshot.data!.docs[index];
              String communityId = communityDoc.id;
              String communityName = communityDoc['name'] ?? 'Unnamed Community';
              List members = communityDoc['members'] ?? [];

              bool isMember = members.contains(currentUserId);

              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Icon(
                    Icons.group,
                    color: Colors.green,
                  ),
                  title: Text(communityName),
                  subtitle: Text('${members.length} member(s)'),
                  trailing: isMember
                      ? IconButton(
                    icon: Icon(Icons.exit_to_app, color: Colors.red),
                    onPressed: () {
                      leaveCommunity(communityId);
                    },
                  )
                      : Icon(Icons.arrow_forward),
                  onTap: () {
                    if (isMember) {
                      showCommunityDetails(communityId, communityName);
                    } else {
                      // Optionally, prompt to join
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Join Community'),
                            content: Text('Do you want to join "$communityName"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  joinCommunity(communityId);
                                  Navigator.pop(context);
                                },
                                child: Text('Join'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Display a loading indicator if the user name is still being fetched
    if (currentUserName == 'Loading...') {
      return Scaffold(
        appBar: AppBar(
          title: Text('Communities'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Communities'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {}); // Refresh the screen
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // User Info Section
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.green[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Logged in as: $currentUserName',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Icon(Icons.account_circle, size: 40, color: Colors.green),
              ],
            ),
          ),
          SizedBox(height: 10),
          // Action Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: showCreateCommunityDialog,
                    icon: Icon(Icons.add),
                    label: Text('Create Community'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: showJoinCommunityDialog,
                    icon: Icon(Icons.group_add),
                    label: Text('Join Community'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Community List
          Expanded(child: buildCommunityList()),
        ],
      ),
    );
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Instagram-like App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PostsScreen(),
    );
  }
}

class PostsScreen extends StatefulWidget {
  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final TextEditingController _captionController = TextEditingController();
  Uint8List? _selectedImageBytes;
  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();

      final postList = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'username': data['username'] ?? 'Unknown User',
          'caption': data['caption'] ?? '',
          'imageUrl': data['imageUrl'],  // Retrieve image URL
          'timestamp': data['timestamp'],
        };
      }).toList();

      setState(() {
        posts = postList;
      });
    }
  }


  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
      });
    }
  }

  Future<void> addPost() async {
    if (_captionController.text.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch the user's name from Firestore
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final userName = userDoc.data()?['name'] ?? 'Unknown User';

        // Create a post object
        final post = {
          'username': userName,
          'caption': _captionController.text,
          'timestamp': Timestamp.now(),
        };

        // If an image is selected, upload it to Firebase Storage
        if (_selectedImageBytes != null) {
          // Generate a unique file name for the image
          final storageRef = FirebaseStorage.instance.ref().child('posts/${DateTime.now().millisecondsSinceEpoch}.jpg');
          await storageRef.putData(_selectedImageBytes!);

          // Get the image URL after upload
          final imageUrl = await storageRef.getDownloadURL();

          // Add the image URL to the post object
          post['imageUrl'] = imageUrl;
        }

        // Save the post in Firestore under the user's `userId`
        await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('posts').add(post);

        setState(() {
          posts.insert(0, post);
          _captionController.clear();
          _selectedImageBytes = null; // Clear after saving
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No user logged in')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Instagram-like Posts'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ElevatedButton.icon(
                //   onPressed: pickImage,
                //   icon: Icon(Icons.image),
                //   label: Text('Pick an Image'),
                // ),
                if (_selectedImageBytes != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.memory(_selectedImageBytes!, height: 100, fit: BoxFit.cover),
                  ),
                TextField(
                  controller: _captionController,
                  decoration: InputDecoration(
                    labelText: 'Caption',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: addPost,
                  child: Text('Post'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return PostCard(
                  username: post['username'],
                  imageUrl: post['imageUrl'],
                  caption: post['caption'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class PostCard extends StatelessWidget {
  final String username;
  final String? imageUrl;
  final String caption;

  const PostCard({
    required this.username,
    this.imageUrl,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  child: Text(username[0].toUpperCase()),
                ),
                SizedBox(width: 8),
                Text(
                  username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (imageUrl != null)
            Image.network(imageUrl!, fit: BoxFit.cover),  // Use Image.network to display image from URL
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(caption),
          ),
        ],
      ),
    );
  }
}


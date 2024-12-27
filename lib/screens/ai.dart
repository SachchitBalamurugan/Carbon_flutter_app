import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled2/components/messaging_widget.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  final FocusNode _textFieldFocus = FocusNode();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: 'AIzaSyDSsc8YHtM-lG3B3in21eVAOdXAx6zVBvs',
    );
    _chatSession = _model.startChat();
  }

  Future<void> _fetchDataAndGenerateFeedback() async {
    setState(() {
      _loading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError("No user is currently logged in.");
        return;
      }

      final userId = user.uid;
      final activitiesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('activities')
          .get();

      if (activitiesSnapshot.docs.isEmpty) {
        _showError("No activity data found for the user.");
        return;
      }

      // Compile activity data into a prompt format
      String promptData = "Here is the user's activity data:\n";
      for (var doc in activitiesSnapshot.docs) {
        final data = doc.data();
        promptData +=
        "Activity: ${data['activity']}, Category: ${data['category']}, Emissions: ${data['emissions']}, Quantity: ${data['quantity']}, Timestamp: ${data['timestamp']}\n";
      }
      promptData += "How can the user improve and reduce their carbon emissions based on this data?";

      // Send prompt to Generative Model
      await _sendChatMessage(promptData);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Flexible(
          child: Text(
            'AI Carbon Emission Strategy ChatBot',
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _fetchDataAndGenerateFeedback,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Get Feedback on Emissions"),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _chatSession.history.length,
                itemBuilder: (context, index) {
                  final Content content = _chatSession.history.toList()[index];
                  final text = content.parts
                      .whereType<TextPart>()
                      .map<String>((e) => e.text)
                      .join('');
                  return MessageWidget(text: text, isFromUser: content.role == 'user');
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      focusNode: _textFieldFocus,
                      decoration: textFieldDecoration(),
                      controller: _textController,
                      onSubmitted: _sendChatMessage,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.blue,
                    onPressed: _loading
                        ? null
                        : () {
                      final inputText = _textController.text.trim();
                      if (inputText.isNotEmpty) {
                        _sendChatMessage(inputText);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration textFieldDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      hintText: 'Enter a prompt...',
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Colors.blue),
      ),
    );
  }

  Future<void> _sendChatMessage(String message) async {
    setState(() {
      _loading = true;
    });

    try {
      final response = await _chatSession.sendMessage(Content.text(message));
      final text = response.text;
      if (text == null) {
        _showError('No response from API');
      }
      setState(() {
        _loading = false;
        _scrollDown();
      });
    } catch (e) {
      _showError(e.toString());
    } finally {
      _textController.clear();
      _textFieldFocus.requestFocus();
      setState(() {
        _loading = false;
      });
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCirc,
      );
    });
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something Went Wrong'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

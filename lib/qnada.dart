import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QandA extends StatefulWidget {
  const QandA({super.key});

  @override
  State<QandA> createState() => _QandAState();
}

class _QandAState extends State<QandA> {
  String dropdownValue = 'Select subject';
  final TextEditingController _questionController = TextEditingController();
  // Removed _pseudonymController
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  String _userName = ''; // Add a variable to store the user's name

  final List<String> subjects = [
    'Select subject',
    '01418325-65 Data Visualization',
    '01418362-65 Introduction to Machine Learning',
    '01418342-65 Mobile Application Design and Development',
    '03752111-67 Information Resources for Reseach',
    '02728102-67 Pigments in Art',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Fetch the user's name when the widget initializes
  }

  Future<void> _fetchUserName() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user!.uid).get();
        if (userDoc.exists) {
          setState(() {
            _userName = userDoc['name'] ?? 'Anonymous'; // Get the name from the user document, default to 'Anonymous' if not found
          });
        }
      } catch (e) {
        print('Error fetching user name: $e');
        setState(() {
          _userName = 'Anonymous';
        });
      }
    } else {
      setState(() {
        _userName = 'Anonymous';
      });
    }
  }

  Future<void> _postQuestion() async {
    if (dropdownValue == 'Select subject' ||
        _questionController.text.isEmpty) { // Removed check for _pseudonymController
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to post a question.')),
      );
      return;
    }

    try {
      await _firestore.collection('qandas').add({
        'courseCode': dropdownValue, // Extract course name from course code
        'question': _questionController.text,
        'userName': _userName, // Use the fetched user name
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user!.uid, // Add the user's UID
      });

      _questionController.clear();
      // Removed _pseudonymController.clear();
      setState(() {
        dropdownValue = 'Select subject';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question posted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error posting question: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to post question.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Q&A', style: TextStyle(color: Colors.white)),
        ),
        actions: const [Icon(Icons.help, color: Colors.white)],
        backgroundColor: const Color.fromARGB(255, 165, 139, 255),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: DropdownButton(
                    isExpanded: true,
                    value: dropdownValue,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 30,
                    items: subjects.map((String subject) {
                      return DropdownMenuItem<String>(
                        value: subject,
                        child: Text(subject),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(top: 0.0, left: 5.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Create a question',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _questionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Write a question ...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: const EdgeInsets.all(15),
                ),
              ),
              const SizedBox(height: 10),
              // Removed the "Written by" section
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 165, 139, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 244, 110),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                    ),
                    onPressed: _postQuestion,
                    child: const Text(
                      'Question',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

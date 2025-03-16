// reviewPage.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eduguide/Component/HomeComponent.dart';

class Reviewpage extends StatefulWidget {
  final VoidCallback onReviewPosted;

  const Reviewpage({Key? key, required this.onReviewPosted}) : super(key: key);

  @override
  State<Reviewpage> createState() => _ReviewpageState();
}

List<String> _radioButtonItems = ['Midterm', 'Final', 'Summer'];
List<String> _gradeItems = ['A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F'];

class _ReviewpageState extends State<Reviewpage> {
  String dropdownValue = 'Select subject';
  String _selectedTerm = _radioButtonItems[0];
  String? _selectedGrade;
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _yearController = TextEditingController(); // Add controller for year
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  String? _userName;
  String? _userId; // Add this line to store the user's UID

  final List<String> subjects = [
    'Select subject',
    '01418325-65 Data Visualization',
    '01418362-65 Introduction to Machine Learning',
    '01418342-65 Mobile Application Design and Development',
    '03752111-67 Information Resources for Reseach',
    '02728102-67 Pigments in Art',
  ];

  Map<String, bool> _selectedValue = {
    'The content does not contain profanity.': false,
    'The content does not refer to others.': false,
  };

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user == null) {
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _userName = userDoc.get('name') ?? 'Unknown User'; // Provide a default value
          _userId = user!.uid; // Store the user's UID here
        });
      } else {
        print('User document does not exist');
        setState(() {
          _userName = 'Unknown User'; // Provide a default value
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _userName = 'Unknown User'; // Provide a default value in case of error
      });
    }
  }

  Future<void> _postReview() async {
    if (dropdownValue == 'Select subject' ||
        _reviewController.text.isEmpty ||
        _selectedGrade == null ||
        _selectedTerm == null ||
        _userName == null || // Remove this check
        _userId == null ||
        _yearController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    try {
      await _firestore.collection('reviews').add({
        'courseCode': dropdownValue,
        'content': _reviewController.text,
        'author': _userName,
        'grade': _selectedGrade,
        'term': _selectedTerm,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': _userId,
        'year': _yearController.text, // Add the year to the review data
        'bookmarkedBy': [],
      });

      _reviewController.clear();
      _yearController.clear(); // Clear the year field
      setState(() {
        dropdownValue = 'Select subject';
        _selectedGrade = null;
        _selectedTerm = _radioButtonItems[0];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review posted successfully!')),
      );

      widget.onReviewPosted();
      Navigator.pop(context);
    } catch (e) {
      print('Error posting review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to post review.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Review', style: TextStyle(color: Colors.white)),
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
                    'Review this subject',
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
                controller: _reviewController,
                maxLines: 5,
                style: const TextStyle(
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Write a review ... ...',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: const EdgeInsets.all(15),
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(top: 0.0, left: 5.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Academic year studied',
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
                controller: _yearController, // Add controller here
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter year ...', // Add hint text
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(top: 0.0, left: 5.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Grade obtained',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                children: _gradeItems.map((String grade) {
                  return FilterChip(
                    label: Text(grade),
                    selected: _selectedGrade == grade,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedGrade = selected ? grade : null;
                      });
                    },
                    selectedColor: const Color.fromARGB(255, 165, 139, 255),
                    backgroundColor: Colors.grey[300],
                    labelStyle: TextStyle(
                      color: _selectedGrade == grade
                          ? Colors.white
                          : Colors.black,
                    ),
                    shape: const CircleBorder(),
                    showCheckmark: false,
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(top: 0.0, left: 5.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Term',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 1),
              Column(
                children: _radioButtonItems.map((String term) {
                  return RadioListTile<String>(
                    title: Text(term),
                    value: term,
                    groupValue: _selectedTerm,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTerm = newValue!;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(top: 0.0, left: 5.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Please verify the accuracy before reviewing.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: _selectedValue.keys.map((String term) {
                  return CheckboxListTile(
                    title: Text(term),
                    value: _selectedValue[term],
                    onChanged: (bool? newValue) {
                      setState(() {
                        _selectedValue[term] = newValue!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
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
                      backgroundColor:
                          const Color.fromARGB(255, 255, 244, 110),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                    ),
                    onPressed: _postReview,
                    child: const Text(
                      'Review',
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

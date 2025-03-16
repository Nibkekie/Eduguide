import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentPage extends StatefulWidget {
  final String docId;
  final String courseCode;
  final String userName;
  final String question;

  CommentPage({
    required this.docId,
    required this.courseCode,
    required this.userName,
    required this.question,
  });

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty && user != null) {
      // Fetch the user's name and avatar URL
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user!.uid).get();
      String userName = userDoc['name'] ?? 'Anonymous';
      String userAvatarUrl =
          userDoc.get('imageUrl') != null ? userDoc.get('imageUrl') : '';
      DocumentSnapshot postDoc =
          await _firestore.collection('qandas').doc(widget.docId).get();
      String postOwnerId =
          postDoc['userId'] ?? ''; // Assuming you have an 'imageUrl' field

      await _firestore
          .collection('qandas')
          .doc(widget.docId)
          .collection('comments')
          .add({
        'text': _commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user!.uid,
        'userName': userName,
        'userAvatarUrl': userAvatarUrl,
        'postOwnerId': postOwnerId,
      });
      _commentController.clear();
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await _firestore
          .collection('qandas')
          .doc(widget.docId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      print('Error deleting comment: $e');
      // Handle error (e.g., show a snackbar)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Comment',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 165, 139, 255),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display Question Information
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 165, 139, 255),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.courseCode,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Q & A from ${widget.userName}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.question,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                const Divider(),
              ],
            ),
          ),
          // Comment Input Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create a comment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Write a comment ...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    contentPadding: const EdgeInsets.all(15),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send,
                          color: Color.fromARGB(255, 165, 139, 255)),
                      onPressed: _addComment,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Text(
              'Comments',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          // Comment List (using Expanded + StreamBuilder)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('qandas')
                  .doc(widget.docId)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var comments = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    var commentData =
                        comments[index].data() as Map<String, dynamic>;
                    // Use null-aware operators and default values
                    var comment = commentData['text'] as String? ?? '';
                    var userName =
                        commentData['userName'] as String? ?? 'Anonymous';
                    var userAvatarUrl =
                        commentData['userAvatarUrl'] as String? ?? '';
                    var commentUserId = commentData['userId'] as String? ?? '';
                    var commentId =
                        comments[index].id; // Get the comment document ID
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 5.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Avatar
                          CircleAvatar(
                            backgroundImage: userAvatarUrl.isNotEmpty
                                ? NetworkImage(userAvatarUrl)
                                : null,
                            child: userAvatarUrl.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),

                          const SizedBox(width: 10),
                          // Comment Block
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Comment by $userName',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 255, 248, 166),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(comment),
                                ),
                              ],
                            ),
                          ),
                          // Delete Button (Conditional)
                          if (user != null && user!.uid == commentUserId)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteComment(commentId);
                              },
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

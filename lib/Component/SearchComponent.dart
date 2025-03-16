import 'package:eduguide/comment.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Post {
  final String courseCode;
  final String content;
  final String author;
  final String grade;
  final String docId;
  final String year;
  final String term;
  final String userId;

  Post({
    required this.courseCode,
    required this.content,
    required this.author,
    required this.grade,
    required this.docId,
    required this.year,
    required this.term,
    required this.userId,
  });
}

class PostQA {
  final String courseCode;
  final String courseName;
  final String userName;
  final String question;
  final String docId;
  final String userId;

  PostQA({
    required this.courseCode,
    required this.courseName,
    required this.userName,
    required this.question,
    required this.docId,
    required this.userId,
  });
}

class SearchComponent extends StatefulWidget {
  const SearchComponent({Key? key}) : super(key: key);

  @override
  State<SearchComponent> createState() => _SearchComponentState();
}

class _SearchComponentState extends State<SearchComponent> {
  String _selectedSubject = 'Select subject';
  List<String> _subjects = [
    'Select subject',
    '01418325-65 Data Visualization',
    '01418362-65 Introduction to Machine Learning',
    '01418342-65 Mobile Application Design and Development',
    '03752111-67 Information Resources for Research',
    '02728102-67 Pigments in Art',
  ];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  String _selectedPostType = 'Review'; // Default to Review
  bool _isSearching = false;
  List<String> _filteredSubjects = [];

  @override
  void initState() {
    super.initState();
    _filteredSubjects = _subjects;
  }

  String _extractCourseCode(String subject) {
    if (subject == 'Select subject') return '';
    String courseCode = subject; // เก็บค่าทั้งหมด
    print('Extracted full subject: $courseCode'); // Debugging
    return courseCode;
  }

  // Stream builder for reviews
  Stream<List<Post>> _getReviewsStream(String courseCode) {
    return _firestore
        .collection('reviews')
        .where('courseCode', isEqualTo: courseCode)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return Post(
                courseCode: data['courseCode'] ?? '',
                content: data['content'] ?? '',
                author: data['author'] ?? '',
                grade: data['grade'] ?? '',
                docId: doc.id,
                year: data['year'] ?? '',
                term: data['term'] ?? '',
                userId: data['userId'] ?? '',
              );
            }).toList());
  }

  // Stream builder for Q&As
  Stream<List<PostQA>> _getQAStream(String courseCode) {
    return _firestore
        .collection('qandas')
        .where('courseCode', isEqualTo: courseCode)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return PostQA(
                courseCode: data['courseCode'] ?? '',
                courseName: data['courseName'] ?? '',
                userName: data['userName'] ?? '',
                question: data['question'] ?? '',
                docId: doc.id,
                userId: data['userId'] ?? '',
              );
            }).toList());
  }

  void _filterSubjects(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredSubjects = _subjects;
      } else {
        _filteredSubjects = _subjects
            .where((subject) =>
                subject.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _toggleBookmark(
      String docId, String collection, bool isBookmarked) async {
    try {
      DocumentReference docRef = _firestore.collection(collection).doc(docId);
      if (isBookmarked) {
        await docRef.update({
          'bookmarkedBy': FieldValue.arrayRemove([user?.uid]),
        });
      } else {
        await docRef.update({
          'bookmarkedBy': FieldValue.arrayUnion([user?.uid]),
        });
      }
    } catch (e) {
      print('Error toggling bookmark: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Search'),
      //   automaticallyImplyLeading: false,
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: _filterSubjects,
              decoration: InputDecoration(
                labelText: 'Search Subjects',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isSearching
                  ? ListView.builder(
                      itemCount: _filteredSubjects.length,
                      itemBuilder: (context, index) {
                        final subject = _filteredSubjects[index];
                        return ListTile(
                          title: Text(subject),
                          onTap: () {
                            setState(() {
                              _selectedSubject = subject;
                              _isSearching = false;
                              _filterSubjects("");
                            });
                          },
                        );
                      },
                    )
                  : Column(
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedPostType = 'Review';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedPostType == 'Review'
                                    ? Color.fromARGB(255, 255, 244, 110)
                                    : Colors.white,
                                foregroundColor: Colors.black,
                              ),
                              child: const Text(
                                'REVIEW',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedPostType = 'Q&A';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedPostType == 'Q&A'
                                    ? Color.fromARGB(255, 255, 244, 110)
                                    : Colors.white,
                                foregroundColor: Colors.black,
                              ),
                              child: const Text(
                                'Q & A',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: _selectedSubject == 'Select subject'
                              ? const Center(
                                  child: Text(
                                      'Please select a subject to search.'))
                              : _selectedPostType == 'Review'
                                  ? StreamBuilder<List<Post>>(
                                      stream: _getReviewsStream(
                                          _extractCourseCode(_selectedSubject)),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                        if (snapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  'Error: ${snapshot.error}'));
                                        }
                                        if (!snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return const Center(
                                              child: Text("No reviews found."));
                                        }
                                        return PostList(
                                            posts: snapshot.data!,
                                            onBookmark: _toggleBookmark,
                                            onDelete: (String docId,
                                                String collection) {});
                                      },
                                    )
                                  : StreamBuilder<List<PostQA>>(
                                      stream: _getQAStream(
                                          _extractCourseCode(_selectedSubject)),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                        if (snapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  'Error: ${snapshot.error}'));
                                        }
                                        if (!snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return const Center(
                                              child: Text("No Q&As found."));
                                        }
                                        return PostQAList(
                                            posts: snapshot.data!,
                                            onBookmark: _toggleBookmark,
                                            onDelete: (String docId,
                                                String collection) {});
                                      },
                                    ),
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

// ... (Rest of your code: PostList, PostQAList, Post, PostQA, PostCard, PostCardQA)
// ... (These parts remain the same)
class PostList extends StatefulWidget {
  final List<Post> posts;
  final Function(String, String, bool) onBookmark;
  final Function(String, String) onDelete;
  const PostList(
      {Key? key,
      required this.posts,
      required this.onBookmark,
      required this.onDelete})
      : super(key: key);

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: widget.posts.length,
      itemBuilder: (context, index) {
        return PostCard(
          post: widget.posts[index],
          onBookmark: widget.onBookmark,
          onDelete: widget.onDelete,
        );
      },
    );
  }
}

class PostQAList extends StatelessWidget {
  final List<PostQA> posts;
  final Function(String, String, bool) onBookmark;
  final Function(String, String) onDelete;
  const PostQAList(
      {Key? key,
      required this.posts,
      required this.onBookmark,
      required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return PostCardQA(
          post: posts[index],
          onBookmark: onBookmark,
          onDelete: onDelete,
        );
      },
    );
  }
}

class PostCard extends StatefulWidget {
  final User? user;
  final Post post;
  final Function(String, String, bool) onBookmark;
  final Function(String, String) onDelete;

  const PostCard(
      {Key? key,
      required this.post,
      required this.onBookmark,
      required this.onDelete,
      this.user})
      : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.grey, width: 1.5), // เพิ่มขอบสีเทา
      ),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 165, 139, 255),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        widget.post.courseCode,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                widget.post.content,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 1),
              child: Text(
                "By ${widget.post.author}",
                style:
                    const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 1),
            // เส้นคั่น
            const Divider(
              thickness: 1.5, // ความหนาของเส้น
              color: Colors.grey, // สีของเส้น
              indent: 0, // ระยะห่างจากด้านซ้าย
              endIndent: 0, // ระยะห่างจากด้านขวา
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 244, 110),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Grade: ${widget.post.grade}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Year: ${widget.post.year}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Term: ${widget.post.term}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PostCardQA extends StatefulWidget {
  final User? user;
  final PostQA post;
  final Function(String, String, bool) onBookmark;
  final Function(String, String) onDelete;

  const PostCardQA(
      {Key? key,
      required this.post,
      required this.onBookmark,
      required this.onDelete,
      this.user})
      : super(key: key);

  @override
  _PostCardQAState createState() => _PostCardQAState();
}

class _PostCardQAState extends State<PostCardQA> {
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.grey, width: 1.5), // เพิ่มขอบสีเทา
      ),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 165, 139, 255),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.post.courseCode,
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
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 1),
              child: Text(
                "Q & A from ${widget.post.userName}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                widget.post.question,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 10),
            // เส้นคั่น
            const Divider(
              thickness: 1.5, // ความหนาของเส้น
              color: Colors.grey, // สีของเส้น
              indent: 0, // ระยะห่างจากด้านซ้าย
              endIndent: 0, // ระยะห่างจากด้านขวา
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.comment_outlined, color: Colors.grey),
                  onPressed: () {
                    // Handle comment action here
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentPage(
                          docId: widget.post.docId,
                          courseCode: widget.post.courseCode,
                          userName: widget.post.userName,
                          question: widget.post.question,
                        ),
                      ),
                    );
                    print('Comment button pressed for ${widget.post.docId}');
                  },
                ),
                const SizedBox(width: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

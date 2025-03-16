import 'package:eduguide/comment.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eduguide/reviewPage.dart';

class HomeComponent extends StatefulWidget {
  const HomeComponent({Key? key}) : super(key: key);

  @override
  State<HomeComponent> createState() => _HomeComponentState();
}

class _HomeComponentState extends State<HomeComponent> {
  List<String> menuItems = ["REVIEW", "Q & A"];
  String selectedItem = "REVIEW";
  List<Post> reviewPosts = [];
  List<PostQA> qaPosts = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;

  void refreshReviews() {
    _fetchReviews();
  }

  @override
  void initState() {
    super.initState();
    _fetchReviews();
    // _fetchQA(); // No need to fetch QA here initially
  }

  Future<void> _fetchReviews() async {
    setState(() {
      _isLoading = true;
    });
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('reviews')
          .orderBy('timestamp', descending: true)
          .get();

      List<Post> fetchedPosts = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Post(
          courseCode: data['courseCode'] ?? '',
          content: data['content'] ?? '',
          author: data['author'] ?? '',
          grade: data['grade'] ?? '',
          docId: doc.id,
          year: data['year'] ?? '',
          term: data['term'] ?? '',
          userId: data['userId'] ?? '', // Add userId
        );
      }).toList();

      setState(() {
        reviewPosts = fetchedPosts;
      });
    } catch (e) {
      print('Error fetching reviews: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchQA() async {
    setState(() {
      _isLoading = true;
    });
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('qandas')
          .orderBy('timestamp', descending: true)
          .get();

      List<PostQA> fetchedPosts = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return PostQA(
          courseCode: data['courseCode'] ?? '',
          courseName: data['courseName'] ?? '',
          userName: data['userName'] ?? '',
          question: data['question'] ?? '',
          docId: doc.id,
          userId: data['userId'] ?? '', // Add userId
        );
      }).toList();

      setState(() {
        qaPosts = fetchedPosts;
      });
    } catch (e) {
      print('Error fetching Q&A: $e');
    } finally {
      setState(() {
        _isLoading = false; // Ensure _isLoading is set to false
      });
    }
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

  void _handleReviewPosted() {
    if (selectedItem == "REVIEW") {
      _fetchReviews();
    }
  }

  Future<void> _deletePost(String docId, String collection) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
      if (collection == 'reviews') {
        _fetchReviews();
      } else if (collection == 'qandas') {
        _fetchQA();
      }
    } catch (e) {
      print('Error deleting post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: menuItems.map((item) {
              bool isSelected = selectedItem == item;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedItem = item;
                    if (selectedItem == "Q & A") {
                      _fetchQA(); // Fetch QA data when Q&A is selected
                    } else {
                      _fetchReviews();
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color.fromARGB(255, 255, 244, 110)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : selectedItem == "REVIEW"
              ? reviewPosts.isEmpty
                  ? const Center(
                      child: Text("No reviews yet."),
                    )
                  : Column(
                      children: [
                        Expanded(
                            child: PostList(
                          posts: reviewPosts,
                          onBookmark: _toggleBookmark,
                          onReviewPosted: _handleReviewPosted,
                          onDelete: _deletePost,
                        )),
                      ],
                    )
              : qaPosts.isEmpty
                  ? const Center(
                      child: Text("No Q&A yet."),
                    )
                  : PostQAList(
                      posts: qaPosts,
                      onBookmark: _toggleBookmark,
                      onDelete: _deletePost,
                    ),
    );
  }
}

class PostList extends StatefulWidget {
  final List<Post> posts;
  final Function(String, String, bool) onBookmark;
  final VoidCallback onReviewPosted;
  final Function(String, String) onDelete;
  const PostList(
      {Key? key,
      required this.posts,
      required this.onBookmark,
      required this.onReviewPosted,
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
          onReviewPosted: widget.onReviewPosted,
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

class PostCard extends StatefulWidget {
  final User? user;
  final Post post;
  final Function(String, String, bool) onBookmark;
  final VoidCallback onReviewPosted;
  final Function(String, String) onDelete;

  const PostCard(
      {Key? key,
      required this.post,
      required this.onBookmark,
      required this.onReviewPosted,
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
                // Delete Button (Conditional)
                if (user != null && user!.uid == widget.post.userId)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      widget.onDelete(widget.post.docId, 'reviews');
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 15), // ดันไปทางขวา
              child: Text(
                widget.post.content,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 15),
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
            const SizedBox(height: 5),
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
                // Delete Button (Conditional)
                if (user != null && user!.uid == widget.post.userId)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      widget.onDelete(widget.post.docId, 'qandas');
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 15), // ดันไปทางขวา
              child: Text(
                "Q & A from ${widget.post.userName}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 15),
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

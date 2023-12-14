import 'package:flutter/material.dart';
import '../book_data.dart';
import '../user_data.dart';
import 'package:login_test/database/book_database.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomePage extends StatefulWidget {

  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BookState> recentlyReadBookStates = [];
  List<Book> recentlyReadBooks = [];

  @override
  void initState() {
    super.initState();
    _loadRecentlyReadBooks();
  }

  Future<void> _loadRecentlyReadBooks() async {
    final provider = container.read(userProvider);
    final UserData? user = provider.user;
    final userId = user!.userId;

    final databaseHelper = DatabaseHelper();
    await databaseHelper.initializeDatabase(user.username);

    // Retrieve all BookState objects
    final List<BookState> allBookStates = await databaseHelper.getAllBookStates(userId);
    final List<Book> allBooks = await databaseHelper.getAllBooks();

    // Sort BookState objects by lastReadDate in descending order
    allBookStates.sort((a, b) => b.lastReadDate.compareTo(a.lastReadDate));

    // Take a subset of recently read books (adjust the number as needed)
    recentlyReadBookStates = allBookStates.take(3).toList();
    recentlyReadBooks = recentlyReadBookStates
        .map((bookState) => allBooks.firstWhere((book) => book.id == bookState.bookId,
        orElse: () => Book.defaultBook(),)).toList();

    setState(() {}); // Trigger a rebuild with the new data
  }

  @override
  Widget build(BuildContext context) {
    final provider = container.read(userProvider);
    final UserData? user = provider.user;
    final username = user!.username;

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 18, color: Colors.black), // Default style for the entire text
                children: [
                  const TextSpan(
                    text: 'Xin chào ',
                  ),
                  TextSpan(
                    text: username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold, // Make the username bold
                      color: Colors.blue, // Change the color to stand out
                    ),
                  ),
                  const TextSpan(
                    text: ',\nBạn muốn đọc sách gì hôm nay?',
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: const Text(
              'Đã đọc gần đây',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 200, // Adjust the height as needed
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: recentlyReadBookStates.map((bookState) {
                // Build recently read book widgets
                return _buildRecentlyReadBook(bookState);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyReadBook(BookState bookState) {
    // You can use bookState.bookId to fetch corresponding Book object
    // using another method in DatabaseHelper
    // For simplicity, I'm using a placeholder Book here

    final Book foundBook = recentlyReadBooks.firstWhere(
          (book) => book.id == bookState.bookId,
      orElse: () => Book.defaultBook(),
    );

    final String timeAgo = timeago.format(bookState.lastReadDate, locale: 'en_short');

    return Container(
      margin: const EdgeInsets.all(8.0),
      width: 140,
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Handle button press
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: foundBook.imageLinks.isNotEmpty
                    ? Image.network(
                  foundBook.imageLinks['thumbnail'] ?? '', // Use the appropriate key for the thumbnail link
                  fit: BoxFit.cover,
                )
                    : Container(), // Placeholder if the image link is empty
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            foundBook.title,
            style: const TextStyle(fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Last Read: $timeAgo',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

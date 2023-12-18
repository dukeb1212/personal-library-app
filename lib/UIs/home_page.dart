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
    recentlyReadBookStates = allBookStates.take(5).toList();
    recentlyReadBooks = recentlyReadBookStates
        .map((bookState) => allBooks.firstWhere((book) => book.id == bookState.bookId,
        orElse: () => Book.defaultBook(),)).toList();

    setState(() {}); // Trigger a rebuild with the new data
  }

  @override
  Widget build(BuildContext context) {
    final provider = container.read(userProvider);
    final UserData? user = provider.user;
    final userName = user!.name;
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      text: userName,
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
            Padding(
              padding: EdgeInsets.fromLTRB(10 * fem, 0, 10 * fem, 0),
              child: Text(
                'Recently',
                style: TextStyle(
                  fontSize: 25 * fem,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10.0*fem,),
            SizedBox(
              height: 340, // Adjust the height as needed
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: recentlyReadBookStates.map((bookState) {
                  // Build recently read book widgets
                  return _buildRecentlyReadBook(bookState);
                }).toList(),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10 * fem, 0, 10 * fem, 0),
              child: Text(
                'New Arrivals',
                style: TextStyle(
                  fontSize: 25 * fem,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10*fem,),
            SizedBox(
              height: 340, // Adjust the height as needed
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

    double fem = MediaQuery.of(context).size.width / 360;
    double ffem = fem * 0.97;

    Widget buildDefaultImage() {
      return Image.asset(
        'assets/default-book.png',
        height: 500,
        width: double.infinity,
        fit: BoxFit.contain,
      );
    }

    var bookCover = NetworkImage(foundBook.imageLinks['thumbnail']!);

    return GestureDetector(
      child: Container(
        margin: EdgeInsets.fromLTRB(10*fem,0,0,0),
        width: 150 * fem,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250 * fem,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12 * fem),
                image: DecorationImage(
                  image: bookCover,
                  fit: BoxFit.cover,
                  onError: (context, stackTrace) => const AssetImage('assets/default-book.png'),
                ),
              ),
            ),
            SizedBox(height: 10 * fem),
            Text(
              foundBook.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16 * ffem,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Last Read: $timeAgo',
              style: TextStyle(
              fontSize: 16 * ffem,
              color: Colors.grey,
            ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

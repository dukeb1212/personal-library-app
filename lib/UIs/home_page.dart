import 'package:flutter/material.dart';
import 'package:login_test/UIs/add_book_page_final.dart';
import '../backend/google_books_api.dart';
import '../book_data.dart';
import '../user_data.dart';
import 'package:login_test/database/book_database.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'book.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BookState> recentlyReadBookStates = [];
  List<Book> recentlyReadBooks = [];
  List<Book> suggestedBooksByCategory = [];
  List<Book> suggestedBooksByAuthor = [];
  List<String> topAuthors = [];
  final databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadRecentlyReadBooks();
    _loadSuggestedBooks();
  }

  Future<void> _loadRecentlyReadBooks() async {
    final provider = container.read(userProvider);
    final UserData? user = provider.user;
    final userId = user!.userId;

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

  Future<void> _loadSuggestedBooks() async {
    var categories = await databaseHelper.getTopCategories(3);
    topAuthors = await databaseHelper.getTopAuthors(3);

    if(categories.isEmpty) {
      categories = getRandomValues(bookCategories);
    }
    for (final category in categories) {
      final result = await getSuggestBook(category, 0);
      suggestedBooksByCategory += result;
    }
    if (topAuthors.isNotEmpty) {
      suggestedBooksByAuthor = await getSuggestBook(topAuthors.first, 1);
    }

    if (mounted) {
      setState(() {}); // Trigger a rebuild with the new data
    }
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
            SizedBox(height: 20*fem,),
            Container(
              padding: EdgeInsets.fromLTRB(10*fem, 16*fem, 16*fem, 16*fem),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 20*fem, color: Colors.black), // Default style for the entire text
                  children: [
                    const TextSpan(
                      text: 'Welcome ',
                    ),
                    TextSpan(
                      text: userName,
                      style: TextStyle(
                        fontSize: 20*fem,
                        fontWeight: FontWeight.bold, // Make the username bold
                        color: const Color(0xff404040), // Change the color to stand out
                      ),
                    ),
                    const TextSpan(
                      text: ',\nWhat do you want to read today?',
                    ),
                  ],
                ),
              ),
            ),
            if (recentlyReadBooks.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    height: 320*fem,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: recentlyReadBookStates.map((bookState) {
                        return FutureBuilder<Widget>(
                          // Assuming _buildRecentlyReadBookAsync is an asynchronous function
                          future: _buildRecentlyReadBook(bookState),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              // If the Future is complete, return the widget
                              return snapshot.data ?? const SizedBox.shrink(); // Handle null case if needed
                            } else {
                              // If the Future is not complete, you can return a loading indicator or an empty container
                              return const CircularProgressIndicator(); // Replace with your loading indicator
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
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
              height: 320*fem,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: suggestedBooksByCategory.map((book) {
                  return FutureBuilder<Widget>(
                    // Assuming _buildRecentlyReadBookAsync is an asynchronous function
                    future: _buildSuggestedBook(book),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        // If the Future is complete, return the widget
                        return snapshot.data ?? const SizedBox.shrink(); // Handle null case if needed
                      } else {
                        // If the Future is not complete, you can return a loading indicator or an empty container
                        return const CircularProgressIndicator(); // Replace with your loading indicator
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            if (topAuthors.isNotEmpty)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(10 * fem, 0, 10 * fem, 0),
                    child: Text(
                      'More from ${shortenName(topAuthors[0])}',
                      style: TextStyle(
                        fontSize: 25 * fem,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 10 *fem,),
                  SizedBox(
                    height: 320*fem,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: suggestedBooksByAuthor.map((book) {
                        return FutureBuilder<Widget>(
                          // Assuming _buildRecentlyReadBookAsync is an asynchronous function
                          future: _buildSuggestedBook(book),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              // If the Future is complete, return the widget
                              return snapshot.data ?? const SizedBox.shrink(); // Handle null case if needed
                            } else {
                              // If the Future is not complete, you can return a loading indicator or an empty container
                              return const CircularProgressIndicator(); // Replace with your loading indicator
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 10 *fem,),
                ],
              )
      ],
        ),
      ),
    );
  }

  Future<Widget> _buildRecentlyReadBook(BookState bookState) async {
    // You can use bookState.bookId to fetch corresponding Book object
    // using another method in DatabaseHelper
    // For simplicity, I'm using a placeholder Book here

    final Book foundBook = recentlyReadBooks.firstWhere(
          (book) => book.id == bookState.bookId,
      orElse: () => Book.defaultBook(),
    );

    final String timeAgo = timeago.format(bookState.lastReadDate, locale: 'en_short');

    double fem = MediaQuery.of(context).size.width / 360;

    var bookCover = NetworkImage(foundBook.imageLinks['thumbnail']!);

    final databaseHelper = DatabaseHelper();
    final provider = container.read(userProvider);
    final int? userId = provider.user?.userId;
    final allBookStates = await databaseHelper.getAllBookStates(userId!);

    BookState bs = allBookStates.where((bookState) => bookState.bookId == foundBook.id).first;

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BookScreen(book: foundBook, bookState: bs)));
          },
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
                    fontSize: 16 * fem,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Last Read: $timeAgo',
                  style: TextStyle(
                    fontSize: 16 * fem,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: SizedBox(
            width: 20.0, // Adjust the size as needed
            height: 20.0,
            child: CircularProgressIndicator(
              value: bs.percentRead / 100.0, // Set the progress value based on the percentage
              strokeWidth: 4.0, // Adjust the thickness of the circular progress indicator
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Future<Widget> _buildSuggestedBook(Book book) async {
    double fem = MediaQuery.of(context).size.width / 360;

    var bookCover = NetworkImage(book.imageLinks['thumbnail']!);

    final result = await databaseHelper.doesBookExist(book.id);
    if (result['existed']) {
      return const SizedBox.shrink();
    } else {
      return GestureDetector(
        onTap: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddBookScreen(book: book)));
        },
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
                book.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16 * fem,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                book.authors.length > 1
                    ? '${truncateAuthorName(book.authors[0])}, ${truncateAuthorName(book.authors[1])}'
                    : book.authors[0],
                style: TextStyle(
                  fontSize: 16 * fem,
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
}

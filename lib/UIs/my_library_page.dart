import 'dart:collection';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:login_test/UIs/add_book_page_final.dart';
import 'package:login_test/UIs/book.dart';
import 'package:login_test/backend/image_helper.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:login_test/backend/google_books_api.dart';
import '../book_data.dart';
import '../database/book_database.dart';
import '../user_data.dart';
import 'package:login_test/backend/update_book_backend.dart';
import 'package:login_test/backend/firebase_auth_service.dart';
import 'add_book_page.dart';

String fbemail = dotenv.env['FIREBASE_EMAIL'] ?? '';
String fbpassword = dotenv.env['FIREBASE_PASSWORD'] ?? '';

class MyLibraryPage extends StatefulWidget {
  const MyLibraryPage({super.key});

  @override
  _MyLibraryPageState createState() => _MyLibraryPageState();
}

class _MyLibraryPageState extends State<MyLibraryPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String currentQuery = '';
  int selectedCategoryIndex = 0;
  List<BookState> allBookStates = [];
  String selectedCategory = '';
  bool getAll = true;
  final databaseHelper = DatabaseHelper();


  Future<List<String>> _updateCategories() async {
    final List<Book> allBooks = await databaseHelper.getAllBooks();

    // Count occurrences of each category
    final Map<String, int> categoryCount = HashMap();

    for (final book in allBooks) {
        categoryCount[book.category] = (categoryCount[book.category] ?? 0) + 1;
    }

    // Sort categories based on count in descending order
    final sortedCategories = categoryCount.keys.toList()
      ..sort((a, b) => categoryCount[b]!.compareTo(categoryCount[a]!));

    // Take the top 10 categories
    List<String> categories = sortedCategories.take(10).toList();
    return categories;
  }

  @override
  void initState() {
    super.initState();
    _updateBookList();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;


    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Enter title or author',
                      ),
                      onChanged: (query) {
                        setState(() {
                          currentQuery = query;
                        });
                      },
                    ),
                  ),
                  // Search icon
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                        _updateBookList();
                    },
                  ),
                  // Stack or List icon
                  IconButton(
                    icon: const Icon(Icons.filter_alt), // You can change the icon
                    onPressed: () {
                      _showDialog(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: FutureBuilder<List<Book>>(
                future: _getFilteredBooksFromDatabase(getAll),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No books found.');
                  } else {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Flex(
                          direction: Axis.horizontal,
                          children: [
                            _buildBookButton(snapshot.data![index]),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40 * fem, // Set the desired height
              child: FutureBuilder<List<String>>(
                future: _updateCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('');
                  } else {
                    return ListView.builder(
                      key: const PageStorageKey<String>('myListView'),
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8 * fem),
                          child: TextButton(
                            onPressed: () {
                              // Handle category button press
                              setState(() {
                                selectedCategoryIndex = index;
                                selectedCategory = snapshot.data![index];
                              });
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: selectedCategoryIndex == index
                                  ? Colors.black
                                  : Colors.grey, backgroundColor: Colors.transparent, // Set background color to transparent
                            ),
                            child: Text(
                              snapshot.data![index],
                              style: TextStyle(
                                fontSize: 14*fem,
                                fontWeight: selectedCategoryIndex == index
                                    ? FontWeight.bold
                                    : FontWeight.normal, // Make the selected category bold
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Book>>(
                future: _getFilteredBooksFromDatabase(!getAll),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No books found.');
                  } else {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Flex(
                          direction: Axis.horizontal,
                          children: [
                            _buildBookButton(snapshot.data![index]),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FloatingActionButton(
                heroTag: 'barcode scanner',
                onPressed: () {
                  // Book? book = await getBookByBarcode();
                  // if (mounted) {
                  //   if (book != null) {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => AddBookDetailsPage(book: book),
                  //       ),
                  //     );
                  //   } else {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(content: Text('Cannot find the book, please try another one!')),
                  //     );
                  //   }
                  // }
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                      builder: (context) => AddBookScreen(book: Book.defaultBook()),
                      ),
                  );
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dialog Title'),
          content: const Text('Dialog Content'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateBookList() async {
    setState(() {});
  }

  Future<List<Book>> _getFilteredBooksFromDatabase(bool getAll) async {
    final List<Book> allBooks = await databaseHelper.getAllBooks();
    final provider = container.read(userProvider);
    final int? userId = provider.user?.userId;
    allBookStates = await databaseHelper.getAllBookStates(userId!);

    // Filter books based on the search query and selected category
    if (!getAll) {
      if (currentQuery.isEmpty && selectedCategory.isEmpty) {
        return allBooks; // Return all books if both query and category are empty
      } else if (currentQuery.isEmpty) {
        return allBooks
            .where((book) => book.category == selectedCategory)
            .toList(); // Filter books based on the selected category
      } else {
        final String queryLowerCase = currentQuery.toLowerCase();
        return allBooks
            .where((book) =>
        (book.title.toLowerCase().contains(queryLowerCase) ||
            book.authors.any((author) => author.toLowerCase().contains(queryLowerCase))) &&
            (selectedCategory.isEmpty || book.category == selectedCategory))
            .toList(); // Filter books based on both query and category
      }
    } else {
      return allBooks;
    }
  }


  String _truncateAuthorName(String authorName) {
    const maxLength = 7;

    if (authorName.length > maxLength) {
      return '${authorName.substring(0, maxLength)}...';
    } else {
      return authorName;
    }
  }

  Widget _buildBookButton(Book book) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;


    BookState bookState = allBookStates.where((bookState) => bookState.bookId == book.id).first;

    var bookCover = NetworkImage(book.imageLinks['thumbnail']!);
    // Implement the UI for a book button
    // You can use ElevatedButton or any other widget you prefer
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BookScreen(book: book, bookState: bookState)));
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
                  ? '${_truncateAuthorName(book.authors[0])}, ${_truncateAuthorName(book.authors[1])}'
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


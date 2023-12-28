import 'dart:collection';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:login_test/UIs/add_book_page_final.dart';
import 'package:login_test/UIs/book.dart';
import '../book_data.dart';
import '../database/book_database.dart';
import '../user_data.dart';

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
  int totalBooks = 0;

  @override
  void initState() {
    super.initState();
    _updateBookList();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;


    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        title: Padding(
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
                  _showFilterDialog(context);
                },
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent, // Set the app bar background color to black
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AddBookScreen(book: Book.defaultBook()),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(
        children: [ Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height -20, // Set a maximum height
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      '  All ($totalBooks books)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 24 * fem,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: FutureBuilder<List<Book>>(
                        future: _getFilteredBooksFromDatabase(getAll),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('No book found!');
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
                    SizedBox(
                      height: 60 * fem, // Set the desired height
                      child: FutureBuilder<List<String>>(
                        future: updateCategories(),
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
                                        fontSize: 18 * fem,
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
                            return const Text('No book found!');
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
            ),
          ),
        ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) async {
    final allAuthors = await databaseHelper.getAllAuthors();
    final allCategories = await databaseHelper.getAllCategories();
    final allLanguages = await databaseHelper.getAllLanguages();

    String selectedCategory = allCategories.isNotEmpty ? allCategories[0] : '';
    String selectedAuthor = allAuthors.isNotEmpty ? allAuthors[0] : '';
    bool filterNewest = false;
    String selectedLanguage = allLanguages.isNotEmpty ? allLanguages[0] : '';

    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Filter Books'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<String>(
                  hint: const Text('Select Category'),
                  value: selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                    });
                  },
                  items: allCategories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  hint: const Text('Select Author'),
                  value: selectedAuthor,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedAuthor = newValue!;
                    });
                  },
                  items: allAuthors.map((String author) {
                    return DropdownMenuItem<String>(
                      value: author,
                      child: Text(author),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: filterNewest,
                      onChanged: (bool? newValue) {
                        setState(() {
                          filterNewest = newValue!;
                        });
                      },
                    ),
                    const Text('Filter Newest Published Book'),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  hint: const Text('Select Language'),
                  value: selectedLanguage,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedLanguage = newValue!;
                    });
                  },
                  items: allLanguages.map((String language) {
                    return DropdownMenuItem<String>(
                      value: language,
                      child: Text(language),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Apply filter logic here
                  // You can use the selectedCategory, selectedAuthor, filterNewest, and selectedLanguage to filter your books
                  Navigator.of(context).pop();
                },
                child: const Text('Apply Filter'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }
  }


  Future<List<String>> updateCategories() async {
    final result = await databaseHelper.getTopCategories(10);
    if (selectedCategory.isEmpty) {
      setState(() {
        selectedCategory = result[0];
      });
    }
    return result;
  }

  Future<void> _updateBookList() async {
    final List<Book> allBooks = await databaseHelper.getAllBooks();
    setState(() {
      totalBooks = allBooks.length;
    });
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
      if (currentQuery.isEmpty) {
        return allBooks;
      } else {
        final String queryLowerCase = currentQuery.toLowerCase();
        return allBooks
            .where((book) =>
        (book.title.toLowerCase().contains(queryLowerCase) ||
            book.authors.any((author) => author.toLowerCase().contains(queryLowerCase))))
            .toList();
      }
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


import 'dart:collection';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:login_test/UIs/add_book_page_final.dart';
import 'package:login_test/UIs/book.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
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

  String filteredCategory = '';
  String filteredAuthor = '';
  bool filterNewest = false;
  String filteredLanguage = '';

  ItemScrollController scrollController = ItemScrollController();
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  PageStorageBucket pageStorageBucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    _updateBookList();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;

    super.build(context);
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
                            return PageStorage(
                              key: const PageStorageKey<String>('myListView'),
                              bucket: pageStorageBucket,
                              child: ScrollablePositionedList.builder(
                                itemPositionsListener: itemPositionsListener,
                                itemScrollController: scrollController,
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data!.length,
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
                              ),
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

    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return FilterDialog(
            allAuthors: allAuthors,
            allCategories: allCategories,
            allLanguages: allLanguages,
            filteredAuthor: filteredAuthor,
            filteredCategory: filteredCategory,
            filterNewest: filterNewest,
            onApplyFilter: (category, author, newest, language) {
              if (category == 'All' && author == 'All') {
                setState(() {
                  filteredCategory = '';
                  selectedCategory = '';
                  currentQuery = '';
                  filteredAuthor = '';
                  filterNewest = newest;
                  filteredLanguage = language;
                });
              } else if (author == 'All' && category != 'All') {
                setState(() {
                  filteredCategory = category;
                  selectedCategory = category;
                  currentQuery = '';
                  filteredAuthor = '';
                  filterNewest = newest;
                  filteredLanguage = language;
                });
              } else if (category == 'All' && author != 'All') {
                  setState(() {
                    selectedCategory = '';
                    filteredCategory = '';
                    currentQuery = author;
                    filteredAuthor = author;
                    filterNewest = newest;
                    filteredLanguage = language;
                  });
              } else {
                setState(() {
                  filteredCategory = category;
                  selectedCategory = category;
                  currentQuery = author;
                  filteredAuthor = author;
                  filterNewest = newest;
                  filteredLanguage = language;
                });
              }
              // Apply your filter logic here
              _updateBookList();
            },
          );
        },
      );
    }
  }


  Future<List<String>> updateCategories() async {
    final result = await databaseHelper.getTopCategories(10);
    if (result.isNotEmpty) {
      if (selectedCategory.isEmpty) {
        setState(() {
          selectedCategory = result[0];
        });
      } else {
        if (result.contains(selectedCategory)) {
          selectedCategoryIndex = result.indexOf(selectedCategory);
        } else {
          result.add(selectedCategory);
          selectedCategoryIndex = result.indexOf(selectedCategory);
        }
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(scrollController.isAttached) {
          scrollController.jumpTo(index: selectedCategoryIndex);
        }
      });
      return result;
    } else {
      return ['No category.'];
    }
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
        if (totalBooks != allBooks.length) {
          setState(() {
            totalBooks = allBooks.length;
          });
        }
        return allBooks;
      } else {
        final String queryLowerCase = currentQuery.toLowerCase();
        final bookList = allBooks
            .where((book) =>
        (book.title.toLowerCase().contains(queryLowerCase) ||
            book.authors.any((author) => author.toLowerCase().contains(queryLowerCase))))
            .toList();
        if (totalBooks != bookList.length) {
          setState(() {
            totalBooks = bookList.length;
          });
        }
        return bookList;
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

class FilterDialog extends StatefulWidget {
  final List<String> allAuthors;
  final List<String> allCategories;
  final List<String> allLanguages;
  final String filteredAuthor;
  final String filteredCategory;
  final bool filterNewest;
  final Function(String, String, bool, String) onApplyFilter;

  const FilterDialog({super.key,
    required this.allAuthors,
    required this.allCategories,
    required this.allLanguages,
    required this.filteredAuthor,
    required this.filteredCategory,
    required this.filterNewest,
    required this.onApplyFilter,
  });

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String selectedCategory = '';
  String selectedAuthor = '';
  bool filterNewest = false;
  String selectedLanguage = '';
  List<String> allAuthors = [];
  List<String> allCategories = [];
  List<String> allLanguages = [];
  List<String> availableAuthors = [];
  List<String> availableCategories = [];
  final databaseHelper = DatabaseHelper();
  final categoryController = TextEditingController();
  final authorController = TextEditingController();
  final languageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    allAuthors = ['All'] + widget.allAuthors;
    allCategories = ['All'] + widget.allCategories;
    allLanguages = ['All'] + widget.allLanguages;
    availableAuthors = allAuthors;
    availableCategories = allCategories;
    if (widget.filteredAuthor.isEmpty) {
      authorController.text = allAuthors[0];
    } else {
      authorController.text = widget.filteredAuthor;
    }
    if (widget.filteredCategory.isEmpty) {
      categoryController.text = allCategories[0];
    } else {
      categoryController.text = widget.filteredCategory;
    }
    languageController.text = allLanguages[0];
  }

  void updateAvailableAuthors() async {
    if (categoryController.text == 'All') {
      availableAuthors = allAuthors;
    } else {
      availableAuthors = await databaseHelper.getAuthorsByCategoryFromDatabase(categoryController.text);
    }
    if (availableAuthors.contains(authorController.text)) {
      availableAuthors = allAuthors;
      return;
    }
    setState(() {
      authorController.text = availableAuthors[0];
      selectedAuthor = availableAuthors[0];
    });
  }

  void updateAvailableCategories() async {
    if (authorController.text == 'All') {
      availableCategories = allCategories;
    } else {
      availableCategories = await databaseHelper.getCategoriesByAuthorFromDatabase(authorController.text);
    }
    if (availableCategories.contains(categoryController.text)) {
      availableCategories = allCategories;
      return;
    }
    setState(() {
      categoryController.text = availableCategories[0];
      selectedCategory = availableCategories[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    double fem = MediaQuery.of(context).size.width / 360;
    return AlertDialog(
      title: const Text(
        'Filter Books',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xff19191b),
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width - 50 * fem,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff19191b),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: DropdownMenu<String>(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff19191b),
                  ),
                  controller: categoryController,
                  menuHeight: 300,
                  width: MediaQuery.of(context).size.width - 110 * fem,
                  requestFocusOnTap: true,
                  inputDecorationTheme: const InputDecorationTheme(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  onSelected: (String? value) {
                    setState(() {
                      categoryController.text = value!;
                      selectedCategory = value;
                      updateAvailableAuthors();
                    });
                  },
                  dropdownMenuEntries: availableCategories
                      .map((category) => DropdownMenuEntry<String>(
                    value: category,
                    label: category.toString(),
                  ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Author',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff19191b),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: DropdownMenu<String>(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff19191b),
                  ),
                  controller: authorController,
                  menuHeight: 300,
                  width: MediaQuery.of(context).size.width - 110 * fem,
                  requestFocusOnTap: true,
                  inputDecorationTheme: const InputDecorationTheme(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  onSelected: (String? value) {
                    setState(() {
                      authorController.text = value!;
                      selectedAuthor = value;
                      updateAvailableCategories();
                    });
                  },
                  dropdownMenuEntries: availableAuthors
                      .map((author) => DropdownMenuEntry<String>(
                    value: author,
                    label: author.toString(),
                  )).toList(),
                ),
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
              const Text(
                'Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff19191b),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: DropdownMenu<String>(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff19191b),
                  ),
                  controller: languageController,
                  menuHeight: 300,
                  width: MediaQuery.of(context).size.width - 110 * fem,
                  requestFocusOnTap: true,
                  inputDecorationTheme: const InputDecorationTheme(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  onSelected: (String? value) {
                    setState(() {
                      languageController.text = value!;
                      selectedLanguage = value;
                    });
                  },
                  dropdownMenuEntries: allLanguages
                      .map((language) => DropdownMenuEntry<String>(
                    value: language,
                    label: language.toString(),
                  )).toList(),
                ),
              ),
              SizedBox(height: 16 * fem,),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      categoryController.text = allCategories[0];
                      authorController.text = allAuthors[0];
                      languageController.text = allLanguages[0];
                      selectedCategory = allCategories[0];
                      selectedAuthor = allAuthors[0];
                      selectedLanguage = allLanguages[0];
                      filterNewest = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xffffffff),
                    backgroundColor: const Color(0xff946f58),
                  ),
                  child: const Text('Reset Filter'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApplyFilter(
              selectedCategory,
              selectedAuthor,
              filterNewest,
              selectedLanguage,
            );
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: const Color(0xffffffff),
            backgroundColor: const Color(0xff946f58),
          ),
          child: const Text('Apply Filter'),
        ),
      ],
    );
  }
}


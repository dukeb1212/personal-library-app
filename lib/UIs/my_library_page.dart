import 'package:flutter/material.dart';
import 'package:login_test/UIs/add_book_page_final.dart';
import 'package:login_test/UIs/book.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../book_data.dart';
import '../database/book_database.dart';
import '../user_data.dart';

class MyLibraryPage extends StatefulWidget {
  const MyLibraryPage({super.key});

  @override
  MyLibraryPageState createState() => MyLibraryPageState();
}

class MyLibraryPageState extends State<MyLibraryPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String currentQuery = '';
  int selectedCategoryIndex = 0;
  int selectedTabIndex = 0;
  List<BookState> allBookStates = [];
  String selectedCategory = '';
  bool getAll = true;
  bool getFavor = false;
  final databaseHelper = DatabaseHelper();
  int totalBooks = 0;

  String filteredCategory = '';
  String filteredAuthor = '';
  String sortBy = '';
  String filteredLanguage = 'All';

  ItemScrollController scrollController = ItemScrollController();
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  PageStorageBucket pageStorageBucket = PageStorageBucket();
  ScrollController pageScrollController = ScrollController();

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
        title: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                    fontSize: 18*fem,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff404040),
                  ),
                  hintText: 'Enter title or author',
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  setState(() {
                    currentQuery = query;
                  });
                },
              style: TextStyle(
                fontSize: 18*fem,
                fontWeight: FontWeight.w400,
                color: const Color(0xff404040),
              ),
              ),
            ),
            // Search icon
            IconButton(
              icon: const Icon(Icons.search, color: Color(0xff404040),),
              onPressed: () {
                _updateBookList();
              },
            ),
            // Stack or List icon
            IconButton(
              icon: const Icon(Icons.filter_alt, color: Color(0xff404040)), // You can change the icon
              onPressed: () {
                _showFilterDialog(context);
              },
            ),
          ],
        ),
        backgroundColor: const Color(0xffffffff), // Set the app bar background color to black
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
        backgroundColor: const Color(0xff404040).withOpacity(0.8),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SingleChildScrollView(
        controller: pageScrollController,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20*fem),
              Padding(
                padding: EdgeInsets.only(left: 10*fem),
                child: Text(
                  'All ($totalBooks books)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24 * fem,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10*fem),
              SizedBox(
                height: 310*fem,
                child: FutureBuilder<List<Book>>(
                  future: _getFilteredBooksFromDatabase(getAll),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No book found!'));
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
              SizedBox(
                height: 330*fem,
                child: FutureBuilder<List<Book>>(
                  future: _getFilteredBooksFromDatabase(!getAll),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No book found!'));
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
              Padding(
                padding: EdgeInsets.only(left: 10*fem),
                child: Text(
                  'Favorites List',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24 * fem,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10*fem,),
              SizedBox(
                height: 330*fem,
                child: FutureBuilder<List<Book>>(
                  future: _getFilteredBooksFromDatabase(getAll, getFavor: true),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No book found!'));
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
              SizedBox(height: 10*fem,),
            ],
          ),
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
            filteredLanguage: filteredLanguage,
            sortOption: sortBy,
            onApplyFilter: (category, author, sort, language) {
              if (category == 'All' && author == 'All') {
                setState(() {
                  filteredCategory = '';
                  selectedCategory = '';
                  currentQuery = '';
                  filteredAuthor = '';
                  filteredLanguage = language;
                });
              } else if (author == 'All' && category != 'All') {
                setState(() {
                  filteredCategory = category;
                  selectedCategory = category;
                  currentQuery = '';
                  filteredAuthor = '';
                  filteredLanguage = language;
                });
              } else {
                setState(() {
                  filteredCategory = category;
                  selectedCategory = category;
                  currentQuery = author;
                  filteredAuthor = author;
                  filteredLanguage = language;
                });
              }
              sortBy = sort;
              // Apply your filter logic here
              _updateBookList();
              if (filteredCategory == category) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  pageScrollController.jumpTo(pageScrollController.position.maxScrollExtent/2);
                });
              } else {
                pageScrollController.jumpTo(pageScrollController.position.minScrollExtent);
              }
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
    if (mounted) {
      setState(() {
        totalBooks = allBooks.length;
      });
    }
  }

  Future<List<Book>> _getFilteredBooksFromDatabase(bool getAll, {bool? getFavor}) async {
    final List<Book> allBooks = await databaseHelper.getAllBooks();
    final provider = container.read(userProvider);
    final int? userId = provider.user?.userId;
    List<Book> result = allBooks;
    allBookStates = await databaseHelper.getAllBookStates(userId!);

    // Filter books based on the search query and selected category
    if (sortBy.isNotEmpty) {
      final List<BookState> resultState = allBookStates.where(
              (bookState) => result.any((book) => bookState.bookId == book.id)
      ).toList();
      result = sortByOption(result, resultState, sortByOptions.indexWhere((option) => sortBy == option));
    }
    if (filteredLanguage != 'All') {
      result = result
          .where((book) => book.language == filteredLanguage).toList();
    }
    if (!getAll) {
      if (currentQuery.isEmpty && selectedCategory.isEmpty) {
        result = result; // Return all books if both query and category are empty
      } else if (currentQuery.isEmpty) {
        result = result
            .where((book) => book.category == selectedCategory)
            .toList();
      } else {
        final String queryLowerCase = currentQuery.toLowerCase();
        result = result
            .where((book) =>
        (book.title.toLowerCase().contains(queryLowerCase) ||
            book.authors.any((author) => author.toLowerCase().contains(queryLowerCase))) &&
            (selectedCategory.isEmpty || book.category == selectedCategory))
            .toList(); // Filter books based on both query and category
      }
    } else {
      if (currentQuery.isEmpty) {
        if (totalBooks != result.length) {
          setState(() {
            totalBooks = result.length;
          });
        }
      } else {
        final String queryLowerCase = currentQuery.toLowerCase();
        result = result
            .where((book) =>
        (book.title.toLowerCase().contains(queryLowerCase) ||
            book.authors.any((author) => author.toLowerCase().contains(queryLowerCase))))
            .toList();
        if (totalBooks != result.length) {
          setState(() {
            totalBooks = result.length;
          });
        }
      }
      if (getFavor != null) {
        if (getFavor) {
          final resultState = allBookStates.where((bookState) => bookState.addToFavorites).toList();
          result = result.where((book) => resultState.any((bookState) => book.id == bookState.bookId)).toList();
        }
      }
    }
    return result;
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
      child: Stack(
        children: [
          Container(
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
          Positioned(
              top: 4,
              right: 4,
              child: SizedBox(
                width: 20.0, // Adjust the size as needed
                height: 20.0,
                child: CircularProgressIndicator(
                  value: bookState.percentRead / 100.0, // Set the progress value based on the percentage
                  strokeWidth: 4.0, // Adjust the thickness of the circular progress indicator
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Colors.grey,
                ),
              ),
          ),
        ],
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
  final String filteredLanguage;
  final String sortOption;
  final Function(String, String, String, String) onApplyFilter;

  const FilterDialog({super.key,
    required this.allAuthors,
    required this.allCategories,
    required this.allLanguages,
    required this.filteredAuthor,
    required this.filteredCategory,
    required this.filteredLanguage,
    required this.sortOption,
    required this.onApplyFilter,
  });

  @override
  FilterDialogState createState() => FilterDialogState();
}

class FilterDialogState extends State<FilterDialog> {
  String selectedCategory = '';
  String selectedAuthor = '';
  bool filterNewest = false;
  String selectedLanguage = 'All';
  List<String> allAuthors = [];
  List<String> allCategories = [];
  List<String> allLanguages = [];
  List<String> availableAuthors = [];
  final databaseHelper = DatabaseHelper();
  final categoryController = TextEditingController();
  final authorController = TextEditingController();
  final sortController = TextEditingController();
  final languageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    allAuthors = ['All'] + widget.allAuthors;
    allCategories = ['All'] + widget.allCategories;
    allLanguages = ['All'] + widget.allLanguages;
    availableAuthors = allAuthors;
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
    languageController.text = widget.filteredLanguage;
    sortController.text = widget.sortOption;
  }

  void updateAvailableAuthors() async {
    if (categoryController.text == 'All') {
      availableAuthors = allAuthors;
    } else {
      availableAuthors = ['All'] + await databaseHelper.getAuthorsByCategoryFromDatabase(categoryController.text);
    }
    setState(() {
      authorController.text = availableAuthors[0];
      selectedAuthor = availableAuthors[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    double fem = MediaQuery.of(context).size.width / 360;
    return AlertDialog(
      title: Text(
        'Filter Books',
        style: TextStyle(
          fontSize: 24*fem,
          fontWeight: FontWeight.w700,
          color: const Color(0xff19191b),
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width - 50 * fem,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Category',
                style: TextStyle(
                  fontSize: 18*fem,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff19191b),
                ),
              ),
              SizedBox(height: 8*fem),
              Center(
                child: DropdownMenu<String>(
                  enableFilter: categoryController.text != 'All',
                  textStyle: TextStyle(
                    fontSize: 16*fem,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff19191b),
                  ),
                  controller: categoryController,
                  menuHeight: 300*fem,
                  width: MediaQuery.of(context).size.width - 120 * fem,
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
                  dropdownMenuEntries: allCategories
                      .map((category) => DropdownMenuEntry<String>(
                    value: category,
                    label: category.toString(),
                  ))
                      .toList(),
                ),
              ),
              SizedBox(height: 16*fem),
              Text(
                'Author',
                style: TextStyle(
                  fontSize: 18*fem,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff19191b),
                ),
              ),
              SizedBox(height: 8*fem),
              Center(
                child: DropdownMenu<String>(
                  enableFilter: authorController.text != 'All',
                  textStyle: TextStyle(
                    fontSize: 16*fem,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff19191b),
                  ),
                  controller: authorController,
                  menuHeight: 300*fem,
                  width: MediaQuery.of(context).size.width - 120 * fem,
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
                    });
                  },
                  dropdownMenuEntries: availableAuthors
                      .map((author) => DropdownMenuEntry<String>(
                    value: author,
                    label: author.toString(),
                  )).toList(),
                ),
              ),
              SizedBox(height: 16*fem),
              Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 18*fem,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff19191b),
                ),
              ),
              SizedBox(height: 8*fem),
              Center(
                child: DropdownMenu<String>(
                  textStyle: TextStyle(
                    fontSize: 16*fem,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff19191b),
                  ),
                  controller: sortController,
                  menuHeight: 300*fem,
                  width: MediaQuery.of(context).size.width - 120 * fem,
                  requestFocusOnTap: false,
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
                      sortController.text = value!;
                    });
                  },
                  dropdownMenuEntries: sortByOptions
                      .map((type) => DropdownMenuEntry<String>(
                    value: type,
                    label: type.toString(),
                  )).toList(),
                ),
              ),
              SizedBox(height: 16*fem),
              Text(
                'Language',
                style: TextStyle(
                  fontSize: 18*fem,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff19191b),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: DropdownMenu<String>(
                  textStyle: TextStyle(
                    fontSize: 16*fem,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff19191b),
                  ),
                  controller: languageController,
                  menuHeight: 300*fem,
                  width: MediaQuery.of(context).size.width - 120 * fem,
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
                      sortController.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xffffffff),
                    backgroundColor: const Color(0xff404040),
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
              sortController.text,
              selectedLanguage,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Apply Filter'),
        ),
      ],
    );
  }
}


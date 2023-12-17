import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  String currentQuery = '';

  @override
  Widget build(BuildContext context) {
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
                        hintText: 'Nhập tên sách hoặc tên tác giả',
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
                future: _getFilteredBooksFromDatabase(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No books found.');
                  } else {
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5.0, // Adjust the spacing as needed
                        mainAxisSpacing: 35.0,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Flex(
                          direction: Axis.vertical,
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
                onPressed: () async {
                  Book? book = await getBookByBarcode();
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddBookDetailsPage(book: book),
                      ),
                    );
                  }
                },
                child: Icon(MdiIcons.barcode),
              ),
              const SizedBox(height: 16.0),
              FloatingActionButton(
                heroTag: 'manual add',
                onPressed: () {
                  _showInputDialog();
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

  Future<List<Book>> _getFilteredBooksFromDatabase() async {
    final databaseHelper = DatabaseHelper();
    final List<Book> allBooks = await databaseHelper.getAllBooks();

    // Filter books based on the search query
    if (currentQuery.isEmpty) {
      return allBooks; // Return all books if the query is empty
    } else {
      final String queryLowerCase = currentQuery.toLowerCase();
      return allBooks.where((book) =>
      book.title.toLowerCase().contains(queryLowerCase) ||
          book.authors.any((author) => author.toLowerCase().contains(queryLowerCase))
      ).toList();
    }
  }

  Widget _buildBookButton(Book book) {
    // Implement the UI for a book button
    // You can use ElevatedButton or any other widget you prefer
    return Flexible(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Handle button press
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: book.imageLinks.isNotEmpty
                    ? Image.network(
                  book.imageLinks['thumbnail'] ?? '', // Use the appropriate key for the thumbnail link
                  fit: BoxFit.cover,
                )
                    : Container(), // Placeholder if the image link is empty
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            book.title,
            style: const TextStyle(fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<void> _showInputDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MyDialog();
      },
    );
  }
}

class MyDialog extends StatefulWidget {
  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  TextEditingController titleController = TextEditingController();
  TextEditingController subtitleController = TextEditingController();
  TextEditingController authorsController = TextEditingController();
  TextEditingController categoriesController = TextEditingController();
  TextEditingController publishedDateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController totalPagesController = TextEditingController();
  TextEditingController languageController = TextEditingController();
  TextEditingController thumbnailController = TextEditingController();
  TextEditingController buyDateController = TextEditingController();
  TextEditingController lastPageReadController = TextEditingController();
  TextEditingController lastSeenPlaceController = TextEditingController();


  List<String> authors = [];
  List<String> selectedCategories = [];
  List<int> years = List.generate(150, (int index) => DateTime.now().year - index);
  String? selectedLanguageCode;
  String? selectedYear;
  String? _imageUrl;
  File? _imageFile;

  final databaseHelper = DatabaseHelper();
  final provider = container.read(userProvider);

  final imageHelper = ImageHelper();

  @override
  Widget build(BuildContext context) {
    final UserData? userData = provider.user;
    return AlertDialog(
      title: const Text('Enter Book Information'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: subtitleController,
              decoration: const InputDecoration(labelText: 'Subtitle'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: authorsController,
                    decoration: const InputDecoration(
                        labelText: 'Author'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // Check if the entered author is not empty and is not already in the list
                    String newAuthor = authorsController.text.trim();
                    if (newAuthor.isNotEmpty &&
                        !authors.contains(newAuthor)) {
                      setState(() {
                        authors.add(newAuthor);
                      });
                      // Clear the value of the controller
                      authorsController.clear();
                    }
                  },
                ),
              ],
            ),
            Wrap(
              spacing: 8.0, // Adjust spacing as needed
              children: authors.map((author) {
                return Chip(
                  label: Text(author),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      authors.remove(author);
                    });
                  },
                );
              }).toList(),
            ),
            Row(
              children: [
                Expanded(
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      return bookCategoriesVietnamese
                          .where((category) => category.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                          .toList();
                    },
                    onSelected: (String selectedCategory) {
                      setState(() {
                        categoriesController.text = selectedCategory;
                      });
                    },
                    fieldViewBuilder: (BuildContext context, TextEditingController fieldController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                      return TextField(
                        controller: fieldController,
                        focusNode: fieldFocusNode,
                        decoration: const InputDecoration(labelText: 'Categories'),
                      );
                    },
                    optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          child: SizedBox(
                            width: double.infinity,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final String category = options.elementAt(index);
                                return ListTile(
                                  title: Text(category),
                                  onTap: () {
                                    onSelected(category);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // Check if the entered category is not empty and is in the available list
                    String newCategory = categoriesController.text.trim();
                    if (newCategory.isNotEmpty && bookCategoriesVietnamese.contains(newCategory) && !selectedCategories.contains(newCategory)) {
                      setState(() {
                        selectedCategories.add(newCategory);
                        // Clear the value of the controller
                        categoriesController.clear();
                      });
                    }
                  },
                ),
              ],
            ),

            Wrap(
              spacing: 8.0, // Adjust spacing as needed
              children: selectedCategories.map((category) {
                return Chip(
                  label: Text(category),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      selectedCategories.remove(category);
                    });
                  },
                );
              }).toList(),
            ),
            TextFormField(
              controller: publishedDateController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Published Year'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Select Year'),
                      content: DropdownButton<int>(
                        value: int.tryParse(selectedYear ?? ''),
                        items: years.map((int year) {
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }).toList(),
                        onChanged: (int? selectedValue) {
                          setState(() {
                            selectedYear = selectedValue?.toString();
                            publishedDateController.text = selectedYear ?? '';
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                );
              },
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: totalPagesController,
              decoration: const InputDecoration(labelText: 'Total Pages'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: languageController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Language'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Select Language'),
                      content: DropdownButton<String>(
                        value: selectedLanguageCode,
                        items: languageMap.entries.map((MapEntry<String, String> entry) {
                          return DropdownMenuItem<String>(
                            value: entry.value,
                            child: Text('${entry.key} (${entry.value})'),
                          );
                        }).toList(),
                        onChanged: (String? selectedValue) {
                          setState(() {
                            selectedLanguageCode = selectedValue;
                            languageController.text =
                            '${languageMap.keys.firstWhere((key) => languageMap[key] == selectedLanguageCode)} ($selectedLanguageCode)';
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                );
              },
            ),
            TextFormField(
              controller: buyDateController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Buy Date'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                  setState(() {
                    buyDateController.text = formattedDate; // Format the date as needed
                  });
                }
              },
            ),
            TextFormField(
              controller: lastPageReadController,
              keyboardType: TextInputType.number,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: 'Last Page Read',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: lastPageReadController.text.isNotEmpty &&
                        int.tryParse(lastPageReadController.text) != null &&
                        int.parse(lastPageReadController.text) > int.parse(totalPagesController.text)
                        ? Colors.red
                        : Colors.transparent, // Set to transparent to remove the border
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),
                errorText: lastPageReadController.text.isNotEmpty &&
                    int.tryParse(lastPageReadController.text) != null &&
                    int.parse(lastPageReadController.text) > int.parse(totalPagesController.text)
                    ? 'Value must be less than or equal to total pages'
                    : null,
              ),
            ),
            TextField(
              controller: lastSeenPlaceController,
              decoration: const InputDecoration(labelText: 'Last Seen Place'),
            ),
            ElevatedButton(
              onPressed: () async{
                final image = await imageHelper.selectImageFromGallery();
                setState(() {
                  _imageFile = image;
                });
              },
              child: const Text('Choose Image'),
            ),

            ElevatedButton(
              onPressed: () async{
                final image = await imageHelper.takePicture();
                setState(() {
                  _imageFile = image;
                });
              },
              child: const Text('Take Picture'),
            ),
            _imageFile != null ? Image.file(_imageFile!) : const Text('Please select image')
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            authors = [];
            selectedCategories = [];
            _imageFile = null;
            Navigator.of(context).pop(false); // Close the dialog and return false
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              barrierDismissible: false, // Prevent user from dismissing the dialog
            );

            final result = await addBook();

            if (mounted) {
              Navigator.of(context).pop();
            }

            if (mounted) {
              Navigator.of(context).pop(); // Close the loading dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result['message'])),
              );

              if (result['message'] == 'Added book successfully') {
                print(result['message']);
                await databaseHelper.syncBooksFromServer(userData!.userId, userData.username);
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> addBook() async {
    // Upload image to Firebase Storage and get the URL
    _imageUrl = await ImageHelper.uploadImageToFirebaseStorage(fbemail, fbpassword, _imageFile!);
    print(_imageUrl);
    final newId = generateUniqueId();
    final UserData? userData = provider.user;

    if (_imageUrl != null) {
      Book book = Book(
          id: newId,
          title: titleController.text,
          subtitle: '',
          authors: authors,
          categories: selectedCategories,
          publishedDate: selectedYear ?? 'unk',
          description: descriptionController.text,
          totalPages: int.parse(totalPagesController.text),
          language: selectedLanguageCode ?? 'unk',
          imageLinks: {'thumbnail': _imageUrl!}
      );

      BookState bookState = BookState(
        bookId: book.id,
        buyDate: buyDateController.text,
        lastReadDate: DateTime.now(),
        lastPageRead: int.parse(lastPageReadController.text),
        percentRead: int.parse(lastPageReadController.text)/book.totalPages*100,
        totalReadHours: 0.0,
        addToFavorites: false,
        lastSeenPlace: lastSeenPlaceController.text,
        userId: userData?.userId ?? 0,
        quotation: [],
        comment: [],
      );

      final updateBackend = UpdateBookBackend();
      final bookResult = await updateBackend.addOrUpdateBook(book);
      final stateResult = await updateBackend.addOrUpdateGoogleBook(bookState);

      Map<String, dynamic> result = {};
      if(bookResult['success'] && stateResult['success']) {
        result['success'] = true;
        result['message'] = 'Added book successfully';
      } else {
        result['success'] = false;
        result['message'] = stateResult['success'] ? bookResult['message'] : stateResult['message'];
      }
      return result;
    } else {
      final result = await addBook();
      return result;
    }
  }
}

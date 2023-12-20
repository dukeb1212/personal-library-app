import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:shelf_router/shelf_router.dart';

import '../backend/update_book_backend.dart';
import '../book_data.dart';
import '../database/book_database.dart';
import '../user_data.dart';
import 'package:login_test/backend/image_helper.dart';


String fbemail = dotenv.env['FIREBASE_EMAIL'] ?? '';
String fbpassword = dotenv.env['FIREBASE_PASSWORD'] ?? '';

class AddBookDetailsPage extends StatefulWidget {
  final Book? book;

  const AddBookDetailsPage({Key? key, required this.book}) : super(key: key);

  @override
  _AddBookDetailsPageState createState() => _AddBookDetailsPageState();
}

class _AddBookDetailsPageState extends State<AddBookDetailsPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController subtitleController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController publishedDateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController totalPagesController = TextEditingController();
  TextEditingController languageController = TextEditingController();
  TextEditingController buyDateController = TextEditingController();
  TextEditingController lastPageReadController = TextEditingController();
  TextEditingController lastSeenPlaceController = TextEditingController();
  String thumbnailLink = '';
  Image bookCover = Image.asset(
    'assets/default-book.png', // Provide the correct path to your default image
    height: 500,
    width: double.infinity,
    fit: BoxFit.contain,
  );
  bool showText = false;
  bool isImageSelected = false;
  List<int> years = List.generate(150, (int index) => DateTime.now().year - index);
  String? selectedLanguageCode;
  String? selectedYear;
  String? _imageUrl;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.book!.title;
    subtitleController.text = widget.book!.subtitle;
    authorController.text = widget.book!.author;
    categoryController.text = widget.book!.category;
    publishedDateController.text = widget.book!.publishedDate;
    descriptionController.text = widget.book!.description;
    totalPagesController.text = widget.book!.totalPages.toString();
    languageController.text = widget.book!.language;
    // Retrieve image link from book object
    final Map<String, String> imageLinks = widget.book?.imageLinks ?? {};
    thumbnailLink = imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final provider = container.read(userProvider);
    final UserData? userData = provider.user;

    final imageHelper = ImageHelper();

    Widget buildDefaultImage() {
      return Image.asset(
        'assets/default-book.png',
        height: 500,
        width: double.infinity,
        fit: BoxFit.contain,
      );
    }

    void setImage() {
      if (thumbnailLink.isNotEmpty) {
          bookCover = Image.network(
            thumbnailLink,
            height: 500, // Set to your desired height
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // If there's an error loading the image, set the showText flag to true
              showText = true;
              // Return the default image
              return buildDefaultImage();
            },
          );
      }
    }

    Widget buildBookImage(BuildContext context) {
      setImage();
      return Column(
        children: [
          Stack(
            children: [
              bookCover,
              if (showText || thumbnailLink.isEmpty) // Show text only when there's an error loading the image
                if (!isImageSelected)
                Positioned.fill(
                  child: Container(
                    color: Colors.transparent, // Make the container transparent
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Không thể tìm thấy bìa sách, hãy thêm ảnh',
                            style: TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (showText || thumbnailLink.isEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () async {
                  final image = await imageHelper.selectImageFromGallery();
                  if (image != null) {
                    setState(() {
                      bookCover = Image.file(
                        image,
                        height: 500,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      );
                      isImageSelected = true; // Set showText to false after setting the image
                    });
                  }
                  print('test');
                },
                child: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 32.0,
                  child: Icon(
                    Icons.photo_camera_back_outlined,
                    color: Colors.white,
                    size: 32.0,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final image = await imageHelper.takePicture();
                  if (image != null) {
                    setState(() {
                      bookCover = Image.file(
                        image,
                        height: 500,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      );
                      isImageSelected = true; // Set showText to false after setting the image
                    });
                  }
                  print('test');
                },
                child: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 32.0,
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 32.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display book image
            buildBookImage(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display existing book information
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: subtitleController,
                    decoration: const InputDecoration(labelText: 'Subtitle'),
                  ),
                  TextField(
                    controller: authorController,
                    decoration: const InputDecoration(labelText: 'Author'),
                  ),
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      return bookCategories
                          .where((category) => category.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                          .toList();
                    },
                    onSelected: (selectedCategory) {
                      setState(() {
                        categoryController.text = selectedCategory;
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
                  // Input fields for additional information
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

                  // Save and Cancel buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Navigate back to the previous page
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final result = await addBook();

                          if (mounted) {
                            if (result['success']) {
                              Navigator.pop(context);
                              final databaseHelper = DatabaseHelper();
                              await databaseHelper.syncBooksFromServer(userData!.userId, userData.username);
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Error'),
                                    content: const Text('Cannot add the book. Please try again later!'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> addBook() async {
    if (thumbnailLink.isEmpty) {
      // Upload image to Firebase Storage and get the URL
      _imageUrl = await ImageHelper.uploadImageToFirebaseStorage(fbemail, fbpassword, _imageFile!);
    }

    final provider = container.read(userProvider);
    final UserData? userData = provider.user;

    if (_imageUrl != null) {
      Book book = Book(
          id: widget.book!.id,
          title: titleController.text,
          subtitle: subtitleController.text,
          author: authorController.text,
          category: categoryController.text,
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
        percentRead: (int.parse(lastPageReadController.text)/book.totalPages)*100,
        totalReadHours: 0.0,
        addToFavorites: false,
        lastSeenPlace: lastSeenPlaceController.text,
        userId: userData?.userId ?? 0,
        quotation: [],
        comment: [],
      );

      final updateBackend = UpdateBookBackend();
      final bookResult = await updateBackend.addOrUpdateBook(book);
      final stateResult = await updateBackend.addBookToLibrary(bookState);

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

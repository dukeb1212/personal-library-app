import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../backend/google_books_api.dart';
import '../backend/update_book_backend.dart';
import '../book_data.dart';
import '../database/book_database.dart';
import '../user_data.dart';
import 'package:login_test/backend/image_helper.dart';
import 'book.dart';
import 'main_page.dart';

String fbemail = dotenv.env['FIREBASE_EMAIL'] ?? '';
String fbpassword = dotenv.env['FIREBASE_PASSWORD'] ?? '';

class AddBookScreen extends StatefulWidget {
  late Book? book;

  AddBookScreen({Key? key, required this.book}) : super(key: key);

  @override
  AddBookScreenState createState() => AddBookScreenState();
}

class AddBookScreenState extends State<AddBookScreen> {
  int _currentIndex = 0;

  TextEditingController titleController = TextEditingController();
  TextEditingController subtitleController = TextEditingController();
  TextEditingController isbnCodeController = TextEditingController();
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
  List<String> authors = [];
  DecorationImage bookCover = const DecorationImage(image: AssetImage("assets/default-book.png"), fit: BoxFit.scaleDown);
  bool showText = false;
  bool isImageSelected = false;
  List<int> years = List.generate(150, (int index) => DateTime.now().year - index);
  String? selectedLanguageCode;
  String? selectedYear;
  String? _imageUrl;
  File? _imageFile;
  bool isEverImage = false;
  bool isSaving = false;

  void initializeState() {
    titleController.text = widget.book!.title;
    subtitleController.text = widget.book!.subtitle;
    isbnCodeController.text = widget.book!.id;
    authors = widget.book!.authors;
    categoryController.text = widget.book!.category;
    publishedDateController.text = widget.book!.publishedDate;
    descriptionController.text = widget.book!.description;
    totalPagesController.text = widget.book!.totalPages.toString();
    selectedLanguageCode = widget.book!.language;
    languageController.text = '${languageMap.keys.firstWhere((key) => languageMap[key] == selectedLanguageCode)} ($selectedLanguageCode)';
    // Retrieve image link from book object
    final Map<String, String> imageLinks = widget.book?.imageLinks ?? {};
    thumbnailLink = imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'] ?? '';
  }

  @override
  void initState(){
    super.initState();
    initializeState();
  }

  @override
  Widget build(BuildContext context) {

    final provider = container.read(userProvider);
    final UserData? userData = provider.user;

    final imageHelper = ImageHelper();
    bool isTextFieldValid() {
      bool lastPageField = lastPageReadController.text.isEmpty ||
          (int.tryParse(lastPageReadController.text) != null &&
              int.parse(lastPageReadController.text) <= int.parse(totalPagesController.text));
      bool titleField = titleController.text.isEmpty;
      bool authorField = authors.isEmpty;
      bool totalPageField = totalPagesController.text.isEmpty || int.parse(totalPagesController.text) <= 0 ;
      return (lastPageField && !titleField && !authorField && !totalPageField);
    }

    double fem = MediaQuery.of(context).size.width / 360;

    void setImage() {
      if (thumbnailLink.isNotEmpty && !isImageSelected) {
        bookCover = DecorationImage(image: NetworkImage(thumbnailLink), fit: BoxFit.cover);
      }
    }


    void showImagePickerOptions() {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Take a photo'),
                onTap: () async {
                  final image = await imageHelper.takePicture();
                  if (image != null) {
                    setState(() {
                      _imageFile = image;
                      bookCover = DecorationImage(image: FileImage(image), fit: BoxFit.cover);
                      isImageSelected = true;
                    });
                  }
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  final image = await imageHelper.selectImageFromGallery();
                  if (image != null) {
                    setState(() {
                      _imageFile = image;
                      bookCover = DecorationImage(image: FileImage(image), fit: BoxFit.cover);
                      isImageSelected = true;
                    });
                  }
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        },
      );
    }

    Widget buildBookImage(BuildContext context) {
      setImage();
      return Container(
            height: 300* fem,
            width: 200* fem,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20 * fem),
              image: bookCover,
            ),
            child: FloatingActionButton(
              heroTag: 'imageTag',
              onPressed: () {
                showImagePickerOptions();
              },
              backgroundColor: Colors.transparent,
              // splashColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20 * fem),
              ),
              child: const Icon(Icons.camera_alt),
            ),
          );
    }

      return WillPopScope(
        onWillPop: () async {
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyMainPage(initialTabIndex: 1)),
          );
          return true;
        },
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xff404040),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // Quay về trang MyLibraryScreen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MyMainPage(initialTabIndex: 1)),
                  );
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: const Color(0xff404040).withOpacity(0.8),
              heroTag: 'save',
              onPressed: isTextFieldValid() ? () async {
                final result = await addBook();

                if (mounted) {
                  if (result['success']) {
                    final databaseHelper = DatabaseHelper();
                    final prefs = await SharedPreferences.getInstance();
                    final accessToken = prefs.getString('accessToken');

                    await databaseHelper.syncBooksFromServer(accessToken!);
                    setState(() {
                      isSaving = false;
                    });
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyMainPage(initialTabIndex: 1),
                        ),
                      );
                    }
                  } else {
                    setState(() {
                      isSaving = false;
                    });
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: Text(
                              'Cannot add the book (${result['message']}). Please try again later!'),
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
              } : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter all the necessary information with a valid value!')),
                );
              },
              child: const Icon(Icons.save),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            body: isSaving
                ? Center(
                child: SizedBox(
                    height: 200*fem,
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            'Adding the book, please wait a moment!',
                            style: TextStyle(
                              fontSize: 18*fem,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xff19191b),
                            ),
                          ),
                        ),
                        Text(
                          'Do not exit the app!',
                          style: TextStyle(
                            fontSize: 18*fem,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff19191b),
                          ),
                        ),
                        SizedBox(height: 18*fem),
                        const CircularProgressIndicator(),
                      ],
                    ),
                  )
                )
                : SingleChildScrollView(
              padding: EdgeInsets.all(16*fem),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: buildBookImage(context)),
                  // Tiêu đề và trình chỉnh sửa cho Title
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Title',
                        style: TextStyle(
                          fontSize: 18*fem,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff19191b),
                        ),
                      ),
                      SizedBox(height: 8*fem),
                      TextField(
                        onChanged: (_) {
                          setState(() {});
                        },
                        controller: titleController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: titleController.text.isEmpty
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          errorText: titleController.text.isEmpty
                              ? 'Please enter title!'
                              : null,
                        ),
                      ),
                      SizedBox(height: 10*fem),
                    ],
                  ),
                  // Tiêu đề và trình chỉnh sửa cho Author
                  buildEditableTextField("Subtitle", subtitleController),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ISBN code',
                        style: TextStyle(
                          fontSize: 18*fem,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff19191b),
                        ),
                      ),
                      SizedBox(height: 8*fem),
                      TextField(
                        readOnly: true,
                        controller: isbnCodeController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(height: 10*fem),
                    ],
                  ),
                  // Tiêu đề và trình chỉnh sửa cho About the Author
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Author',
                            style: TextStyle(
                              fontSize: 18*fem,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xff19191b),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              // Check if the entered author is not empty and is not already in the list
                              String newAuthor = authorController.text.trim();
                              if (newAuthor.isNotEmpty &&
                                  !authors.contains(newAuthor)) {
                                setState(() {
                                  authors.add(newAuthor);
                                });
                                // Clear the value of the controller
                                authorController.clear();
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 8*fem),
                      TextField(
                        controller: authorController,
                        decoration: InputDecoration(
                          hintText: 'Enter Author and Press Plus Icon',
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors
                                  .grey, // Set to transparent to remove the border
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          errorText:
                          authors.isEmpty ? 'Please add author(s)!' : null,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8.0*fem, // Adjust spacing as needed
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
                  SizedBox(height: 16*fem),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      DropdownMenu<String>(
                        textStyle: TextStyle(
                          fontSize: 16*fem,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff19191b),
                        ),
                        controller: categoryController,
                        enableFilter: true,
                        enableSearch: categoryController.text != 'Unknown',
                        menuHeight: 300*fem,
                        width: MediaQuery.of(context).size.width - 29 * fem,
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
                          });
                        },
                        dropdownMenuEntries: bookCategories
                            .map((category) => DropdownMenuEntry<String>(
                          value: category,
                          label: category.toString(),
                        ))
                            .toList(),
                      )
                    ],
                  ),
                  SizedBox(height: 16*fem),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Published Year',
                        style: TextStyle(
                          fontSize: 18*fem,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff19191b),
                        ),
                      ),
                      SizedBox(height: 8*fem),
                      TextFormField(
                        controller: publishedDateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          hintText: 'Choose published year',
                        ),
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
                                      publishedDateController.text =
                                          selectedYear ?? '';
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(height: 16*fem),
                    ],
                  ),
                  // Tiêu đề và trình chỉnh sửa cho Overview
                  buildEditableTextField("Description", descriptionController),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Pages',
                        style: TextStyle(
                          fontSize: 18*fem,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff19191b),
                        ),
                      ),
                      SizedBox(height: 8*fem),
                      TextField(
                        controller: totalPagesController,
                        onChanged: (_) {
                          setState(() {});
                        },
                        keyboardType:
                        const TextInputType.numberWithOptions(decimal: false),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: totalPagesController.text.isNotEmpty &&
                                  int.tryParse(totalPagesController.text) !=
                                      null &&
                                  int.parse(totalPagesController.text) <= 0
                                  ? Colors.red
                                  : Colors
                                  .grey, // Set to transparent to remove the border
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          errorText: totalPagesController.text.isNotEmpty &&
                              int.tryParse(totalPagesController.text) != null &&
                              int.parse(totalPagesController.text) <= 0
                              ? 'Please add a value greater than 0!'
                              : null,
                          hintText: 'Enter total pages',
                        ),
                      ),
                      SizedBox(height: 16*fem),
                    ],
                  ),
                  // Tiêu đề và trình chỉnh sửa cho Language
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Language',
                        style: TextStyle(
                          fontSize: 18*fem,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff19191b),
                        ),
                      ),
                      SizedBox(height: 8*fem),
                      TextFormField(
                        controller: languageController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          hintText: 'Choose language',
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Select Language'),
                                content: DropdownButton<String>(
                                  value: selectedLanguageCode,
                                  items: languageMap.entries
                                      .map((MapEntry<String, String> entry) {
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
                      SizedBox(height: 16*fem),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buy Date',
                        style: TextStyle(
                          fontSize: 18*fem,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff19191b),
                        ),
                      ),
                      SizedBox(height: 8*fem),
                      TextFormField(
                        controller: buyDateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          hintText: 'Choose buy date',
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            final formattedDate =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                            setState(() {
                              buyDateController.text =
                                  formattedDate; // Format the date as needed
                            });
                          }
                        },
                      ),
                      SizedBox(height: 16*fem),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Page Read',
                        style: TextStyle(
                          fontSize: 18*fem,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff19191b),
                        ),
                      ),
                      SizedBox(height: 8*fem),
                      TextFormField(
                        controller: lastPageReadController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (_) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          labelText: 'Enter the last page that you read',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: lastPageReadController.text.isNotEmpty &&
                                  int.tryParse(lastPageReadController.text) !=
                                      null &&
                                  int.parse(lastPageReadController.text) >
                                      int.parse(totalPagesController.text)
                                  ? Colors.red
                                  : Colors
                                  .grey, // Set to transparent to remove the border
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          errorText: lastPageReadController.text.isNotEmpty &&
                              int.tryParse(lastPageReadController.text) !=
                                  null &&
                              int.parse(lastPageReadController.text) >
                                  int.parse(totalPagesController.text)
                              ? 'Value must be less than or equal to total pages'
                              : null,
                        ),
                      ),
                      SizedBox(height: 16*fem),
                    ],
                  ),
                  buildEditableTextField(
                      "Last seen place", lastSeenPlaceController),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              height: 80*fem, // Đặt chiều cao của thanh điều hướng
              decoration: BoxDecoration(
                color: const Color(0xff404040), // Màu của thanh điều hướng
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: BottomNavigationBar(
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.add),
                    label: 'Create new',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(MdiIcons.barcode),
                    label: 'Scan ISBN code',
                  ),
                ],
                backgroundColor: Colors.transparent,
                selectedItemColor: Colors.white,
                // Màu của mục được chọn
                unselectedItemColor: Colors.grey,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                currentIndex: _currentIndex,
                onTap: (index) async {
                  setState(() {
                    _currentIndex = index;
                  });
                  if (index == 1) {
                    final result = await getBookByBarcode();
                    setState(() {
                      _currentIndex = 0;
                    });
                    if (result['success']) {
                      setState(() {
                        widget.book = result['book'];
                        isImageSelected = false;
                        initializeState();
                      });
                    } else {
                      if (mounted) {
                        if (result.containsKey('book') && result.containsKey('bookState')) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookScreen(book: result['book'], bookState: result['bookState'],),
                            ),
                          );
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(result['message'])),
                        );
                      }
                    }
                  }
                },
              ),
            )
        ),
      );
  }

  Widget buildEditableTextField(String title, TextEditingController controller) {
    double fem = MediaQuery.of(context).size.width / 360;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18*fem,
            fontWeight: FontWeight.w700,
            color: const Color(0xff19191b),
          ),
        ),
        SizedBox(height: 8*fem),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black,),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            hintText: 'Enter $title',
          ),
        ),
        SizedBox(height: 16*fem),
      ],
    );
  }

  Future<Map<String, dynamic>> addBook() async {
    if(!isSaving) {
      setState(() {
        isSaving = true;
      });
    }
    if (thumbnailLink.isEmpty) {
      // Upload image to Firebase Storage and get the URL
      if (_imageFile != null) {
        _imageUrl = await ImageHelper.uploadImageToFirebaseStorage(fbemail, fbpassword, _imageFile!);
        isEverImage = true;
      }
    } else {
      _imageUrl = thumbnailLink;
      isEverImage = true;
    }

    final String bookId;
    if (widget.book!.id.isEmpty) {
      bookId = generateUniqueId();
    } else {
      bookId = widget.book!.id;
    }

    final provider = container.read(userProvider);
    final UserData? userData = provider.user;

    if (isEverImage) {
      if (_imageUrl != null) {
        Book book = Book(
            id: bookId,
            title: titleController.text,
            subtitle: subtitleController.text,
            authors: authors,
            category: categoryController.text,
            publishedDate: publishedDateController.text,
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
    } else {
      Map<String, dynamic> result = {};
      result['success'] = false;
      result['message'] = 'No image was selected';
      return  result;
    }
  }
}
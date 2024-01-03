import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:login_test/UIs/my_library_page.dart';
import 'package:login_test/backend/update_book_backend.dart';
import 'dart:async';

import 'package:login_test/book_data.dart';
import 'package:login_test/database/book_database.dart';

import '../user_data.dart';
import 'main_page.dart';

class BookScreen extends StatefulWidget {
  final Book? book;
  final BookState? bookState;

  const BookScreen({Key? key, required this.book, required this.bookState}) : super(key: key);

  @override
  _BookScreenState createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  bool isReturn = false;
  bool isReading = false;
  Duration elapsedTime = Duration.zero;
  Timer? readingTimer;
  TextEditingController pageController = TextEditingController();
  BookState bookState = BookState.initial();

  @override
  void initState() {
    super.initState();
    bookState = BookState(
      bookId: widget.bookState!.bookId,
      userId: widget.bookState!.userId,
      buyDate: widget.bookState!.buyDate,
      totalReadHours: widget.bookState!.totalReadHours,
      lastPageRead: widget.bookState!.lastPageRead,
      lastReadDate: widget.bookState!.lastReadDate,
      lastSeenPlace: widget.bookState!.lastSeenPlace,
      comment: widget.bookState!.comment,
      quotation: widget.bookState!.quotation,
      percentRead: widget.bookState!.percentRead,
      addToFavorites: widget.bookState!.addToFavorites,
    );
    _updateState;
  }

  void _updateState () {
    setState(() {
    });
  }

  void startReadingTimer() {
    readingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedTime = elapsedTime + const Duration(seconds: 1);
      });
    });
  }

  void returnReadingTimer() {
    readingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedTime = elapsedTime + const Duration(seconds: 1);
      });
    });
  }

  void stopReadingTimer() {
    if (readingTimer != null && readingTimer!.isActive) {
      readingTimer!.cancel();
    }
    // Add your alert dialog here
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('You have read for ${formatDuration(elapsedTime)}.'),
          content: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Để Dialog ôm sát nội dung bên trong
              children: [
                TextField(
                  controller: pageController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Read page',
                    hintText: 'Enter the page you finished reading',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Update button text after closing the dialog
                setState(() {
                  isReading = true;
                });
                startReadingTimer();
              },
              child: const Text('Continue Reading'),
            ),
            TextButton(
              onPressed: () async {
                // Handle the save action with the entered page value
                String enteredPage = pageController.text;
                // You can use the enteredPage value as needed
                if (enteredPage.isNotEmpty && int.tryParse(enteredPage)! <= widget.book!.totalPages){
                  setState(() {
                    bookState.lastPageRead = int.tryParse(enteredPage)!;
                  });
                  bookState.lastReadDate = DateTime.now();

                  final updateBookBackend = UpdateBookBackend();
                  final localDatabase = DatabaseHelper();
                  final provider = container.read(userProvider);
                  final UserData? user = provider.user;

                  bookState.totalReadHours += elapsedTime.inSeconds/3600;

                  await updateBookBackend.addBookToLibrary(bookState);
                  await localDatabase.syncBooksFromServer(user!.userId, user.username);
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MyMainPage(initialTabIndex: 1)),
                    );
                  }
                  setState(() {
                    isReading = false;
                    elapsedTime = Duration.zero;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid page number!')),
                  );
                }
              },
              child: const Text('End Reading'),
            ),
          ],
        );
      },
    );

    setState(() {
      //isDialogButtonReading = false; // Reset dialog button state
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Widget readButton(){
    double fem = MediaQuery.of(context).size.width / 360;
    return SizedBox(
      height: 50 * fem,
      width: MediaQuery.of(context).size.width - 38 * fem,
      child: FloatingActionButton(
        onPressed: () {
          if (!isReading) {
            startReadingTimer();
          } else {
            stopReadingTimer();
          }
          setState(() {
            isReading = !isReading;
          });
        },
        backgroundColor: isReading? const Color(0xff6B0E0E) : const Color(0xff404040),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0 * fem),
        ),
        child: Text(
          isReading ? formatDuration(elapsedTime) : 'Read book',
          style: TextStyle(
            color: const Color(0xffdadada),
            fontSize: 16 * fem,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    final updateBookBackend = UpdateBookBackend();
    final localDatabase = DatabaseHelper();
    final provider = container.read(userProvider);
    final UserData? user = provider.user;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {

            // Quay về trang MyLibraryScreen
            if (!isReading) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyMainPage(initialTabIndex: 1)),
              );
            } else {
              stopReadingTimer();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Xử lý khi người dùng nhấn nút chia sẻ
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                width: 150 * fem,
                height: 220 * fem,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20 * fem),
                  child: Image.network(
                    widget.book!.imageLinks['thumbnail']!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10 * fem),
            Center(
              child: Text(
                widget.book!.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20 * fem,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Center(
              child: Text(
                widget.book!.authors.join(', '),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18 * fem,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(height: 10 * fem),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Description: ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18 * fem,
                      fontWeight: FontWeight.w600,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text:
                        widget.book!.description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10 * fem),
                RichText(
                  text: TextSpan(
                    text: 'Categories: ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18 * fem,
                      fontWeight: FontWeight.w600,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: widget.book!.category,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10 * fem),
                RichText(
                  text: TextSpan(
                    text: 'Published Date: ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18 * fem,
                      fontWeight: FontWeight.w600,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: widget.book!.publishedDate,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10 * fem),
                RichText(
                  text: TextSpan(
                    text: 'Language: ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18 * fem,
                      fontWeight: FontWeight.w600,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: languageMap.keys.firstWhere((key) => languageMap[key] == widget.book!.language),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10 * fem),
                RichText(
                  text: TextSpan(
                    text: 'Buy Date: ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18 * fem,
                      fontWeight: FontWeight.w600,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: bookState.buyDate,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10 * fem),
                RichText(
                  text: TextSpan(
                    text: 'Pages: ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18 * fem,
                      fontWeight: FontWeight.w600,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '${bookState.lastPageRead}/${widget.book!.totalPages}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10 * fem),
                RichText(
                  text: TextSpan(
                    text: 'Read Hours: ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18 * fem,
                      fontWeight: FontWeight.w600,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: bookState.totalReadHours.toString().length >= 6
                              ? '${bookState.totalReadHours.toString().substring(0, 5)} hours'
                              : '${bookState.totalReadHours.toString()} hours',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10 * fem),
                RichText(
                  text: TextSpan(
                    text: 'Last Read Date: ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18 * fem,
                      fontWeight: FontWeight.w600,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: DateFormat('yyyy-MM-dd').format(bookState.lastReadDate),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10 * fem),
                TextButton(
                  onPressed: () {
                    TextEditingController placeController = TextEditingController(text: bookState.lastSeenPlace);

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Edit Last Seen Place'),
                          content: TextField(
                            controller: placeController,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                setState(() {
                                  bookState.lastSeenPlace = placeController.text;
                                });
                                await updateBookBackend.addBookToLibrary(bookState);
                                await localDatabase.syncBooksFromServer(user!.userId, user.username);
                                if (mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'Last Seen Place: ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18 * fem,
                              fontWeight: FontWeight.w600,
                            ),
                            children: [
                              TextSpan(
                                text: bookState.lastSeenPlace,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Icon(
                          Icons.edit,
                          size: 18*fem,
                          color: const Color(0xff404040),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 10 * fem),
                TextButton(
                  onPressed: () {
                    TextEditingController pageNumberController = TextEditingController();
                    TextEditingController newQuotationController = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Edit Quotation'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Display each quotation in a separate row
                              Column(
                                children: bookState.quotation.map((quotation) {
                                  return Text('- $quotation');
                                }).toList(),
                              ),
                              // Row with two text fields for page numbers and the quotation
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: pageNumberController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      decoration: const InputDecoration(labelText: 'Page Number'),
                                    ),
                                  ),
                                  const SizedBox(width: 16), // Add some space between the text fields
                                  Expanded(
                                    child: TextField(
                                      controller: newQuotationController,
                                      decoration: const InputDecoration(labelText: 'New Quotation'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async{
                                setState(() {
                                  // Extract page number and new quotation from the text fields
                                  String newQuotation = '${pageNumberController.text}: ${newQuotationController.text}';
                                  if (bookState.quotation[0] == '') {
                                    bookState.quotation.removeAt(0);
                                  }
                                  bookState.quotation.add(newQuotation);
                                  // Do something with the extracted values, e.g., update the list
                                  // yourListOfQuotations.add(newQuotation);
                                  pageNumberController.clear();
                                  newQuotationController.clear();
                                });
                                await updateBookBackend.addBookToLibrary(bookState);
                                await localDatabase.syncBooksFromServer(user!.userId, user.username);

                                if (mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        );
                      },
                    );

                  },
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'Quotation: ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18 * fem,
                              fontWeight: FontWeight.w600,
                            ),
                            children: [
                              TextSpan(
                                text: bookState.quotation[0],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Icon(
                          Icons.edit,
                          size: 18*fem,
                          color: const Color(0xff404040),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 10 * fem),
                TextButton(
                  onPressed: () {
                    TextEditingController newCommentController = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Edit Comment'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Display each quotation in a separate row
                              Column(
                                children: bookState.comment.map((comment) {
                                  return Text(comment);
                                }).toList(),
                              ),
                              // Row with two text fields for page numbers and the quotation
                              TextField(
                                  controller: newCommentController,
                                  decoration: const InputDecoration(labelText: 'New Comment'),
                                ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                setState(() {
                                  // Extract page number and new quotation from the text fields
                                  String newComment = newCommentController.text;
                                  if (bookState.comment[0] == '') {
                                    bookState.comment.removeAt(0);
                                  }
                                  bookState.comment.add(newComment);
                                  newCommentController.clear();
                                });
                                await updateBookBackend.addBookToLibrary(bookState);
                                await localDatabase.syncBooksFromServer(user!.userId, user.username);

                                if (mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'Comment: ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18 * fem,
                              fontWeight: FontWeight.w600,
                            ),
                            children: [
                              TextSpan(
                                text: bookState.comment[0],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Icon(
                          Icons.edit,
                          size: 18*fem,
                          color: const Color(0xff404040),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 70*fem,),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: readButton(),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}h:${twoDigitMinutes}m:${twoDigitSeconds}s';
  }

}
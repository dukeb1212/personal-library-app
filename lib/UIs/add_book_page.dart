import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shelf_router/shelf_router.dart';

import '../backend/update_book_backend.dart';
import '../book_data.dart';
import '../database/book_database.dart';
import '../user_data.dart';

class BookDetailsPage extends StatefulWidget {
  final Book? book;

  const BookDetailsPage({Key? key, required this.book}) : super(key: key);

  @override
  _BookDetailsPageState createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  late TextEditingController buyDateController;
  late TextEditingController lastPageReadController;
  late TextEditingController lastSeenPlaceController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing book information
    buyDateController = TextEditingController();
    lastPageReadController = TextEditingController();
    lastSeenPlaceController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final provider = container.read(userProvider);
    final UserData? userData = provider.user;

    // Retrieve image link from book object
    final Map<String, String> imageLinks = widget.book?.imageLinks ?? {};
    final String thumbnailLink = imageLinks['thumbnail'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display book image
            if (thumbnailLink.isNotEmpty)
              Image.network(
                thumbnailLink,
                height: 500, // Set to your desired height
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display existing book information
                  Text('Title: ${widget.book?.title ?? ''}'),
                  Text('Subtitle: ${widget.book?.subtitle ?? ''}'),
                  Text('Authors: ${widget.book?.authors ?? ''}'),
                  Text('Categories: ${widget.book?.categories ?? ''}'),
                  Text('Published Year: ${widget.book?.publishedDate ?? ''}'),
                  Text('Description: ${widget.book?.description ?? ''}'),
                  Text('Total Pages: ${widget.book?.totalPages ?? ''}'),
                  Text('Language: ${widget.book?.language ?? ''}'),
                  Text('ISBN: ${widget.book?.id ?? ''}'),
                  // Add other fields for displaying book information

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
                              int.parse(lastPageReadController.text) > widget.book!.totalPages
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
                          int.parse(lastPageReadController.text) > widget.book!.totalPages
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
                          BookState bookState = BookState(
                              bookId: widget.book!.id,
                              buyDate: buyDateController.text,
                              lastReadDate: DateTime.now(),
                              lastPageRead: int.parse(lastPageReadController.text),
                              percentRead: (int.parse(lastPageReadController.text)/widget.book!.totalPages*100).toDouble(),
                              totalReadHours: 0.0,
                              addToFavorites: false,
                              lastSeenPlace: lastSeenPlaceController.text,
                              userId: userData?.userId ?? 0,
                              quotation: [],
                              comment: [],
                          );
                          // Update or add the book to the database
                          final updateBackend = UpdateBookBackend();
                          final result = await updateBackend.addOrUpdateGoogleBook(bookState);

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
}

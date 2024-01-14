// pages/add_event_page.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login_test/database/book_database.dart';
import 'package:login_test/notification_data.dart' as noti;

import '../backend/notification_backend.dart';
import '../book_data.dart';
import '../user_data.dart';

class AddEventPage extends StatefulWidget {
  final int? id;
  final String? bookTitle;
  final String? bookId;
  final DateTime? date;
  final TimeOfDay? time;
  final noti.RepeatType? repeat;

  const AddEventPage({
    Key? key,
    required this.id,
    required this.bookTitle,
    required this.bookId,
    required this.date,
    required this.time,
    required this.repeat,
  }) : super(key: key);

  @override
  AddEventPageState createState() => AddEventPageState();
}

class AddEventPageState extends State<AddEventPage> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  noti.RepeatType repeat = noti.RepeatType.noRepeat;
  bool active = true;
  DateTime finalDateTime = DateTime.now();
  List<Book> booksList = [];
  Book selectedBook = Book.defaultBook();
  TextEditingController repeatController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.id! != 0){
      selectedBook.title = widget.bookTitle!;
      selectedBook.id = widget.bookId!;
      repeatController.text = widget.repeat!.toStr();
      repeat = widget.repeat!;
      dateController.text = DateFormat('dd-MM-yyyy').format(widget.date!);
      selectedDate = widget.date!;
      timeController.text = '${widget.time!.hour} : ${widget.time!.minute}';
      selectedTime = widget.time!;
    }
    loadBooks();
  }

  Future<void> loadBooks() async {
    final databaseHelper = DatabaseHelper();
    final List<Book> loadedBooks = await databaseHelper.getAllBooks();
    setState(() {
      booksList = loadedBooks;
    });
  }

  @override
  Widget build(BuildContext context) {
    double fem = MediaQuery.of(context).size.width / 360;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Reading Plans'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Book To Read:',
              style: TextStyle(
                fontSize: 20*fem,
                fontWeight: FontWeight.w700,
                color: const Color(0xff19191b),
              ),
            ),
            SizedBox(height: 8*fem,),
            Center(
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(5)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton(
                          hint: SizedBox(
                            width:280*fem,
                            child:
                            Text(
                              selectedBook.title.isEmpty ? 'Select Book' : selectedBook.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectedBook = value!;
                            });
                          },
                          items: booksList.map((Book book) {
                            return DropdownMenuItem<Book>(
                              value: book,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                      width: 250*fem,
                                      child: Text(book.title)
                                  ),
                                  Container(
                                    height: 50*fem,
                                    width: 35*fem,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(image: NetworkImage(book.imageLinks['thumbnail']!), fit: BoxFit.cover),
                                    ),
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 20*fem),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date Start:',
                  style: TextStyle(
                    fontSize: 20*fem,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff19191b),
                  ),
                ),
                SizedBox(height: 8*fem),
                TextFormField(
                  controller: dateController,
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
                    hintText: 'Set date',
                  ),
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != selectedDate) {
                      setState(() {
                        selectedDate = pickedDate;
                        dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
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
                  'Time:',
                  style: TextStyle(
                    fontSize: 20*fem,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff19191b),
                  ),
                ),
                SizedBox(height: 8*fem),
                TextFormField(
                  controller: timeController,
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
                    hintText: 'Set time',
                  ),
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null && pickedTime != selectedTime) {
                      setState(() {
                        selectedTime = pickedTime;
                        timeController.text = '${selectedTime.hour} : ${selectedTime.minute}';
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
                  'Repeat Option:',
                  style: TextStyle(
                    fontSize: 20*fem,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff19191b),
                  ),
                ),
                SizedBox(height: 8*fem),
                TextFormField(
                  controller: repeatController,
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
                    hintText: 'Choose repeat option',
                  ),
                  onTap: () {
                    _showRepeatOptionsDialog();
                  },
                ),
                SizedBox(height: 16*fem),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 30*fem),
        child: SizedBox(
          height: 80*fem,
          width: 80*fem,
          child: FittedBox(
            child: FloatingActionButton(
              heroTag: 'save schedule',
              onPressed: () async {
                final noti.Notification notification = noti.Notification(
                    id: widget.id ?? 0,
                    bookId: selectedBook.id,
                    dateTime: DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    ),
                    repeatType: repeat.toInt(),
                    active: true
                );

                final provider = container.read(userProvider);
                final userId = provider.user?.userId;
                final NotificationBackend notificationBackend = NotificationBackend();
                final Map<String, dynamic> result =
                await notificationBackend.addScheduleNotification(notification, userId!);

                if (result['success']) {
                  final databaseHelper = DatabaseHelper();
                  await databaseHelper.syncNotificationsFromServer(userId);
                  // Notification added successfully
                  if(mounted) {
                    Navigator.pop(context, true);
                  }
                  // Add any additional UI logic or navigation here
                } else {
                  // Failed to add notification
                  if(mounted) {
                    Navigator.pop(context, false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add plan failed!')),
                    );
                  }
                  // Handle the error or provide user feedback
                }
              },
              child: const Icon(Icons.save_rounded),
            ),
          ),
        ),
      ),
    );
  }

  //Chọn lựa chọn cho biến laplai
  Future<void> _showRepeatOptionsDialog() async {
    final result = await showDialog<noti.RepeatType>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose repeat option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRepeatOptionButton('No Repeat', noti.RepeatType.noRepeat),
              _buildRepeatOptionButton('Daily', noti.RepeatType.daily),
              _buildRepeatOptionButton('Weekly', noti.RepeatType.weekly),
              _buildRepeatOptionButton('Monthly', noti.RepeatType.monthly),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        repeat = result;
        repeatController.text = result.toStr();
        if (kDebugMode) {
          print(repeat.toInt());
        }
      });
    }
  }
  Widget _buildRepeatOptionButton(String label, noti.RepeatType value) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop(value);
      },
      child: Text(label),
    );
  }
}

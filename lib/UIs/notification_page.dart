import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:login_test/UIs/book.dart';
import 'package:login_test/UIs/main_page.dart';
import 'package:login_test/backend/notification_backend.dart';
import 'package:flutter/foundation.dart';
import '../backend/local_notification.dart';
import '../book_data.dart';
import '../database/book_database.dart';
import 'package:login_test/notification_data.dart' as noti;

import '../user_data.dart';
import 'add_schedule_page.dart';



class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key,}) : super(key: key);

  @override
  NotificationPageState createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  final dbHelper = DatabaseHelper();
  final notificationBackend = NotificationBackend();
  List<noti.Notification> plans = [];
  List<ActiveNotification> activeNotificationsList = [];
  List<Book> books = [];
  final provider = container.read(userProvider);

  @override
  void initState() {
    super.initState();
    _updateEventList();
    _updateNotificationList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _updateEventList() async {
    books.clear();
    List<noti.Notification> notificationsList = await dbHelper.getNotificationSchedule();
    for (var notification in notificationsList) {
      final result = await dbHelper.doesBookExist(notification.bookId);
      if (result['existed']) {
        Book newBook = result['book'];
        books.add(newBook);
      } else {
        books.add(Book.defaultBook());
      }
    }
    setState(() {
      plans = notificationsList;
    });
  }

  _updateNotificationList() async {
    final List<ActiveNotification> activeNotifications =
    await LocalNotification.flutterLocalNotificationsPlugin.getActiveNotifications();
    setState(() {
      activeNotificationsList = activeNotifications;
    });
  }


  @override
  Widget build(BuildContext context) {
    double fem = MediaQuery.of(context).size.width / 360;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 40 * fem),
          Container(
            padding: EdgeInsets.fromLTRB(15 * fem, 0, 15 * fem, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notification',
                  style: TextStyle(
                    fontSize: 28 * fem,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _updateNotificationList();
                          });
                        },
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                      IconButton(
                        onPressed: () async {
                          await LocalNotification.flutterLocalNotificationsPlugin.cancelAll();
                          setState(() {
                            activeNotificationsList.clear();
                          });
                        },
                        icon: const Icon(Icons.delete_rounded),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 200 * fem,
            margin: EdgeInsets.fromLTRB(10 * fem, 0, 10 * fem, 0),
            child: activeNotificationsList.isEmpty
                ? Center(
                    child: Text(
                      'You have no notification',
                      style: TextStyle(fontSize: 18 * fem),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.vertical,
                    itemCount: activeNotificationsList.length,
                    itemBuilder: (context, index) => Dismissible(
                      key: UniqueKey(),
                      onDismissed: (direction) async {
                        await LocalNotification.flutterLocalNotificationsPlugin.cancel(activeNotificationsList[index].id!);
                        if (kDebugMode) {
                          print(index);
                        }
                        setState(() {
                          activeNotificationsList.removeAt(index);
                        });
                      },
                      background: Container(
                        color: Colors.white10,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(
                          Icons.delete,
                          color: Color(0xff404040),
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8 * fem),
                        width: MediaQuery.of(context).size.width - 20 * fem,
                        child: ElevatedButton(
                          onPressed: () async {
                            final result = await dbHelper.doesBookExist(activeNotificationsList[index].body!);
                            if (mounted) {
                              if (result['existed']) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => BookScreen(book: result['book'], bookState: result['bookState']))
                                );
                              } else {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const MyMainPage(initialTabIndex: 1,))
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12 * fem),
                            ),
                            foregroundColor: Colors.black,
                            backgroundColor: const Color(0xffeeeeee),
                            padding: EdgeInsets.all(10 * fem),
                            textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16 * fem,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${activeNotificationsList[index].title}',
                                style: TextStyle(
                                  fontSize: 18 * fem,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4 * fem),
                              Text("Today's book: ${books.where((book) => book.id == activeNotificationsList[index].body!).first.title}"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          SizedBox(height: 10 * fem),
          Container(
            padding: EdgeInsets.fromLTRB(15 * fem, 0, 15 * fem, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reading plan',
                  style: TextStyle(
                    fontSize: 28 * fem,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _showDeleteConfirmationDialog();
                  },
                  icon: const Icon(Icons.delete_rounded),
                )
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height - 420*fem,
            margin: EdgeInsets.fromLTRB(15 * fem, 0, 15 * fem, 0),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.vertical,
              itemCount: plans.length,
              itemBuilder: (context, index) => Container(
                margin: EdgeInsets.symmetric(vertical: 8 * fem),
                child: ElevatedButton(
                  onPressed: () async {
                    var newEvent = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>AddEventPage(
                        id: plans[index].id,
                        bookTitle: books[index].title,
                        bookId: plans[index].bookId,
                        time: TimeOfDay.fromDateTime(plans[index].dateTime),
                        date: plans[index].dateTime,
                        repeat: noti.RepeatType.values[plans[index].repeatType],
                      )),
                    );
                    if (newEvent != null) {
                      _updateEventList();
                    }
                  },
                  onLongPress: (){
                    _showDeletePlanDialog(index);
                  },
                  style: ElevatedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12 * fem),
                    ),
                    foregroundColor: Colors.black,
                    backgroundColor: const Color(0xffeeeeee),
                    padding: EdgeInsets.all(10 * fem),
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 16 * fem,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 200*fem,
                            child: Text(
                              'Book: ${books[index].title}',
                              style: TextStyle(
                                fontSize: 18 * fem,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 4 * fem),
                          Text('Start date: ${plans[index].dateTime.day} - ${plans[index].dateTime.month} - ${plans[index].dateTime.year}'),
                          Text(
                            'Time: ${_formatDateTime(plans[index].dateTime)}',
                          ),
                          Text('Repeat: ${noti.RepeatType.values[plans[index].repeatType].toStr()}'),

                        ],
                      ),
                      Switch(
                        value: plans[index].active,
                        onChanged: (value) async{
                          final result = await notificationBackend.activateNotification(value, plans[index].id);
                          await dbHelper.activateNotificationById(plans[index].id, value);
                          setState(() {
                            plans[index].active = value ;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: 'add schedule',
        onPressed: () async {
          var newEvent = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const
            AddEventPage(
              id: 0,
              bookTitle: null,
              bookId: null,
              time: null,
              date: null,
              repeat: null,
            )),
          );
          if (newEvent != null) {
            _updateEventList();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Do you want to delete all?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng hộp thoại
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _deleteAllEvents();
              if(mounted) {
                Navigator.of(context).pop();// Đóng hộp thoại sau khi xóa
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeletePlanDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Do you want to delete this plan?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng hộp thoại
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final result = await notificationBackend.deleteNotification(plans[index].id);
              if (result['success']) {
                await dbHelper.deleteNotificationScheduleById(plans[index].id);
                _updateEventList();
                if(mounted) {
                  Navigator.of(context).pop();
                }
              } else {
                if(mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message']))
                  );
                  Navigator.of(context).pop();
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllEvents() async {
    final result = await notificationBackend.deleteAllNotifications(provider.user!.userId);
    if(result['success']) {
      await dbHelper.deleteAllSchedules();
      _updateEventList();
    }
  }
  String _formatDateTime(DateTime dateTime) =>
      '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
}

class PaddedElevatedButton extends StatelessWidget {
  const PaddedElevatedButton({
    required this.buttonText,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
    child: ElevatedButton(
      onPressed: onPressed,
      child: Text(buttonText),
    ),
  );
}

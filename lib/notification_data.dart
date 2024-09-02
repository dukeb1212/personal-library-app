
import 'package:intl/intl.dart';

class Notification {
  final int id;
  String bookId;
  DateTime dateTime;
  int repeatType;
  bool active;

  Notification({
    required this.id,
    required this.bookId,
    required this.dateTime,
    required this.repeatType,
    required this.active
  });

  factory Notification.defaultNotification() {
    return Notification(
      id: 0,
      bookId: '',
      dateTime: DateTime.now(),
      repeatType: 0,
      active: false
    );
  }
  
  factory Notification.fromMap(Map<String, dynamic> dataMap) {
    return Notification(
      id: dataMap['id'],
      bookId: dataMap['book_id'],
      dateTime: DateTime.parse(dataMap['date_time']),
      repeatType: dataMap['repeat_type'],
      active: dataMap['active'] == 1 ? true : false
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'date_time': DateFormat().add_yMd().add_Hm().format(dateTime),
      'repeat_type': repeatType,
      'active': active ? 1 : 0
    };
  }
}

enum RepeatType {
  noRepeat,   // 0
  daily,      // 1
  weekly,     // 2
  monthly,    // 3
}

extension RepeatTypeExtension on RepeatType {
  int toInt() {
    switch (this) {
      case RepeatType.noRepeat:
        return 0;
      case RepeatType.daily:
        return 1;
      case RepeatType.weekly:
        return 2;
      case RepeatType.monthly:
        return 3;
    }
  }

  String toStr() {
    switch (this) {
      case RepeatType.noRepeat:
        return 'No Repeat';
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.weekly:
        return 'Weekly';
      case RepeatType.monthly:
        return 'Monthly';
    }
  }
}

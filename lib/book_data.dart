import 'dart:convert';
import 'dart:math';

import 'package:intl/intl.dart';

class Book {
  final String id;
  final String title;
  final String subtitle;
  final List<String> authors;
  final List<String> categories;
  final String publishedDate;
  final String description;
  final int totalPages;
  final String language;
  final Map<String, String> imageLinks;

  Book({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.authors,
    required this.categories,
    required this.publishedDate,
    required this.description,
    required this.totalPages,
    required this.language,
    required this.imageLinks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'authors': authors.join(', '),
      'categories': categories.join(', '),
      'publishedDate': publishedDate,
      'description': description,
      'totalPages': totalPages,
      'language': language,
      'imageLinks': jsonEncode(imageLinks),
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      subtitle: map['subtitle'],
      authors: List<String>.from(map['authors'] ?? []),
      categories: List<String>.from(map['categories'] ?? []),
      publishedDate: map['publishedDate'],
      description: map['description'],
      totalPages: map['totalPages'],
      language: map['language'],
      imageLinks: {
        'smallThumbnail': map['imageLinks']['smallThumbnail'].toString() ?? '',
        'thumbnail': map['imageLinks']['thumbnail'].toString() ?? '',
      },
    );
  }

  factory Book.fromGoogleBooksAPI(Map<String, dynamic> volumeInfo) {
    return Book(
      id: volumeInfo['id'],
      title: volumeInfo['title'] ?? '',
      subtitle: volumeInfo['subtitle'] ?? '',
      authors: List<String>.from(volumeInfo['authors'] ?? []),
      categories: List<String>.from(volumeInfo['categories'] ?? []),
      publishedDate: volumeInfo['publishedDate'] ?? '',
      description: volumeInfo['description'] ?? '',
      totalPages: volumeInfo['pageCount'] ?? 0,
      language: volumeInfo['language'] ?? '',
      imageLinks: {
        'smallThumbnail': volumeInfo['imageLinks']['smallThumbnail'].toString() ?? '',
        'thumbnail': volumeInfo['imageLinks']['thumbnail'].toString() ?? '',
      },
    );
  }
}

class BookState {
  final String bookId;
  final String buyDate;
  final DateTime lastReadDate;
  final int lastPageRead;
  final double percentRead;
  final double totalReadHours;
  final bool addToFavorites;
  final String lastSeenPlace;
  final int userId;
  final List<String> quotation;
  final List<String> comment;

  BookState({
    required this.bookId,
    required this.buyDate,
    required this.lastReadDate,
    required this.lastPageRead,
    required this.percentRead,
    required this.totalReadHours,
    required this.addToFavorites,
    required this.lastSeenPlace,
    required this.userId,
    required this.quotation,
    required this.comment,
  });

  factory BookState.initial() {
    return BookState(
      bookId: '0',
      buyDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      lastReadDate: DateTime.now(),
      lastPageRead: 0,
      percentRead: 0.0,
      totalReadHours: 0.0,
      addToFavorites: false,
      lastSeenPlace: '',
      userId: 0,
      quotation: [],
      comment: [],
    );
  }

  BookState update({
    String? bookId,
    String? buyDate,
    DateTime? lastReadDate,
    int? lastPageRead,
    double? percentRead,
    double? totalReadHours,
    bool? addToFavorites,
    String? lastSeenPlace,
    int? userId,
    List<String>? quotation,
    List<String>? comment,
  }) {
    return BookState(
      bookId: bookId ?? this.bookId,
      buyDate: buyDate ?? this.buyDate,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      lastPageRead: lastPageRead ?? this.lastPageRead,
      percentRead: percentRead ?? this.percentRead,
      totalReadHours: totalReadHours ?? this.totalReadHours,
      addToFavorites: addToFavorites ?? this.addToFavorites,
      lastSeenPlace: lastSeenPlace ?? this.lastSeenPlace,
      userId: userId ?? this.userId,
      quotation: quotation ?? this.quotation,
      comment: comment ?? this.comment,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'buyDate': buyDate,
      'lastReadDate': DateFormat('yyyy-MM-dd').format(lastReadDate),
      'lastPageRead': lastPageRead,
      'percentRead': percentRead,
      'totalReadHours': totalReadHours,
      'addToFavorites': addToFavorites ? 1 : 0, // Convert bool to 1 or 0
      'lastSeenPlace': lastSeenPlace,
      'userId' : userId,
      'quotation': quotation.join(', '),
      'comment': comment.join(', '),
    };
  }

  factory BookState.fromMap(Map<String, dynamic> map) {
    return BookState(
      bookId: map['bookId'],
      buyDate: map['buyDate'],
      lastReadDate: DateFormat('yyyy-MM-dd').parse(map['lastReadDate']),
      lastPageRead: map['lastPageRead'],
      percentRead: map['percentRead'],
      totalReadHours: map['totalReadHours'],
      addToFavorites: map['addToFavorites'] == 1, // Convert 1 or 0 to bool
      lastSeenPlace: map['lastSeenPlace'],
      userId: map['userId'],
      quotation: List<String>.from(map['quotation'] ?? []),
      comment: List<String>.from(map['comment'] ?? []),
    );
  }
}

Map<String, String> languageMap = {
'English': 'en',
'Spanish': 'es',
'French': 'fr',
'German': 'de',
'Chinese': 'zh',
'Japanese': 'ja',
'Korean': 'ko',
'Russian': 'ru',
'Arabic': 'ar',
'Portuguese': 'pt',
'Italian': 'it',
'Dutch': 'nl',
'Swedish': 'sv',
'Norwegian': 'no',
'Danish': 'da',
'Finnish': 'fi',
'Turkish': 'tr',
'Greek': 'el',
'Hindi': 'hi',
'Bengali': 'bn',
'Urdu': 'ur',
'Thai': 'th',
'Vietnamese': 'vi',
'Polish': 'pl',
'Czech': 'cs',
'Hungarian': 'hu',
'Romanian': 'ro',
'Hebrew': 'he',
'Slovak': 'sk',
// Add more languages as needed
};

final List<String> bookCategories = [
  "antiques & collectibles",
  "literary collections",
  "architecture",
  "literary criticism",
  "art",
  "mathematics",
  "bibles",
  "medical",
  "biography & autobiography",
  "music",
  "body, mind & spirit",
  "nature",
  "business & economics",
  "performing arts",
  "comics & graphic novels",
  "pets",
  "computers",
  "philosophy",
  "cooking",
  "photography",
  "crafts & hobbies",
  "poetry",
  "design",
  "political science",
  "drama",
  "psychology",
  "education",
  "reference",
  "family & relationships",
  "religion",
  "fiction",
  "science",
  "foreign language study",
  "self-help",
  "games & activities",
  "social science",
  "gardening",
  "sports & recreation",
  "health & fitness",
  "study aids",
  "history",
  "technology & engineering",
  "house & home",
  "transportation",
  "humor",
  "travel",
  "juvenile fiction",
  "true crime",
  "juvenile nonfiction",
  "young adult fiction",
  "language arts & disciplines",
  "young adult nonfiction",
  "law",
];

final List<String> bookCategoriesVietnamese = [
  "Cổ Điển & Sưu Tầm",
  "Văn Học",
  "Kiến Trúc",
  "Phê Bình Văn Học",
  "Nghệ Thuật",
  "Toán Học",
  "Kinh Thánh",
  "Y Khoa",
  "Tiểu Sử & Tự Truyện",
  "Âm Nhạc",
  "Tâm Hồn & Tinh Thần",
  "Thiên Nhiên",
  "Kinh Doanh & Kinh Tế",
  "Nghệ Thuật Biểu Diễn",
  "Truyện Tranh & Tiểu Thuyết Đồ Họa",
  "Thú Cưng",
  "Máy Tính",
  "Triết Học",
  "Nấu Ăn",
  "Nhiếp Ảnh",
  "Nghệ Thuật Thủ Công",
  "Thơ Ca",
  "Thiết Kế",
  "Khoa Học Chính Trị",
  "Kịch",
  "Tâm Lý Học",
  "Giáo Dục",
  "Tài Liệu Tham Khảo",
  "Gia Đình & Mối Quan Hệ",
  "Tôn Giáo",
  "Tiểu Thuyết",
  "Khoa Học",
  "Học Ngoại Ngữ",
  "Phát Triển Bản Thân",
  "Trò Chơi & Hoạt Động",
  "Khoa Học Xã Hội",
  "Làm Vườn",
  "Thể Thao & Giải Trí",
  "Sức Khỏe & Thể Công",
  "Sách Học",
  "Lịch Sử",
  "Công Nghệ & Kỹ Thuật",
  "Nhà Cửa",
  "Giao Thông Vận Tải",
  "Truyện Cười",
  "Du Lịch",
  "Truyện Thiếu Nhi",
  "Hình Sự",
  "Sách Thiếu Nhi",
  "Tiểu Thuyết Dành Cho Thanh Thiếu Niên",
  "Ngôn Ngữ Học & Khoa Học Ngôn Ngữ",
  "Sách Dành Cho Thanh Thiếu Niên",
  "Luật",
];

Map<String, String> categoryTranslation = Map.fromIterables(
  bookCategories,
  bookCategoriesVietnamese,
);

String generateUniqueId() {
  // Get current timestamp in milliseconds
  int timestamp = DateTime.now().millisecondsSinceEpoch;

  // Generate a random string of length 5
  String randomString = generateRandomString(5);

  // Combine timestamp and random string to create a unique ID
  String uniqueId = '$timestamp$randomString';

  return uniqueId;
}

String generateRandomString(int length) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();
  return String.fromCharCodes(
    List.generate(length, (index) => chars.codeUnitAt(random.nextInt(chars.length))),
  );
}
import 'dart:convert';
import 'dart:math';

import 'package:intl/intl.dart';

Map<int, String> parseAuthorNames(String authorNames) {
  Map<int, String> result = {};

  List<String> authorPairs = authorNames.split(', ');

  for (String authorPair in authorPairs) {
    List<String> parts = authorPair.split(': ');
    if (parts.length == 2) {
      int? authorId = int.tryParse(parts[0]);
      String authorName = parts[1];
      if (authorId != null) {
        result[authorId] = authorName;
      }
    }
  }

  return result;
}

class Book {
  String id;
  String title;
  String subtitle;
  List<String> authors;
  String category;
  String publishedDate;
  String description;
  int totalPages;
  String language;
  Map<String, String> imageLinks;

  Book({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.authors,
    required this.category,
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
      'category': category,
      'publishedDate': publishedDate,
      'description': description,
      'totalPages': totalPages,
      'language': language,
      'imageLinks': jsonEncode(imageLinks),
    };
  }

  factory Book.fromMap(Map<String, dynamic> bookData) {
    return Book(
      id: bookData['book_id'],
      title: bookData['title'],
      subtitle: bookData['subtitle'],
      authors: parseAuthorNames(bookData['author_names']).values.toList(),
      category: bookData['category_name'],
      publishedDate: bookData['published_date'] ?? '',
      description: bookData['description'],
      totalPages: bookData['total_pages'],
      language: bookData['language'],
      imageLinks: Map<String, String>.from(bookData['image_links'] ?? {}),
    );
  }

  factory Book.fromGoogleBooksAPI(Map<String, dynamic> volumeInfo) {
    return Book(
      id: volumeInfo['id'] ?? generateUniqueId(),
      title: volumeInfo['title'] ?? 'Unknown',
      subtitle: volumeInfo['subtitle'] ?? '',
      authors: List<String>.from(volumeInfo['authors'] ?? ['Unknown']),
      category: volumeInfo['category'] ?? 'Unknown',
      publishedDate: volumeInfo['publishedDate'] ?? '',
      description: volumeInfo['description'] ?? '',
      totalPages: volumeInfo['pageCount'] ?? 1,
      language: volumeInfo['language'] ?? 'en',
      imageLinks: {
        'smallThumbnail': volumeInfo['imageLinks']['smallThumbnail'].toString(),
        'thumbnail': volumeInfo['imageLinks']['thumbnail'].toString(),
      },
    );
  }

  factory Book.defaultBook() {
    return Book(
      id: '',
      title: '',
      subtitle: '',
      authors: [],
      category: 'Unknown',
      publishedDate: '',
      description: '',
      totalPages: 1,
      language: 'en',
      imageLinks: {'thumbnail': ''},
    );
  }
}

class BookState {
  String bookId;
  String buyDate;
  DateTime lastReadDate;
  int lastPageRead;
  double percentRead;
  double totalReadHours;
  bool addToFavorites;
  String lastSeenPlace;
  int userId;
  List<String> quotation;
  List<String> comment;

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
  "Antiques & Collectibles",
  "Literary Collections",
  "Architecture",
  "Literary Criticism",
  "Art",
  "Mathematics",
  "Bibles",
  "Medical",
  "Biography & Autobiography",
  "Music",
  "Body, Mind & Spirit",
  "Nature",
  "Business & Economics",
  "Performing Arts",
  "Comics & Graphic Novels",
  "Pets",
  "Computers",
  "Philosophy",
  "Cooking",
  "Photography",
  "Crafts & Hobbies",
  "Poetry",
  "Design",
  "Political Science",
  "Drama",
  "Psychology",
  "Education",
  "Reference",
  "Family & Relationships",
  "Religion",
  "Fiction",
  "Science",
  "Foreign Language Study",
  "Self-help",
  "Games & Activities",
  "Social Science",
  "Gardening",
  "Sports & Recreation",
  "Health & Fitness",
  "Study Aids",
  "History",
  "Technology & Engineering",
  "House & Home",
  "Transportation",
  "Humor",
  "Travel",
  "Juvenile Fiction",
  "True Crime",
  "Juvenile Nonfiction",
  "Young Adult Fiction",
  "Language Arts & Disciplines",
  "Young Adult Nonfiction",
  "Law",
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

String truncateAuthorName(String authorName) {
  const maxLength = 7;

  if (authorName.length > maxLength) {
    return '${authorName.substring(0, maxLength)}...';
  } else {
    return authorName;
  }
}

String shortenName(String fullName) {
  List<String> names = fullName.split(' ');

  if (names.length < 2) {
    // Handle cases where the full name does not have both first and last names
    return fullName;
  }

  String firstNameInitial = names[0][0].toUpperCase();
  String lastName = names.last;

  return '$firstNameInitial. $lastName';
}

List<String> getRandomValues(List<String> inputList) {
  Random random = Random();
  List<String> randomValues = [];

  // Make sure the input list has at least 3 elements
  if (inputList.length < 3) {
    throw ArgumentError("Input list must have at least 3 elements");
  }

  // Shuffle the input list to get a random order
  inputList.shuffle(random);

  // Add the first 3 elements to the result list
  for (int i = 0; i < 3; i++) {
    randomValues.add(inputList[i]);
  }

  return randomValues;
}

final List<String> sortByOptions = [
  'Latest Buy',
  'Published Date (Newest)',
  'Percent Read (highest to lowest)',
  'Percent Read (lowest to highest)',
  'Total Hours Highest',
  'Total Hours Lowest',
];

List<Book> sortByOption(List<Book> bookList, List<BookState> bookState, int index) {
  switch (index){
    case 0:
      bookState.sort((a,b) => DateTime.parse(b.buyDate).compareTo(DateTime.parse(a.buyDate)));
      bookList.sort((a,b) {
        int index1 = bookState.indexWhere((state) => state.bookId == a.id);
        int index2 = bookState.indexWhere((state) => state.bookId == b.id);
        return index1.compareTo(index2);
      });
      return bookList;
    case 1:
      bookList.sort((a,b) => parseDateString(b.publishedDate).compareTo(parseDateString(a.publishedDate)));
      return bookList;
    case 2:
      bookState.sort((a,b) => b.percentRead.compareTo(a.percentRead));
      bookList.sort((a,b) {
        int index1 = bookState.indexWhere((state) => state.bookId == a.id);
        int index2 = bookState.indexWhere((state) => state.bookId == b.id);
        return index1.compareTo(index2);
      });
      return bookList;
    case 3:
      bookState.sort((a,b) => a.percentRead.compareTo(b.percentRead));
      bookList.sort((a,b) {
        int index1 = bookState.indexWhere((state) => state.bookId == a.id);
        int index2 = bookState.indexWhere((state) => state.bookId == b.id);
        return index1.compareTo(index2);
      });
      return bookList;
    case 4:
      bookState.sort((a,b) => b.totalReadHours.compareTo(a.totalReadHours));
      bookList.sort((a,b) {
        int index1 = bookState.indexWhere((state) => state.bookId == a.id);
        int index2 = bookState.indexWhere((state) => state.bookId == b.id);
        return index1.compareTo(index2);
      });
      return bookList;
    case 5:
      bookState.sort((a,b) => a.percentRead.compareTo(b.percentRead));
      bookList.sort((a,b) {
        int index1 = bookState.indexWhere((state) => state.bookId == a.id);
        int index2 = bookState.indexWhere((state) => state.bookId == b.id);
        return index1.compareTo(index2);
      });
      return bookList;
    default:
      return bookList;
  }
}

DateTime parseDateString(String dateString) {
  List<String> dateParts = dateString.split('-');

  if (dateParts.length == 1) {
    // If there is only one part, it's a year
    return DateTime(int.parse(dateParts[0]));
  } else if (dateParts.length == 3) {
    // If there are three parts, it's in the format year-month-day
    return DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
    );
  } else if (dateParts.length == 2) {
    return DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
    );
  } else {
    throw const FormatException("Invalid date format");
  }
}
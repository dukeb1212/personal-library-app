import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import '../backend/google_books_api.dart';
import '../book_data.dart';

class DatabaseHelper {
  final String _baseUrl = dotenv.env['NODE_JS_SERVER_URL'] ?? '';
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  late Database _db;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<void> initializeDatabase(String username) async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, '$username.db');

    _db = await openDatabase(
      path,
      version: 1,
      readOnly: false,
      onCreate: (db, version) async {
        // Create tables if needed
        await db.execute('''
          CREATE TABLE books (
            book_id TEXT PRIMARY KEY,
            title TEXT,
            subtitle TEXT,
            author TEXT,
            category TEXT,
            published_date TEXT,
            description TEXT,
            total_pages INTEGER,
            language TEXT,
            image_links TEXT,
            buy_date TEXT,
            last_read_date TEXT,
            last_page_read INTEGER,
            percent_read REAL,
            total_read_hour REAL,
            favorite INTEGER,
            last_seen_place TEXT,
            quotation TEXT,
            comment TEXT
          )
        ''');
      },
    );
  }

  Future<void> syncBooks(List<Map<String, dynamic>> books, int userId) async {
    List<String> existingBookIds = await _db.query(
      'books',
      columns: ['book_id'],
    ).then((List<Map<String, dynamic>> results) {
      return results.map<String>((row) => row['book_id'].toString()).toList();
    });

    for (var bookData in books) {
      String bookId = bookData['book_id'];
      BookState bookState = BookState(
          bookId: bookData['book_id'],
          buyDate: bookData['buy_date'],
          lastReadDate: DateTime.tryParse(bookData['last_read_date']) ?? DateTime.now(),
          lastPageRead: bookData['last_page_read'],
          percentRead: bookData['percent_read'].toDouble(),
          totalReadHours: bookData['total_read_hours'].toDouble(),
          addToFavorites: bookData['favorite'],
          lastSeenPlace: bookData['last_seen_place'],
          userId: userId,
          quotation: List<String>.from(bookData['quotation'] ?? []),
          comment: List<String>.from(bookData['comment'] ?? [])
      );

      Map<String, dynamic> bookMap = {};

        Book book = Book(
          id: bookData['book_id'],
          title: bookData['title'],
          subtitle: bookData['subtitle'],
          author: bookData ['author_name'],
          category: bookData['category_name'],
          publishedDate: bookData['published_date'] ?? '',
          description: bookData['description'],
          totalPages: bookData['total_pages'],
          language: bookData['language'],
          imageLinks: Map<String, String>.from(bookData['image_links'] ?? {}),
          // Assign other properties...
        );

        bookMap = {
          'book_id': book.id,
          'title': book.title,
          'subtitle': book.subtitle,
          'author': book.author,
          'category': book.category,
          'published_date': book.publishedDate,
          'description': book.description,
          'total_pages': book.totalPages,
          'language': book.language,
          'image_links': jsonEncode(book.imageLinks),
          'buy_date': bookState.buyDate,
          'last_read_date': bookData['last_read_date'],
          'last_page_read': bookState.lastPageRead,
          'percent_read': bookState.percentRead,
          'total_read_hour': bookState.totalReadHours,
          'favorite': bookState.addToFavorites ? 1 : 0,
          'last_seen_place': bookData['last_seen_place'],
          'quotation': bookState.quotation.join(', '),
          'comment': bookState.comment.join(', ')
        };

      if (existingBookIds.contains(bookId)) {
        // Book exists, perform an update
        await _db.update(
          'books',
          bookMap,
          where: 'book_id = ?',
          whereArgs: [bookState.bookId],
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        await _db.insert('books', bookMap, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }

    List<String> booksToDelete = existingBookIds.where((id) => !books.any((book) => book['book_id'] == id)).toList();
    for (String bookIdToDelete in booksToDelete) {
      // Delete the book from SQLite
      await _db.delete('books', where: 'book_id = ?', whereArgs: [bookIdToDelete]);
    }
  }
// Add more methods for CRUD operations as needed
  Future<void> syncBooksFromServer(int userId, String username) async {
    final response = await http.get(Uri.parse('$_baseUrl/books?userId=$userId'));


    if (response.statusCode == 200) {

      final List<dynamic> booksData = jsonDecode(response.body);
      final List<Map<String, dynamic>> books = booksData.map((book) => book as Map<String, dynamic>).toList();

      final databaseHelper = DatabaseHelper();
      await databaseHelper.initializeDatabase(username);
      await databaseHelper.syncBooks(books, userId);
    } else {
      // Handle error
      print('Failed to fetch books from the server');
    }
  }

  Future<List<BookState>> getAllBookStates(int userId) async {
    final List<Map<String, dynamic>> bookStatesData = await _db.query('books');
    return bookStatesData.map((data) => _mapToBookState(data, userId)).toList();
  }

  Future<List<Book>> getAllBooks() async {
    final List<Map<String, dynamic>> booksData = await _db.query('books');
    return booksData.map((data) => _mapToBook(data)).toList();
  }

  BookState _mapToBookState(Map<String, dynamic> data, int userId) {
    return BookState(
      bookId: data['book_id'],
      buyDate: data['buy_date'],
      lastReadDate: DateTime.tryParse(data['last_read_date']) ?? DateTime.now(),
      lastPageRead: data['last_page_read'],
      percentRead: data['percent_read'].toDouble(),
      totalReadHours: data['total_read_hour'].toDouble(),
      addToFavorites: data['favorite'] == 1,
      lastSeenPlace: data['last_seen_place'],
      quotation: List<String>.from(data['quotation']?.split(', ') ?? []),
      comment: List<String>.from(data['comment']?.split(', ') ?? []),
      userId: userId,
    );
  }

  Book _mapToBook(Map<String, dynamic> data) {
    return Book(
      id: data['book_id'],
      title: data['title'],
      subtitle: data['subtitle'],
      author: data['author'],
      category: data['category'],
      publishedDate: data['published_date'] ?? '',
      description: data['description'],
      totalPages: data['total_pages'],
      language: data['language'],
      imageLinks: Map<String, String>.from(jsonDecode(data['image_links'] ?? '{}')),
    );
  }
}



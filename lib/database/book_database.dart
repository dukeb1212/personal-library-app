import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
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

    const String booksTable = '''
    CREATE TABLE books (
        book_id TEXT PRIMARY KEY,
        title TEXT,
        subtitle TEXT,
        authors TEXT,
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
    );''';

    const String authorsTable = '''
        CREATE TABLE authors (
          author_id INTEGER PRIMARY KEY,
          author_name TEXT
        );
      ''';

    const String writeBookTable = '''
        CREATE TABLE write_book (
          author_id INTEGER,
          book_id TEXT
        );
      ''';

    _db = await openDatabase(
      path,
      version: 1,
      readOnly: false,
      onCreate: (db, version) async {
        // Create tables if needed
        // Create books table
        await db.execute(booksTable);

        // Create authors table
        await db.execute(authorsTable);

        // Create write_book table
        await db.execute(writeBookTable);
      },
    );
  }

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

  Future<void> syncBooks(List<Map<String, dynamic>> books, int userId) async {
    List<String> existingBookIds = await _db.query(
      'books',
      columns: ['book_id'],
    ).then((List<Map<String, dynamic>> results) {
      return results.map<String>((row) => row['book_id'].toString()).toList();
    });

    for (var bookData in books) {
      Map<int, String> authors = parseAuthorNames(bookData['author_names']);

      String bookId = bookData['book_id'];
      BookState bookState = BookState(
          bookId: bookData['book_id'],
          buyDate: bookData['buy_date'].toString().substring(0, 10),
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
        authors: authors.values.toList(),
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
          'authors': book.authors.join(', '),
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
      for (var entry in authors.entries) {
        await _db.insert(
          'authors',
          {
            'author_id': entry.key,
            'author_name': entry.value,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await _db.insert(
          'write_book',
          {
            'author_id': entry.key,
            'book_id': bookId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
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
      if (kDebugMode) {
        print('Failed to fetch books from the server');
      }
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
      authors: (data['authors'] as String?)?.split(', ') ?? ['Unknown'],
      category: data['category'],
      publishedDate: data['published_date'] ?? '',
      description: data['description'],
      totalPages: data['total_pages'],
      language: data['language'],
      imageLinks: Map<String, String>.from(jsonDecode(data['image_links'] ?? '{}')),
    );
  }

  Future<List<String>> getTopCategories(int numberOfCategories) async {
    final databaseHelper = DatabaseHelper();
    final List<Book> allBooks = await databaseHelper.getAllBooks();

    // Count occurrences of each category
    final Map<String, int> categoryCount = HashMap();

    for (final book in allBooks) {
      if (book.category != 'Unknown') {
        categoryCount[book.category] = (categoryCount[book.category] ?? 0) + 1;
      }
    }

    // Sort categories based on count in descending order
    final sortedCategories = categoryCount.keys.toList()
      ..sort((a, b) => categoryCount[b]!.compareTo(categoryCount[a]!));

    // Take the top 10 categories
    List<String> categories = sortedCategories.take(numberOfCategories).toList();
    return categories;
  }

  Future<List<String>> getAllAuthors() async {
    final List<Map<String, dynamic>> authorsData = await _db.query('authors');
    return authorsData.map((map) => map['author_name'].toString()).toList();
  }

  Future<List<String>> getAllCategories() async {
    final List<Map<String, dynamic>> result = await _db.rawQuery('SELECT DISTINCT category FROM books');
    return result.map((map) => map['category'] as String).toList();
  }

  Future<List<String>> getAllLanguages() async {
    final List<Map<String, dynamic>> result = await _db.rawQuery('SELECT DISTINCT language FROM books');
    return result.map((map) => map['language'] as String).toList();
  }

  Future<List<String>> getAuthorsByCategoryFromDatabase(String category) async {
    final List<Map<String, dynamic>> authorsData = await _db.rawQuery('''
      SELECT DISTINCT authors.author_name
      FROM authors
      INNER JOIN write_book ON authors.author_id = write_book.author_id
      INNER JOIN books ON write_book.book_id = books.book_id
      WHERE books.category = ?
    ''', [category]);

    return authorsData.map((map) => map['author_name'].toString()).toList();
  }

  Future<List<String>> getCategoriesByAuthorFromDatabase(String author) async {
    final List<Map<String, dynamic>> categoriesData = await _db.rawQuery('''
      SELECT DISTINCT books.category
      FROM books
      INNER JOIN write_book ON books.book_id = write_book.book_id
      INNER JOIN authors ON write_book.author_id = authors.author_id
      WHERE authors.author_name = ?
    ''', [author]);

    return categoriesData.map((map) => map['category'].toString()).toList();
  }

  Future<List<String>> getTopAuthors(int numberOfAuthors) async {
    final List<Map<String, dynamic>> result = await _db.rawQuery('''
    SELECT authors.author_name, COUNT(write_book.book_id) as book_count
    FROM authors
    INNER JOIN write_book ON authors.author_id = write_book.author_id
    GROUP BY authors.author_name
    ORDER BY book_count DESC
    LIMIT ?
  ''', [numberOfAuthors]);

    final List<String> authorNames = result.map((author) => author['author_name'].toString()).toList();

    return authorNames;
  }

  Future<void> deleteBookAndAuthor(String bookId) async {
    await _db.transaction((txn) async {
      // Get the author IDs associated with the book
      List<int> authorIds = await txn.query(
        'write_book',
        columns: ['author_id'],
        where: 'book_id = ?',
        whereArgs: [bookId],
      ).then((List<Map<String, dynamic>> results) {
        return results.map<int>((row) => row['author_id'] as int).toList();
      });

      // Delete book from the 'books' table
      await txn.delete('books', where: 'book_id = ?', whereArgs: [bookId]);

      // Delete associated author entries from 'write_book' table
      await txn.delete('write_book', where: 'book_id = ?', whereArgs: [bookId]);

      // Delete authors if no more books associated with them
      for (int authorId in authorIds) {
        int bookCount = Sqflite.firstIntValue(await txn.rawQuery(
          'SELECT COUNT(*) FROM write_book WHERE author_id = ?',
          [authorId],
        )) ?? 0;

        if (bookCount == 0) {
          // No more books associated with this author, delete from 'authors' table
          await txn.delete('authors', where: 'author_id = ?', whereArgs: [authorId]);
        }
      }
    });
  }

  Future<void> updatePercentReadForAllBooks() async {
    final List<Map<String, dynamic>> booksData = await _db.query('books');

    for (var bookData in booksData) {
      int lastPageRead = bookData['last_page_read'];
      int totalPages = bookData['total_pages'];

      if (totalPages > 0) {
        double percentRead = (lastPageRead / totalPages) * 100.0;

        // Update the 'percent_read' in the 'books' table
        await _db.update(
          'books',
          {'percent_read': percentRead},
          where: 'book_id = ?',
          whereArgs: [bookData['book_id']],
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }
}



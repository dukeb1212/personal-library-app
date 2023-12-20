import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:login_test/book_data.dart';
import '../user_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UpdateBookBackend {
  final String _baseUrl = dotenv.env['NODE_JS_SERVER_URL'] ?? ''; // Adjust this to your server's address

  // Function to handle user login
  Future<Map<String, dynamic>> addOrUpdateBook(Book? book) async {
    if (book == null) {
      return {
        'success': false,
        'message': 'Book parameter is null',
      };
    }
    final Map<String, dynamic> requestBody = {
      'book_id': book.id,
      'title': book.title,
      'subtitle': book.subtitle,
      'author': book.author,
      'category': book.category,
      'publishedDate': book.publishedDate,
      'description': book.description,
      'totalPages': book.totalPages,
      'language': book.language,
      'imageLinks': jsonEncode(book.imageLinks),
    };

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/addOrUpdateBook"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Book added/updated successfully',
        };
      } else {
        print('Response body on error: ${response.body}');
        return {
          'success': false,
          'message': 'Failed to add/update book. Status code: ${response.statusCode}',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Error during HTTP request: $error',
      };
    }
  }

  Future<Map<String, dynamic>> addBookToLibrary(BookState? bookState) async {
    if (bookState == null) {
      return {
        'success': false,
        'message': 'Book parameter is null',
      };
    }
    final Map<String, dynamic> requestBody = {
      'book_id': bookState.bookId,
      'buy_date': bookState.buyDate,
      'last_read_date': bookState.lastReadDate.toIso8601String(),
      'last_page_read': bookState.lastPageRead,
      'percent_read': bookState.percentRead,
      'total_read_hours': bookState.totalReadHours,
      'favorite': bookState.addToFavorites,
      'last_seen_place': bookState.lastSeenPlace,
      'user_id': bookState.userId,
      'quotation': bookState.quotation,
      'comment': bookState.comment,
    };

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/addBookToLibrary"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Book added/updated successfully',
        };
      } else {
        print('Response body on error: ${response.body}');
        return {
          'success': false,
          'message': 'Failed to add/update book. Status code: ${response.statusCode}',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Error during HTTP request: $error',
      };
    }
  }


}

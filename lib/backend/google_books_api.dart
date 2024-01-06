import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:login_test/book_data.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String apiKey = dotenv.env['GOOGLE_BOOKS_API_KEY'] ?? '';

Future<Map<String, dynamic>> getBookSuggestions(List<String> selectedCategories) async {
  final Map<String, dynamic> bookSuggestions = {};

  for (final category in selectedCategories) {
    final encodedCategory = Uri.encodeComponent(category);
    final response = await http.get(
      Uri.parse(
        'https://www.googleapis.com/books/v1/volumes?q=subject:$encodedCategory&maxResults=10&langRestrict=en+vn+fr&orderBy=newest&key=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse.containsKey('items')) {
        final List<String> bookNames = [];
        for (final item in jsonResponse['items']) {
          if (item.containsKey('volumeInfo') && item['volumeInfo'].containsKey('title')) {
            final title = item['volumeInfo']['title'];
            bookNames.add(title);
          }
        }
        bookSuggestions[category] = bookNames;
      } else {
        bookSuggestions[category] = [];
      }
    } else {
      return {
        'success': false,
        'message': 'Failed to retrieve book suggestions for category: $category',
      };
    }
  }

  return {
    'success': true,
    'bookSuggestions': bookSuggestions,
  };
}

Future<Map<String, dynamic>> getBookByISBN(String isbn) async {
  final Map<String, dynamic> bookInfo = {};

  final encodedISBN = Uri.encodeComponent(isbn);
  final response = await http.get(
    Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=isbn:$encodedISBN&key=$apiKey',
    ),
  );
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);

    if (jsonResponse.containsKey('items') && jsonResponse['items'].isNotEmpty) {
      final item = jsonResponse['items'][0];
      if (item.containsKey('volumeInfo')) {
        final volumeInfo = item['volumeInfo'];
        if (volumeInfo.containsKey('title')) {
          bookInfo['title'] = volumeInfo['title'];
        }
        if (volumeInfo.containsKey('subtitle')) {
          bookInfo['subtitle'] = volumeInfo['subtitle'];
        }
        if (volumeInfo.containsKey('authors')) {
          bookInfo['authors'] = volumeInfo['authors'];
        }
        if (volumeInfo.containsKey('categories')) {
          bookInfo['category'] = volumeInfo['categories'][0];
        }
        if (volumeInfo.containsKey('publishedDate')) {
          bookInfo['publishedDate'] = volumeInfo['publishedDate'];
        }
        if (volumeInfo.containsKey('description')) {
          bookInfo['description'] = volumeInfo['description'];
        }
        if (volumeInfo.containsKey('pageCount')) {
          bookInfo['pageCount'] = volumeInfo['pageCount'];
        }
        if (volumeInfo.containsKey('language')) {
          bookInfo['language'] = volumeInfo['language'];
        }
        if (volumeInfo.containsKey('imageLinks')) {
          bookInfo['imageLinks'] = volumeInfo['imageLinks'];
        } else { bookInfo['imageLinks'] = {'smallThumbnail': '', 'thumbnail': ''}; }
        // Add more fields as needed
        bookInfo['id'] = isbn;
      }
    } else {
      return {
        'success': false,
        'message': 'No book found for ISBN: $isbn',
      };
    }
  } else {
    return {
      'success': false,
      'message': 'Failed to retrieve book information for ISBN: $isbn',
    };
  }

  return {
    'success': true,
    'bookInfo': bookInfo,
  };
}

Future<Book?> getBookByBarcode() async {
  String scannedBarcode = '';
  try {
    ScanResult barcode = await BarcodeScanner.scan();
    scannedBarcode = barcode.rawContent;
  } catch (e) {
    if (kDebugMode) {
      print('Error: $e');
    }
    return null; // or handle the error appropriately
  }
  if (scannedBarcode.isNotEmpty) {
    final result = await getBookByISBN(scannedBarcode);

    if (result['success']) {
      final bookInfo = result['bookInfo'];
      Book retrievedBook = Book.fromGoogleBooksAPI(bookInfo);
      return retrievedBook;
    } else {
      if (kDebugMode) {
        print('Error: ${result['message']}');
      }
      return null; // or handle the error appropriately
    }
  }
  return null;
}

Future<Map<String, dynamic>> getBookByCategory(String category) async {
  final List<Map<String,dynamic>> books = [];
  late http.Response response;
  String encodedCategory = category.replaceAll(' ', '').toLowerCase();

  response = await http.get(
    Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=subject:$encodedCategory&orderBy=newest&langRestrict=en&filter=full&maxResults=20&key=$apiKey',
    ),
  );
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);

    if (jsonResponse.containsKey('items') && jsonResponse['items'].isNotEmpty) {
      for (final item in jsonResponse['items']) {
        Map<String, dynamic> book = {};
        if (item.containsKey('volumeInfo')) {
          final volumeInfo = item['volumeInfo'];
          if (volumeInfo.containsKey('title')) {
            book['title'] = volumeInfo['title'];
          }
          if (volumeInfo.containsKey('subtitle')) {
            book['subtitle'] = volumeInfo['subtitle'];
          }
          if (volumeInfo.containsKey('authors')) {
            book['authors'] = volumeInfo['authors'];
          }
          if (volumeInfo.containsKey('categories')) {
            book['category'] = volumeInfo['categories'][0];
          }
          if (volumeInfo.containsKey('publishedDate')) {
            book['publishedDate'] = volumeInfo['publishedDate'];
          }
          if (volumeInfo.containsKey('description')) {
            book['description'] = volumeInfo['description'];
          }
          if (volumeInfo.containsKey('pageCount')) {
            book['pageCount'] = volumeInfo['pageCount'];
          }
          if (volumeInfo.containsKey('language')) {
            book['language'] = volumeInfo['language'];
          }
          if (volumeInfo.containsKey('imageLinks')) {
            book['imageLinks'] = volumeInfo['imageLinks'];
          } else { book['imageLinks'] = {'smallThumbnail': '', 'thumbnail': ''}; }
          // Add more fields as needed
          if (volumeInfo.containsKey('industryIdentifiers')) {
            List<dynamic> industryIdentifiers = volumeInfo['industryIdentifiers'];

            String isbn13 = '';

            for (var identifier in industryIdentifiers) {
              if (identifier is Map<String, dynamic> && identifier.containsKey('type') && identifier.containsKey('identifier')) {
                String type = identifier['type'];
                String identifierCode = identifier['identifier'];

                // Check for ISBN-13 and store it
                if (type == 'ISBN_13') {
                  isbn13 = identifierCode;
                  break;  // Stop the loop if ISBN-13 is found
                }
              }
            }

            // If ISBN-13 is available, use it; otherwise, use the first identifier found
            book['id'] = isbn13.isEmpty ? (industryIdentifiers.isNotEmpty ? industryIdentifiers[0]['identifier'] : '') : isbn13;
          }
          books.add(book);
        }
      }
    } else {
      return {
        'success': false,
        'message': 'No book found for category: $category',
      };
    }
  } else {
    return {
      'success': false,
      'message': 'Failed to retrieve book information for category: $category',
    };
  }

  return {
    'success': true,
    'books': books,
  };
}

Future<List<Book>> getSuggestBook(String category) async {
  List<Book> newBooks = [];
  final result = await getBookByCategory(category);
  if (result['success']) {
    final booksInfo = result['books'];
    for (final bookInfo in booksInfo) {
      Book retrievedBook = Book.fromGoogleBooksAPI(bookInfo);
      newBooks.add(retrievedBook);
    }
  } else {
    if (kDebugMode) {
      print('failed');
    }
  }
  return newBooks;
}


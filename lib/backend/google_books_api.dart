import 'dart:convert';
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
  final bookId = isbn;

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
    print('Error: $e');
    return null; // or handle the error appropriately
  }
  if (scannedBarcode.isNotEmpty) {
    final result = await getBookByISBN(scannedBarcode);

    if (result['success']) {
      final bookInfo = result['bookInfo'];
      Book retrievedBook = Book.fromGoogleBooksAPI(bookInfo);
      return retrievedBook;
    } else {
      print('Error: ${result['message']}');
      return null; // or handle the error appropriately
    }
  }
}


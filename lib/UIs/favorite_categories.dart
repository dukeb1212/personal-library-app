import 'package:flutter/material.dart';
import 'package:login_test/backend/google_books_api.dart';

import '../book_data.dart';

class CategorySelectionPage extends StatefulWidget {
  const CategorySelectionPage({super.key});

  @override
  CategorySelectionPageState createState() => CategorySelectionPageState();
}

class CategorySelectionPageState extends State<CategorySelectionPage> {
  List<String> selectedCategories = [];
  int minSelectedCategories = 3;

  void toggleGenre(String category, bool? value) {
    if (value != null) {
      if (value) {
        setState(() {
          selectedCategories.add(category);
        });
      } else {
        setState(() {
          selectedCategories.remove(category);
        });
      }
    }
  }

  bool canProceed() {
    return selectedCategories.length >= minSelectedCategories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Selection'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'What are your favorites?',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Select at least $minSelectedCategories categories:',
                  style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.cyan),
                ),
                const Divider(),
                for (String category in bookCategories)
                  CheckboxListTile(
                    title: Text(categoryTranslation[category] ?? category), // Display the Vietnamese name
                    value: selectedCategories.contains(category),
                    onChanged: (bool? value) {
                      toggleGenre(category, value);
                    },
                  ),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
          // Position the "Next" button in the bottom right corner
          Align(
            alignment: Alignment.bottomLeft,
            child: GestureDetector(
              onTap: canProceed()
                  ? () async {
                await getBookSuggestions(selectedCategories);
              }
                  : null,
              child: Container(
                margin: const EdgeInsets.all(16.0),
                width: 60, // Adjust the width and height to make it circular
                height: 60,
                decoration: BoxDecoration(
                  color: canProceed() ? Colors.blue : Colors.transparent, // Background color
                  shape: BoxShape.circle, // Circular shape
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white, // Icon color
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}


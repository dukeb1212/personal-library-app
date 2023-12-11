import 'package:flutter/material.dart';
import '../user_data.dart';

class HomePage extends StatelessWidget {
  int selectedTabIndex = 0;
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = container.read(userProvider);
    final String? nameOfUser = provider.user?.name;
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Hello $nameOfUser\nWhat do you want to read today?',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: const Text(
              'Recently',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 200, // Adjust the height as needed
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildRecentlyReadBook("Book 1", "3 days ago"),
                _buildRecentlyReadBook("Book 2", "5 days ago"),
                _buildRecentlyReadBook("Book 3", "1 week ago"),
                // Add more recently read books as needed
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyReadBook(String bookName, String lastRead) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      width: 140, // Adjust the width as needed
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {

            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // Set the button background color to white
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Add border radius
              ),
            ),
            child: Container(
              height: 100, // Adjust the height as needed
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white, // Background color for book poster
              ),
              child: const Center(
                child: Text("Poster\nImage", textAlign: TextAlign.center),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bookName,
            style: const TextStyle(fontSize: 16),
            maxLines: 1, // Ensure text does not overflow
            overflow: TextOverflow.ellipsis, // Ensure text does not overflow
          ),
          Text(
            lastRead,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            maxLines: 1, // Ensure text does not overflow
            overflow: TextOverflow.ellipsis, // Ensure text does not overflow
          ),
        ],
      ),
    );
  }
}

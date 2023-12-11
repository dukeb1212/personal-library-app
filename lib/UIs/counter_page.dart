import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _counter = 0;

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    Navigator.pushReplacementNamed(context, '/login'); // This will navigate back to the previous screen, which is the login page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Page'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text('$_counter', style: Theme.of(context).textTheme.headline4),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _counter++;
                });
              },
              child: const Text('Increment Counter'),
            ),
          ],
        ),
      ),
    );
  }
}

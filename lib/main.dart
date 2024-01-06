import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'UIs/login_page.dart';
import 'UIs/automatic_login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAppCheck.instance.activate();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentication App',
      theme: ThemeData(
          primarySwatch: getMaterialColor(const Color(0xff404040)),
          // colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff404040)),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          focusColor: Colors.grey,
          splashColor: const Color(0xff505050)
      ),
      home: const AutomaticLogin(),
      initialRoute: '/',
      routes: {
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

MaterialColor getMaterialColor(Color color) {
  final int red = color.red;
  final int green = color.green;
  final int blue = color.blue;
  final int alpha = color.alpha;

  final Map<int, Color> shades = {
    50: Color.fromARGB(alpha, red, green, blue),
    100: Color.fromARGB(alpha, red, green, blue),
    200: Color.fromARGB(alpha, red, green, blue),
    300: Color.fromARGB(alpha, red, green, blue),
    400: Color.fromARGB(alpha, red, green, blue),
    500: Color.fromARGB(alpha, red, green, blue),
    600: Color.fromARGB(alpha, red, green, blue),
    700: Color.fromARGB(alpha, red, green, blue),
    800: Color.fromARGB(alpha, red, green, blue),
    900: Color.fromARGB(alpha, red, green, blue),
  };

  return MaterialColor(color.value, shades);
}




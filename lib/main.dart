import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:login_test/UIs/add_book_page_final.dart';
import 'package:login_test/UIs/book.dart';
import 'package:login_test/UIs/main_page.dart';
import 'package:login_test/book_data.dart';
import 'package:login_test/database/book_database.dart';
import 'UIs/login_page.dart';
import 'UIs/automatic_login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'backend/local_notification.dart';
import 'backend/navigator.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String payload = '';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAppCheck.instance.activate();

  final firebaseMessaging = FirebaseMessaging.instance;

  await LocalNotification().initializeLocalNotifications();

  await firebaseMessaging.requestPermission();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Display a notification
    LocalNotification().displayNotification(message.notification?.title ?? 'Notification', message.notification?.body ?? '', message.notification?.body ?? '');
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.notification?.title == "It's reading time!") {
      final String? id = message.notification?.body;
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => AutomaticLogin(payload: id!),
      ));
    }
  }

  @override
  void initState(){
    listenNotification();
    super.initState();
    initializeDateFormatting();
    setupInteractedMessage();
  }

  listenNotification() {
    LocalNotification.onClickNotification.stream.listen((event) async {
      String a = event.replaceAll('"', '');
      print(a);
      final databaseHelper = DatabaseHelper();
      final result = await databaseHelper.doesBookExist(a);
      if(result['existed']) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => BookScreen(book: result['book'], bookState: result['bookState'],),
          ),
        );
      } else {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => const MyMainPage(initialTabIndex: 0,),
        ),
        );
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Authentication App',
      theme: ThemeData(
          primarySwatch: getMaterialColor(const Color(0xff404040)),
          // colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff404040)),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          focusColor: Colors.grey,
          splashColor: const Color(0xff505050)
      ),
      home: AutomaticLogin(payload: payload,),
      initialRoute: '/',
      routes: {
        '/login': (context) => LoginPage(payload: payload,),
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




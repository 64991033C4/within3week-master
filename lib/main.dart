import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'intro_page.dart'; // Import the IntroPage class
import 'login_page.dart';
import 'register_page.dart';
import 'screen/journey.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Within3week',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/intro', // Set initial route
      routes: {
        '/intro': (context) => IntroPage(), // Add route for IntroPage
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/journey': (context) => Journey(),
      },
    );
  }
}

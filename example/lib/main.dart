import 'package:flutter/material.dart';

import 'home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primaryColor: const Color(0xFF00BAFF),
          primaryColorDark: const Color(0xFF0592D7),
          // accentColor: const Color(0xFF58585A),
          cardColor: const Color(0xFF888888)),
      home: const HomePage(),
    );
  }
}

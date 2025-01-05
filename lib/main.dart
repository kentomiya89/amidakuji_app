import 'package:amidakuji_app/page/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AmidaApp());
}

class AmidaApp extends StatelessWidget {
  const AmidaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

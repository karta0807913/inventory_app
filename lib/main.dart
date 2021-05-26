import 'package:inventory_app/LoadingPage.dart';
import 'package:flutter/material.dart';

void main() => runApp(MainPage());

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "inventory_app",
      home: LoadingPage(),
    );
  }
}

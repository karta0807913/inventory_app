import 'package:flutter/material.dart';
import 'package:inventory_app/LoginPage.dart';
import 'package:inventory_app/global.dart';
import 'package:inventory_app/pages/HomePage.dart';

class LoadingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoadingPageState();
}

class LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    ServerAdapter.loadCookie().then(
      (value) async {
        // if loading cookie success and get userInfo
        if (value) {
          try {
            final userInfo = await ServerAdapter.me();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return HomePage(userInfo);
                },
              ),
            );
            return;
          } catch (error) {
            debugPrint(error.toString());
          }
        }
        // if load cookie or check session not valid.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return LoginPage();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

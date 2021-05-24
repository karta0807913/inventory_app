import 'package:inventory_app/global.dart';
import 'package:flutter/material.dart';
import 'package:inventory_app/pages/HomePage.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "My App",
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: SubmitForm(),
        ),
      ),
    );
  }
}

class SubmitForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SubmitFormState();
}

class _SubmitFormState extends State<SubmitForm> {
  final account = TextEditingController();
  final password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    ServerAdapter.loadCookie().then((value) async {
      if (value) {
        try {
          final userInfo = await ServerAdapter.me();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) {
              return HomePage(userInfo);
            }),
            (route) => false,
          );
        } catch (error) {
          debugPrint(error.toString());
        }
      }
    });
  }

  String? _noneEmptyCheck(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "登入頁面",
              style: TextStyle(fontSize: 24),
            ),
          ),
          Card(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Icon(
                          Icons.account_box,
                        ),
                      ),
                      Expanded(
                        flex: 8,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Text("帳號"),
                            ),
                            TextFormField(
                              controller: account,
                              validator: this._noneEmptyCheck,
                              decoration: InputDecoration(
                                isCollapsed: true,
                                contentPadding:
                                    EdgeInsets.only(top: 10, bottom: 10),
                                border: UnderlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Icon(
                          Icons.keyboard,
                        ),
                      ),
                      Expanded(
                        flex: 8,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Text("密碼"),
                            ),
                            TextFormField(
                              obscureText: true,
                              controller: password,
                              validator: this._noneEmptyCheck,
                              decoration: InputDecoration(
                                isCollapsed: true,
                                contentPadding:
                                    EdgeInsets.only(top: 10, bottom: 10),
                                border: UnderlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      try {
                        final userInfo = await ServerAdapter.login(
                            account.text, password.text);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(userInfo),
                          ),
                          (route) => false,
                        );
                      } on String catch (reason) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("login failed"),
                              content: Text(reason),
                            );
                          },
                        );
                      } catch (error, s) {
                        debugPrint(s.toString());
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("login failed"),
                              content: Text(error.toString()),
                            );
                          },
                        );
                      }
                    },
                    child: Text("Login"),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:inventory_app/http_client/responses.dart';
import 'package:inventory_app/pages/BorrowItem/BorrowList.dart';
import 'package:inventory_app/pages/ItemList.dart';

class HomePage extends StatefulWidget {
  final UserInfo _userInfo;
  HomePage(UserInfo userInfo) : _userInfo = userInfo;

  @override
  State<StatefulWidget> createState() => _HomePageState(_userInfo);
}

class _HomePageState extends State<HomePage> {
  Widget _body = ItemList();
  String _title = "物品列表";
  UserInfo _userInfo;

  _HomePageState(UserInfo userInfo) : _userInfo = userInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      drawer: FractionallySizedBox(
        widthFactor: .7,
        child: Drawer(
          child: ListView(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.2,
                child: DrawerHeader(
                  child: UserInfoWidget(_userInfo.nickname),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(12, 12, 21, 12),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.apps),
                title: Text("物品列表"),
                onTap: () {
                  _title = "物品列表";
                  setState(() {
                    _body = ItemList();
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.view_list_rounded),
                title: Text("借出紀錄"),
                onTap: () {
                  setState(() {
                    _title = "借出紀錄";
                    _body = BorrowListPage();
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: _body,
    );
  }
}

class UserInfoWidget extends StatelessWidget {
  final _username;
  UserInfoWidget(String username) : _username = username;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipOval(
              child: Material(
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(Icons.house),
                ),
              ),
            ),
            Center(
              child: Text(_username),
            )
          ],
        )
      ],
    );
  }
}

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Text("A"),
    );
  }
}

class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Text("B"),
    );
  }
}

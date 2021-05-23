import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory_app/global.dart';
import 'package:inventory_app/http_client/responses.dart';
import 'package:inventory_app/pages/Borrower/SearchBorrowerDialog.dart';
import 'package:inventory_app/utils.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class NewBorrowRecord extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NewBorrowReardState();
}

class NewBorrowReardState extends State<NewBorrowRecord> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _borrowerController = TextEditingController();
  final TextEditingController _borrowDateController =
      TextEditingController(text: DateTime.now().toLocal().toString());
  final TextEditingController _itemController = TextEditingController();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  Borrower? borrower;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("新增借出紀錄"),
      ),
      body: Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.only(
                top: 0,
                left: 10,
                right: 10,
                bottom: 20,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextTileEdit(
                      controller: _borrowerController,
                      icon: Icon(Icons.account_box),
                      title: "借出人",
                      textOnTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return SearchBorrowerDialog(
                                onSelect: (Borrower borrower) {
                              this.borrower = borrower;
                              _borrowerController.text =
                                  borrower.name + "-" + borrower.phone;
                            });
                          },
                        );
                      },
                    ),
                    TextTileEdit(
                      controller: _itemController,
                      icon: Icon(Icons.account_box),
                      title: "借出物品",
                      textOnTap: () {},
                    ),
                    TextTileEdit(
                      controller: _borrowDateController,
                      icon: Icon(Icons.account_box),
                      title: "借出時間",
                      textOnTap: () async {
                        DateTime pickedDate =
                            await showModalBottomSheet<DateTime>(
                                builder: dateTimePickerBuilder,
                                context: context) as DateTime;
                        _borrowDateController.text =
                            pickedDate.toLocal().toString();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: RoundedLoadingButton(
              controller: _btnController,
              child: Text("送出"),
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  _btnController.reset();
                  return;
                }
                try {
                  debugPrint(_itemController.text);
                  await ServerAdapter.newBorrowRecord(
                    borrowerID: borrower!.id,
                    itemID: int.parse(_itemController.text),
                    borrowDate: DateTime.parse(_borrowDateController.text),
                  );
                  _btnController.success();
                  Timer(Duration(seconds: 1), () {
                    Navigator.pop(context);
                  });
                } catch (cause, stack) {
                  debugPrint(cause.toString());
                  debugPrint(stack.toString());
                  _btnController.error();
                  Timer(Duration(seconds: 1), () {
                    _btnController.reset();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget dateTimePickerBuilder(BuildContext context) {
  late DateTime tempPickedDate;
  return Container(
    height: 250,
    child: Column(
      children: <Widget>[
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CupertinoButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoButton(
                child: Text('Done'),
                onPressed: () {
                  Navigator.pop(context, tempPickedDate);
                },
              ),
            ],
          ),
        ),
        Divider(
          height: 0,
          thickness: 1,
        ),
        Expanded(
          child: Container(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.dateAndTime,
              onDateTimeChanged: (DateTime dateTime) {
                tempPickedDate = dateTime;
              },
            ),
          ),
        ),
      ],
    ),
  );
}

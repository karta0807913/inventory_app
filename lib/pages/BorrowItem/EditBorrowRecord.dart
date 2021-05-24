import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventory_app/global.dart';
import 'package:inventory_app/http_client/responses.dart';
import 'package:inventory_app/pages/Borrower/EditBorrowerDialog.dart';
import 'package:inventory_app/pages/ItemInfo.dart';
import 'package:inventory_app/utils.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class EditBorrowRecordPage extends StatefulWidget {
  final BorrowRecord record;
  final Borrower borrower;
  final ItemData itemData;
  final void Function()? notifyChange;

  EditBorrowRecordPage({
    Key? key,
    this.notifyChange,
    required this.borrower,
    required this.record,
    required this.itemData,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => EditBorrowRecordState();
}

class EditBorrowRecordState extends State<EditBorrowRecordPage> {
  Widget _replyWidget() {
    if (widget.record.replyDate == null) {
      return ListTile(
        title: Text("尚未歸還"),
        subtitle: Text("-"),
      );
    }
    return ListTile(
      title: Text("歸還日期"),
      subtitle: Text(widget.record.borrowDate.toLocal().toString()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("編輯借出紀錄"),
      ),
      body: Column(
        children: [
          Card(
            child: ListTile(
              title: Text("借出人"),
              trailing: Icon(Icons.edit),
              subtitle: Text(widget.borrower.name),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return EditBorrowerDialog(
                      widget.borrower,
                      notifyChange: () {
                        debugPrint(widget.notifyChange.toString());
                        widget.notifyChange?.call();
                        setState(() {});
                      },
                    );
                  },
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              title: Text("借出物品"),
              trailing: Icon(Icons.edit),
              subtitle: Text(widget.itemData.name),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return ItemInfoPage(
                      widget.itemData,
                      notifyChange: () {
                        widget.notifyChange?.call();
                        setState(() {});
                      },
                    );
                  }),
                );
              },
            ),
          ),
          Card(
            child: InkWell(
              child: Column(
                children: [
                  ListTile(
                    title: Text("借出時間"),
                    subtitle:
                        Text(widget.record.borrowDate.toLocal().toString()),
                    trailing: Icon(Icons.edit),
                  ),
                  _replyWidget(),
                ],
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return EditBorrowRecordDialog(
                      widget.record,
                      notifyChange: () {
                        widget.notifyChange?.call();
                        setState(() {});
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EditBorrowRecordDialog extends StatefulWidget {
  final BorrowRecord record;
  final void Function()? notifyChange;

  EditBorrowRecordDialog(this.record, {Key? key, this.notifyChange})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => EditBorrowRecordDialogState();
}

class EditBorrowRecordDialogState extends State<EditBorrowRecordDialog> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  late final TextEditingController _borrowController = TextEditingController(
      text: widget.record.borrowDate.toLocal().toString());
  late final TextEditingController _replyController;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.record.replyDate == null) {
      _replyController = TextEditingController(text: "-");
    } else {
      _replyController = TextEditingController(
          text: widget.record.replyDate!.toLocal().toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("修改日期"),
      content: Form(
        key: _key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextTileEdit(
              icon: Icon(Icons.calendar_today),
              title: "借出日期",
              controller: _borrowController,
              textOnTap: () async {
                DateTime? initDate;
                try {
                  initDate = DateTime.parse(_borrowController.text);
                } catch (e) {}
                DateTime? date = await showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return dateTimePickerBuilder(
                      context,
                      initialDateTime: initDate,
                    );
                  },
                );
                if (date == null) {
                  return;
                }
                _borrowController.text = date.toLocal().toString();
              },
            ),
            TileEdit(
              icon: Icon(Icons.calendar_today),
              title: Row(
                children: [
                  Text(
                    "歸還日期",
                    style: TextStyle(fontSize: 12),
                  ),
                  TextButton(
                    child: Text(
                      "清空日期",
                      style: TextStyle(fontSize: 12),
                    ),
                    onPressed: () {
                      _replyController.text = "-";
                    },
                  ),
                ],
              ),
              controller: _replyController,
              validator: (String? input) {
                if (input == "-") {
                  return null;
                }
                return dateValidation(input);
              },
              textOnTap: () async {
                DateTime? initDate;
                try {
                  initDate = DateTime.parse(_borrowController.text);
                } catch (e) {}
                DateTime? date = await showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return dateTimePickerBuilder(
                      context,
                      initialDateTime: initDate,
                    );
                  },
                );
                if (date == null) {
                  return;
                }
                _replyController.text = date.toLocal().toString();
              },
            ),
            Padding(
              child: RoundedLoadingButton(
                controller: _btnController,
                child: Text("修改"),
                onPressed: () async {
                  if (!_key.currentState!.validate()) {
                    _btnController.reset();
                    return;
                  }
                  bool returned = true;
                  DateTime borrowDate = DateTime.parse(_borrowController.text);
                  DateTime? replyDate;
                  if (_replyController.text == "-") {
                    returned = false;
                  } else {
                    replyDate = DateTime.parse(_replyController.text);
                  }
                  bool replyDateChanged = true;
                  if (replyDate == widget.record.replyDate) {
                    replyDateChanged = false;
                  } else if (replyDate != null &&
                      widget.record.replyDate != null) {
                    replyDateChanged =
                        replyDate.compareTo(widget.record.replyDate!) != 0;
                  }
                  if (!replyDateChanged &&
                      borrowDate.compareTo(widget.record.borrowDate) == 0) {
                    _btnController.success();
                    Timer(Duration(seconds: 1), () {
                      Navigator.pop(context);
                    });
                    return;
                  }
                  try {
                    await ServerAdapter.modifyBorrowRecord(
                      widget.record.id,
                      returned: returned,
                      replyDate: replyDate,
                    );
                    widget.record.replyDate = replyDate;
                    widget.record.borrowDate = borrowDate;
                    widget.notifyChange?.call();

                    _btnController.success();
                    Timer(Duration(seconds: 1), () {
                      Navigator.pop(context);
                    });
                  } catch (error, stack) {
                    debugPrint(error.toString());
                    debugPrint(stack.toString());
                    _btnController.error();
                    Timer(Duration(seconds: 1), () {
                      _btnController.reset();
                    });
                  }
                },
              ),
              padding: EdgeInsets.only(top: 20),
            ),
          ],
        ),
      ),
    );
  }
}

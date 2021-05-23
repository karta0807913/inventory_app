import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventory_app/global.dart';
import 'package:inventory_app/http_client/responses.dart';
import 'package:inventory_app/utils.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class NewBorrowerDialog extends StatefulWidget {
  final void Function(Borrower)? onSelect;

  NewBorrowerDialog({this.onSelect, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NewBorrowerDialogState();
}

class _NewBorrowerDialogState extends State<NewBorrowerDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  String? _nullValidation(String? input) {
    if (input == null || input.isEmpty) {
      return "請填寫這個欄位";
    }
    return null;
  }

  Widget _textEdit(
      {required Widget icon,
      required String title,
      required TextEditingController controller}) {
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      minVerticalPadding: 0,
      leading: Transform.translate(
        offset: Offset(10, 13),
        child: icon,
      ),
      title: Transform.translate(
        offset: Offset(-16, 7),
        child: Text(
          title,
          style: TextStyle(fontSize: 12),
        ),
      ),
      subtitle: Transform.translate(
        offset: Offset(-16, 0),
        child: TextFormField(
          validator: this._nullValidation,
          controller: controller,
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: EdgeInsets.only(top: 10, bottom: 10),
            border: UnderlineInputBorder(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("新借貸人"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextTileEdit(
                    icon: Icon(Icons.account_box),
                    title: "借貸人名稱",
                    controller: _nameController),
                TextTileEdit(
                    icon: Icon(Icons.local_phone_rounded),
                    title: "借貸人電話",
                    controller: _phoneController),
              ],
            ),
          ),
        ],
      ),
      actions: [
        RoundedLoadingButton(
          height: 30,
          borderRadius: 0,
          controller: _btnController,
          child: Text("送出"),
          onPressed: () async {
            if (!_formKey.currentState!.validate()) {
              this._btnController.reset();
              return;
            }
            try {
              widget.onSelect?.call(await ServerAdapter.newBorrower(
                name: _nameController.text,
                phone: _phoneController.text,
              ));
              this._btnController.success();
              Timer(Duration(seconds: 1), () {
                Navigator.pop(context);
              });
            } catch (error, stack) {
              debugPrint(error.toString());
              debugPrint(stack.toString());
              this._btnController.error();
              Timer(Duration(seconds: 1), () {
                this._btnController.reset();
              });
            }
          },
        )
      ],
    );
  }
}

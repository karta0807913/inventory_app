import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventory_app/global.dart';
import 'package:inventory_app/http_client/responses.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class EditBorrowerDialog extends StatefulWidget {
  final void Function()? notifyChange;
  final Borrower borrower;

  EditBorrowerDialog(this.borrower, {this.notifyChange, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditBorrowerDialogState();
}

class _EditBorrowerDialogState extends State<EditBorrowerDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneController =
      TextEditingController(text: widget.borrower.phone);
  late TextEditingController _nameController =
      TextEditingController(text: widget.borrower.name);
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
      title: Text("修改借貸人資料"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _textEdit(
                    icon: Icon(Icons.account_box),
                    title: "借貸人名稱",
                    controller: _nameController),
                _textEdit(
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
          child: Text("修改"),
          onPressed: () async {
            if (!_formKey.currentState!.validate()) {
              this._btnController.reset();
              return;
            }
            try {
              await ServerAdapter.modifyBorrower(
                widget.borrower.id,
                name: _nameController.text,
                phone: _phoneController.text,
              );
              widget.borrower.name = _nameController.text;
              widget.borrower.phone = _phoneController.text;
              widget.notifyChange?.call();
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

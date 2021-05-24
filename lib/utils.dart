import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showErrorMessage(BuildContext context, String title, String content) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
        );
      });
}

String? notEmptyValidation(String? input) {
  if (input == null || input.isEmpty) {
    return "請填寫這個欄位";
  }
  return null;
}

String? dateValidation(String? input) {
  final isEmpty = notEmptyValidation(input);
  if (isEmpty != null) {
    return isEmpty;
  }
  try {
    DateTime.parse(input!);
    return null;
  } catch (e) {
    return "請輸入正確的日期";
  }
}

String? intValidation(String? input) {
  final isEmpty = notEmptyValidation(input);
  if (isEmpty != null) {
    return isEmpty;
  }
  try {
    int.parse(input!);
    return null;
  } catch (e) {
    return "請輸入數字";
  }
}

Widget TileEdit({
  required Widget icon,
  required Widget title,
  TextEditingController? controller,
  String? Function(String?)? validator = notEmptyValidation,
  void Function()? textOnTap,
  FocusNode? focusNode,
}) {
  return ListTile(
    contentPadding: EdgeInsets.all(0),
    minVerticalPadding: 0,
    leading: Transform.translate(
      offset: Offset(10, 13),
      child: icon,
    ),
    title: Transform.translate(
      offset: Offset(-16, 7),
      child: title,
    ),
    subtitle: Transform.translate(
      offset: Offset(-16, 0),
      child: TextFormField(
        onTap: textOnTap,
        validator: validator,
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          isCollapsed: true,
          contentPadding: EdgeInsets.only(top: 10, bottom: 10),
          border: UnderlineInputBorder(),
        ),
      ),
    ),
  );
}

Widget TextTileEdit({
  required Widget icon,
  required String title,
  TextEditingController? controller,
  String? Function(String?)? validator = notEmptyValidation,
  void Function()? textOnTap,
  FocusNode? focusNode,
}) {
  return TileEdit(
    icon: icon,
    title: Text(
      title,
      style: TextStyle(fontSize: 12),
    ),
    focusNode: focusNode,
    controller: controller,
    validator: validator,
    textOnTap: textOnTap,
  );
}

Widget dateTimePickerBuilder(
  BuildContext context, {
  final CupertinoDatePickerMode mode = CupertinoDatePickerMode.dateAndTime,
  final DateTime? minimumDate,
  final DateTime? initialDateTime,
}) {
  DateTime tempPickedDate = DateTime.now();
  if (initialDateTime != null) {
    tempPickedDate = initialDateTime;
  }
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
              mode: mode,
              minimumDate: minimumDate,
              initialDateTime: initialDateTime,
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

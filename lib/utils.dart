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

Widget TextTileEdit({
  required Widget icon,
  required String title,
  TextEditingController? controller,
  String? Function(String?)? validator = notEmptyValidation,
  void Function()? textOnTap,
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
      child: Text(
        title,
        style: TextStyle(fontSize: 12),
      ),
    ),
    subtitle: Transform.translate(
      offset: Offset(-16, 0),
      child: TextFormField(
        onTap: textOnTap,
        validator: validator,
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

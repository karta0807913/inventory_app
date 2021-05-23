import 'package:flutter/material.dart';
import 'package:inventory_app/http_client/responses.dart';
import 'package:inventory_app/pages/Borrower/EditBorrowerDialog.dart';
import 'package:inventory_app/pages/ItemInfo.dart';

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
        ],
      ),
    );
  }
}

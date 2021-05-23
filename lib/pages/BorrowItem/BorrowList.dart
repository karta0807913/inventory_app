import 'package:flutter/material.dart';
import 'package:inventory_app/http_client/responses.dart';
import 'package:inventory_app/pages/BorrowItem/BorrowRecordList.dart';
import 'package:inventory_app/pages/BorrowItem/EditBorrowRecord.dart';
import 'package:inventory_app/pages/BorrowItem/NewBorrowRecord.dart';
import 'package:inventory_app/pages/Borrower/SearchBorrowerDialog.dart';

class BorrowListPage extends StatefulWidget {
  @override
  State<BorrowListPage> createState() => _BorrowListPageState();
}

class _BorrowListPageState extends State<BorrowListPage> {
  late BorrowRecordList _borrowList = BorrowRecordList(
    onTap: this._editRecord,
  );

  void _editRecord({
    required BorrowRecord record,
    required Borrower borrower,
    required ItemData itemData,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return EditBorrowRecordPage(
            record: record,
            borrower: borrower,
            itemData: itemData,
            notifyChange: () {
              _borrowList.refresh();
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _borrowList,
      floatingActionButton: FloatingActionButton(
        heroTag: "add borrow record",
        child: Icon(Icons.add_rounded),
        onPressed: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return NewBorrowRecord();
          }));
        },
      ),
    );
  }
}

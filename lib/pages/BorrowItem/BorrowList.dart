import 'package:flutter/material.dart';
import 'package:inventory_app/http_client/responses.dart';
import 'package:inventory_app/pages/BorrowItem/BorrowRecordList.dart';
import 'package:inventory_app/pages/BorrowItem/EditBorrowRecord.dart';
import 'package:inventory_app/pages/BorrowItem/NewBorrowRecord.dart';

class BorrowListPage extends StatefulWidget {
  @override
  State<BorrowListPage> createState() => _BorrowListPageState();
}

class _BorrowListPageState extends State<BorrowListPage> {
  final GlobalKey<BorrowRecordListState> _bKey =
      GlobalKey<BorrowRecordListState>();

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
              _bKey.currentState?.refresh();
              setState(() {});
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BorrowRecordList(
        onTap: this._editRecord,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add borrow record",
        child: Icon(Icons.add_rounded),
        onPressed: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return NewBorrowRecord(
              notifyChange: () {
                _bKey.currentState?.reload();
              },
            );
          }));
        },
      ),
    );
  }
}

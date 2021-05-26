import 'package:flutter/material.dart';
import 'package:inventory_app/global.dart';
import 'package:inventory_app/http_client/responses.dart';
import 'package:inventory_app/utils.dart';

class BorrowRecordList extends StatefulWidget {
  final int? borrowerID;
  final int? itemID;
  final void Function()? notifyChange;
  final void Function({
    required BorrowRecord record,
    required Borrower borrower,
    required ItemData itemData,
  })? onTap;

  BorrowRecordList(
      {this.itemID, this.borrowerID, this.onTap, this.notifyChange, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => BorrowRecordListState();
}

class BorrowRecordListState extends State<BorrowRecordList> {
  List<BorrowRecord> _borrowRecords = [];
  Map<int, Borrower> _borrowerMap = {};
  Map<int, ItemData> _itemMap = {};
  Set<int> _recordsLoadinSet = {};
  bool _loading = false;
  bool _finish = false;
  int _offset = 0;
  int limit = 40;

  Future<void> loadMore() async {
    if (_loading || _finish) return;
    try {
      _loading = true;
      final result = await ServerAdapter.getBorrowRecordList(
        itemID: widget.itemID,
        borrowerID: widget.borrowerID,
        offset: _offset,
        limit: limit,
      );
      for (BorrowRecord record in result) {
        if (!_borrowerMap.containsKey(record.borrowerID)) {
          _borrowerMap[record.borrowerID] =
              await ServerAdapter.getBorrower(record.borrowerID);
        }
        if (!_itemMap.containsKey(record.itemID)) {
          _itemMap[record.itemID] = await ServerAdapter.getItem(record.itemID);
        }
      }
      if (result.length == 0) {
        _finish = true;
        return;
      }
      setState(() {
        _borrowRecords.addAll(result);
        _offset += result.length;
      });
    } on String catch (cause) {
      showErrorMessage(context, "取得紀錄失敗", cause);
    } catch (error, s) {
      showErrorMessage(context, "取得紀錄失敗", error.toString());
      debugPrint(s.toString());
    } finally {
      _loading = false;
    }
  }

  @override
  void initState() {
    super.initState();
    this.loadMore();
  }

  void refresh() {
    setState(() {});
  }

  Future<void> reload() {
    late Future<void> load;
    setState(() {
      _offset = 0;
      _finish = false;
      _borrowRecords.clear();
      load = this.loadMore();
    });
    return load;
  }

  Future<void> _toggleReturnedState(int i) async {
    final future = ServerAdapter.modifyBorrowRecord(
      _borrowRecords[i].id,
      returned: _borrowRecords[i].replyDate == null,
    );
    setState(() {
      _recordsLoadinSet.add(i);
    });
    try {
      await future;
      if (_borrowRecords[i].replyDate == null) {
        _borrowRecords[i].replyDate = DateTime.now();
      } else {
        _borrowRecords[i].replyDate = null;
      }
      widget.notifyChange?.call();
    } catch (cause, s) {
      debugPrint(s.toString());
      showErrorMessage(context, "更改狀態失敗", cause.toString());
    } finally {
      setState(() {
        _recordsLoadinSet.remove(i);
      });
    }
  }

  Widget _replayIcon(int i) {
    if (_recordsLoadinSet.contains(i)) {
      return ClipOval(
        child: Material(
          color: Colors.blue,
          child: Padding(
            padding: EdgeInsets.all(7),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.0,
              ),
            ),
          ),
        ),
      );
    } else if (_borrowRecords[i].replyDate == null) {
      return ClipOval(
        child: Material(
          color: Colors.red,
          child: InkWell(
            onTap: () => this._toggleReturnedState(i),
            child: Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }
    return ClipOval(
      child: Material(
        color: Colors.green,
        child: InkWell(
          child: Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.check,
              color: Colors.white,
            ),
          ),
          onTap: () => this._toggleReturnedState(i),
        ),
      ),
    );
  }

  void Function()? _onTap(i) {
    if (widget.onTap == null) {
      return null;
    }
    return () {
      widget.onTap!.call(
        record: _borrowRecords[i],
        itemData: _itemMap[_borrowRecords[i].itemID]!,
        borrower: _borrowerMap[_borrowRecords[i].borrowerID]!,
      );
    };
  }

  Widget? _editIcon() {
    if (widget.onTap != null) {
      return Icon(
        Icons.edit,
        size: 20,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _borrowRecords.length,
      itemBuilder: (context, i) {
        final bDate = _borrowRecords[i].borrowDate.toLocal();
        return ListTile(
          onTap: this._onTap(i),
          leading: _replayIcon(i),
          trailing: _editIcon(),
          title: Text(_itemMap[_borrowRecords[i].itemID]!.name),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_borrowerMap[_borrowRecords[i].borrowerID]!.name),
              Text(
                  "${bDate.year.toString()}-${bDate.month.toString()}-${bDate.day.toString()}"),
            ],
          ),
        );
      },
    );
  }
}

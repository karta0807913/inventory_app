import 'package:flutter/material.dart';
import 'package:inventory_app/global.dart';
import 'package:inventory_app/http_client/responses.dart';
import 'package:inventory_app/pages/ItemInfo.dart';
import 'package:inventory_app/pages/ScanItemQrCode.dart';

class ItemList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  int _offset = 0;
  int _limit = 20;
  bool _done = false;
  List<ItemData> _data = [];
  Future<Iterable<ItemData>>? _lock;

  void _loadNext() async {
    if (_done || this._lock != null) {
      return;
    }
    try {
      final future = ServerAdapter.getItemList(limit: _limit, offset: _offset);
      this._lock = future;
      final data = await future;
      _offset += _limit;
      if (data.length < _limit) {
        _done = true;
      }
      setState(() {
        _data.addAll(data);
      });
    } on String catch (error) {} catch (error, s) {
      debugPrint(error.toString());
      debugPrint(s.toString());
    } finally {
      this._lock = null;
    }
  }

  @override
  void initState() {
    super.initState();
    this._loadNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: this._data.length,
          itemBuilder: (context, i) {
            if (i + 10 > _data.length) {
              this._loadNext();
            }
            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemInfoPage(
                      _data[i],
                      notifyChange: () {
                        setState(() {});
                      },
                    ),
                  ),
                );
              },
              title: Text(_data[i].name),
              trailing: Icon(
                Icons.edit,
                size: 20,
              ),
              subtitle: Text(_data[i].location),
            );
          }),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: 10,
              ),
              child: SizedBox(
                width: 50,
                height: 50,
                child: FloatingActionButton(
                  heroTag: "scan qrcode",
                  child: Icon(Icons.camera_alt),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanItemQrCode(),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              width: 50,
              height: 50,
              child: FloatingActionButton(
                heroTag: "add item",
                onPressed: () {},
                child: Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

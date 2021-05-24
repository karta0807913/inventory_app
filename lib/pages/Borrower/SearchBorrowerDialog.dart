import 'package:flutter/material.dart';
import 'package:inventory_app/global.dart';
import 'package:inventory_app/http_client/responses.dart';
import 'package:inventory_app/pages/Borrower/NewBorrowerDialog.dart';

class SearchBorrowerDialog extends StatefulWidget {
  final void Function(Borrower)? onSelect;
  SearchBorrowerDialog({Key? key, this.onSelect}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SearchBorrowerDialogState();
}

class _SearchBorrowerDialogState extends State<SearchBorrowerDialog> {
  static const Map<int, String> searchMap = {
    0: "手機搜尋",
    1: "姓名搜尋",
  };
  late final List<DropdownMenuItem<int>> _listMenuItem;

  int _currentSearch = 0;
  List<Borrower> _bList = [];
  bool _reloading = false, _refresh = false;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    this._reload("");
    List<DropdownMenuItem<int>> item = [];
    for (int key in searchMap.keys) {
      item.add(DropdownMenuItem(
        value: key,
        child: Text(searchMap[key]!),
      ));
    }
    _listMenuItem = item;
  }

  Future<void> _reload(String data) async {
    if (_reloading) {
      _refresh = true;
      return;
    }
    _reloading = true;

    try {
      late Future<Iterable<Borrower>> future;
      if (_currentSearch == 0) {
        future = ServerAdapter.fussyBorrowerSearch(phone: data);
      } else {
        future = ServerAdapter.fussyBorrowerSearch(name: data);
      }
      final result = await future;
      setState(() {
        _bList = result.toList(growable: false);
      });
    } catch (error, stack) {
      debugPrint(error.toString());
      debugPrint(stack.toString());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('搜尋時發生錯誤，請稍後再試')));
    } finally {
      this._reloading = false;
      if (_refresh) {
        _refresh = false;
        this._reload(_controller.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("搜尋借出人"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButton(
                  value: _currentSearch,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        this._currentSearch = value as int;
                      });
                    }
                  },
                  items: _listMenuItem,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    contentPadding: EdgeInsets.only(top: 7, bottom: 7),
                  ),
                  onChanged: (String string) {
                    this._reload(string);
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _bList.length + 1,
              itemBuilder: (context, i) {
                // return the option for create a new user
                if (i == _bList.length) {
                  return ListTile(
                    title: Text("新增使用者"),
                    leading: Icon(Icons.add_rounded),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        DialogRoute(
                          context: context,
                          builder: (context) {
                            return NewBorrowerDialog(
                              onSelect: widget.onSelect,
                            );
                          },
                        ),
                      );
                    },
                  );
                }
                return ListTile(
                  title: Text(_bList[i].name),
                  subtitle: Text(_bList[i].phone),
                  onTap: () {
                    widget.onSelect?.call(_bList[i]);
                    Navigator.pop(context);
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

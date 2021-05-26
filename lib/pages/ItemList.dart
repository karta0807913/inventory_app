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
  ItemState? searchState;

  void _loadNext() async {
    if (_done || this._lock != null) {
      return;
    }
    try {
      final future = ServerAdapter.getItemList(
        state: searchState,
        limit: _limit,
        offset: _offset,
      );
      this._lock = future;
      final data = await future;
      _offset += _limit;
      if (data.length < _limit) {
        _done = true;
      }
      setState(() {
        _data.addAll(data);
      });
    } on String catch (error) {
      debugPrint(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          content: Text('載入資料時發生錯誤，請稍後再試'),
        ),
      );
    } catch (error, s) {
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

  void reload() {
    setState(() {
      _done = false;
      _offset = 0;
      _data.clear();
    });
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
                  onPressed: () async {
                    ItemData? itemData = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanItemQrCode(),
                      ),
                    );
                    if (itemData != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemInfoPage(
                            itemData,
                            notifyChange: () => setState(() {}),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            SizedBox(
              width: 50,
              height: 50,
              child: SearchButton(
                onSearch: (state) {
                  searchState = state;
                  this.reload();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchButton extends StatefulWidget {
  final void Function(ItemState?)? onSearch;

  SearchButton({Key? key, this.onSearch}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SearchButtonState();
}

class SearchButtonState extends State<SearchButton> {
  final searchingIcon = const Icon(Icons.saved_search_rounded);
  final searchIcon = const Icon(Icons.search);
  late Icon currentIcon = searchIcon;
  ItemState currentState = ItemState();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () async {
        ItemState? state = await showDialog(
          context: context,
          builder: (context) => ItemStateDialog(
            state: this.currentState,
          ),
        );
        if (state != null) {
          this.currentState = state;
          widget.onSearch?.call(state);
          setState(() {
            currentIcon = searchingIcon;
          });
        }
      },
      child: FloatingActionButton(
        heroTag: "filter",
        onPressed: () {
          if (currentIcon == searchIcon) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 1),
                content: Text('只顯示未被標記（長按設定詳細）'),
              ),
            );
            currentState = ItemState();
            widget.onSearch?.call(ItemState());
            setState(() {
              currentIcon = searchingIcon;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 1),
                content: Text('顯示全部'),
              ),
            );
            currentState = ItemState();
            widget.onSearch?.call(null);
            setState(() {
              currentIcon = searchIcon;
            });
          }
        },
        child: currentIcon,
      ),
    );
  }
}

class ItemStateDialog extends StatefulWidget {
  final ItemState state;
  ItemStateDialog({Key? key, required this.state}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ItemStateDialogState();
}

class ItemStateDialogState extends State<ItemStateDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("搜尋狀態"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: LabeledCheckbox(
                  label: "符合",
                  padding: EdgeInsets.all(2),
                  value: widget.state.correct,
                  onChanged: (b) {
                    if (b != null) {
                      setState(() {
                        widget.state.correct = b;
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: LabeledCheckbox(
                  label: "報廢",
                  padding: EdgeInsets.all(2),
                  value: widget.state.discard,
                  onChanged: (b) {
                    if (b != null) {
                      setState(() {
                        widget.state.discard = b;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: LabeledCheckbox(
                  label: "送修",
                  padding: EdgeInsets.all(2),
                  value: widget.state.fixing,
                  onChanged: (b) {
                    if (b != null) {
                      setState(() {
                        widget.state.fixing = b;
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: LabeledCheckbox(
                  label: "標籤未貼",
                  padding: EdgeInsets.all(2),
                  value: widget.state.unlabel,
                  onChanged: (b) {
                    if (b != null) {
                      setState(() {
                        widget.state.unlabel = b;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, widget.state),
          child: const Text('確認'),
        ),
      ],
    );
  }
}

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    Key? key,
    required this.label,
    required this.padding,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final String label;
  final EdgeInsets padding;
  final bool value;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            Expanded(child: Text(label)),
            Checkbox(
              value: value,
              onChanged: (bool? newValue) {
                onChanged(newValue);
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:inventory_app/global.dart';
import 'package:inventory_app/http_client/responses.dart';
import 'package:inventory_app/pages/BorrowItem/BorrowRecordList.dart';
import 'package:inventory_app/utils.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class ItemInfoPage extends StatefulWidget {
  final ItemData item;
  final void Function()? notifyChange;

  ItemInfoPage(this.item, {this.notifyChange});

  @override
  State<StatefulWidget> createState() => _ItemInfoPateState();
}

class _ItemInfoPateState extends State<ItemInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name),
      ),
      body: Column(
        children: [
          Card(
            color: Colors.grey[100],
            elevation: 8,
            child: Padding(
              padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: ClipOval(
                      child: Material(
                        color: Colors.white,
                        child: InkWell(
                          splashColor: Colors.grey,
                          child: SizedBox(
                            width: 36,
                            height: 36,
                            child: Icon(Icons.mode_edit),
                          ),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return ModifyItemDialog(
                                    widget.item,
                                    notifyChange: () {
                                      setState(() {});
                                      widget.notifyChange?.call();
                                    },
                                  );
                                });
                          },
                        ),
                      ),
                    ),
                  ),
                  Table(
                    columnWidths: {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(7),
                    },
                    children: [
                      TableRow(
                        children: [
                          Text("物品名稱"),
                          Text(widget.item.name),
                        ],
                      ),
                      TableRow(
                        children: [
                          Text("存置地點"),
                          Text(widget.item.location),
                        ],
                      ),
                      TableRow(
                        children: [
                          Text("物品ID"),
                          Text(widget.item.itemID),
                        ],
                      ),
                      TableRow(
                        children: [
                          Text("物品註記"),
                          Text(widget.item.note),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: BorrowRecordList(
              itemID: widget.item.id,
              notifyChange: widget.notifyChange,
            ),
          ),
          ItemStateWidget(widget.item.itemID, widget.item.state),
        ],
      ),
    );
  }
}

class ItemStateWidget extends StatefulWidget {
  final ItemState state;
  final String itemID;
  ItemStateWidget(this.itemID, this.state);

  @override
  State<StatefulWidget> createState() => _ItemStateWidget();
}

class _ItemStateWidget extends State<ItemStateWidget> {
  ItemState _state = ItemState();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
    _state.correct = widget.state.correct;
    _state.discard = widget.state.discard;
    _state.fixing = widget.state.fixing;
    _state.unlabel = widget.state.unlabel;
    if (SchedulerBinding.instance != null) {
      SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
        _btnController.success();
      });
    }
  }

  bool _checkStateChange() {
    if (_state.correct != widget.state.correct ||
        _state.discard != widget.state.discard ||
        _state.fixing != widget.state.fixing ||
        _state.unlabel != widget.state.unlabel) {
      _btnController.reset();
      return true;
    } else {
      _btnController.success();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Center(
            child: Text("物品自盤狀態"),
          ),
        ),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: _state.correct,
                        onChanged: (b) {
                          if (b != null) {
                            setState(() {
                              _state.correct = b;
                              this._checkStateChange();
                            });
                          }
                        },
                      ),
                      Text("符合"),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: _state.discard,
                        onChanged: (b) {
                          if (b != null) {
                            setState(() {
                              _state.discard = b;
                              this._checkStateChange();
                            });
                          }
                        },
                      ),
                      Text("報廢"),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: _state.fixing,
                        onChanged: (b) {
                          if (b != null) {
                            setState(() {
                              _state.fixing = b;
                              this._checkStateChange();
                            });
                          }
                        },
                      ),
                      Text("送修"),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: _state.unlabel,
                  onChanged: (b) {
                    if (b != null) {
                      setState(() {
                        _state.unlabel = b;
                        this._checkStateChange();
                      });
                    }
                  },
                ),
                Text("標籤未貼"),
              ],
            ),
          ],
        ),
        Center(
          child: RoundedLoadingButton(
            child: Text("更新狀態"),
            controller: _btnController,
            onPressed: () async {
              if (!this._checkStateChange()) {
                return;
              }
              try {
                await ServerAdapter.modifyItem(widget.itemID, state: _state);
                widget.state.correct = _state.correct;
                widget.state.discard = _state.discard;
                widget.state.fixing = _state.fixing;
                widget.state.unlabel = _state.unlabel;
                _btnController.success();
              } on String catch (cause) {
                showErrorMessage(context, "更新狀態時發生錯誤", cause);
                _btnController.error();
                Timer(Duration(seconds: 1), () {
                  _btnController.reset();
                });
              } catch (error, trace) {
                showErrorMessage(context, "發生未知的錯誤", error.toString());
                debugPrint(trace.toString());
                _btnController.error();
                Timer(Duration(seconds: 1), () {
                  _btnController.reset();
                });
              }
            },
          ),
        ),
      ],
    );
  }
}

class ModifyItemDialog extends StatelessWidget {
  static const InputDecoration _inputStyle = const InputDecoration(
    contentPadding: EdgeInsets.only(bottom: 5, top: 5),
    isCollapsed: true,
    hintText: null,
    border: UnderlineInputBorder(),
  );

  late final TextEditingController locationController;
  late final TextEditingController noteController;

  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  final ItemData item;
  final void Function()? notifyChange;

  ModifyItemDialog(this.item, {this.notifyChange, Key? key}) : super(key: key) {
    locationController = TextEditingController(text: item.location);
    noteController = TextEditingController(text: item.note);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("修改 " + item.name),
      content: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                child: Column(
                  children: [
                    ListTile(
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("存置地點"),
                          TextFormField(
                            controller: locationController,
                            scrollPadding: EdgeInsets.all(0),
                            decoration: _inputStyle,
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("備註"),
                          TextFormField(
                            controller: noteController,
                            scrollPadding: EdgeInsets.all(0),
                            maxLines: null,
                            decoration: _inputStyle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        RoundedLoadingButton(
          height: 30,
          borderRadius: 0,
          controller: _btnController,
          child: Text("送出"),
          onPressed: () async {
            try {
              await ServerAdapter.modifyItem(
                item.itemID,
                location: locationController.text,
                note: noteController.text,
              );
              item.location = locationController.text;
              item.note = noteController.text;
              _btnController.success();
              Timer(Duration(seconds: 1), () {
                Navigator.pop(context);
              });
              notifyChange?.call();
            } catch (error, stack) {
              debugPrint(stack.toString());
              showErrorMessage(context, "更新失敗", error.toString());
              _btnController.error();
              Timer(Duration(seconds: 1), () {
                _btnController.reset();
              });
            }
          },
        ),
      ],
    );
  }
}

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:inventory_app/global.dart';
import 'package:inventory_app/http_client/responses.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanItemQrCode extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanItemQrCodeState();
}

class _ScanItemQrCodeState extends State<ScanItemQrCode> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;
  bool loading = false;
  bool done = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan QR Code")),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }

  _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen(
      (scanData) async {
        if (loading || done) {
          return;
        }
        try {
          loading = true;
          ItemData? data = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return _GetItemDialog(
                itemID: scanData.code,
                context: context,
              );
            },
          );
          if (data == null) {
            return;
          }
          done = true;
          Navigator.pop(context, data);
        } finally {
          loading = false;
        }
      },
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }
}

class _GetItemDialog extends AlertDialog {
  final String itemID;
  final BuildContext context;
  _GetItemDialog({required this.itemID, required this.context})
      : super(content: Text("Loading")) {
    _loadItem();
  }
  Future<void> _loadItem() async {
    try {
      final ItemData itemData = await ServerAdapter.getItemByID(itemID);
      Navigator.pop(context, itemData);
    } catch (error, stack) {
      Navigator.pushReplacement(
        context,
        DialogRoute(
          context: context,
          builder: (context) {
            debugPrint(stack.toString());
            return AlertDialog(
              title: Text("搜尋時出現錯誤"),
              content: Text(error.toString()),
            );
          },
        ),
      );
    }
  }
}

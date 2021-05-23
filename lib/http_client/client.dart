import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inventory_app/http_client/responses.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Client {
  Cookie _cookie = Cookie("session", "");
  String _host;

  Client(String host) : this._host = host;

  Future<bool> loadCookie() async {
    final prefs = await SharedPreferences.getInstance();
    String? cookie = prefs.getString("cookie");
    if (cookie != null) {
      this._cookie = Cookie.fromSetCookieValue(cookie);
      return true;
    }
    return false;
  }

  Future<bool> saveCookie() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString("cookie", _cookie.toString());
  }

  Future<dynamic> _put(String path, Map<String, dynamic> body) async {
    debugPrint(jsonEncode(body));
    final response = await http
        .put(Uri.http(this._host, path), body: jsonEncode(body), headers: {
      "Cookie": this._cookie.toString(),
    });
    final decodedBody = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw decodedBody["message"];
    }
    return decodedBody;
  }

  Future<dynamic> _post(String path, Object? body) async {
    final response = await http
        .post(Uri.http(this._host, path), body: jsonEncode(body), headers: {
      "Cookie": this._cookie.toString(),
    });

    final setCookieValue = response.headers.remove("Set-Cookies");
    if (setCookieValue != null) {
      final cookie = Cookie.fromSetCookieValue(setCookieValue);
      if (cookie.name == "session") {
        this._cookie = cookie;
      }
    }
    final decodedBody = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw decodedBody["message"];
    }
    return decodedBody;
  }

  Future<dynamic> _get(String path, Map<String, dynamic>? query) async {
    final response =
        await http.get(Uri.http(this._host, path, query), headers: {
      "Cookie": this._cookie.toString(),
    });
    final dynamic decodedBody = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw decodedBody["message"];
    }
    return decodedBody;
  }

  Future<UserInfo> login(String account, String password) async {
    final body = await this._post("login", {
      "account": account,
      "password": password,
    });
    return UserInfo.fromJSON(body);
  }

  Future<Iterable<ItemData>> getItemList(
      {String? name, int limit = 20, int offset = 0}) async {
    final List<dynamic> result = await _get("/api/item", <String, dynamic>{
      "name": name,
      "limit": limit.toString(),
      "offset": offset.toString(),
    });
    if (result.length != 0) {
      return result.map((e) => ItemData.fromJSON(e));
    }
    return [];
  }

  Future<ItemData> getItem(int id) async {
    final result = await _get("/api/item", <String, dynamic>{
      "id": id.toString(),
    });
    debugPrint(result.toString());
    return ItemData.fromJSON(result);
  }

  Future<void> modifyItem(String itemID,
      {String? location, String? note, ItemState? state}) async {
    Map<String, dynamic> body = {};

    body["item_id"] = itemID;

    if (location != null) {
      body["location"] = location;
    }
    if (note != null) {
      body["note"] = note;
    }
    if (state != null) {
      body["state"] = {
        "correct": state.correct,
        "discard": state.discard,
        "fixing": state.fixing,
        "unlabel": state.unlabel,
      };
    }
    await this._put("/api/item", body);
  }

  Future<Iterable<Borrower>> getBorrowerList(
      {String? phone, String? name, int limit = 20, int offset = 0}) async {
    final List<dynamic> result = await _get("/api/borrower", {
      "phone": phone,
      "name": name,
      "limit": limit.toString(),
      "offset": offset.toString(),
    });

    if (result.length != 0) {
      return result.map((e) => Borrower.fromJSON(e));
    }
    return [];
  }

  Future<Borrower> getBorrower(int id) async {
    final result = await _get("/api/borrower", {
      "id": id.toString(),
    });
    return Borrower.fromJSON(result);
  }

  Future<Borrower> newBorrower({
    required String name,
    required String phone,
  }) async {
    final result = await _post("/api/borrower", {
      "name": name,
      "phone": phone,
    });
    return Borrower.fromJSON(result);
  }

  Future<void> modifyBorrower(
    int id, {
    String? name,
    String? phone,
  }) async {
    await _put("/api/borrower", {
      "id": id,
      "name": name,
      "phone": phone,
    });
  }

  Future<Iterable<BorrowRecord>> getBorrowRecordList(
      {int? borrowerID,
      int? itemID,
      bool? returned,
      int offset = 0,
      int limit = 20}) async {
    Map<String, String> query = {
      "offset": offset.toString(),
      "limit": limit.toString(),
    };
    if (borrowerID != null) {
      query["borower_id"] = borrowerID.toString();
    }
    if (itemID != null) {
      query["item_id"] = itemID.toString();
    }
    if (returned != null) {
      query["returned"] = returned.toString();
    }
    final List<dynamic> result = await _get("/api/borrow_record", query);
    if (result.length == 0) {
      return [];
    }
    return result.map((e) => BorrowRecord.fromJSON(e));
  }

  Future<void> modifyBorrowRecord(
    int id, {
    int? borrowID,
    DateTime? replyDate,
    String? note,
    bool? returned,
  }) async {
    Map<String, dynamic> body = {
      "id": id,
    };

    if (borrowID != null) {
      body["borrow_id"] = borrowID;
    }

    if (replyDate != null) {
      body["reply_date"] = replyDate.toIso8601String();
    }

    if (note != null) {
      body["note"] = note;
    }

    if (returned != null) {
      body["returned"] = returned;
    }

    await _put("/api/borrow_record", body);
  }

  Future<BorrowRecord> newBorrowRecord({
    required int borrowerID,
    required int itemID,
    required DateTime borrowDate,
    String? note,
  }) async {
    debugPrint(borrowDate.toIso8601String());
    final result = await _post("/api/borrow_record", {
      "borrower_id": borrowerID,
      "item_id": itemID,
      "borrow_date": borrowDate.toUtc().toIso8601String(),
      "note": note,
    });
    return BorrowRecord.fromJSON(result);
  }

  Future<Iterable<Borrower>> fussyBorrowerSearch({
    String? phone,
    String? name,
  }) async {
    final List<dynamic> result = await _get("/api/borrower_fuzzy", {
      "phone": phone,
      "name": name,
    });
    if (result.length == 0) {
      return [];
    }
    return result.map((e) => Borrower.fromJSON(e));
  }
}

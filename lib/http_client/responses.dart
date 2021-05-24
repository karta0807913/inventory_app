class UserInfo {
  final String nickname;

  UserInfo({required String nickname}) : this.nickname = nickname;

  factory UserInfo.fromJSON(Map<String, dynamic> json) {
    return UserInfo(nickname: json["Name"]);
  }
}

class ItemState {
  bool correct;
  bool discard;
  bool fixing;
  bool unlabel;

  ItemState({
    this.correct = false,
    this.discard = false,
    this.fixing = false,
    this.unlabel = false,
  });

  factory ItemState.fromJSON(Map<String, dynamic> json) {
    ItemState state = ItemState();
    state.correct = json["correct"];
    state.discard = json["discard"];
    state.fixing = json["fixing"];
    state.unlabel = json["unlabel"];
    return state;
  }
}

class ItemData {
  int ageLimit = 0;
  int cost = 0;
  int id = 0;
  String date = '';
  String itemID = '';
  String location = '';
  String name = '';
  String note;
  late ItemState state;

  ItemData({
    this.ageLimit = 0,
    this.cost = 0,
    this.id = 0,
    this.date = '',
    this.itemID = '',
    this.location = '',
    this.name = '',
    ItemState? state,
    this.note = '',
  }) {
    if (state != null) {
      this.state = state;
    }
  }

  factory ItemData.fromJSON(Map<String, dynamic> json) {
    ItemData data = ItemData();
    data.ageLimit = json["age_limit"];
    data.cost = json["cost"];
    data.date = json["date"];
    data.id = json["id"];
    data.itemID = json["item_id"];
    data.location = json["location"];
    data.name = json["name"];
    if (json["note"] != null) {
      data.note = json["note"];
    }
    data.state = ItemState.fromJSON(json["state"]);
    return data;
  }
}

class Borrower {
  int id;
  String name;
  String phone;

  Borrower({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory Borrower.fromJSON(Map<String, dynamic> json) {
    return Borrower(
      id: json["id"],
      name: json["name"],
      phone: json["phone"],
    );
  }
}

class BorrowRecord {
  int id;
  int borrowerID;
  int itemID;
  String note;
  DateTime borrowDate;
  DateTime? replyDate;

  BorrowRecord({
    required this.id,
    required this.borrowerID,
    required this.itemID,
    required this.borrowDate,
    this.note = "",
    this.replyDate,
  });

  factory BorrowRecord.fromJSON(Map<String, dynamic> json) {
    DateTime? replyDate;
    if (json["reply_date"] != null) {
      replyDate = DateTime.parse(json["reply_date"]);
    }
    return BorrowRecord(
      id: json["id"],
      itemID: json["item_id"],
      borrowerID: json["borrower_id"],
      borrowDate: DateTime.parse(json["borrow_date"]),
      replyDate: replyDate,
      note: json["note"],
    );
  }
}

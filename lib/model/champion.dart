import 'account.dart';

class Champion {
  Champion({this.id, this.name, this.chest});

  int id;
  String name;
  bool chest = false;

  Champion.empty();

  static final table = 'champion';

  static final columnId = 'id';
  static final columnName = 'name';
  static final columnChest = 'chest';
  static final columnAccountId = 'account_id';

  Map<String, dynamic> toMap(Account account) {
    return {
      columnName: name,
      columnChest: chest ? 1 : 0,
      columnAccountId: account.id,
    };
  }

  Champion.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    chest = map[columnChest] == 1;
  }
}
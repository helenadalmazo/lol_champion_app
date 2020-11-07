import 'package:lol_champion_app/model/account.dart';
import 'package:sqflite/sqflite.dart';

import 'champion_repository.dart';
import 'database.dart';

class AccountRepository {

  Future<int> insert(Account account) async {
    final Database database = await LolChampionAppDatabase.instance.database;

    return database.insert(
      Account.table,
      account.toMap()
    );
  }

  Future<List<Account>> list() async {
    final Database database = await LolChampionAppDatabase.instance.database;

    final List<Map<String, dynamic>> mapList = await database.query(Account.table);

    List<Account> accountList = List.generate(mapList.length, (i) {
      return Account.fromMap(mapList[i]);
    });

    ChampionRepository championRepository = ChampionRepository();
    for (Account account in accountList) {
      account.championList = await championRepository.list(account);
    }

    return accountList;
  }

  Future<int> update(Account account) async {
    final Database database = await LolChampionAppDatabase.instance.database;

    return database.update(
      Account.table,
      account.toMap(),
      where: "${Account.columnId} = ?",
      whereArgs: [account.id],
    );
  }

  Future<int> delete(int id) async {
    final Database database = await LolChampionAppDatabase.instance.database;

    return database.delete(
      Account.table,
      where: "${Account.columnId} = ?",
      whereArgs: [id],
    );
  }

  static String createTable() {
    return """
      CREATE TABLE ${Account.table} (
        ${Account.columnId} INTEGER PRIMARY KEY,
        ${Account.columnName} TEXT NOT NULL,
        ${Account.columnImageId} INTEGER NOT NULL
      );
    """;
  }
}
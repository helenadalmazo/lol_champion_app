import 'package:lol_champion_app/model/account.dart';
import 'package:lol_champion_app/model/champion.dart';
import 'package:sqflite/sqflite.dart';

import 'database.dart';

class ChampionRepository {

  Future<int> insert(Account account, Champion champion) async {
    final Database database = await LolChampionAppDatabase.instance.database;

    return database.insert(
      Champion.table,
      champion.toMap(account)
    );
  }

  Future<List<Champion>> list(Account account) async {
    final Database database = await LolChampionAppDatabase.instance.database;

    final List<Map<String, dynamic>> mapList = await database.query(
      Champion.table,
      where: "${Champion.columnAccountId} = ?",
      whereArgs: [account.id],
    );

    return List.generate(mapList.length, (index) {
      return Champion.fromMap(mapList[index]);
    });
  }

  Future<void> update(Account account, Champion champion) async {
    final Database database = await LolChampionAppDatabase.instance.database;

    return database.update(
      Champion.table,
      champion.toMap(account),
      where: "${Champion.columnId} = ?",
      whereArgs: [champion.id],
    );
  }

//  Future<void> delete(int id) async {
//    final Database database = await LolChampionAppDatabase.instance.database;
//
//    await database.delete(
//      table,
//      where: "id = ?",
//      whereArgs: [id],
//    );
//  }

  static String createTable() {
    return """
      CREATE TABLE ${Champion.table} (
        ${Champion.columnId} INTEGER PRIMARY KEY,
        ${Champion.columnName} TEXT NOT NULL UNIQUE,
        ${Champion.columnChest} INTEGER NOT NULL DEFAULT 0,
        ${Champion.columnAccountId} INTEGER NOT NULL,
        FOREIGN KEY (${Champion.columnAccountId}) REFERENCES account (${Account.columnId}) 
      );
    """;
  }
}
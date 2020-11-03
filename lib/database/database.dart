import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'account_repository.dart';
import 'champion_repository.dart';

class LolChampionAppDatabase {

  static final name = "lol_champions.db";
  static final version = 1;

  LolChampionAppDatabase.privateConstructor();
  static final LolChampionAppDatabase instance = LolChampionAppDatabase.privateConstructor();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await getDatabase();
    return _database;
  }

  Future<Database> getDatabase() async {
    var databasesPath = await getDatabasesPath();
    print("[INFO] databases path: $databasesPath");

    var path = join(databasesPath, name);

//    await deleteDatabase(path);

    return openDatabase(
      path,
      version: version,
      onCreate: onCreate
    );
  }

  void onCreate(Database db, int version) {
    db.execute(AccountRepository.createTable());
    db.execute(ChampionRepository.createTable());
  }

  Future<void> closeDatabase() async{
    return (await database).close();
  }
}
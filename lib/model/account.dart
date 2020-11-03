import 'champion.dart';

class Account {
  Account({this.id, this.name, this.imageId});

  int id;
  String name;
  int imageId = 29;
  List<Champion> championList = [];

  Account.empty();

  static final table = 'account';

  static final columnId = 'id';
  static final columnName = 'name';
  static final columnImageId = 'image_id';

  Map<String, dynamic> toMap() {
    return {
      columnName: name,
      columnImageId: imageId
    };
  }

  Account.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    imageId = map[columnImageId];
  }

  List<Champion> getChampionWithChest() {
    return this.championList.where((champ) => champ.chest).toList();
  }

  int getChampionWithChestCount() {
    return this.championList.where((champ) => champ.chest).length;
  }

  List<Champion> getChampionWithoutChest() {
    return this.championList.where((champ) => !champ.chest).toList();
  }

  int getChampionWithoutChestCount() {
    return this.championList.where((champ) => !champ.chest).length;
  }
}
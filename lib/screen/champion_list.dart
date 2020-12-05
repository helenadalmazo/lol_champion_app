import 'package:flutter/material.dart';
import 'package:lol_champion_app/database/champion_repository.dart';
import 'package:lol_champion_app/model/account.dart';
import 'package:lol_champion_app/model/champion.dart';
import 'package:lol_champion_app/screen/home.dart';
import 'package:lol_champion_app/widget/champion_list.dart';

class ChampionListScreen extends StatefulWidget {
  final Account account;

  const ChampionListScreen({Key key, this.account}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChampionListScreenState(account);
  }
}

class _ChampionListScreenState extends State<StatefulWidget> {
  ChampionRepository championRepository;

  final Account account;
  List<Champion> disabledChampionsList = [];
  List<Champion> addedChampionsList = [];

  double loadingValue = 0;

  _ChampionListScreenState(this.account) {
    championRepository = ChampionRepository();
    List<String> championNameList = account.championList
        .map((champ) => champ.name)
        .toList();
    this.disabledChampionsList = ddragonChampionList
        .where((str) => !championNameList.contains(str))
        .map((str) => Champion(name: str, chest: false))
        .toList();
  }

  void addChampion(Champion champion, BuildContext context) {
    setState(() {
      if (addedChampionsList.contains(champion)) {
        addedChampionsList.remove(champion);
      } else {
        addedChampionsList.add(champion);
      }
    });
  }

  IconData getIcon(Champion champion) {
    return addedChampionsList.contains(champion)
        ? Icons.check : Icons.lock_outline;
  }

  String getTitle() {
    if (addedChampionsList.length == 0) {
      return 'Adicionar campeões';
    } else {
      return 'Adicionar ${addedChampionsList.length} campeões';
    }
  }

  Widget getFab(BuildContext context) {
    if (addedChampionsList.length == 0) {
      return Container();
    } else {
      return FloatingActionButton(
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            child: getLoadingAlertDialog()
          );
          for (var champion in addedChampionsList) {
            champion.id = await championRepository.insert(account, champion);
          }
          Navigator.pop(context); // Dialog
          Navigator.pop(context, addedChampionsList); // ChampionListScreen
        },
        child: Icon(Icons.check),
      );
    }
  }

  Widget getLoadingAlertDialog() {
    return WillPopScope(
      child: AlertDialog(
        backgroundColor: Colors.transparent,
        content: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      onWillPop: () { },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTitle()),
      ),
      body: ListView(
        children: [
          SizedBox(height: 16),
          ChampionList(
            championList: disabledChampionsList,
            getIcon: getIcon,
            onTapItem: addChampion,
          ),
          SizedBox(height: 16),
        ],
      ),
      floatingActionButton: getFab(context)
    );
  }
}
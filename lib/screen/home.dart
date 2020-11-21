import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lol_champion_app/database/account_repository.dart';
import 'package:lol_champion_app/database/champion_repository.dart';
import 'package:lol_champion_app/model/account.dart';
import 'package:lol_champion_app/model/champion.dart';
import 'package:lol_champion_app/screen/account.dart';
import 'package:lol_champion_app/screen/account_list.dart';
import 'package:lol_champion_app/screen/setting.dart';
import 'package:lol_champion_app/widget/account_empty_item.dart';
import 'package:lol_champion_app/widget/account_item.dart';
import 'package:lol_champion_app/widget/champion_list.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  AccountRepository accountRepository;
  ChampionRepository championRepository;

  List<Account> accountList;
  Account selectedAccount;
  List<Champion> disabledChampionsList = [];

  String appBarTitle = "";

  Key chestAvailableKey = Key('chest_available');
  Key chestObtainedKey = Key('chest_obtained');
  Key chestDisabledKey = Key('chest_disabled');

  double chestAvailableVisibilityPercentage = 0;
  double chestObtainedVisibilityPercentage = 0;
  double chestDisabledVisibilityPercentage = 0;

  _HomeScreenState() {
    accountRepository = AccountRepository();
    championRepository = ChampionRepository();
    listAccounts();
  }

  void listAccounts() {
    accountRepository.list().then((List<Account> accountList) {
      setState(() {
        this.accountList = accountList;
      });
      if (accountList.isNotEmpty) {
        selectAccount(accountList.first);
      }
    });
  }

  void addAccount(Account account) {
    accountRepository.insert(account).then((id) {
      setState(() {
        account.id = id;
        this.accountList.add(account);
      });
      selectAccount(account);
    });
  }

  void selectAccount(Account account) {
    setState(() {
      this.selectedAccount = account;
      List<String> championNameList = selectedAccount.championList
          .map((champ) => champ.name)
          .toList();
      this.disabledChampionsList = ddragonChampionList
          .where((str) => !championNameList.contains(str))
          .map((str) => Champion(name: str, chest: false))
          .toList();
    });
  }

  void deselectAccount() {
    setState(() {
      this.selectedAccount = null;
      this.disabledChampionsList = [];
    });
  }

  void addChampion(Champion champion, BuildContext context) {
    championRepository.insert(selectedAccount, champion).then((id) {
      setState(() {
        champion.id = id;
        this.selectedAccount.championList.add(champion);
        this.selectedAccount.championList.sort((a, b) => a.name.compareTo(b.name));
        this.disabledChampionsList.remove(champion);
      });
    });
  }

  void toggleChampionChest(Champion champion, BuildContext context) {
    champion.chest = !champion.chest;

    Text text = Text('Campeão ${champion.name} marcado ${champion.chest ? 'com' : 'sem'} baú.');
    SnackBar snackBar = SnackBar(
      content: text,
      duration: Duration(seconds: 3),
    );
    Scaffold.of(context).showSnackBar(snackBar);

    championRepository.update(selectedAccount, champion).then((_) {
      setState(() {
        champion = champion;
      });
    });
  }

  void onVisibilityChanged(VisibilityInfo visibilityInfo) {
    double visiblePercentage = visibilityInfo.visibleFraction * 100;

    if (visibilityInfo.key == chestAvailableKey) {
      chestAvailableVisibilityPercentage = visiblePercentage;
    } else if (visibilityInfo.key == chestObtainedKey) {
      chestObtainedVisibilityPercentage = visiblePercentage;
    } else if (visibilityInfo.key == chestDisabledKey) {
      chestDisabledVisibilityPercentage = visiblePercentage;
    }

    changeAppBarTitle();
  }

  void changeAppBarTitle() {
    String appBarTitle = "";

    var maxVisibility = max(chestAvailableVisibilityPercentage, chestObtainedVisibilityPercentage);
    maxVisibility = max(maxVisibility, chestDisabledVisibilityPercentage);

    if (maxVisibility == chestAvailableVisibilityPercentage) {
      appBarTitle = "Baús disponíveis";
    } else if (maxVisibility == chestObtainedVisibilityPercentage) {
      appBarTitle = "Baús obtidos";
    } else if (maxVisibility == chestDisabledVisibilityPercentage) {
      appBarTitle = "Baús desabilitados";
    }

    setState(() {
      this.appBarTitle = appBarTitle;
    });
  }

  Widget getSelectedAccountWidget() {
    if (selectedAccount == null) {
      return InkWell(
        onTap: () async {
          var accountScreenResult = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccountScreen()
            )
          );
          if (accountScreenResult != null) {
            var action = accountScreenResult['action'];
            var object = accountScreenResult['object'];

            if (action == 'save') {
              addAccount(object);
            }
          }
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: AccountEmptyItem(icon: Icons.edit, text: 'Adicionar conta')
        )
      );
    } else {
      return InkWell(
        onTap: () {
          showDialog(
            context: context,
            child: SimpleDialog(
              title: Text('Selecione uma conta'),
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              children: [
                for ( var account in accountList )
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 'selected_an_account');
                      selectAccount(account);
                    },
                    child: AccountItem(account: account)
                  ),
                SimpleDialogOption(
                  onPressed: () async {
                    Navigator.pop(context, 'selected_edit_accounts');
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountListScreen(
                          accountList: accountList
                        )
                      )
                    );
                    if (accountList.isEmpty) {
                      deselectAccount();
                    }
                    if (!accountList.contains(selectedAccount)) {
                      selectAccount(accountList.first);
                    }
                  },
                  child: AccountEmptyItem(icon: Icons.edit, text: 'Editar contas')
                )
              ],
            )
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: AccountItem(account: selectedAccount)
              ),
              Icon(Icons.keyboard_arrow_down),
            ],
          ),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingScreen()
                )
              );
            },
          )
        ],
      ),
      body: ListView(
        children: [
          SizedBox(height: 8),
          getSelectedAccountWidget(),
          SizedBox(height: 16),
          VisibilityDetector(
            key: chestAvailableKey,
            child: ChampionList(
              title: 'Campeões com baús disponíveis',
              championList: selectedAccount == null ? [] : selectedAccount.getChampionWithoutChest(),
              onTapItem: toggleChampionChest
            ),
            onVisibilityChanged: onVisibilityChanged,
          ),
          SizedBox(height: 16),
          VisibilityDetector(
            key: chestObtainedKey,
            child: ChampionList(
              title: 'Campeões com baús obtidos',
              championList: selectedAccount == null ? [] : selectedAccount.getChampionWithChest(),
              onTapItem: toggleChampionChest
            ),
            onVisibilityChanged: onVisibilityChanged,
          ),
          SizedBox(height: 16),
          VisibilityDetector(
            key: chestDisabledKey,
            child: ChampionList(
              title: 'Campões não obtidos',
              championList: disabledChampionsList,
              onTapItem: addChampion,
            ),
            onVisibilityChanged: onVisibilityChanged,
          ),
          SizedBox(height: 16)
        ],
      ),
    );
  }
}

List<String> ddragonChampionList = [
  "Aatrox",
  "Ahri",
  "Akali",
  "Alistar",
  "Amumu",
  "Anivia",
  "Annie",
  "Aphelios",
  "Ashe",
  "AurelionSol",
  "Azir",
  "Bard",
  "Blitzcrank",
  "Brand",
  "Braum",
  "Caitlyn",
  "Camille",
  "Cassiopeia",
  "Chogath",
  "Corki",
  "Darius",
  "Diana",
  "Draven",
  "DrMundo",
  "Ekko",
  "Elise",
  "Evelynn",
  "Ezreal",
  "Fiddlesticks",
  "Fiora",
  "Fizz",
  "Galio",
  "Gangplank",
  "Garen",
  "Gnar",
  "Gragas",
  "Graves",
  "Hecarim",
  "Heimerdinger",
  "Illaoi",
  "Irelia",
  "Ivern",
  "Janna",
  "JarvanIV",
  "Jax",
  "Jayce",
  "Jhin",
  "Jinx",
  "Kaisa",
  "Kalista",
  "Karma",
  "Karthus",
  "Kassadin",
  "Katarina",
  "Kayle",
  "Kayn",
  "Kennen",
  "Khazix",
  "Kindred",
  "Kled",
  "KogMaw",
  "Leblanc",
  "LeeSin",
  "Leona",
  "Lillia",
  "Lissandra",
  "Lucian",
  "Lulu",
  "Lux",
  "Malphite",
  "Malzahar",
  "Maokai",
  "MasterYi",
  "MissFortune",
  "MonkeyKing",
  "Mordekaiser",
  "Morgana",
  "Nami",
  "Nasus",
  "Nautilus",
  "Neeko",
  "Nidalee",
  "Nocturne",
  "Nunu",
  "Olaf",
  "Orianna",
  "Ornn",
  "Pantheon",
  "Poppy",
  "Pyke",
  "Qiyana",
  "Quinn",
  "Rakan",
  "Rammus",
  "RekSai",
  "Renekton",
  "Rengar",
  "Riven",
  "Rumble",
  "Ryze",
  "Samira",
  "Sejuani",
  "Senna",
  "Seraphine",
  "Sett",
  "Shaco",
  "Shen",
  "Shyvana",
  "Singed",
  "Sion",
  "Sivir",
  "Skarner",
  "Sona",
  "Soraka",
  "Swain",
  "Sylas",
  "Syndra",
  "TahmKench",
  "Taliyah",
  "Talon",
  "Taric",
  "Teemo",
  "Thresh",
  "Tristana",
  "Trundle",
  "Tryndamere",
  "TwistedFate",
  "Twitch",
  "Udyr",
  "Urgot",
  "Varus",
  "Vayne",
  "Veigar",
  "Velkoz",
  "Vi",
  "Viktor",
  "Vladimir",
  "Volibear",
  "Warwick",
  "Xayah",
  "Xerath",
  "XinZhao",
  "Yasuo",
  "Yone",
  "Yorick",
  "Yuumi",
  "Zac",
  "Zed",
  "Ziggs",
  "Zilean",
  "Zoe",
  "Zyra",
];
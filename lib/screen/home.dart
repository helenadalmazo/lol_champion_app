import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lol_champion_app/database/account_repository.dart';
import 'package:lol_champion_app/database/champion_repository.dart';
import 'package:lol_champion_app/model/account.dart';
import 'package:lol_champion_app/model/champion.dart';
import 'package:lol_champion_app/screen/account.dart';
import 'package:lol_champion_app/screen/account_list.dart';
import 'package:lol_champion_app/screen/champion_list.dart';
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
  AccountRepository accountRepository = AccountRepository();
  ChampionRepository championRepository = ChampionRepository();

  List<Account> accountList = [];
  Account selectedAccount = null;

  String appBarTitle = "";

  Key chestAvailableKey = Key('chest_available');
  Key chestObtainedKey = Key('chest_obtained');

  double chestAvailableVisibilityPercentage = 0;
  double chestObtainedVisibilityPercentage = 0;

  _HomeScreenState() {
    listAccounts();
  }

  void listAccounts() {
    accountRepository.list().then((List<Account> accountList) {
      setState(() {
        this.accountList = accountList;
      });
      if (accountList.isEmpty) {
        deselectAccount();
      } else if (!accountList.contains(selectedAccount)) {
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
    });
  }

  void deselectAccount() {
    setState(() {
      this.selectedAccount = null;
    });
  }

  void showChampionBottomSheet(Champion champion, BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
        builder: (BuildContext context) {
          return Container(
            child: Wrap(
              children: [
                ListTile(
                  onTap: () {
                    deleteChampion(champion);
                    Navigator.pop(context);
                  },
                  leading: Icon(Icons.delete),
                  title: Text('Remover campeão'),
                ),
              ],
            ),
          );
        }
    );
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

  void deleteChampion(Champion champion) {
    championRepository.delete(selectedAccount, champion).then((value) {
      if (value > 0) {
        setState(() {
          selectedAccount.championList.remove(champion);
          selectedAccount.championList.sort((a, b) => a.name.compareTo(b.name));
        });
      }
    });
  }

  void onVisibilityChanged(VisibilityInfo visibilityInfo) {
    double visiblePercentage = visibilityInfo.visibleFraction * 100;

    if (visibilityInfo.key == chestAvailableKey) {
      chestAvailableVisibilityPercentage = visiblePercentage;
    } else if (visibilityInfo.key == chestObtainedKey) {
      chestObtainedVisibilityPercentage = visiblePercentage;
    }

    changeAppBarTitle();
  }

  void changeAppBarTitle() {
    String appBarTitle = "";

    var maxVisibility = max(chestAvailableVisibilityPercentage, chestObtainedVisibilityPercentage);

    if (maxVisibility == chestAvailableVisibilityPercentage) {
      appBarTitle = "Baús disponíveis";
    } else if (maxVisibility == chestObtainedVisibilityPercentage) {
      appBarTitle = "Baús obtidos";
    }

    setState(() {
      this.appBarTitle = appBarTitle;
    });
  }

  IconData getIcon(Champion champion) {
    return champion.chest ? Icons.check : Icons.close;
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
                    listAccounts();
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

  Widget getFab(BuildContext context) {
    if (selectedAccount == null) {
      return Container();
    } else {
      return FloatingActionButton(
        onPressed: () async {
          var addedChampionResult = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChampionListScreen(account: selectedAccount)
            )
          );
          if (addedChampionResult != null) {
            selectedAccount.championList.addAll(addedChampionResult);
            selectedAccount.championList.sort((a, b) => a.name.compareTo(b.name));
          }
        },
        child: Icon(Icons.add),
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
              getIcon: getIcon,
              onTapItem: toggleChampionChest,
              onLongPressItem: showChampionBottomSheet
            ),
            onVisibilityChanged: onVisibilityChanged,
          ),
          SizedBox(height: 16),
          VisibilityDetector(
            key: chestObtainedKey,
            child: ChampionList(
              title: 'Campeões com baús obtidos',
              championList: selectedAccount == null ? [] : selectedAccount.getChampionWithChest(),
              getIcon: getIcon,
              onTapItem: toggleChampionChest,
              onLongPressItem: showChampionBottomSheet
            ),
            onVisibilityChanged: onVisibilityChanged,
          ),
          SizedBox(height: 16)
        ],
      ),
      floatingActionButton: getFab(context)
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
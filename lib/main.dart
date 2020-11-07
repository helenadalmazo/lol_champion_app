import 'dart:convert';
import 'dart:math';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'database/account_repository.dart';
import 'database/champion_repository.dart';
import 'model/account.dart';
import 'model/champion.dart';

void main() => runApp(LolChampionApp());

class LolChampionApp extends StatelessWidget {@override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lol Champion App',
      theme: ThemeData(
          primaryColor: Color.fromRGBO(6, 28, 37, 1),
//        primaryColorLight: Color.fromRGBO(46, 67, 77, 1),
//        primaryColorDark: Color.fromRGBO(0, 0, 0, 1),

          accentColor: Color.fromRGBO(194, 143, 44, 1),

          appBarTheme: AppBarTheme(
            brightness: Brightness.light,
          ),

          brightness: Brightness.light,

          textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.black87
          )
      ),
      darkTheme: ThemeData(
          primaryColor: Color.fromRGBO(6, 28, 37, 1),
//        primaryColorLight: Color.fromRGBO(46, 67, 77, 1),
//        primaryColorDark: Color.fromRGBO(0, 0, 0, 1),

          accentColor: Color.fromRGBO(194, 143, 44, 1),

          toggleableActiveColor: Color.fromRGBO(194, 143, 44, 1),

          appBarTheme: AppBarTheme(
            color: Color.fromRGBO(25, 25, 25, 1),
          ),

          brightness: Brightness.dark,

          textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.white
          )
      ),
      themeMode: ThemeMode.light,
      home: HomeScreen(),
    );
  }
}

class AccountListItem extends StatelessWidget {
  final Account account;

  const AccountListItem({Key key, this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'images/account/${account.imageId}.png',
          height: 56,
          width: 56,
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              account.name,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Text(
              '${account.getChampionWithoutChestCount()} baús disponíveis'
            )
          ],
        ),
      ],
    );
  }
}

class ChampionListItem extends StatelessWidget {
  final Champion champion;
  final Function onTap;

  const ChampionListItem({Key key, this.champion, this.onTap}) : super(key: key);

  IconData getIcon() {
    if (champion.id == null) {
      return Icons.lock_outline;
    }

    return champion.chest ? Icons.check : Icons.close;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          onTap(champion, context);
        },
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Image.asset(
                    'images/champion/${champion.name}_0.jpg',
                    fit: BoxFit.contain,
                  ),
                  Positioned(
                    top: -8,
                    right: -8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).accentColor,
                        shape: BoxShape.circle
                      ),
                      width: 32,
                      height: 32,
                      child: Icon(
                        getIcon(),
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor
                  ),
                  child: Text(
                    champion.name,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                ),
              )
            ]
        )
    );
  }
}

class ChampionList extends StatelessWidget {
  final String title;
  final List<Champion> championList;
  final Function onTapItem;

  const ChampionList({Key key, this.title, this.championList, this.onTapItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headline6
          ),
          SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 3/4,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              for (var champion in championList)
                ChampionListItem(
                  champion: champion,
                  onTap: onTapItem
                )
            ]
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
//  AccountRepository accountRepository = AccountRepository();
//  ChampionRepository championRepository = ChampionRepository();
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

//  was used with FAB
//  void addChampion(Champion champion) {
//    championRepository.insert(selectedAccount, champion).then((_) {
//      setState(() {
//        this.selectedAccount.championList.add(champion);
//      });
//    });
//  }

    void addChampion(Champion champion, BuildContext context) {
    champion.chest = false;
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
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 10, 19, 1)
                ),
                child: Icon(
                  Icons.edit,
                  size: 32,
                  color: Color.fromRGBO(52, 57, 60, 1),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Adicionar conta',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            ],
          ),
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
                    child: AccountListItem(account: account)
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
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(0, 10, 19, 1)
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 32,
                          color: Color.fromRGBO(52, 57, 60, 1),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Editar contas',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                    ],
                  ),
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
                  child: AccountListItem(account: selectedAccount)
              ),
              Icon(Icons.keyboard_arrow_down),
            ],
          ),
        )
      );
    }
  }

  Widget getFAB() {
    if (selectedAccount == null) {
      return Container();
    } else {
      return FloatingActionButton(
        onPressed: () async {
          List<String> existingChampionNameList = selectedAccount.championList.map((champ) => champ.name).toList();
          var championResult = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChampionScreen(existingChampionNameList: existingChampionNameList)
            )
          );
          if (championResult != null) {
            addChampion(championResult, null);
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
//      floatingActionButton: getFAB()
    );
  }
}

class AccountListScreen extends StatefulWidget {
  final List<Account> accountList;

  const AccountListScreen({Key key, this.accountList}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AccountListScreenState(accountList);
  }
}

class _AccountListScreenState extends State<StatefulWidget> {
  final List<Account> accountList;

  _AccountListScreenState(this.accountList);

  AccountRepository accountRepository = AccountRepository();

  void add(Account account) {
    accountRepository.insert(account).then((id) {
      setState(() {
        account.id = id;
        accountList.add(account);
      });
    });
  }

  void updateAt(int index, Account account) {
    accountRepository.update(account).then((_) {
      setState(() {
        accountList[index] = account;
      });
    });
  }

  void removeAt(int index, Account account) {
    accountRepository.delete(account.id).then((_) {
      setState(() {
        accountList.removeAt(index);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Contas'),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              tooltip: 'Novo',
              onPressed: () async {
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
                    add(object);
                  }
                }
              },
            )
          ],
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(vertical: 8),
          children: [
            for (var index = 0; index < accountList.length; index ++)
              InkWell(
                onTap: () async {
                  var accountScreenResult = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountScreen(
                        index: index,
                        account: accountList[index]
                      )
                    )
                  );

                  if (accountScreenResult != null) {
                    var action = accountScreenResult['action'];
                    var object = accountScreenResult['object'];

                    if (action == 'save') {
                      updateAt(index, object);
                    } else if (action == 'delete') {
                      removeAt(index, object);
                    }
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'account_image_$index',
                        child: Image.asset(
                          'images/account/${accountList[index].imageId}.png',
                          height: 128,
                          width: 128,
                        ),
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            accountList[index].name,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Text(
                            '${accountList[index].championList.length} campeões'
                          ),
                          Text(
                            '${accountList[index].getChampionWithChestCount()} campeões com baús'
                          ),
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyText2,
                              children: <TextSpan>[
                                TextSpan(text: '${accountList[index].getChampionWithoutChestCount()} campeões'),
                                TextSpan(text: ' sem', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: ' baús'),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              )
          ],
        )
    );
  }
}

class AccountScreen extends StatefulWidget {
  final int index;
  final Account account;

  const AccountScreen({Key key, this.index, this.account}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AccountScreenState(index, account);
  }
}

class _AccountScreenState extends State<StatefulWidget> {
  final int index;
  Account account;

  _AccountScreenState(this.index, this.account);

  TextEditingController nameTextEditingController = TextEditingController();

  Widget getImageWidget() {
    if (index == null) {
      return Image.asset(
        'images/account/${account.imageId}.png',
        height: 170,
        width: 170,
        fit: BoxFit.contain,
      );
    } else {
      return Hero(
        tag: 'account_image_$index',
        child: Image.asset(
          'images/account/${account.imageId}.png',
          height: 170,
          width: 170,
          fit: BoxFit.contain,
        ),
      );
    }
  }

  setImage(int imageId) {
    setState(() {
      account.imageId = imageId;
    });
  }

  @override
  void initState() {
    if (index == null) {
      account = Account.empty();
    }
    nameTextEditingController.text = account.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text((index == null) ? 'Nova conta' : 'Editar conta'),
          actions: [
            if (index != null)
              IconButton(
                icon: Icon(Icons.delete),
                tooltip: 'Remover',
                onPressed: () async {
                  var confirmResult = await showDialog(
                    context: context,
                    child: AlertDialog(
                      title: Text('Excluir conta'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text('Você quer realmente excluir essa conta?'),
                            Text('Essa ação não pode ser desfeita.'),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text('Não'),
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                        ),
                        TextButton(
                          child: Text('Sim'),
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                        ),
                      ],
                    )
                  );

                  if (confirmResult != null && confirmResult) {
                    Navigator.pop(context, {
                      'action': 'delete',
                      'object': account
                    });
                  }
                },
              ),
            IconButton(
              icon: Icon(Icons.check),
              tooltip: 'Salvar',
              onPressed: () {
                account.name = nameTextEditingController.text;
                Navigator.pop(context, {
                  'action': 'save',
                  'object': account
                });
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              InkWell(
                onTap: () async {
                  var imageIdResult = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AccountImagesScreen())
                  );
                  if (imageIdResult != null) {
                    setImage(imageIdResult);
                  }
                },
                child: getImageWidget()
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: nameTextEditingController,
                  style: Theme.of(context).textTheme.headline6,
                  textAlign: TextAlign.center,
                ),
              )
            ],
          )
        ),
    );
  }
}

class AccountImagesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AccountImagesStateScreen();
  }
}

class _AccountImagesStateScreen extends State<StatefulWidget> {
  int imageCount = 0;

  void getImages(BuildContext context) async {
    final manifestJson = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    setState(() {
      imageCount = json
          .decode(manifestJson)
          .keys
          .where((String key) => key.startsWith('images/account'))
          .length;
    });
  }

  @override
  Widget build(BuildContext context) {
    getImages(context);

    return Scaffold(
        body: GridView.extent(
          maxCrossAxisExtent: 128,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: [
            for ( var i = 1; i < imageCount + 1; i ++ )
              GestureDetector(
                onTap: () {
                  Navigator.pop(context, i);
                },
                child: Image.asset(
                    'images/account/${i}.png'
                )
              )
          ],
        )
    );
  }
}

class ChampionScreen extends StatefulWidget {
  final List<String> existingChampionNameList;

  const ChampionScreen({Key key, this.existingChampionNameList}) : super(key: key);
  
  @override
  _ChampionScreenState createState() {
    return _ChampionScreenState(existingChampionNameList);
  }
}

class _ChampionScreenState extends State<ChampionScreen> {
  Champion champion;
  List<String> existingChampionNameList;

  _ChampionScreenState(this.existingChampionNameList);

  void selectChampion(String text) {
    setState(() {
      champion.name = ddragonChampionList.firstWhere((element) => element == text);
    });
  }

  void setChampionChest(bool bool) {
    setState(() {
      champion.chest = bool;
    });
  }

  @override
  void initState() {
    if (champion == null) {
      champion = Champion.empty();
    }
    super.initState();
  }

  List<String> getSuggestions() {
    return ddragonChampionList.where((string) => !existingChampionNameList.contains(string)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text((champion.name != null) ? champion.name : 'Novo campeão' ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.check,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, champion);
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            margin: EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Container(
                  child: AutoCompleteTextField<String>(
                      decoration: InputDecoration(
                          hintText: "Procurar por nome do campeão"
                      ),
                      suggestions: getSuggestions(),
                      itemFilter:(suggestion, query) {
                        return suggestion.toLowerCase().startsWith(query.toLowerCase());
                      },
                      itemSubmitted: (item) {
                        selectChampion(item);
                      },
                      itemBuilder: (context, item) {
                        return Container(
                          padding: EdgeInsets.all(16),
                          child: Text(
                              item
                          ),
                        );
                      }
                  ),
                ),
                if ( champion.name != null )
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'images/champion/${champion.name}_0.jpg',
                        ),
                        Row(
                          children: [
                            Checkbox(
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              value: champion.chest,
                              onChanged: setChampionChest
                            ),
                            Text('Já tem baú?')
                          ],
                        )
                      ]
                  )
              ],
            ),
          ),
        )
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

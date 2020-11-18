import 'package:flutter/material.dart';
import 'package:lol_champion_app/database/account_repository.dart';
import 'package:lol_champion_app/model/account.dart';
import 'package:lol_champion_app/screen/account.dart';

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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.asset(
                          'images/account/${accountList[index].imageId}.png',
                          height: 128,
                          width: 128,
                        ),
                      )
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
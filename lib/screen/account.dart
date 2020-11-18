import 'package:flutter/material.dart';
import 'package:lol_champion_app/model/account.dart';
import 'package:lol_champion_app/screen/account_image_list.dart';

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
  String nameTextValidation;

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

  bool validateName() {
    if (nameTextEditingController.text == null
        || nameTextEditingController.text.isEmpty) {
      nameTextValidation = 'Campo obrigatório';
      return false;
    }

    nameTextValidation = null;
    return true;
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
              var validateResult = validateName();
              if (!validateResult) {
                setState(() { });
                return;
              }

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
                    MaterialPageRoute(builder: (context) => AccountImageListScreen())
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
                  decoration: InputDecoration(
                    errorText: nameTextValidation
                  ),
                ),
              )
            ],
          )
      ),
    );
  }
}
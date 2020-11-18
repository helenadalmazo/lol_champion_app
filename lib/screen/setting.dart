import 'package:flutter/material.dart';
import 'package:lol_champion_app/main.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _SettingScreenState();
  }
}

class _SettingScreenState extends State<StatefulWidget> {
  AppNotifier appNotifier;

  @override
  Widget build(BuildContext context) {
    appNotifier = Provider.of<AppNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          margin: EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tema',
                style: Theme.of(context).textTheme.headline6,
              ),
              Row(
                children: [
                  Radio(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: ThemeMode.light,
                    groupValue: appNotifier.themeMode,
                    onChanged: (ThemeMode themeMode) {
                      appNotifier.themeMode = themeMode;
                    },
                  ),
                  Text(
                    'Claro'
                  )
                ],
              ),
              Row(
                children: [
                  Radio(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: ThemeMode.dark,
                    groupValue: appNotifier.themeMode,
                    onChanged: (ThemeMode themeMode) {
                      appNotifier.themeMode = themeMode;
                    },
                  ),
                  Text(
                    'Escuro'
                  )
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}
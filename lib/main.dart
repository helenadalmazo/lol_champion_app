import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lol_champion_app/screen/home.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppNotifier with ChangeNotifier {
  final SharedPreferences sharedPreferences;
  final String THEME_MODE_KEY = 'theme_mode';

  ThemeMode _themeMode;

  AppNotifier(this.sharedPreferences) {
    initThemeMode();
  }

  initThemeMode() {
    var themeModePref = sharedPreferences.getString(THEME_MODE_KEY) ?? 'light';
    _themeMode = themeModePref == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode value) {
    _themeMode = value;
    notifyListeners();

    var themeModePref = _themeMode == ThemeMode.dark ? 'dark' : 'light';
    sharedPreferences.setString(THEME_MODE_KEY, themeModePref);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Future<SharedPreferences> sharedPreferences = SharedPreferences.getInstance();
  sharedPreferences.then((value) {
    runApp(
      ChangeNotifierProvider(
        create: (context) => AppNotifier(value),
        child: LolChampionApp(),
      ),
    );
  });
}

class LolChampionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appNotifier = Provider.of<AppNotifier>(context);

    return MaterialApp(
      title: 'Lol Champion App',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(6, 28, 37, 1),
//        primaryColorLight: Color.fromRGBO(46, 67, 77, 1),
//        primaryColorDark: Color.fromRGBO(0, 0, 0, 1),

        accentColor: Color.fromRGBO(194, 143, 44, 1),

        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primaryColor: Color.fromRGBO(6, 28, 37, 1),

        accentColor: Color.fromRGBO(194, 143, 44, 1),

        toggleableActiveColor: Color.fromRGBO(194, 143, 44, 1),

        brightness: Brightness.dark,
      ),
      themeMode: appNotifier.themeMode,
      home: HomeScreen(),
    );
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';

class AccountImageListScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AccountImageListStateScreen();
  }
}

class _AccountImageListStateScreen extends State<StatefulWidget> {
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
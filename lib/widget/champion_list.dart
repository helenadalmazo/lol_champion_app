import 'package:flutter/material.dart';
import 'package:lol_champion_app/model/champion.dart';

class ChampionList extends StatelessWidget {
  final String title;
  final List<Champion> championList;
  final Function getIcon;
  final Function onTapItem;
  final Function onLongPressItem;

  const ChampionList({
    Key key,
    this.title,
    this.championList,
    this.getIcon,
    this.onTapItem,
    this.onLongPressItem
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title,
              style: Theme.of(context).textTheme.headline6
            ),
          if (title != null)
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
                  getIcon: getIcon,
                  onTap: onTapItem,
                  onLongPress: onLongPressItem
                )
            ]
          ),
        ],
      ),
    );
  }
}

class ChampionListItem extends StatelessWidget {
  final Champion champion;
  final Function getIcon;
  final Function onTap;
  final Function onLongPress;

  const ChampionListItem({
    Key key,
    this.champion,
    this.getIcon,
    this.onTap,
    this.onLongPress
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap == null) return;
        onTap(champion, context);
      },
      onLongPress: () {
        if (onLongPress == null) return;
        onLongPress(champion, context);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
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
                      getIcon(champion),
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
      )
    );
  }
}
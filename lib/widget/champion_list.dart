import 'package:flutter/material.dart';
import 'package:lol_champion_app/model/champion.dart';

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
      )
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lol_champion_app/model/account.dart';

class AccountItem extends StatelessWidget {
  final Account account;

  const AccountItem({Key key, this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Image.asset(
            'images/account/${account.imageId}.png',
            height: 56,
            width: 56,
          ),
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
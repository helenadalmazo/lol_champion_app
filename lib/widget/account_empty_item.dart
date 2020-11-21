import 'package:flutter/material.dart';

class AccountEmptyItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const AccountEmptyItem({Key key, this.icon, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32.0),
            color: Color.fromRGBO(0, 10, 19, 1)
          ),
          child: Icon(
            icon,
            size: 32,
            color: Color.fromRGBO(52, 57, 60, 1),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      ],
    );
  }
}
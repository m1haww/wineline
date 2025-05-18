import 'package:flutter/material.dart';

Widget buildtext(BuildContext context, String text) {
  return Text(
    text,
    maxLines: 3,
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
  );
}

Widget buildsubttext(BuildContext context, String text) {
  return Text(
    text,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w300,
      color: Colors.white,
    ),
  );
}

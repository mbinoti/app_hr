import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void pushAdaptive(BuildContext context, Widget page, bool cupertino) {
  Navigator.of(context).push(
    cupertino
        ? CupertinoPageRoute(builder: (_) => page)
        : MaterialPageRoute(builder: (_) => page),
  );
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class HrPage extends StatelessWidget {
  const HrPage({
    super.key,
    required this.useCupertino,
    required this.title,
    required this.child,
    this.leading,
    this.trailing,
  });

  final bool useCupertino;
  final String title;
  final Widget child;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    if (useCupertino) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
          leading: leading,
          trailing: trailing,
          border: const Border(bottom: BorderSide(color: AppColors.line)),
          backgroundColor: Colors.white,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                top: kMinInteractiveDimensionCupertino,
              ),
              child: child,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        leading: leading == null
            ? null
            : IconButton(onPressed: () {}, icon: leading!),
        actions: trailing == null
            ? null
            : [IconButton(onPressed: () {}, icon: trailing!)],
      ),
      body: SafeArea(top: false, child: child),
    );
  }
}

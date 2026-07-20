import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdaptiveProgress extends StatelessWidget {
  const AdaptiveProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return defaultTargetPlatform == TargetPlatform.iOS
        ? const CupertinoActivityIndicator()
        : const CircularProgressIndicator();
  }
}

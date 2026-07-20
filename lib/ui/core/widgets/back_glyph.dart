import 'package:flutter/cupertino.dart';

class BackGlyph extends StatelessWidget {
  const BackGlyph({super.key, required this.useCupertino});

  final bool useCupertino;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: const Icon(CupertinoIcons.back),
    );
  }
}

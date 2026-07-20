import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repositories/hr_repository.dart';
import '../firebase/firebase_bootstrap.dart';
import '../ui/core/theme/app_colors.dart';
import '../ui/features/shell/hr_shell.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.firebaseStatus});

  final FirebaseBootstrapStatus firebaseStatus;

  @override
  Widget build(BuildContext context) {
    final platform = defaultTargetPlatform;
    final isIos =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    return MultiProvider(
      providers: [
        Provider<FirebaseBootstrapStatus>.value(value: firebaseStatus),
        Provider<HrRepository>(create: (_) => FirestoreHrRepository()),
      ],
      child: isIos
          ? CupertinoApp(
              debugShowCheckedModeBanner: false,
              title: 'HR Explorer',
              localizationsDelegates: const [
                DefaultMaterialLocalizations.delegate,
                DefaultCupertinoLocalizations.delegate,
                DefaultWidgetsLocalizations.delegate,
              ],
              theme: const CupertinoThemeData(
                brightness: Brightness.light,
                primaryColor: AppColors.brand,
                scaffoldBackgroundColor: AppColors.pageBg,
                barBackgroundColor: CupertinoColors.systemBackground,
                textTheme: CupertinoTextThemeData(
                  textStyle: TextStyle(
                    fontFamily: '.SF Pro Text',
                    color: AppColors.ink,
                    fontSize: 15,
                  ),
                ),
              ),
              home: const HrShell(useCupertino: true),
            )
          : MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'HR Explorer',
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.brand,
                  brightness: Brightness.light,
                  primary: AppColors.brand,
                  secondary: AppColors.mint,
                  tertiary: AppColors.rose,
                  surface: const Color(0xFFFEFBFF),
                ),
                scaffoldBackgroundColor: AppColors.pageBg,
                cardTheme: CardThemeData(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: Colors.black.withValues(alpha: .06),
                    ),
                  ),
                ),
              ),
              home: const HrShell(useCupertino: false),
            ),
    );
  }
}

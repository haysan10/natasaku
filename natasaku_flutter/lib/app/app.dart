import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class NataSakuApp extends StatelessWidget {
  const NataSakuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NataSaku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRouter.launch,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:muvees/core/models/app_tab.dart';
import 'package:muvees/ui/pages/main_shell.dart';

class MyHomePageParams {
  const MyHomePageParams({
    this.title = '',
    this.isDeepLink = false,
    this.initialTab = AppTab.movies,
  });

  final String title;
  final bool isDeepLink;
  final AppTab initialTab;
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({required this.params, super.key});

  final MyHomePageParams params;

  @override
  Widget build(BuildContext context) {
    return MainShell(initialTab: params.initialTab);
  }
}

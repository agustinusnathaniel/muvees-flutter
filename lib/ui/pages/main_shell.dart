import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muvees/core/models/app_tab.dart';
import 'package:muvees/core/page_models/watchlist_page_model.dart';
import 'package:muvees/ui/pages/movies_page.dart';
import 'package:muvees/ui/pages/search_page.dart';
import 'package:muvees/ui/pages/tv_shows_page.dart';
import 'package:muvees/ui/pages/watchlist_page.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({this.initialTab = AppTab.movies, super.key});

  final AppTab initialTab;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  late AppTab _currentTab;

  // Cache pages to preserve state
  final Map<AppTab, Widget> _pages = {};

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  Widget _getPage(AppTab tab) {
    if (_pages[tab] != null) {
      return _pages[tab]!;
    }

    final Widget page;
    switch (tab) {
      case AppTab.movies:
        page = const MoviesPage();
      case AppTab.tvShows:
        page = const TvShowsPage();
      case AppTab.search:
        page = const SearchPage();
      case AppTab.watchlist:
        page = const WatchlistPage();
    }

    _pages[tab] = page;
    return page;
  }

  void _onTabSelected(AppTab tab) {
    // Refresh watchlist when switching to that tab
    if (tab == AppTab.watchlist) {
      ref.read(watchlistPageModel.notifier).refreshWatchList();
    }

    setState(() {
      _currentTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: AppTab.values.indexOf(_currentTab),
        children: AppTab.values.map(_getPage).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: AppTab.values.indexOf(_currentTab),
        onDestinationSelected: (int index) {
          _onTabSelected(AppTab.values[index]);
        },
        destinations: AppTab.values.map((AppTab tab) {
          return NavigationDestination(
            icon: Icon(_getIcon(tab)),
            label: tab.label,
          );
        }).toList(),
      ),
    );
  }

  IconData _getIcon(AppTab tab) {
    switch (tab) {
      case AppTab.movies:
        return Icons.movie_outlined;
      case AppTab.tvShows:
        return Icons.tv_outlined;
      case AppTab.search:
        return Icons.search_outlined;
      case AppTab.watchlist:
        return Icons.bookmark_outline;
    }
  }
}

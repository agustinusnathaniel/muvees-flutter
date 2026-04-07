enum AppTab {
  movies('movies'),
  tvShows('tv_shows'),
  search('search'),
  watchlist('watchlist');

  const AppTab(this.key);
  final String key;

  String get label {
    switch (this) {
      case AppTab.movies:
        return 'Movies';
      case AppTab.tvShows:
        return 'TV Shows';
      case AppTab.search:
        return 'Search';
      case AppTab.watchlist:
        return 'Watchlist';
    }
  }
}

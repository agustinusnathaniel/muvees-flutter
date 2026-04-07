import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muvees/core/models/watchlist_item.dart';
import 'package:muvees/core/page_models/page_model.dart';
import 'package:muvees/core/services/watchlist_service.dart';

final NotifierProvider<WatchlistPageModel, WatchlistPageState>
watchlistPageModel = NotifierProvider<WatchlistPageModel, WatchlistPageState>(
  () {
    return WatchlistPageModel();
  },
);

class WatchlistPageState {
  const WatchlistPageState({
    this.items = const <WatchlistItem>[],
    this.isLoading = false,
  });

  final List<WatchlistItem> items;
  final bool isLoading;

  WatchlistPageState copyWith({List<WatchlistItem>? items, bool? isLoading}) {
    return WatchlistPageState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WatchlistPageModel extends PageStateNotifier<WatchlistPageState> {
  WatchlistPageModel();

  @override
  WatchlistPageState build() {
    return const WatchlistPageState();
  }

  @override
  Future<void> initPageModel() async {
    state = state.copyWith(isLoading: true);
    await _loadWatchlist();
    state = state.copyWith(isLoading: false);
  }

  Future<void> _loadWatchlist() async {
    final List<WatchlistItem> items = await WatchlistService.getWatchlist();
    state = state.copyWith(items: items);
  }

  Future<void> refreshWatchList() async {
    state = state.copyWith(isLoading: true);
    await _loadWatchlist();
    state = state.copyWith(isLoading: false);
  }
}

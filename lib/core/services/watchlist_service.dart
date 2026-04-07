import 'dart:convert';

import 'package:muvees/core/models/watchlist_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WatchlistService {
  WatchlistService._();

  static const String _watchlistKey = 'muvees_watchlist';

  static Future<List<WatchlistItem>> getWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_watchlistKey);
    if (jsonString == null) {
      return <WatchlistItem>[];
    }

    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((dynamic json) =>
            WatchlistItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Future<void> addToWatchlist(WatchlistItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<WatchlistItem> watchlist = await getWatchlist();

    // Don't add duplicates
    final bool exists = watchlist.any(
      (WatchlistItem existing) =>
          existing.id == item.id && existing.type == item.type,
    );
    if (exists) {
      return;
    }

    watchlist.add(item);
    await prefs.setString(
      _watchlistKey,
      json.encode(watchlist.map((WatchlistItem i) => i.toJson()).toList()),
    );
  }

  static Future<void> removeFromWatchlist({
    required int id,
    required String type,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final List<WatchlistItem> watchlist = await getWatchlist();

    watchlist.removeWhere(
      (WatchlistItem item) => item.id == id && item.type == type,
    );

    await prefs.setString(
      _watchlistKey,
      json.encode(watchlist.map((WatchlistItem i) => i.toJson()).toList()),
    );
  }

  static Future<bool> isInWatchlist({
    required int id,
    required String type,
  }) async {
    final List<WatchlistItem> watchlist = await getWatchlist();
    return watchlist.any(
      (WatchlistItem item) => item.id == id && item.type == type,
    );
  }

  static Stream<List<WatchlistItem>> watchlistStream() async* {
    while (true) {
      yield await getWatchlist();
      await Future<void>.delayed(const Duration(seconds: 1));
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muvees/core/services/api/tmdb/search_api.dart';
import 'package:muvees/core/services/api/tmdb/tmdb_fetcher.dart';

final Provider<SearchApi> searchApiProvider = Provider<SearchApi>((Ref ref) {
  return SearchApi(tmdbFetcher);
});

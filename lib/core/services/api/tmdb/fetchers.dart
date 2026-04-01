import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muvees/core/services/api/tmdb/movie_api.dart';
import 'package:muvees/core/services/api/tmdb/tmdb_fetcher.dart';

final movieApiProvider = Provider<MovieApi>((ref) {
  return MovieApi(tmdbFetcher);
});

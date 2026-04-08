import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muvees/core/services/api/tmdb/movie_api.dart';
import 'package:muvees/core/services/api/tmdb/tmdb_fetcher.dart';

final Provider<MovieApi> movieApiProvider = Provider<MovieApi>((Ref ref) {
  return MovieApi(tmdbFetcher);
});

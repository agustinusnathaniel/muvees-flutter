import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muvees/core/services/api/tmdb/tv_api.dart';
import 'package:muvees/core/services/api/tmdb/tmdb_fetcher.dart';

final Provider<TvApi> tvApiProvider = Provider<TvApi>((Ref ref) {
  return TvApi(tmdbFetcher);
});

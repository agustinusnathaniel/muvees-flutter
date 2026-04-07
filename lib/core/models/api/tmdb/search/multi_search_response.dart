import 'package:json_annotation/json_annotation.dart';

part 'multi_search_response.g.dart';

@JsonSerializable(includeIfNull: false)
class MultiSearchParams {
  MultiSearchParams({
    this.language,
    this.page,
    required this.query,
  });

  factory MultiSearchParams.fromJson(Map<String, dynamic> json) =>
      _$MultiSearchParamsFromJson(json);

  String? language;
  int? page;
  String query;

  Map<String, dynamic> toJson() => _$MultiSearchParamsToJson(this);
}

@JsonSerializable()
class MultiSearchResponse {
  MultiSearchResponse({
    required this.page,
    required this.totalResults,
    required this.totalPages,
    required this.results,
  });

  factory MultiSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$MultiSearchResponseFromJson(json);

  final int page;
  @JsonKey(name: 'total_results')
  final int totalResults;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  final List<MultiSearchResult> results;

  Map<String, dynamic> toJson() => _$MultiSearchResponseToJson(this);
}

@JsonSerializable()
class MultiSearchResult {
  const MultiSearchResult({
    required this.id,
    required this.mediaType,
    this.title,
    this.name,
    this.posterPath,
    this.backdropPath,
    this.overview = '',
    this.voteAverage = 0,
    this.releaseDate,
    this.firstAirDate,
    this.genreIds = const <int>[],
    this.adult = false,
    this.originalLanguage = '',
    this.popularity = 0,
    this.voteCount = 0,
  });

  factory MultiSearchResult.fromJson(Map<String, dynamic> json) =>
      _$MultiSearchResultFromJson(json);

  final int id;
  @JsonKey(name: 'media_type')
  final String mediaType; // 'movie' or 'tv'
  final String? title;
  final String? name;
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;
  final String overview;
  @JsonKey(name: 'vote_average')
  final double voteAverage;
  @JsonKey(name: 'release_date')
  final String? releaseDate;
  @JsonKey(name: 'first_air_date')
  final String? firstAirDate;
  @JsonKey(name: 'genre_ids')
  final List<int> genreIds;
  final bool adult;
  @JsonKey(name: 'original_language')
  final String originalLanguage;
  final double popularity;
  @JsonKey(name: 'vote_count')
  final int voteCount;

  String get displayName => title ?? name ?? 'Unknown';

  String? get date => releaseDate ?? firstAirDate;

  Map<String, dynamic> toJson() => _$MultiSearchResultToJson(this);
}

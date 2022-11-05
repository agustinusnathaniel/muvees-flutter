import 'package:json_annotation/json_annotation.dart';
import 'package:muvees/core/models/api/tmdb/tmdb_list_response.dart';

part 'movie_list.g.dart';

@JsonSerializable(includeIfNull: false)
class MovieListParams {
  MovieListParams({
    this.language,
    this.page,
    this.query,
    this.withGenres,
  });

  factory MovieListParams.fromJson(Map<String, dynamic> json) =>
      _$MovieListParamsFromJson(json);

  String? language;
  int? page;
  String? query;
  @JsonKey(name: 'with_genres')
  List<String>? withGenres;

  Map<String, dynamic> toJson() => _$MovieListParamsToJson(this);
}

@JsonSerializable()
class MovieListResponse extends TmdbListResponse {
  MovieListResponse({
    required int page,
    required int totalResults,
    required int totalPages,
    required this.results,
  }) : super(
          page: page,
          totalResults: totalResults,
          totalPages: totalPages,
        );

  factory MovieListResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieListResponseFromJson(json);

  final List<MovieListItemType> results;

  @override
  Map<String, dynamic> toJson() => _$MovieListResponseToJson(this);
}

@JsonSerializable()
class MovieListItemType {
  const MovieListItemType({
    required this.releaseDate,
    required this.id,
    required this.popularity,
    this.posterPath,
    this.adult = false,
    this.overview = '',
    this.genreIDs = const <int>[],
    this.originalTitle = '',
    this.originalLanguage = '',
    this.title = '',
    this.backdropPath,
    this.voteCount = 0,
    this.video = false,
    this.voteAverage = 0,
  });

  factory MovieListItemType.fromJson(Map<String, dynamic> json) =>
      _$MovieListItemTypeFromJson(json);

  @JsonKey(name: 'poster_path')
  final String? posterPath;
  final bool adult;
  final String overview;

  @JsonKey(name: 'release_date')
  final String releaseDate;

  @JsonKey(name: 'genre_ids')
  final List<int> genreIDs;
  final int id;

  @JsonKey(name: 'original_title')
  final String originalTitle;

  @JsonKey(name: 'original_language')
  final String originalLanguage;
  final String title;

  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;
  final double popularity;

  @JsonKey(name: 'vote_count')
  final int voteCount;
  final bool video;

  @JsonKey(name: 'vote_average')
  final double voteAverage;

  Map<String, dynamic> toJson() => _$MovieListItemTypeToJson(this);
}

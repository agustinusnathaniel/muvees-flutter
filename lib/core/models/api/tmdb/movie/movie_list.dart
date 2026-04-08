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
    this.includeAdult,
    this.withoutGenres,
  });

  factory MovieListParams.fromJson(Map<String, dynamic> json) =>
      _$MovieListParamsFromJson(json);

  static String? _pipeList(List<String>? genres) => genres?.join('|');

  String? language;
  int? page;
  String? query;
  @JsonKey(name: 'with_genres', toJson: _pipeList)
  List<String>? withGenres;
  @JsonKey(name: 'include_adult')
  bool? includeAdult;
  @JsonKey(name: 'without_genres', toJson: _pipeList)
  List<String>? withoutGenres;

  Map<String, dynamic> toJson() => _$MovieListParamsToJson(this);
}

@JsonSerializable()
class MovieListResponse extends TmdbListResponse {
  MovieListResponse({
    required super.page,
    required super.totalResults,
    required super.totalPages,
    required this.results,
  });

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

@JsonEnum(valueField: 'key')
enum MovieSection {
  nowPlaying('now_playing'),
  topRated('top_rated'),
  popular('popular'),
  upcoming('upcoming')
  ;

  const MovieSection(this.key);
  final String key;
}

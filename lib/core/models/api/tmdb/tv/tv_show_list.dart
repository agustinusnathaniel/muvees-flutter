import 'package:json_annotation/json_annotation.dart';
import 'package:muvees/core/models/api/tmdb/tmdb_list_response.dart';

part 'tv_show_list.g.dart';

@JsonSerializable(includeIfNull: false)
class TvShowListParams {
  TvShowListParams({
    this.language,
    this.page,
    this.query,
    this.withGenres,
    this.includeAdult,
    this.withoutGenres,
  });

  factory TvShowListParams.fromJson(Map<String, dynamic> json) =>
      _$TvShowListParamsFromJson(json);

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

  Map<String, dynamic> toJson() => _$TvShowListParamsToJson(this);
}

@JsonSerializable()
class TvShowListResponse extends TmdbListResponse {
  TvShowListResponse({
    required super.page,
    required super.totalResults,
    required super.totalPages,
    required this.results,
  });

  factory TvShowListResponse.fromJson(Map<String, dynamic> json) =>
      _$TvShowListResponseFromJson(json);

  final List<TvShowListItem> results;

  @override
  Map<String, dynamic> toJson() => _$TvShowListResponseToJson(this);
}

@JsonSerializable()
class TvShowListItem {
  const TvShowListItem({
    required this.id,
    required this.popularity,
    this.posterPath,
    this.adult = false,
    this.overview = '',
    this.genreIDs = const <int>[],
    this.originalName = '',
    this.originalLanguage = '',
    this.name = '',
    this.backdropPath,
    this.voteCount = 0,
    this.voteAverage = 0,
    this.firstAirDate = '',
    this.originCountry = const <String>[],
  });

  factory TvShowListItem.fromJson(Map<String, dynamic> json) =>
      _$TvShowListItemFromJson(json);

  @JsonKey(name: 'poster_path')
  final String? posterPath;
  final bool adult;
  final String overview;
  @JsonKey(name: 'first_air_date')
  final String firstAirDate;
  @JsonKey(name: 'genre_ids')
  final List<int> genreIDs;
  final int id;
  @JsonKey(name: 'original_name')
  final String originalName;
  @JsonKey(name: 'original_language')
  final String originalLanguage;
  final String name;
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;
  final double popularity;
  @JsonKey(name: 'vote_count')
  final int voteCount;
  @JsonKey(name: 'vote_average')
  final double voteAverage;
  @JsonKey(name: 'origin_country')
  final List<String> originCountry;

  Map<String, dynamic> toJson() => _$TvShowListItemToJson(this);
}

@JsonEnum(valueField: 'key')
enum TvShowSection {
  airingToday('airing_today'),
  onTheAir('on_the_air'),
  popular('popular'),
  topRated('top_rated')
  ;

  const TvShowSection(this.key);
  final String key;
}

@JsonSerializable()
class TvShowDetailResponse {
  TvShowDetailResponse({
    required this.id,
    required this.originalLanguage,
    required this.originalName,
    required this.overview,
    required this.popularity,
    required this.status,
    required this.name,
    required this.voteAverage,
    required this.voteCount,
    required this.type,
    this.inProduction = false,
    this.adult = false,
    this.genres = const <Genre>[],
    this.productionCompanies = const <ProductionCompany>[],
    this.productionCountries = const <ProductionCountry>[],
    this.spokenLanguages = const <SpokenLanguage>[],
    this.networks = const <Network>[],
    this.seasons = const <Season>[],
    this.backdropPath,
    this.firstAirDate,
    this.lastAirDate,
    this.homepage,
    this.posterPath,
    this.tagline,
    this.numberOfSeasons = 0,
    this.numberOfEpisodes = 0,
  });

  factory TvShowDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$TvShowDetailResponseFromJson(json);

  bool adult;
  @JsonKey(name: 'backdrop_path')
  String? backdropPath;
  @JsonKey(name: 'first_air_date')
  DateTime? firstAirDate;
  List<Genre> genres;
  String? homepage;
  int id;
  @JsonKey(name: 'in_production')
  bool inProduction;
  @JsonKey(name: 'last_air_date')
  DateTime? lastAirDate;
  List<Network> networks;
  @JsonKey(name: 'original_language')
  String originalLanguage;
  @JsonKey(name: 'original_name')
  String originalName;
  String overview;
  double popularity;
  @JsonKey(name: 'poster_path')
  String? posterPath;
  List<ProductionCompany> productionCompanies;
  List<ProductionCountry> productionCountries;
  List<Season> seasons;
  @JsonKey(name: 'spoken_languages')
  List<SpokenLanguage> spokenLanguages;
  String status;
  String? tagline;
  String name;
  @JsonKey(name: 'number_of_seasons')
  int numberOfSeasons;
  @JsonKey(name: 'number_of_episodes')
  int numberOfEpisodes;
  String type;
  @JsonKey(name: 'vote_average')
  double voteAverage;
  @JsonKey(name: 'vote_count')
  int voteCount;

  Map<String, dynamic> toJson() => _$TvShowDetailResponseToJson(this);
}

@JsonSerializable()
class Genre {
  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);

  int id;
  String name;

  Map<String, dynamic> toJson() => _$GenreToJson(this);
}

@JsonSerializable()
class Network {
  Network({
    required this.id,
    required this.name,
    this.logoPath,
    this.originCountry,
  });

  factory Network.fromJson(Map<String, dynamic> json) =>
      _$NetworkFromJson(json);

  int id;
  @JsonKey(name: 'logo_path')
  String? logoPath;
  String name;
  @JsonKey(name: 'origin_country')
  String? originCountry;

  Map<String, dynamic> toJson() => _$NetworkToJson(this);
}

@JsonSerializable()
class ProductionCompany {
  ProductionCompany({
    required this.id,
    required this.name,
    required this.originCountry,
    this.logoPath,
  });

  factory ProductionCompany.fromJson(Map<String, dynamic> json) =>
      _$ProductionCompanyFromJson(json);

  int id;
  @JsonKey(name: 'logo_path')
  String? logoPath;
  String name;
  @JsonKey(name: 'origin_country')
  String originCountry;

  Map<String, dynamic> toJson() => _$ProductionCompanyToJson(this);
}

@JsonSerializable()
class ProductionCountry {
  ProductionCountry({required this.iso31661, required this.name});

  factory ProductionCountry.fromJson(Map<String, dynamic> json) =>
      _$ProductionCountryFromJson(json);

  @JsonKey(name: 'iso_3166_1')
  String iso31661;
  String name;

  Map<String, dynamic> toJson() => _$ProductionCountryToJson(this);
}

@JsonSerializable()
class Season {
  Season({
    required this.id,
    required this.seasonNumber,
    required this.name,
    required this.episodeCount,
    this.airDate,
    this.overview = '',
    this.posterPath,
    this.voteAverage = 0,
  });

  factory Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);

  int id;
  @JsonKey(name: 'air_date')
  DateTime? airDate;
  @JsonKey(name: 'episode_count')
  int episodeCount;
  String name;
  String overview;
  @JsonKey(name: 'poster_path')
  String? posterPath;
  @JsonKey(name: 'season_number')
  int seasonNumber;
  @JsonKey(name: 'vote_average')
  double voteAverage;

  Map<String, dynamic> toJson() => _$SeasonToJson(this);
}

@JsonSerializable()
class SpokenLanguage {
  SpokenLanguage({required this.iso6391, required this.name});

  factory SpokenLanguage.fromJson(Map<String, dynamic> json) =>
      _$SpokenLanguageFromJson(json);

  @JsonKey(name: 'iso_639_1')
  String iso6391;
  String name;

  Map<String, dynamic> toJson() => _$SpokenLanguageToJson(this);
}

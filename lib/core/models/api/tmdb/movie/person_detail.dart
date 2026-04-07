import 'package:json_annotation/json_annotation.dart';

part 'person_detail.g.dart';

@JsonSerializable()
class PersonDetailResponse {
  PersonDetailResponse({
    required this.id,
    required this.name,
    required this.popularity,
    this.biography = '',
    this.birthday,
    this.deathday,
    this.placeOfBirth,
    this.profilePath,
    this.alsoKnownAs = const <String>[],
    this.knownForDepartment = '',
    this.homepage,
    this.adult = false,
  });

  factory PersonDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$PersonDetailResponseFromJson(json);

  final int id;
  final String name;
  final String biography;
  final String? birthday;
  final String? deathday;
  @JsonKey(name: 'place_of_birth')
  final String? placeOfBirth;
  @JsonKey(name: 'profile_path')
  final String? profilePath;
  @JsonKey(name: 'also_known_as')
  final List<String> alsoKnownAs;
  @JsonKey(name: 'known_for_department')
  final String knownForDepartment;
  final String? homepage;
  final bool adult;
  final double popularity;

  Map<String, dynamic> toJson() => _$PersonDetailResponseToJson(this);
}

@JsonSerializable()
class PersonCreditsResponse {
  PersonCreditsResponse({
    required this.id,
    this.cast = const <PersonMovieCredit>[],
    this.crew = const <PersonMovieCredit>[],
  });

  factory PersonCreditsResponse.fromJson(Map<String, dynamic> json) =>
      _$PersonCreditsResponseFromJson(json);

  final int id;
  final List<PersonMovieCredit> cast;
  final List<PersonMovieCredit> crew;

  Map<String, dynamic> toJson() => _$PersonCreditsResponseToJson(this);
}

@JsonSerializable()
class PersonMovieCredit {
  PersonMovieCredit({
    required this.id,
    required this.title,
    required this.releaseDate,
    this.character = '',
    this.department = '',
    this.job = '',
    this.posterPath,
    this.voteAverage = 0,
    this.genreIds = const <int>[],
    this.overview = '',
  });

  factory PersonMovieCredit.fromJson(Map<String, dynamic> json) =>
      _$PersonMovieCreditFromJson(json);

  final int id;
  final String title;
  @JsonKey(name: 'release_date')
  final String releaseDate;
  final String character;
  final String department;
  final String job;
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  @JsonKey(name: 'vote_average')
  final double voteAverage;
  @JsonKey(name: 'genre_ids')
  final List<int> genreIds;
  final String overview;

  Map<String, dynamic> toJson() => _$PersonMovieCreditToJson(this);
}

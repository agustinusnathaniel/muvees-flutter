import 'package:json_annotation/json_annotation.dart';

part 'movie_credits.g.dart';

@JsonSerializable()
class MovieCreditsResponse {
  MovieCreditsResponse({
    required this.id,
    required this.cast,
    required this.crew,
  });

  factory MovieCreditsResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieCreditsResponseFromJson(json);

  final int id;
  final List<CastMember> cast;
  final List<CrewMember> crew;

  Map<String, dynamic> toJson() => _$MovieCreditsResponseToJson(this);
}

@JsonSerializable()
class CastMember {
  CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
    this.order = 0,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) =>
      _$CastMemberFromJson(json);

  final int id;
  final String name;
  final String character;
  @JsonKey(name: 'profile_path')
  final String? profilePath;
  final int order;

  Map<String, dynamic> toJson() => _$CastMemberToJson(this);
}

@JsonSerializable()
class CrewMember {
  CrewMember({
    required this.id,
    required this.name,
    required this.job,
    this.department = '',
  });

  factory CrewMember.fromJson(Map<String, dynamic> json) =>
      _$CrewMemberFromJson(json);

  final int id;
  final String name;
  final String job;
  final String department;

  Map<String, dynamic> toJson() => _$CrewMemberToJson(this);
}

@JsonSerializable()
class MovieVideosResponse {
  MovieVideosResponse({required this.id, required this.results});

  factory MovieVideosResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieVideosResponseFromJson(json);

  final int id;
  final List<Video> results;

  Map<String, dynamic> toJson() => _$MovieVideosResponseToJson(this);
}

@JsonSerializable()
class Video {
  Video({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    this.size = 0,
  });

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);

  final String id;
  final String key;
  final String name;
  final String site;
  final String type;
  final int size;

  Map<String, dynamic> toJson() => _$VideoToJson(this);
}

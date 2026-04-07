import 'package:json_annotation/json_annotation.dart';

part 'tv_credits.g.dart';

@JsonSerializable()
class TvCreditsResponse {
  TvCreditsResponse({
    required this.id,
    required this.cast,
    required this.crew,
  });

  factory TvCreditsResponse.fromJson(Map<String, dynamic> json) =>
      _$TvCreditsResponseFromJson(json);

  final int id;
  final List<TvCastMember> cast;
  final List<TvCrewMember> crew;

  Map<String, dynamic> toJson() => _$TvCreditsResponseToJson(this);
}

@JsonSerializable()
class TvCastMember {
  TvCastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
    this.order = 0,
  });

  factory TvCastMember.fromJson(Map<String, dynamic> json) =>
      _$TvCastMemberFromJson(json);

  final int id;
  final String name;
  final String character;
  @JsonKey(name: 'profile_path')
  final String? profilePath;
  final int order;

  Map<String, dynamic> toJson() => _$TvCastMemberToJson(this);
}

@JsonSerializable()
class TvCrewMember {
  TvCrewMember({
    required this.id,
    required this.name,
    required this.job,
    this.department = '',
  });

  factory TvCrewMember.fromJson(Map<String, dynamic> json) =>
      _$TvCrewMemberFromJson(json);

  final int id;
  final String name;
  final String job;
  final String department;

  Map<String, dynamic> toJson() => _$TvCrewMemberToJson(this);
}

@JsonSerializable()
class TvVideosResponse {
  TvVideosResponse({
    required this.id,
    required this.results,
  });

  factory TvVideosResponse.fromJson(Map<String, dynamic> json) =>
      _$TvVideosResponseFromJson(json);

  final int id;
  final List<TvVideo> results;

  Map<String, dynamic> toJson() => _$TvVideosResponseToJson(this);
}

@JsonSerializable()
class TvVideo {
  TvVideo({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    this.size = 0,
  });

  factory TvVideo.fromJson(Map<String, dynamic> json) => _$TvVideoFromJson(json);

  final String id;
  final String key;
  final String name;
  final String site;
  final String type;
  final int size;

  Map<String, dynamic> toJson() => _$TvVideoToJson(this);
}

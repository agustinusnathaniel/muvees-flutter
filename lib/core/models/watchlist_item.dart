import 'package:json_annotation/json_annotation.dart';

part 'watchlist_item.g.dart';

enum ContentType {
  movie('movie'),
  tv('tv'),
  person('person');

  const ContentType(this.key);
  final String key;
}

@JsonSerializable()
class WatchlistItem {
  WatchlistItem({
    required this.id,
    required this.type,
    required this.title,
    required this.posterPath,
    required this.voteAverage,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> json) =>
      _$WatchlistItemFromJson(json);

  final int id;
  final String type;
  final String title;
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  @JsonKey(name: 'vote_average')
  final double voteAverage;

  Map<String, dynamic> toJson() => _$WatchlistItemToJson(this);

  ContentType get contentType => switch (type) {
    'movie' => ContentType.movie,
    'tv' => ContentType.tv,
    'person' => ContentType.person,
    _ => ContentType.movie,
  };
}

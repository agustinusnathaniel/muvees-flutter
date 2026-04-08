import 'package:json_annotation/json_annotation.dart';

part 'search_response.g.dart';

@JsonSerializable(includeIfNull: false)
class SearchParams {
  SearchParams({required this.query, this.language, this.page});

  factory SearchParams.fromJson(Map<String, dynamic> json) =>
      _$SearchParamsFromJson(json);

  String? language;
  int? page;
  String query;

  Map<String, dynamic> toJson() => _$SearchParamsToJson(this);
}

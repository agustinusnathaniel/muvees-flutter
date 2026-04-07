import 'package:json_annotation/json_annotation.dart';

part 'search_response.g.dart';

@JsonSerializable(includeIfNull: false)
class SearchParams {
  SearchParams({this.language, this.page, required this.query});

  factory SearchParams.fromJson(Map<String, dynamic> json) =>
      _$SearchParamsFromJson(json);

  String? language;
  int? page;
  String query;

  Map<String, dynamic> toJson() => _$SearchParamsToJson(this);
}

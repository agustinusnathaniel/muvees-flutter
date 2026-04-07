import 'package:dio/dio.dart';
import 'package:muvees/core/models/api/tmdb/search/multi_search_response.dart';
import 'package:retrofit/retrofit.dart';

part 'search_api.g.dart';

@RestApi()
abstract class SearchApi {
  factory SearchApi(Dio dio, {String? baseUrl}) = _SearchApi;

  @GET('/search/multi')
  Future<HttpResponse<MultiSearchResponse>> searchMulti({
    @Queries() required MultiSearchParams params,
  });
}

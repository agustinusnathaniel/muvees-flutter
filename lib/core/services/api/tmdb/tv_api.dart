import 'package:dio/dio.dart';
import 'package:muvees/core/models/api/tmdb/tv/tv_credits.dart';
import 'package:muvees/core/models/api/tmdb/tv/tv_show_list.dart';
import 'package:retrofit/retrofit.dart';

part 'tv_api.g.dart';

@RestApi()
abstract class TvApi {
  factory TvApi(Dio dio, {String? baseUrl}) = _TvApi;

  @GET('/tv/{section}')
  Future<HttpResponse<TvShowListResponse>> getTvShowListBySection({
    @Path() required String section,
    @Queries() required TvShowListParams params,
  });

  @GET('/tv/{tvId}')
  Future<HttpResponse<TvShowDetailResponse>> getTvShowDetail({
    @Path() required int tvId,
  });

  @GET('/tv/{tvId}/credits')
  Future<HttpResponse<TvCreditsResponse>> getTvShowCredits({
    @Path() required int tvId,
  });

  @GET('/tv/{tvId}/similar')
  Future<HttpResponse<TvShowListResponse>> getSimilarTvShows({
    @Path() required int tvId,
    @Queries() required TvShowListParams params,
  });

  @GET('/tv/{tvId}/videos')
  Future<HttpResponse<TvVideosResponse>> getTvShowVideos({
    @Path() required int tvId,
  });
}

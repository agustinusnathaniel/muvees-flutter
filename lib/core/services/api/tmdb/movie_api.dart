import 'package:dio/dio.dart';
import 'package:muvees/core/models/api/tmdb/movie/movie_credits.dart';
import 'package:muvees/core/models/api/tmdb/movie/movie_detail.dart';
import 'package:muvees/core/models/api/tmdb/movie/movie_list.dart';
import 'package:muvees/core/models/api/tmdb/movie/person_detail.dart';
import 'package:retrofit/retrofit.dart';

part 'movie_api.g.dart';

@RestApi()
abstract class MovieApi {
  factory MovieApi(Dio dio, {String? baseUrl}) = _MovieApi;

  @GET('/movie/{section}')
  Future<HttpResponse<MovieListResponse>> getMovieListBySection({
    @Path() required String section,
    @Queries() required MovieListParams params,
  });

  @GET('/movie/{movieId}')
  Future<HttpResponse<MovieDetailResponse>> getMovieDetail({
    @Path() required int movieId,
  });

  @GET('/movie/{movieId}/credits')
  Future<HttpResponse<MovieCreditsResponse>> getMovieCredits({
    @Path() required int movieId,
  });

  @GET('/movie/{movieId}/similar')
  Future<HttpResponse<MovieListResponse>> getSimilarMovies({
    @Path() required int movieId,
    @Queries() required MovieListParams params,
  });

  @GET('/movie/{movieId}/videos')
  Future<HttpResponse<MovieVideosResponse>> getMovieVideos({
    @Path() required int movieId,
  });

  @GET('/person/{personId}')
  Future<HttpResponse<PersonDetailResponse>> getPersonDetail({
    @Path() required int personId,
  });

  @GET('/person/{personId}/movie_credits')
  Future<HttpResponse<PersonCreditsResponse>> getPersonMovieCredits({
    @Path() required int personId,
  });
}

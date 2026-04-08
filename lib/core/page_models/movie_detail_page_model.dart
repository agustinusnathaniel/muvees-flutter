import 'package:flutter/material.dart';
import 'package:muvees/core/models/api/tmdb/movie/movie_credits.dart';
import 'package:muvees/core/models/api/tmdb/movie/movie_detail.dart';
import 'package:muvees/core/models/api/tmdb/movie/movie_list.dart';
import 'package:muvees/core/models/parsed_response.dart';
import 'package:muvees/core/page_models/page_model.dart';
import 'package:muvees/core/services/api/tmdb/fetchers.dart';
import 'package:muvees/core/services/api/tmdb/movie_api.dart';
import 'package:retrofit/dio.dart';

@immutable
class MovieDetailPageState {
  const MovieDetailPageState({
    this.data,
    this.cast = const <CastMember>[],
    this.similarMovies = const <MovieListItemType>[],
    this.trailerKey,
    this.isLoading = false,
  });

  final MovieDetailResponse? data;
  final List<CastMember> cast;
  final List<MovieListItemType> similarMovies;
  final String? trailerKey;
  final bool isLoading;

  MovieDetailPageState copyWith({
    MovieDetailResponse? data,
    List<CastMember>? cast,
    List<MovieListItemType>? similarMovies,
    String? trailerKey,
    bool? isLoading,
  }) {
    return MovieDetailPageState(
      data: data ?? this.data,
      cast: cast ?? this.cast,
      similarMovies: similarMovies ?? this.similarMovies,
      trailerKey: trailerKey ?? this.trailerKey,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MovieDetailPageModel extends PageStateNotifier<MovieDetailPageState> {
  MovieDetailPageModel({required int movieId}) : _movieId = movieId;

  final int _movieId;

  @override
  MovieDetailPageState build() {
    return const MovieDetailPageState();
  }

  MovieApi get _movieApi => ref.read(movieApiProvider);

  @override
  Future<void> initPageModel() async {
    state = state.copyWith(isLoading: true);
    await Future.wait(<Future<void>>[
      _fetchMovieDetail(),
      _fetchCredits(),
      _fetchSimilar(),
      _fetchVideos(),
    ]);
    state = state.copyWith(isLoading: false);
  }

  Future<void> _fetchMovieDetail() async {
    final HttpResponse<MovieDetailResponse> result = await _movieApi
        .getMovieDetail(movieId: _movieId);

    if (result.isSuccess) {
      state = state.copyWith(data: result.data);
    }
  }

  Future<void> _fetchCredits() async {
    final HttpResponse<MovieCreditsResponse> result = await _movieApi
        .getMovieCredits(movieId: _movieId);

    if (result.isSuccess) {
      state = state.copyWith(cast: result.data.cast.take(10).toList());
    }
  }

  Future<void> _fetchSimilar() async {
    final HttpResponse<MovieListResponse> result = await _movieApi
        .getSimilarMovies(movieId: _movieId, params: MovieListParams(page: 1));

    if (result.isSuccess) {
      state = state.copyWith(similarMovies: result.data.results);
    }
  }

  Future<void> _fetchVideos() async {
    final HttpResponse<MovieVideosResponse> result = await _movieApi
        .getMovieVideos(movieId: _movieId);

    if (result.isSuccess) {
      String? trailerKey;
      for (final Video video in result.data.results) {
        if (video.type == 'Trailer' && video.site == 'YouTube') {
          trailerKey = video.key;
          break;
        }
      }
      trailerKey ??= result.data.results.isNotEmpty
          ? result.data.results.first.key
          : null;

      state = state.copyWith(trailerKey: trailerKey);
    }
  }
}

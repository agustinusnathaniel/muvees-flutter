import 'package:flutter/material.dart';
import 'package:muvees/core/models/api/tmdb/tv/tv_credits.dart';
import 'package:muvees/core/models/api/tmdb/tv/tv_show_list.dart';
import 'package:muvees/core/models/parsed_response.dart';
import 'package:muvees/core/page_models/page_model.dart';
import 'package:muvees/core/services/api/tmdb/tv_api.dart';
import 'package:muvees/core/services/api/tmdb/tv_fetchers.dart';
import 'package:retrofit/dio.dart';

@immutable
class TvDetailPageState {
  const TvDetailPageState({
    this.data,
    this.cast = const <TvCastMember>[],
    this.similarShows = const <TvShowListItem>[],
    this.trailerKey,
    this.isLoading = false,
  });

  final TvShowDetailResponse? data;
  final List<TvCastMember> cast;
  final List<TvShowListItem> similarShows;
  final String? trailerKey;
  final bool isLoading;

  TvDetailPageState copyWith({
    TvShowDetailResponse? data,
    List<TvCastMember>? cast,
    List<TvShowListItem>? similarShows,
    String? trailerKey,
    bool? isLoading,
  }) {
    return TvDetailPageState(
      data: data ?? this.data,
      cast: cast ?? this.cast,
      similarShows: similarShows ?? this.similarShows,
      trailerKey: trailerKey ?? this.trailerKey,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TvDetailPageModel extends PageStateNotifier<TvDetailPageState> {
  TvDetailPageModel({required int tvId}) : _tvId = tvId;

  final int _tvId;

  @override
  TvDetailPageState build() {
    return const TvDetailPageState();
  }

  TvApi get _tvApi => ref.read(tvApiProvider);

  @override
  Future<void> initPageModel() async {
    state = state.copyWith(isLoading: true);
    await Future.wait(<Future<void>>[
      _fetchTvDetail(),
      _fetchCredits(),
      _fetchSimilar(),
      _fetchVideos(),
    ]);
    state = state.copyWith(isLoading: false);
  }

  Future<void> _fetchTvDetail() async {
    final HttpResponse<TvShowDetailResponse> result = await _tvApi
        .getTvShowDetail(tvId: _tvId);
    if (result.isSuccess) {
      state = state.copyWith(data: result.data);
    }
  }

  Future<void> _fetchCredits() async {
    final HttpResponse<TvCreditsResponse> result = await _tvApi
        .getTvShowCredits(tvId: _tvId);
    if (result.isSuccess) {
      state = state.copyWith(cast: result.data.cast.take(10).toList());
    }
  }

  Future<void> _fetchSimilar() async {
    final HttpResponse<TvShowListResponse> result = await _tvApi
        .getSimilarTvShows(tvId: _tvId, params: TvShowListParams(page: 1));
    if (result.isSuccess) {
      state = state.copyWith(similarShows: result.data.results);
    }
  }

  Future<void> _fetchVideos() async {
    final HttpResponse<TvVideosResponse> result = await _tvApi.getTvShowVideos(
      tvId: _tvId,
    );
    if (result.isSuccess) {
      String? trailerKey;
      for (final TvVideo video in result.data.results) {
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

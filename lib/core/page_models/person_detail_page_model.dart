import 'package:flutter/material.dart';
import 'package:muvees/core/models/api/tmdb/movie/person_detail.dart';
import 'package:muvees/core/models/parsed_response.dart';
import 'package:muvees/core/page_models/page_model.dart';
import 'package:muvees/core/services/api/tmdb/fetchers.dart';
import 'package:muvees/core/services/api/tmdb/movie_api.dart';
import 'package:retrofit/dio.dart';

@immutable
class PersonDetailPageState {
  const PersonDetailPageState({
    this.detail,
    this.credits = const <PersonMovieCredit>[],
    this.isLoading = false,
  });

  final PersonDetailResponse? detail;
  final List<PersonMovieCredit> credits;
  final bool isLoading;

  PersonDetailPageState copyWith({
    PersonDetailResponse? detail,
    List<PersonMovieCredit>? credits,
    bool? isLoading,
  }) {
    return PersonDetailPageState(
      detail: detail ?? this.detail,
      credits: credits ?? this.credits,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PersonDetailPageModel extends PageStateNotifier<PersonDetailPageState> {
  PersonDetailPageModel({required int personId}) : _personId = personId;

  final int _personId;

  @override
  PersonDetailPageState build() {
    return const PersonDetailPageState();
  }

  MovieApi get _movieApi => ref.read(movieApiProvider);

  @override
  Future<void> initPageModel() async {
    state = state.copyWith(isLoading: true);
    await Future.wait(<Future<void>>[_fetchDetail(), _fetchCredits()]);
    state = state.copyWith(isLoading: false);
  }

  Future<void> _fetchDetail() async {
    final HttpResponse<PersonDetailResponse> result = await _movieApi
        .getPersonDetail(personId: _personId);
    if (result.isSuccess) {
      state = state.copyWith(detail: result.data);
    }
  }

  Future<void> _fetchCredits() async {
    final HttpResponse<PersonCreditsResponse> result = await _movieApi
        .getPersonMovieCredits(personId: _personId);
    if (result.isSuccess) {
      // Combine cast + crew, sort by release date
      final List<PersonMovieCredit> all =
          <PersonMovieCredit>[...result.data.cast, ...result.data.crew]
            ..removeWhere((PersonMovieCredit c) => c.releaseDate.isEmpty)
            ..sort((PersonMovieCredit a, PersonMovieCredit b) => b.releaseDate.compareTo(a.releaseDate));
      state = state.copyWith(credits: all);
    }
  }
}

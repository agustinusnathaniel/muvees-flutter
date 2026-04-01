import 'package:flutter/material.dart';
import 'package:muvees/core/models/api/tmdb/movie/movie_list.dart';
import 'package:muvees/core/models/parsed_response.dart';
import 'package:muvees/core/page_models/page_model.dart';
import 'package:muvees/core/services/api/tmdb/fetchers.dart';
import 'package:muvees/core/services/api/tmdb/movie_api.dart';
import 'package:retrofit/dio.dart';

final List<String> movieSections = MovieSection.values
    .map(
      (MovieSection item) => item.key,
    )
    .toList();

@immutable
class HomePageState {
  const HomePageState({
    this.items = const <MovieListItemType>[],
    this.movieSection = 'top_rated',
  });

  final List<MovieListItemType> items;
  final String movieSection;

  HomePageState copyWith({
    List<MovieListItemType>? items,
    String? movieSection,
  }) {
    return HomePageState(
      items: items ?? this.items,
      movieSection: movieSection ?? this.movieSection,
    );
  }
}

class HomePageModel extends PageStateNotifier<HomePageState> {
  HomePageModel();

  @override
  HomePageState build() {
    return const HomePageState();
  }

  MovieApi get _movieApi => ref.read(movieApiProvider);

  @override
  Future<void> initPageModel() async {
    setIsLoading(true);
    await fetchMovieList();
    setIsLoading(false);
  }

  Future<void> fetchMovieList() async {
    final HttpResponse<MovieListResponse> result =
        await _movieApi.getMovieListBySection(
      section: state.movieSection,
      params: MovieListParams(
        page: 1,
      ),
    );

    if (result.isSuccess) {
      state = state.copyWith(
        items: result.data.results,
      );
    }
  }

  Future<void> setMovieSection(String? movieSection) async {
    state = state.copyWith(
      movieSection: movieSection,
    );
    await fetchMovieList();
  }
}

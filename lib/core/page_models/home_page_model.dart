import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muvees/core/models/api/tmdb/movie/movie_list.dart';
import 'package:muvees/core/models/parsed_response.dart';
import 'package:muvees/core/page_models/content_filter_model.dart';
import 'package:muvees/core/page_models/page_model.dart';
import 'package:muvees/core/services/api/tmdb/fetchers.dart';
import 'package:muvees/core/services/api/tmdb/movie_api.dart';
import 'package:retrofit/dio.dart';

final List<String> movieSections = MovieSection.values
    .map((MovieSection item) => item.key)
    .toList();

final NotifierProvider<HomePageModel, HomePageState> homePageModel =
    NotifierProvider<HomePageModel, HomePageState>(() {
      return HomePageModel();
    });

@immutable
class HomePageState {
  const HomePageState({
    this.items = const <MovieListItemType>[],
    this.movieSection = 'top_rated',
    this.isLoading = false,
  });

  final List<MovieListItemType> items;
  final String movieSection;
  final bool isLoading;

  HomePageState copyWith({
    List<MovieListItemType>? items,
    String? movieSection,
    bool? isLoading,
  }) {
    return HomePageState(
      items: items ?? this.items,
      movieSection: movieSection ?? this.movieSection,
      isLoading: isLoading ?? this.isLoading,
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
    state = state.copyWith(isLoading: true);
    await fetchMovieList();
  }

  Future<void> fetchMovieList() async {
    final ContentFilterState filter = ref.read(contentFilterModelProvider);
    final List<String>? excludedGenres = filter.includeHorrorContent
        ? null
        : <String>['27'];
    final HttpResponse<MovieListResponse> result = await _movieApi
        .getMovieListBySection(
          section: state.movieSection,
          params: MovieListParams(
            page: 1,
            includeAdult: filter.includeAdultContent,
            withoutGenres: excludedGenres,
          ),
        );

    if (result.isSuccess) {
      state = state.copyWith(items: result.data.results, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> setMovieSection(String? movieSection) async {
    state = state.copyWith(movieSection: movieSection, isLoading: true);
    await fetchMovieList();
  }
}

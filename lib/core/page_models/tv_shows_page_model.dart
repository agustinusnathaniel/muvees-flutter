import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muvees/core/models/api/tmdb/tv/tv_show_list.dart';
import 'package:muvees/core/models/parsed_response.dart';
import 'package:muvees/core/page_models/page_model.dart';
import 'package:muvees/core/services/api/tmdb/tv_api.dart';
import 'package:muvees/core/services/api/tmdb/tv_fetchers.dart';
import 'package:retrofit/dio.dart';

final List<String> tvShowSections = TvShowSection.values
    .map((TvShowSection item) => item.key)
    .toList();

final NotifierProvider<TvShowsPageModel, TvShowsPageState> tvShowsPageModel =
    NotifierProvider<TvShowsPageModel, TvShowsPageState>(() {
      return TvShowsPageModel();
    });

@immutable
class TvShowsPageState {
  const TvShowsPageState({
    this.items = const <TvShowListItem>[],
    this.tvSection = 'popular',
    this.isLoading = false,
  });

  final List<TvShowListItem> items;
  final String tvSection;
  final bool isLoading;

  TvShowsPageState copyWith({
    List<TvShowListItem>? items,
    String? tvSection,
    bool? isLoading,
  }) {
    return TvShowsPageState(
      items: items ?? this.items,
      tvSection: tvSection ?? this.tvSection,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TvShowsPageModel extends PageStateNotifier<TvShowsPageState> {
  TvShowsPageModel();

  @override
  TvShowsPageState build() {
    return const TvShowsPageState();
  }

  TvApi get _tvApi => ref.read(tvApiProvider);

  @override
  Future<void> initPageModel() async {
    state = state.copyWith(isLoading: true);
    await fetchTvShowList();
  }

  Future<void> fetchTvShowList() async {
    final HttpResponse<TvShowListResponse> result = await _tvApi
        .getTvShowListBySection(
          section: state.tvSection,
          params: TvShowListParams(page: 1),
        );

    if (result.isSuccess) {
      state = state.copyWith(items: result.data.results, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> setTvShowSection(String? tvSection) async {
    state = state.copyWith(tvSection: tvSection, isLoading: true);
    await fetchTvShowList();
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muvees/core/models/api/tmdb/search/multi_search_response.dart';
import 'package:muvees/core/models/parsed_response.dart';
import 'package:muvees/core/page_models/page_model.dart';
import 'package:muvees/core/services/api/tmdb/search_api.dart';
import 'package:muvees/core/services/api/tmdb/search_fetchers.dart';
import 'package:retrofit/dio.dart';

final NotifierProvider<SearchPageModel, SearchPageState> searchPageModel =
    NotifierProvider<SearchPageModel, SearchPageState>(() {
      return SearchPageModel();
    });

class SearchPageState {
  const SearchPageState({
    this.items = const <MultiSearchResult>[],
    this.query = '',
    this.isLoading = false,
  });

  final List<MultiSearchResult> items;
  final String query;
  final bool isLoading;

  SearchPageState copyWith({
    List<MultiSearchResult>? items,
    String? query,
    bool? isLoading,
  }) {
    return SearchPageState(
      items: items ?? this.items,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SearchPageModel extends PageStateNotifier<SearchPageState> {
  SearchPageModel();

  Timer? _debounceTimer;

  @override
  SearchPageState build() {
    return const SearchPageState();
  }

  SearchApi get _searchApi => ref.read(searchApiProvider);

  @override
  Future<void> initPageModel() async {
    // No initial load needed for search
  }

  void searchQuery(String query) {
    // Update state immediately with query
    state = state.copyWith(query: query);

    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    // If query is empty, clear results
    if (query.trim().isEmpty) {
      state = state.copyWith(items: <MultiSearchResult>[]);
      return;
    }

    // Debounce search by 500ms
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      await _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    state = state.copyWith(isLoading: true);

    try {
      final HttpResponse<MultiSearchResponse> result = await _searchApi
          .searchMulti(params: MultiSearchParams(query: query, page: 1));

      if (result.isSuccess) {
        state = state.copyWith(items: result.data.results, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void onDispose() {
    _debounceTimer?.cancel();
  }
}

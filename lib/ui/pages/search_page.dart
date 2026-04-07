import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:muvees/core/config/routes/routes.dart';
import 'package:muvees/core/models/api/tmdb/search/multi_search_response.dart';
import 'package:muvees/core/page_models/search_page_model.dart';
import 'package:muvees/ui/page_model_consumer.dart';
import 'package:muvees/ui/pages/movie_detail_page.dart';
import 'package:muvees/ui/pages/tv_detail_page.dart';
import 'package:muvees/ui/widgets/shared/content_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: PageModelConsumer<SearchPageModel, SearchPageState>(
        pageModel: searchPageModel,
        onModelReady: (SearchPageModel model) async {
          await model.initPageModel();
        },
        builder:
            (
              BuildContext context,
              SearchPageState searchState,
              SearchPageModel notifier,
            ) {
              // Update controller listener
              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search movies & TV shows...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  notifier.searchQuery('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                      onChanged: notifier.searchQuery,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _buildSearchResults(
                      items: searchState.items,
                      isLoading: searchState.isLoading,
                      query: searchState.query,
                      onTapItem: (MultiSearchResult item) =>
                          _openDetail(context: context, result: item),
                    ),
                  ),
                ],
              );
            },
      ),
    );
  }

  Widget _buildSearchResults({
    required List<MultiSearchResult> items,
    required bool isLoading,
    required String query,
    required void Function(MultiSearchResult) onTapItem,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Search for movies and TV shows',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No results found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 24,
      crossAxisSpacing: 24,
      childAspectRatio: 3 / 4,
      children: List<Widget>.generate(items.length, (int index) {
        final MultiSearchResult item = items[index];
        return GestureDetector(
          onTap: () => onTapItem(item),
          child: ContentCard(
            title: item.displayName,
            imageUrl: item.posterPath,
            voteAverage: item.voteAverage,
          ),
        );
      }),
    );
  }

  void _openDetail({
    required BuildContext context,
    required MultiSearchResult result,
  }) {
    if (result.mediaType == 'movie') {
      context.pushNamed(
        AppRoute.movieDetail,
        extra: MovieDetailPageParams(id: result.id),
      );
    } else if (result.mediaType == 'tv') {
      context.pushNamed(
        AppRoute.tvDetail,
        extra: TvDetailPageParams(id: result.id),
      );
    }
  }
}

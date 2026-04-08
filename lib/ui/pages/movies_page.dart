import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:muvees/core/config/routes/routes.dart';
import 'package:muvees/core/models/api/tmdb/movie/movie_list.dart';
import 'package:muvees/core/page_models/home_page_model.dart';
import 'package:muvees/ui/page_model_consumer.dart';
import 'package:muvees/ui/pages/movie_detail_page.dart';
import 'package:muvees/ui/widgets/shared/content_card.dart';

class MoviesPage extends StatelessWidget {
  const MoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('muvees')),
      body: PageModelConsumer<HomePageModel, HomePageState>(
        pageModel: homePageModel,
        onModelReady: (HomePageModel model) async {
          await model.initPageModel();
        },
        builder:
            (
              BuildContext context,
              HomePageState state,
              HomePageModel notifier,
            ) {
              if (state.isLoading && state.items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return Stack(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        child: DropdownButton<String>(
                          value: state.movieSection,
                          items: movieSections
                              .map(
                                (String item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item
                                        .split('_')
                                        .map(
                                          (String item) =>
                                              '${item[0].toUpperCase()}${item.substring(1)}',
                                        )
                                        .join(' '),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: notifier.setMovieSection,
                          isExpanded: true,
                        ),
                      ),
                      Expanded(
                        child: _MoviesGrid(
                          items: state.items,
                          onRefresh: notifier.fetchMovieList,
                          onTapItem: (int id) =>
                              _openDetail(context: context, id: id),
                        ),
                      ),
                    ],
                  ),
                  if (state.isLoading)
                    Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withAlpha(138),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              );
            },
      ),
    );
  }

  void _openDetail({required BuildContext context, required int id}) {
    context.pushNamed(
      AppRoute.movieDetail,
      extra: MovieDetailPageParams(id: id),
    );
  }
}

class _MoviesGrid extends StatelessWidget {
  const _MoviesGrid({
    required this.items,
    required this.onTapItem,
    required this.onRefresh,
  });

  final List<MovieListItemType> items;
  final void Function(int id) onTapItem;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 3 / 4,
        children: List<Widget>.generate(items.length, (int index) {
          return GestureDetector(
            onTap: () => onTapItem(items[index].id),
            child: ContentCard(
              title: items[index].title,
              imageUrl: items[index].posterPath,
              voteAverage: items[index].voteAverage,
              heroTag: 'movie_${items[index].id}',
            ),
          );
        }),
      ),
    );
  }
}

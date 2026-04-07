import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:muvees/core/config/routes/routes.dart';
import 'package:muvees/core/models/api/tmdb/tv/tv_show_list.dart';
import 'package:muvees/core/page_models/tv_shows_page_model.dart';
import 'package:muvees/ui/page_model_consumer.dart';
import 'package:muvees/ui/pages/tv_detail_page.dart';
import 'package:muvees/ui/widgets/shared/content_card.dart';

class TvShowsPage extends StatelessWidget {
  const TvShowsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TV Shows')),
      body: PageModelConsumer<TvShowsPageModel, TvShowsPageState>(
        pageModel: tvShowsPageModel,
        onModelReady: (TvShowsPageModel model) async {
          await model.initPageModel();
        },
        builder:
            (
              BuildContext context,
              TvShowsPageState state,
              TvShowsPageModel notifier,
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
                          value: state.tvSection,
                          items: tvShowSections
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
                          onChanged: notifier.setTvShowSection,
                          isExpanded: true,
                        ),
                      ),
                      Expanded(
                        child: _TvGrid(
                          items: state.items,
                          onRefresh: notifier.fetchTvShowList,
                          onTapItem: (int id) =>
                              _openDetail(context: context, id: id),
                        ),
                      ),
                    ],
                  ),
                  if (state.isLoading)
                    Container(
                      color: Colors.black54,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              );
            },
      ),
    );
  }

  void _openDetail({required BuildContext context, required int id}) {
    context.pushNamed(AppRoute.tvDetail, extra: TvDetailPageParams(id: id));
  }
}

class _TvGrid extends StatelessWidget {
  const _TvGrid({
    required this.items,
    required this.onTapItem,
    required this.onRefresh,
  });

  final List<TvShowListItem> items;
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
              title: items[index].name,
              imageUrl: items[index].posterPath,
              voteAverage: items[index].voteAverage,
              heroTag: 'tv_${items[index].id}',
            ),
          );
        }),
      ),
    );
  }
}

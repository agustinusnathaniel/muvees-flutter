import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:muvees/core/config/routes/routes.dart';
import 'package:muvees/core/models/watchlist_item.dart';
import 'package:muvees/core/page_models/watchlist_page_model.dart';
import 'package:muvees/core/services/watchlist_service.dart';
import 'package:muvees/ui/page_model_consumer.dart';
import 'package:muvees/ui/pages/movie_detail_page.dart';
import 'package:muvees/ui/pages/person_detail_page.dart';
import 'package:muvees/ui/pages/tv_detail_page.dart';
import 'package:muvees/ui/widgets/shared/content_card.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: PageModelConsumer<WatchlistPageModel, WatchlistPageState>(
        pageModel: watchlistPageModel,
        onModelReady: (WatchlistPageModel model) async => model.initPageModel(),
        builder:
            (
              BuildContext context,
              WatchlistPageState state,
              WatchlistPageModel notifier,
            ) {
              if (state.items.isEmpty) {
                return const _EmptyWatchlist();
              }

              return RefreshIndicator(
                onRefresh: notifier.refreshWatchList,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          '${state.items.length} item${state.items.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: _WatchlistGrid(
                        items: state.items,
                        notifier: notifier,
                      ),
                    ),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
                  ],
                ),
              );
            },
      ),
    );
  }
}

class _EmptyWatchlist extends StatelessWidget {
  const _EmptyWatchlist();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.bookmark_outline, size: 64),
          SizedBox(height: 16),
          Text(
            'Your watchlist is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add movies and TV shows to watch later',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _WatchlistGrid extends StatelessWidget {
  const _WatchlistGrid({required this.items, required this.notifier});

  final List<WatchlistItem> items;
  final WatchlistPageModel notifier;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 3 / 4,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) =>
              _WatchlistCard(item: items[index], notifier: notifier),
          childCount: items.length,
        ),
      ),
    );
  }
}

class _WatchlistCard extends StatefulWidget {
  const _WatchlistCard({required this.item, required this.notifier});

  final WatchlistItem item;
  final WatchlistPageModel notifier;

  @override
  State<_WatchlistCard> createState() => _WatchlistCardState();
}

class _WatchlistCardState extends State<_WatchlistCard> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey('${widget.item.type}_${widget.item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(Icons.delete_outline, color: colorScheme.onErrorContainer),
      ),
      confirmDismiss: (DismissDirection direction) async {
        return await _showDeleteDialog(context);
      },
      onDismissed: (_) async {
        setState(() => _isVisible = false);
        await WatchlistService.removeFromWatchlist(
          id: widget.item.id,
          type: widget.item.type,
        );
        await widget.notifier.refreshWatchList();
        // Note: No SnackBar shown — swipe-to-remove is self-explanatory.
        // Also, SnackBars with an SnackBarAction do NOT auto-dismiss in Flutter.
      },
      child: GestureDetector(
        onTap: () => _openDetail(context, widget.item),
        child: Stack(
          children: <Widget>[
            ContentCard(
              title: widget.item.title,
              imageUrl: widget.item.posterPath,
              voteAverage: widget.item.voteAverage,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withAlpha(204),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  switch (widget.item.contentType) {
                    ContentType.movie => 'Movie',
                    ContentType.tv => 'TV',
                    ContentType.person => 'Person',
                  },
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Remove from Watchlist?'),
        content: Text('Remove "${widget.item.title}"?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _openDetail(BuildContext context, WatchlistItem item) async {
    switch (item.contentType) {
      case ContentType.movie:
        await context.pushNamed(
          AppRoute.movieDetail,
          extra: MovieDetailPageParams(id: item.id),
        );
      case ContentType.tv:
        await context.pushNamed(
          AppRoute.tvDetail,
          extra: TvDetailPageParams(id: item.id),
        );
      case ContentType.person:
        await context.pushNamed(
          AppRoute.personDetail,
          extra: PersonDetailPageParams(id: item.id),
        );
    }
    // Refresh watchlist when returning from detail page
    if (mounted) {
      await widget.notifier.refreshWatchList();
    }
  }
}

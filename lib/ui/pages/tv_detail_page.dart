import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:muvees/core/config/routes/routes.dart';
import 'package:muvees/core/models/api/tmdb/tv/tv_credits.dart';
import 'package:muvees/core/models/api/tmdb/tv/tv_show_list.dart';
import 'package:muvees/core/models/watchlist_item.dart';
import 'package:muvees/core/page_models/tv_detail_page_model.dart';
import 'package:muvees/ui/page_model_consumer.dart';
import 'package:muvees/ui/pages/person_detail_page.dart';
import 'package:muvees/ui/widgets/shared/poster_image.dart';
import 'package:muvees/ui/widgets/shared/staggered_fade_slide_in.dart';
import 'package:muvees/ui/widgets/shared/watchlist_button.dart';
import 'package:url_launcher/url_launcher.dart';

class TvDetailPageParams {
  const TvDetailPageParams({this.id = 0});
  final int id;
}

NotifierProvider<TvDetailPageModel, TvDetailPageState> tvDetailPageModel({
  required int tvId,
}) {
  return NotifierProvider<TvDetailPageModel, TvDetailPageState>(
    () => TvDetailPageModel(tvId: tvId),
  );
}

class TvDetailPage extends StatefulWidget {
  const TvDetailPage({required this.params, super.key});
  final TvDetailPageParams params;

  @override
  State<TvDetailPage> createState() => _TvDetailPageState();
}

class _TvDetailPageState extends State<TvDetailPage> {
  late NotifierProvider<TvDetailPageModel, TvDetailPageState> pageModel;

  @override
  void initState() {
    super.initState();
    pageModel = tvDetailPageModel(tvId: widget.params.id);
  }

  @override
  Widget build(BuildContext context) {
    return PageModelConsumer<TvDetailPageModel, TvDetailPageState>(
      pageModel: pageModel,
      onModelReady: (TvDetailPageModel model) async => model.initPageModel(),
      builder:
          (
            BuildContext context,
            TvDetailPageState state,
            TvDetailPageModel notifier,
          ) {
            return Scaffold(
              appBar: AppBar(
                title: Text(state.data?.name ?? 'TV Show Detail (loading...)'),
                actions: state.data == null
                    ? null
                    : <Widget>[
                        WatchlistButton(
                          id: state.data!.id,
                          type: ContentType.tv.key,
                          title: state.data!.name,
                          posterPath: state.data!.posterPath,
                          voteAverage: state.data!.voteAverage,
                        ),
                      ],
              ),
              body: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _TvDetailContent(
                      data: state.data,
                      cast: state.cast,
                      similarShows: state.similarShows,
                      trailerKey: state.trailerKey,
                      showId: state.data?.id ?? 0,
                    ),
            );
          },
    );
  }
}

class _TvDetailContent extends StatelessWidget {
  const _TvDetailContent({
    this.data,
    this.cast = const <TvCastMember>[],
    this.similarShows = const <TvShowListItem>[],
    this.trailerKey,
    this.showId = 0,
  });

  final TvShowDetailResponse? data;
  final List<TvCastMember> cast;
  final List<TvShowListItem> similarShows;
  final String? trailerKey;
  final int showId;

  @override
  Widget build(BuildContext context) {
    final TvShowDetailResponse? show = data;
    if (show == null) return const SizedBox.shrink();

    int staggerIndex = 0;
    Widget staggered(Widget child) =>
        StaggeredFadeSlideIn(index: staggerIndex++, child: child);

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          if (show.backdropPath != null)
            staggered(
              SizedBox(
                width: double.infinity,
                height: 200,
                child: PosterImage(
                  imagePath: show.backdropPath!,
                  isRounded: false,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                staggered(
                  Row(
                    children: <Widget>[
                      if (show.posterPath != null)
                        SizedBox(
                          width: 120,
                          child: Hero(
                            tag: 'tv_$showId',
                            child: PosterImage(imagePath: show.posterPath!),
                          ),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              show.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (show.tagline != null) ...<Widget>[
                              const SizedBox(height: 6),
                              Text(
                                show.tagline!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            if (show.firstAirDate != null)
                              Text(
                                'First Air: ${DateFormat('dd MMMM yyyy').format(show.firstAirDate!.toLocal())}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            if (show.lastAirDate != null)
                              Text(
                                'Last Air: ${DateFormat('dd MMMM yyyy').format(show.lastAirDate!.toLocal())}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              '${show.numberOfSeasons} Season${show.numberOfSeasons != 1 ? 's' : ''} • ${show.numberOfEpisodes} Episode${show.numberOfEpisodes != 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                            if (show.status.isNotEmpty &&
                                show.status != 'Returning Series') ...<Widget>[
                              const SizedBox(height: 4),
                              Chip(
                                label: Text(
                                  show.status,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                backgroundColor: show.status == 'Ended'
                                    ? Colors.red.shade50
                                    : Colors.orange.shade50,
                              ),
                            ],
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: show.genres
                                    .map(
                                      (Genre genre) => Padding(
                                        padding: const EdgeInsets.only(
                                          right: 4,
                                        ),
                                        child: Chip(
                                          label: Text(
                                            genre.name,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              height: 1.5,
                                            ),
                                          ),
                                          padding: EdgeInsets.zero,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                staggered(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        show.overview,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(138),
                          height: 1.5,
                        ),
                      ),
                      if (show.networks.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(
                          'Network${show.networks.length > 1 ? 's' : ''}:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: show.networks
                              .map(
                                (Network network) => Chip(
                                  label: Text(
                                    network.name,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (cast.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            staggered(_buildCastSection(cast, context)),
          ],
          if (trailerKey != null) ...<Widget>[
            const SizedBox(height: 16),
            staggered(_buildTrailerSection(context, trailerKey!)),
          ],
          if (similarShows.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            staggered(_buildSimilarShowsSection(similarShows, context)),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCastSection(List<TvCastMember> cast, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Cast',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cast.length,
            itemBuilder: (BuildContext context, int index) {
              final TvCastMember member = cast[index];
              return GestureDetector(
                onTap: () => context.pushNamed(
                  AppRoute.personDetail,
                  extra: PersonDetailPageParams(id: member.id),
                ),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        backgroundImage: member.profilePath != null
                            ? NetworkImage(
                                'https://image.tmdb.org/t/p/w185${member.profilePath}',
                              )
                            : null,
                        child: member.profilePath == null
                            ? const Icon(Icons.person, size: 30)
                            : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrailerSection(BuildContext context, String trailerKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Trailer',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final Uri url = Uri.parse(
                'https://www.youtube.com/watch?v=$trailerKey',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: <Widget>[
                  Center(
                    child: Image.network(
                      'https://img.youtube.com/vi/$trailerKey/0.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.play_circle_filled,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(179),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarShowsSection(
    List<TvShowListItem> shows,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Similar Shows',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: shows.length > 10 ? 10 : shows.length,
            itemBuilder: (BuildContext context, int index) {
              final TvShowListItem show = shows[index];
              return GestureDetector(
                onTap: () => context.pushNamed(
                  AppRoute.tvDetail,
                  extra: TvDetailPageParams(id: show.id),
                ),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: show.posterPath != null
                            ? Hero(
                                tag: 'tv_${show.id}',
                                child: PosterImage(imagePath: show.posterPath!),
                              )
                            : Container(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.tv, size: 40),
                              ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        show.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

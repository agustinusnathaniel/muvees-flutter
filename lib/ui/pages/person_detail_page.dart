import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muvees/core/config/routes/routes.dart';
import 'package:muvees/core/models/api/tmdb/movie/person_detail.dart';
import 'package:muvees/core/models/watchlist_item.dart';
import 'package:muvees/core/page_models/person_detail_page_model.dart';
import 'package:muvees/ui/page_model_consumer.dart';
import 'package:muvees/ui/pages/movie_detail_page.dart';
import 'package:muvees/ui/widgets/shared/poster_image.dart';
import 'package:muvees/ui/widgets/shared/staggered_fade_slide_in.dart';
import 'package:muvees/ui/widgets/shared/watchlist_button.dart';

class PersonDetailPageParams {
  const PersonDetailPageParams({this.id = 0});
  final int id;
}

NotifierProvider<PersonDetailPageModel, PersonDetailPageState>
personDetailPageModel({required int personId}) {
  return NotifierProvider<PersonDetailPageModel, PersonDetailPageState>(
    () => PersonDetailPageModel(personId: personId),
  );
}

class PersonDetailPage extends StatefulWidget {
  const PersonDetailPage({required this.params, super.key});
  final PersonDetailPageParams params;

  @override
  State<PersonDetailPage> createState() => _PersonDetailPageState();
}

class _PersonDetailPageState extends State<PersonDetailPage> {
  late NotifierProvider<PersonDetailPageModel, PersonDetailPageState> pageModel;

  @override
  void initState() {
    super.initState();
    pageModel = personDetailPageModel(personId: widget.params.id);
  }

  @override
  Widget build(BuildContext context) {
    return PageModelConsumer<PersonDetailPageModel, PersonDetailPageState>(
      pageModel: pageModel,
      onModelReady: (PersonDetailPageModel model) async =>
          model.initPageModel(),
      builder:
          (
            BuildContext context,
            PersonDetailPageState state,
            PersonDetailPageModel notifier,
          ) {
            return Scaffold(
              appBar: AppBar(
                title: Text(state.detail?.name ?? 'Person Detail (loading...)'),
                actions: state.detail == null
                    ? null
                    : <Widget>[
                        WatchlistButton(
                          id: state.detail!.id,
                          type: ContentType.person.key,
                          title: state.detail!.name,
                          posterPath: state.detail!.profilePath,
                          voteAverage: 0,
                        ),
                      ],
              ),
              body: state.isLoading
                  ? const _PersonDetailSkeleton()
                  : state.detail == null
                  ? const Center(child: Text('Failed to load person details'))
                  : _PersonDetailContent(
                      detail: state.detail!,
                      credits: state.credits,
                    ),
            );
          },
    );
  }
}

class _PersonDetailContent extends StatelessWidget {
  const _PersonDetailContent({required this.detail, required this.credits});
  final PersonDetailResponse detail;
  final List<PersonMovieCredit> credits;

  @override
  Widget build(BuildContext context) {
    int staggerIndex = 0;
    Widget staggered(Widget child) =>
        StaggeredFadeSlideIn(index: staggerIndex++, child: child);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (detail.profilePath != null)
            staggered(
              Center(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  width: 200,
                  child: PosterImage(imagePath: detail.profilePath!),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                staggered(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        detail.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (detail.knownForDepartment.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(detail.knownForDepartment),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                      if (detail.birthday != null) ...<Widget>[
                        const SizedBox(height: 8),
                        Text('Born: ${detail.birthday}'),
                      ],
                      if (detail.placeOfBirth != null) ...<Widget>[
                        const SizedBox(height: 4),
                        Text('From: ${detail.placeOfBirth}'),
                      ],
                      if (detail.deathday != null) ...<Widget>[
                        const SizedBox(height: 4),
                        Text('Died: ${detail.deathday}'),
                      ],
                      if (detail.biography.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 16),
                        const Text(
                          'Biography',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          detail.biography,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (credits.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            staggered(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Known For',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: credits.length,
                        itemBuilder: (BuildContext context, int index) {
                          final PersonMovieCredit credit = credits[index];
                          if (credit.posterPath == null) {
                            return const SizedBox.shrink();
                          }
                          return GestureDetector(
                            onTap: () => context.pushNamed(
                              AppRoute.movieDetail,
                              extra: MovieDetailPageParams(id: credit.id),
                            ),
                            child: Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: PosterImage(
                                      imagePath: credit.posterPath!,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    credit.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (credit.character.isNotEmpty)
                                    Text(
                                      'as ${credit.character}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
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
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PersonDetailSkeleton extends StatelessWidget {
  const _PersonDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color skeletonColor = colorScheme.surfaceContainer;
    final Color borderColor = colorScheme.outlineVariant;

    return Stack(
      children: <Widget>[
        const Positioned.fill(
          child: Center(child: CircularProgressIndicator()),
        ),
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 120,
                      height: 180,
                      decoration: BoxDecoration(
                        color: skeletonColor,
                        border: Border.all(color: borderColor, width: 0.5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _PersonSkeletonBar(
                            height: 24,
                            color: colorScheme.onSurface.withAlpha(30),
                          ),
                          const SizedBox(height: 8),
                          _PersonSkeletonBar(
                            height: 12,
                            width: 120,
                            color: colorScheme.onSurfaceVariant.withAlpha(40),
                          ),
                          const SizedBox(height: 4),
                          _PersonSkeletonBar(
                            height: 12,
                            width: 100,
                            color: colorScheme.onSurfaceVariant.withAlpha(40),
                          ),
                          const SizedBox(height: 4),
                          _PersonSkeletonBar(
                            height: 12,
                            width: 80,
                            color: colorScheme.onSurfaceVariant.withAlpha(40),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _PersonSkeletonChip(),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: <Widget>[
                    _PersonSkeletonBar(
                      height: 14,
                      color: colorScheme.onSurfaceVariant.withAlpha(40),
                    ),
                    const SizedBox(height: 8),
                    _PersonSkeletonBar(
                      height: 14,
                      color: colorScheme.onSurfaceVariant.withAlpha(40),
                    ),
                    const SizedBox(height: 8),
                    _PersonSkeletonBar(
                      height: 14,
                      width: 200,
                      color: colorScheme.onSurfaceVariant.withAlpha(40),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _PersonSkeletonChip(width: 80),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: List<Widget>.generate(
                    5,
                    (int index) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: skeletonColor,
                              border: Border.all(
                                color: borderColor,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _PersonSkeletonBar(
                                height: 10,
                                width: 80,
                                color: colorScheme.onSurfaceVariant.withAlpha(
                                  40,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _PersonSkeletonBar(
                                height: 8,
                                width: 50,
                                color: colorScheme.onSurfaceVariant.withAlpha(
                                  40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

class _PersonSkeletonBar extends StatelessWidget {
  const _PersonSkeletonBar({
    required this.height,
    this.width = double.infinity,
    this.color,
  });

  final double height;
  final double width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _PersonSkeletonChip extends StatelessWidget {
  const _PersonSkeletonChip({this.color, this.width = 60, this.height = 18});

  final Color? color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

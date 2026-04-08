import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:muvees/core/config/routes/routes.dart';
import 'package:muvees/core/models/api/tmdb/movie/movie_credits.dart';
import 'package:muvees/core/models/api/tmdb/movie/movie_detail.dart';
import 'package:muvees/core/models/api/tmdb/movie/movie_list.dart';
import 'package:muvees/core/models/watchlist_item.dart';
import 'package:muvees/core/page_models/movie_detail_page_model.dart';
import 'package:muvees/ui/page_model_consumer.dart';
import 'package:muvees/ui/pages/person_detail_page.dart';
import 'package:muvees/ui/widgets/shared/poster_image.dart';
import 'package:muvees/ui/widgets/shared/staggered_fade_slide_in.dart';
import 'package:muvees/ui/widgets/shared/watchlist_button.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieDetailPageParams {
  const MovieDetailPageParams({this.id = 0});

  final int id;
}

NotifierProvider<MovieDetailPageModel, MovieDetailPageState>
movieDetailPageModel({required int movieId}) {
  return NotifierProvider<MovieDetailPageModel, MovieDetailPageState>(() {
    return MovieDetailPageModel(movieId: movieId);
  });
}

class MovieDetailPage extends StatefulWidget {
  const MovieDetailPage({required this.params, super.key});

  final MovieDetailPageParams params;

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  NotifierProvider<MovieDetailPageModel, MovieDetailPageState> pageModel =
      movieDetailPageModel(movieId: 0);

  @override
  void initState() {
    super.initState();
    pageModel = movieDetailPageModel(movieId: widget.params.id);
  }

  @override
  Widget build(BuildContext context) {
    return PageModelConsumer<MovieDetailPageModel, MovieDetailPageState>(
      pageModel: pageModel,
      onModelReady: (MovieDetailPageModel model) async {
        await model.initPageModel();
      },
      builder:
          (
            BuildContext context,
            MovieDetailPageState state,
            MovieDetailPageModel notifier,
          ) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  state.data?.title == null
                      ? 'Movie Detail (loading...)'
                      : (state.data?.title ?? ''),
                ),
                actions: state.data == null
                    ? null
                    : <Widget>[
                        WatchlistButton(
                          id: state.data!.id,
                          type: ContentType.movie.key,
                          title: state.data!.title,
                          posterPath: state.data!.posterPath,
                          voteAverage: state.data!.voteAverage,
                        ),
                      ],
              ),
              body: state.isLoading || state.data == null
                  ? const _MovieDetailSkeleton()
                  : _MovieDetailContent(
                      data: state.data,
                      cast: state.cast,
                      similarMovies: state.similarMovies,
                      trailerKey: state.trailerKey,
                      movieId: state.data?.id ?? 0,
                    ),
            );
          },
    );
  }
}

class _MovieDetailContent extends StatelessWidget {
  const _MovieDetailContent({
    this.data,
    this.cast = const <CastMember>[],
    this.similarMovies = const <MovieListItemType>[],
    this.trailerKey,
    this.movieId = 0,
  });

  final MovieDetailResponse? data;
  final List<CastMember> cast;
  final List<MovieListItemType> similarMovies;
  final String? trailerKey;
  final int movieId;

  @override
  Widget build(BuildContext context) {
    final MovieDetailResponse? movie = data;
    if (movie == null) {
      return const SizedBox.shrink();
    }

    final String? posterPath = movie.posterPath;
    final String? backdropPath = movie.backdropPath;
    final String? tagline = movie.tagline;
    int staggerIndex = 0;

    Widget staggered(Widget child) =>
        StaggeredFadeSlideIn(index: staggerIndex++, child: child);

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          if (backdropPath != null)
            staggered(
              SizedBox(
                width: double.infinity,
                height: 200,
                child: PosterImage(imagePath: backdropPath, isRounded: false),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                staggered(
                  Row(
                    children: <Widget>[
                      if (posterPath != null)
                        SizedBox(
                          width: 120,
                          child: Hero(
                            tag: 'movie_$movieId',
                            child: PosterImage(imagePath: posterPath),
                          ),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              movie.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (tagline != null) ...<Widget>[
                              const SizedBox(height: 6),
                              Text(
                                tagline,
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
                            Text(
                              'Released: ${DateFormat('dd MMMM yyyy').format(movie.releaseDate.toLocal())}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: movie.genres
                                    .map(
                                      (Genre genre) => Container(
                                        padding: const EdgeInsets.only(
                                          right: 4,
                                        ),
                                        child: Chip(
                                          label: Text(
                                            genre.name,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                              height: 1.5,
                                            ),
                                          ),
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
                        movie.overview,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      if (movie.runtime > 0) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(
                          'Runtime: ${movie.runtime} minutes',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (movie.budget > 0 || movie.revenue > 0) ...<Widget>[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            if (movie.budget > 0)
                              _buildInfoColumn(
                                'Budget',
                                '\$${_formatNumber(movie.budget)}',
                                context,
                              ),
                            if (movie.revenue > 0)
                              _buildInfoColumn(
                                'Revenue',
                                '\$${_formatNumber(movie.revenue)}',
                                context,
                              ),
                          ],
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
          if (similarMovies.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            staggered(_buildSimilarMoviesSection(similarMovies, context)),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    }
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Widget _buildCastSection(List<CastMember> cast, BuildContext context) {
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
              final CastMember member = cast[index];
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

  Widget _buildSimilarMoviesSection(
    List<MovieListItemType> movies,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Similar Movies',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: movies.length > 10 ? 10 : movies.length,
            itemBuilder: (BuildContext context, int index) {
              final MovieListItemType movie = movies[index];
              return GestureDetector(
                onTap: () => context.pushNamed(
                  AppRoute.movieDetail,
                  extra: MovieDetailPageParams(id: movie.id),
                ),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: movie.posterPath != null
                            ? Hero(
                                tag: 'movie_${movie.id}',
                                child: PosterImage(
                                  imagePath: movie.posterPath!,
                                ),
                              )
                            : Container(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.movie, size: 40),
                              ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        movie.title,
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

class _StaggeredFadeSlideIn extends StatefulWidget {
  const _StaggeredFadeSlideIn({required this.index, required this.child});

  final int index;
  final Widget child;

  static const Duration _baseDuration = Duration(milliseconds: 600);
  static const Duration _staggerDelay = Duration(milliseconds: 150);
  static const double _startOffset = 60.0;
  static const double _startBlur = 12.0;

  @override
  State<_StaggeredFadeSlideIn> createState() => _StaggeredFadeSlideInState();
}

class _StaggeredFadeSlideInState extends State<_StaggeredFadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _StaggeredFadeSlideIn._baseDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    Future<void>.delayed(
      Duration(
        milliseconds:
            widget.index * _StaggeredFadeSlideIn._staggerDelay.inMilliseconds,
      ),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        final double value = _animation.value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, _StaggeredFadeSlideIn._startOffset * (1 - value)),
            child: ClipRRect(
              clipBehavior: Clip.none,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: _StaggeredFadeSlideIn._startBlur * (1 - value),
                  sigmaY: _StaggeredFadeSlideIn._startBlur * (1 - value),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _MovieDetailSkeleton extends StatelessWidget {
  const _MovieDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color skeletonColor = colorScheme.surfaceContainer;
    final Color borderColor = colorScheme.outlineVariant;

    return Stack(
      children: <Widget>[
        const Positioned.fill(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Backdrop
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  border: Border.all(color: borderColor, width: 0.5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    // Poster + title row
                    Row(
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
                              _SkeletonBar(
                                height: 28,
                                color: colorScheme.onSurface.withAlpha(30),
                              ),
                              const SizedBox(height: 6),
                              _SkeletonBar(
                                height: 14,
                                width: 150,
                                color: colorScheme.onSurfaceVariant.withAlpha(
                                  40,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _SkeletonBar(
                                height: 10,
                                width: 120,
                                color: colorScheme.onSurfaceVariant.withAlpha(
                                  40,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: <Widget>[
                                  _SkeletonChip(color: skeletonColor),
                                  const SizedBox(width: 4),
                                  _SkeletonChip(color: skeletonColor),
                                  const SizedBox(width: 4),
                                  _SkeletonChip(color: skeletonColor),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Overview
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _SkeletonBar(
                          height: 16,
                          color: colorScheme.onSurfaceVariant.withAlpha(40),
                        ),
                        const SizedBox(height: 8),
                        _SkeletonBar(
                          height: 16,
                          color: colorScheme.onSurfaceVariant.withAlpha(40),
                        ),
                        const SizedBox(height: 8),
                        _SkeletonBar(
                          height: 16,
                          width: 200,
                          color: colorScheme.onSurfaceVariant.withAlpha(40),
                        ),
                        const SizedBox(height: 12),
                        _SkeletonBar(
                          height: 12,
                          width: 120,
                          color: colorScheme.onSurfaceVariant.withAlpha(40),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                _SkeletonBar(
                                  height: 10,
                                  width: 50,
                                  color: colorScheme.onSurfaceVariant.withAlpha(
                                    40,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _SkeletonBar(
                                  height: 14,
                                  width: 70,
                                  color: colorScheme.onSurfaceVariant.withAlpha(
                                    40,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                _SkeletonBar(
                                  height: 10,
                                  width: 50,
                                  color: colorScheme.onSurfaceVariant.withAlpha(
                                    40,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _SkeletonBar(
                                  height: 14,
                                  width: 70,
                                  color: colorScheme.onSurfaceVariant.withAlpha(
                                    40,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Cast section header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _SkeletonChip(),
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
                      child: Column(
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
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _SkeletonBar(
                            height: 8,
                            width: 50,
                            color: colorScheme.onSurfaceVariant.withAlpha(40),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Trailer section
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _SkeletonChip(width: 60),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: skeletonColor,
                  border: Border.all(color: borderColor, width: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.play_circle_outline,
                  size: 48,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              // Similar movies section
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _SkeletonChip(width: 100),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: List<Widget>.generate(
                    4,
                    (int index) => Container(
                      width: 130,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: skeletonColor,
                        border: Border.all(color: borderColor, width: 0.5),
                        borderRadius: BorderRadius.circular(24),
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

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({
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

class _SkeletonChip extends StatelessWidget {
  const _SkeletonChip({this.color, this.width = 60, this.height = 18});

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

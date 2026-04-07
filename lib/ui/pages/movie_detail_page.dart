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
  const MovieDetailPage({required this.params, Key? key}) : super(key: key);

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
              body: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
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
    var staggerIndex = 0;

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
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              'Released: ${DateFormat('dd MMMM yyyy').format(movie.releaseDate.toLocal())}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
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
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.black54,
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
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      if (movie.runtime > 0) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(
                          'Runtime: ${movie.runtime} minutes',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
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
                              ),
                            if (movie.revenue > 0)
                              _buildInfoColumn(
                                'Revenue',
                                '\$${_formatNumber(movie.revenue)}',
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
            staggered(_buildTrailerSection(trailerKey!)),
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

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: <Widget>[
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
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
                        backgroundColor: Colors.grey.shade300,
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

  Widget _buildTrailerSection(String trailerKey) {
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
              final url = Uri.parse(
                'https://www.youtube.com/watch?v=$trailerKey',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black,
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
                  const Center(
                    child: Icon(
                      Icons.play_circle_filled,
                      size: 64,
                      color: Colors.white70,
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
                                color: Colors.grey.shade300,
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

  static const _baseDuration = Duration(milliseconds: 600);
  static const _staggerDelay = Duration(milliseconds: 150);
  static const _startOffset = 60.0;
  static const _startBlur = 12.0;

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
        final value = _animation.value;
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

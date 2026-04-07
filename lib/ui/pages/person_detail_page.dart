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
      onModelReady: (model) async => model.initPageModel(),
      builder: (context, state, notifier) {
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
              ? const Center(child: CircularProgressIndicator())
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (detail.profilePath != null)
            Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                width: 200,
                child: PosterImage(imagePath: detail.profilePath!),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
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
                    label: Text(
                      detail.knownForDepartment,
                      style: const TextStyle(fontSize: 12),
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
                if (detail.birthday != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    'Born: ${detail.birthday}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
                if (detail.placeOfBirth != null) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    'From: ${detail.placeOfBirth}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
                if (detail.deathday != null) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    'Died: ${detail.deathday}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
                if (detail.biography.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  const Text(
                    'Biography',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detail.biography,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
                if (credits.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  const Text(
                    'Known For',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: credits.length,
                      itemBuilder: (context, index) {
                        final credit = credits[index];
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
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

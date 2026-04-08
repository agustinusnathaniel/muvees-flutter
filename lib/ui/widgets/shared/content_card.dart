import 'package:flutter/material.dart';
import 'package:muvees/ui/widgets/shared/poster_image.dart';

const double _borderRadius = 24;

class ContentCard extends StatelessWidget {
  const ContentCard({
    required this.title,
    required this.imageUrl,
    this.voteAverage,
    this.heroTag,
    super.key,
  });

  final String title;
  final String? imageUrl;
  final double? voteAverage;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final String? image = imageUrl;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.6 : 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          if (image != null)
            Positioned.fill(
              child: heroTag != null
                  ? Hero(
                      tag: heroTag!,
                      child: PosterImage(imagePath: image),
                    )
                  : PosterImage(imagePath: image),
            ),
          if (voteAverage != null)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withAlpha(204),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.star, color: Colors.amber, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      voteAverage!.toStringAsFixed(1),
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

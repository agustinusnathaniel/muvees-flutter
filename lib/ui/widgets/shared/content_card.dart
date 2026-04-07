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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Colors.black54, blurRadius: 8),
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
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.star, color: Colors.amber, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      voteAverage!.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
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

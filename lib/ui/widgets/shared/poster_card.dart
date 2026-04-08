import 'package:flutter/material.dart';
import 'package:muvees/ui/widgets/shared/poster_image.dart';

const double _borderRadius = 24;

class PosterCard extends StatelessWidget {
  const PosterCard({
    required this.name,
    required this.imageUrl,
    super.key,
  });

  final String name;
  final String? imageUrl;

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
              child: PosterImage(imagePath: image),
            ),
          Center(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: colorScheme.onPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

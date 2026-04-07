import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

const double _borderRadius = 24;
const String _tmdbImgHostUrl = 'https://image.tmdb.org/t/p/w500';

class PosterImage extends StatelessWidget {
  const PosterImage({
    required this.imagePath,
    this.isRounded = true,
    super.key,
  });

  final String imagePath;
  final bool isRounded;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(isRounded ? _borderRadius : 0);

    return ClipRRect(
      borderRadius: borderRadius,
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: CachedNetworkImage(
          imageUrl: '$_tmdbImgHostUrl$imagePath',
          fadeInDuration: const Duration(milliseconds: 300),
          placeholder: (context, url) => _Skeleton(borderRadius: borderRadius),
          errorWidget: (context, url, error) =>
              _Skeleton(borderRadius: borderRadius, isError: true),
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.borderRadius, this.isError = false});

  final BorderRadius borderRadius;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 750,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Colors.grey.shade300,
      ),
      child: isError
          ? Icon(
              Icons.broken_image_outlined,
              color: Colors.grey.shade400,
              size: 48,
            )
          : null,
    );
  }
}

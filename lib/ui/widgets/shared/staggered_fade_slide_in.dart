import 'dart:ui';

import 'package:flutter/material.dart';

class StaggeredFadeSlideIn extends StatefulWidget {
  const StaggeredFadeSlideIn({
    required this.index,
    required this.child,
    super.key,
  });

  final int index;
  final Widget child;

  static const _baseDuration = Duration(milliseconds: 500);
  static const _staggerDelay = Duration(milliseconds: 100);
  static const _startOffset = 60.0;
  static const _startBlur = 12.0;

  @override
  State<StaggeredFadeSlideIn> createState() => _StaggeredFadeSlideInState();
}

class _StaggeredFadeSlideInState extends State<StaggeredFadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: StaggeredFadeSlideIn._baseDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    Future<void>.delayed(
      Duration(
        milliseconds:
            widget.index * StaggeredFadeSlideIn._staggerDelay.inMilliseconds,
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
            offset: Offset(
              0,
              StaggeredFadeSlideIn._startOffset * (1 - value),
            ),
            child: ClipRRect(
              clipBehavior: Clip.none,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: StaggeredFadeSlideIn._startBlur * (1 - value),
                  sigmaY: StaggeredFadeSlideIn._startBlur * (1 - value),
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

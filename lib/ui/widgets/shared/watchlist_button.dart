import 'package:flutter/material.dart';
import 'package:muvees/core/models/watchlist_item.dart';
import 'package:muvees/core/services/watchlist_service.dart';

class WatchlistButton extends StatefulWidget {
  const WatchlistButton({
    required this.id,
    required this.type,
    required this.title,
    required this.posterPath,
    required this.voteAverage,
    Key? key,
  }) : super(key: key);

  final int id;
  final String type;
  final String title;
  final String? posterPath;
  final double voteAverage;

  @override
  State<WatchlistButton> createState() => _WatchlistButtonState();
}

class _WatchlistButtonState extends State<WatchlistButton> {
  bool _isInWatchlist = false;

  @override
  void initState() {
    super.initState();
    _checkWatchlist();
  }

  Future<void> _checkWatchlist() async {
    final bool isInWatchlist = await WatchlistService.isInWatchlist(
      id: widget.id,
      type: widget.type,
    );
    if (mounted) {
      setState(() {
        _isInWatchlist = isInWatchlist;
      });
    }
  }

  Future<void> _toggleWatchlist() async {
    final messenger = ScaffoldMessenger.of(context);
    if (_isInWatchlist) {
      await WatchlistService.removeFromWatchlist(
        id: widget.id,
        type: widget.type,
      );
      if (mounted) {
        // Note: SnackBars with an SnackBarAction do NOT auto-dismiss in Flutter.
        // Keeping action-less snackbars ensures they auto-hide after `duration`.
        messenger.showSnackBar(
          SnackBar(
            content: Text('${widget.title} removed from watchlist'),
            behavior: SnackBarBehavior.fixed,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      final WatchlistItem item = WatchlistItem(
        id: widget.id,
        type: widget.type,
        title: widget.title,
        posterPath: widget.posterPath,
        voteAverage: widget.voteAverage,
      );
      await WatchlistService.addToWatchlist(item);
      if (mounted) {
        // Note: SnackBars with an SnackBarAction do NOT auto-dismiss in Flutter.
        // Keeping action-less snackbars ensures they auto-hide after `duration`.
        messenger.showSnackBar(
          SnackBar(
            content: Text('${widget.title} added to watchlist'),
            behavior: SnackBarBehavior.fixed,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isInWatchlist = !_isInWatchlist;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isInWatchlist ? Icons.bookmark : Icons.bookmark_outline,
        color: _isInWatchlist ? Colors.teal : null,
      ),
      onPressed: _toggleWatchlist,
      tooltip: _isInWatchlist ? 'Remove from watchlist' : 'Add to watchlist',
    );
  }
}

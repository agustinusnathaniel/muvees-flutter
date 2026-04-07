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
    if (_isInWatchlist) {
      await WatchlistService.removeFromWatchlist(
        id: widget.id,
        type: widget.type,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.title} removed from watchlist'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.title} added to watchlist'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                await WatchlistService.removeFromWatchlist(
                  id: widget.id,
                  type: widget.type,
                );
                if (mounted) setState(() => _isInWatchlist = false);
              },
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
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

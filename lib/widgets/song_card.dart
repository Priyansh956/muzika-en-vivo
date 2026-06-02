// lib/widgets/song_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/download_state.dart';
import '../models/song.dart';
import '../theme/app_theme.dart';

/// A single row in the search results list.
class SongCard extends StatelessWidget {
  final Song song;
  final DownloadState downloadState;
  final VoidCallback onDownload;

  const SongCard({
    super.key,
    required this.song,
    required this.downloadState,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // ── Main row ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _Thumbnail(url: song.thumbnailUrl),
                  const SizedBox(width: 12),
                  Expanded(child: _Info(song: song)),
                  const SizedBox(width: 8),
                  _ActionButton(
                    state: downloadState,
                    onDownload: onDownload,
                  ),
                ],
              ),
            ),

            // ── Progress bar (only while downloading) ─────────────────
            if (downloadState.isDownloading)
              _ProgressBar(progress: downloadState.progress),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  final String? url;
  const _Thumbnail({this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: url != null
          ? CachedNetworkImage(
        imageUrl: url!,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        placeholder: (_, __) => _placeholder(),
        errorWidget: (_, __, ___) => _placeholder(),
      )
          : _placeholder(),
    );
  }

  Widget _placeholder() => Container(
    width: 60,
    height: 60,
    color: AppTheme.surfaceHi,
    child: const Icon(Icons.music_note_rounded,
        color: AppTheme.textLo, size: 28),
  );
}

class _Info extends StatelessWidget {
  final Song song;
  const _Info({required this.song});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          song.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.person_outline_rounded,
                size: 12, color: AppTheme.textMid),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                song.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.access_time_rounded,
                size: 12, color: AppTheme.textMid),
            const SizedBox(width: 4),
            Text(
              song.durationLabel,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final DownloadState state;
  final VoidCallback onDownload;
  const _ActionButton({required this.state, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    // Done
    if (state.isDone) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded,
            color: Colors.greenAccent, size: 22),
      );
    }

    // Downloading — show a spinning circular indicator
    if (state.isDownloading) {
      return SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                value: state.progress,
                strokeWidth: 3,
                backgroundColor: AppTheme.accentLo,
                valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.accent),
              ),
            ),
            Text(
              '${(state.progress * 100).toInt()}',
              style: const TextStyle(
                  fontSize: 9,
                  color: AppTheme.textHi,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    // Error
    if (state.isError) {
      return GestureDetector(
        onTap: onDownload,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.refresh_rounded,
              color: Colors.redAccent, size: 22),
        ),
      );
    }

    // Idle — download button
    return GestureDetector(
      onTap: onDownload,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: AppTheme.accentLo,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.download_rounded,
            color: AppTheme.accent, size: 22),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: progress,
      minHeight: 3,
      backgroundColor: AppTheme.accentLo,
      valueColor:
      const AlwaysStoppedAnimation<Color>(AppTheme.accent),
    );
  }
}
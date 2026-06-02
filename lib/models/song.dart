// lib/models/song.dart

/// Represents a single YouTube search result / song.
class Song {
  final String id;          // YouTube video ID  e.g. "dQw4w9WgXcQ"
  final String title;
  final String author;
  final Duration? duration;
  final String? thumbnailUrl;

  const Song({
    required this.id,
    required this.title,
    required this.author,
    this.duration,
    this.thumbnailUrl,
  });

  /// Formatted mm:ss duration string
  String get durationLabel {
    if (duration == null) return '--:--';
    final m = duration!.inMinutes;
    final s = duration!.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  /// A sanitised filename (no special chars)
  String get safeTitle =>
      title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
}
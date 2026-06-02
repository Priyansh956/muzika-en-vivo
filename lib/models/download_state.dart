// lib/models/download_state.dart

enum DownloadStatus { idle, downloading, done, error }

/// Tracks the download state for one song.
class DownloadState {
  final DownloadStatus status;
  final double progress; // 0.0 – 1.0
  final String? savedPath;
  final String? errorMessage;

  const DownloadState({
    this.status = DownloadStatus.idle,
    this.progress = 0.0,
    this.savedPath,
    this.errorMessage,
  });

  DownloadState copyWith({
    DownloadStatus? status,
    double? progress,
    String? savedPath,
    String? errorMessage,
  }) {
    return DownloadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      savedPath: savedPath ?? this.savedPath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isIdle => status == DownloadStatus.idle;
  bool get isDownloading => status == DownloadStatus.downloading;
  bool get isDone => status == DownloadStatus.done;
  bool get isError => status == DownloadStatus.error;
}
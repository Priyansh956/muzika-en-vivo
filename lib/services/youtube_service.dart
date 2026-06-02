// lib/services/youtube_service.dart

import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/song.dart';

class YoutubeService {
  final YoutubeExplode _yt = YoutubeExplode();

  // ─── Search ───────────────────────────────────────────────────────────────

  Future<List<Song>> search(String query, {int maxResults = 15}) async {
    final results = await _yt.search.search(query);
    return results.take(maxResults).map((v) => Song(
      id: v.id.value,
      title: v.title,
      author: v.author,
      duration: v.duration,
      thumbnailUrl: 'https://i.ytimg.com/vi/${v.id.value}/mqdefault.jpg',
    )).toList();
  }

  // ─── Download ─────────────────────────────────────────────────────────────

  Future<String> downloadAudio(
      Song song, {
        required void Function(double) onProgress,
      }) async {
    print('=== downloadAudio started for: ${song.title}');

    // Resolve the audio stream using youtube_explode_dart.
    // By explicitly providing client impersonations (iOS, Android VR, Safari), we merge
    // their available streams and bypass YouTube rate-limiting (RequestLimitExceededException).
    final manifest = await _yt.videos.streams.getManifest(
      song.id,
      ytClients: [
        YoutubeApiClient.ios,
        YoutubeApiClient.androidVr,
        YoutubeApiClient.safari,
      ],
    );
    final streamInfo = manifest.audioOnly.withHighestBitrate();
    final totalBytes = streamInfo.size.totalBytes;

    print('=== resolved stream, bytes: $totalBytes');

    final dir = await _getSaveDirectory();
    final filePath = '${dir.path}/${song.safeTitle}.m4a';

    print('=== saving to: $filePath');

    final file = File(filePath);
    final sink = file.openWrite();
    int received = 0;
    double lastProgress = -1.0;

    // Use a clean, dedicated HttpClient instance to download the stream.
    // This avoids connection pooling issues, locks, and freezes on mobile devices,
    // while ensuring we don't trigger mismatching signature blocks or 403 errors.
    final client = HttpClient();

    try {
      final request = await client.getUrl(streamInfo.url);
      final response = await request.close();

      if (response.statusCode != 200 && response.statusCode != 206) {
        throw Exception('HTTP ${response.statusCode}');
      }

      await for (final chunk in response) {
        sink.add(chunk);
        received += chunk.length;

        if (totalBytes > 0) {
          final progress = received / totalBytes;
          // Throttle progress updates to at least 1% increments or completion
          // to prevent excessive setState rebuilds in the UI thread.
          if ((progress - lastProgress).abs() >= 0.01 || progress == 1.0) {
            lastProgress = progress;
            onProgress(progress);
          }
        }
      }
      await sink.flush();
      await sink.close();
      client.close();
    } catch (e, stack) {
      print('=== DOWNLOAD ERROR: $e');
      print(stack);
      await sink.close();
      client.close(force: true);
      if (await file.exists()) {
        await file.delete();
      }
      rethrow;
    }

    print('=== file saved: $filePath');
    return filePath;
  }

  Future<Directory> _getSaveDirectory() async {
    if (Platform.isAndroid) {
      // Request storage permission for writing to the public Downloads folder.
      // On Android 11+ (API 30+), MANAGE_EXTERNAL_STORAGE is required.
      // On Android 10 and below, WRITE_EXTERNAL_STORAGE suffices.
      if (await Permission.manageExternalStorage.request().isGranted ||
          await Permission.storage.request().isGranted) {
        // Derive the public Downloads path from app-specific external storage.
        // getExternalStorageDirectory() returns something like:
        //   /storage/emulated/0/Android/data/com.example.muzika/files
        // We navigate up to /storage/emulated/0/ and append Download/Muzika.
        final appDir = await getExternalStorageDirectory();
        if (appDir != null) {
          final parts = appDir.path.split('/');
          final androidIdx = parts.indexOf('Android');
          if (androidIdx > 0) {
            final rootPath = parts.sublist(0, androidIdx).join('/');
            final downloadsDir = Directory('$rootPath/Download/Muzika');
            if (!await downloadsDir.exists()) {
              await downloadsDir.create(recursive: true);
            }
            return downloadsDir;
          }
        }
      }

      // Fallback to app-private external storage if permission denied
      final appDir = await getExternalStorageDirectory();
      if (appDir != null) {
        final muzika = Directory('${appDir.path}/Muzika');
        if (!await muzika.exists()) await muzika.create(recursive: true);
        return muzika;
      }
    }

    // Fallback for desktop or if Android path derivation fails
    final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
    final muzika = Directory('${dir.path}/Muzika');
    if (!await muzika.exists()) await muzika.create(recursive: true);
    return muzika;
  }

  void dispose() => _yt.close();
}
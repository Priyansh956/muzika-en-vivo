// lib/screens/home_screen.dart

import 'package:flutter/material.dart';

import '../models/download_state.dart';
import '../models/song.dart';
import '../services/youtube_service.dart';
import '../theme/app_theme.dart';
import '../widgets/search_bar_field.dart';
import '../widgets/song_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Dependencies ───────────────────────────────────────────────────────────
  final _service = YoutubeService();
  final _searchController = TextEditingController();

  // ── State ──────────────────────────────────────────────────────────────────
  List<Song> _results = [];
  bool _isSearching = false;
  String? _searchError;

  // videoId → DownloadState
  final Map<String, DownloadState> _downloads = {};

  @override
  void dispose() {
    _service.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Search ─────────────────────────────────────────────────────────────────
  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isSearching = true;
      _searchError = null;
      _results = [];
    });

    try {
      final songs = await _service.search(query);
      setState(() => _results = songs);
    } catch (e) {
      if (e.toString().contains('RequestLimitExceededException') || e.toString().contains('rate limiting')) {
        setState(() => _searchError = 'YouTube rate limit exceeded. Please wait a few minutes and try again.');
      } else {
        setState(() => _searchError = 'Search failed. Check your internet connection.');
      }
    } finally {
      setState(() => _isSearching = false);
    }
  }

  // ── Download ───────────────────────────────────────────────────────────────
  Future<void> _download(Song song) async {
    final current = _downloads[song.id];
    if (current != null && (current.isDownloading || current.isDone)) return;

    setState(() {
      _downloads[song.id] = const DownloadState(
        status: DownloadStatus.downloading,
        progress: 0,
      );
    });

    try {
      final path = await _service.downloadAudio(
        song,
        onProgress: (p) {
          if (mounted) {
            setState(() {
              _downloads[song.id] = DownloadState(
                status: DownloadStatus.downloading,
                progress: p,
              );
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _downloads[song.id] = DownloadState(
            status: DownloadStatus.done,
            progress: 1,
            savedPath: path,
          );
        });
        _showSnack('✓ Saved: ${song.title}', isError: false);
      }
    } catch (e, stackTrace) {
      print('DOWNLOAD ERROR: $e');
      print('STACK: $stackTrace');

      if (mounted) {
        String msg = e.toString();
        if (msg.contains('RequestLimitExceededException') || msg.contains('rate limiting')) {
          msg = 'YouTube rate limit exceeded. Please wait a few minutes and try again.';
        }
        setState(() {
          _downloads[song.id] = DownloadState(
            status: DownloadStatus.error,
            errorMessage: msg,
          );
        });
        _showSnack(msg, isError: true);
      }
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            const SizedBox(height: 8),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Muzi',
              style: TextStyle(
                color: AppTheme.textHi,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            TextSpan(
              text: 'ka',
              style: TextStyle(
                color: AppTheme.accent,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SearchBarField(
        controller: _searchController,
        isSearching: _isSearching,
        onSubmit: _search,
      ),
    );
  }

  Widget _buildBody() {
    // ── Searching spinner ──────────────────────────────────────────────────
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // ── Error ──────────────────────────────────────────────────────────────
    if (_searchError != null) {
      return _EmptyState(
        icon: Icons.wifi_off_rounded,
        label: _searchError!,
      );
    }

    // ── No results yet ─────────────────────────────────────────────────────
    if (_results.isEmpty) {
      return const _EmptyState(
        icon: Icons.music_note_rounded,
        label: 'Search for any song\nto get started',
      );
    }

    // ── Results list ───────────────────────────────────────────────────────
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      itemCount: _results.length,
      itemBuilder: (context, i) {
        final song = _results[i];
        return SongCard(
          song: song,
          downloadState: _downloads[song.id] ?? const DownloadState(),
          onDownload: () => _download(song),
        );
      },
    );
  }
}

// ─── Empty / placeholder state ────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EmptyState({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppTheme.textLo),
          const SizedBox(height: 16),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textMid,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
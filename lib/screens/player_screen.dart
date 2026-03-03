import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class PlayerScreen extends StatefulWidget {
  final Map episode;
  final String animeTitle;
  final String? aniwatchEpisodeId;

  const PlayerScreen({
    super.key,
    required this.episode,
    required this.animeTitle,
    this.aniwatchEpisodeId,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final Player _player;
  late final VideoController _controller;

  String? videoUrl;
  bool _isFullscreen = false;
  bool _isLoading = true;
  bool _hasError = false;

  static const _headers = {
    'Referer': 'https://hianime.to',
    'Origin': 'https://hianime.to',
    'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120.0.0.0 Mobile Safari/537.36',
  };

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);

    final url = widget.episode['video_url'];
    if (url != null && (url as String).isNotEmpty) {
      videoUrl = url;
      _playVideo(url);
    }
  }

  Future<void> _playVideo(String url) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      await _player.open(
        Media(url, httpHeaders: _headers),
      );
      _player.stream.error.listen((err) {
        if (mounted && err.isNotEmpty) {
          setState(() => _hasError = true);
        }
      });
      _player.stream.buffering.listen((buffering) {
        if (mounted) setState(() => _isLoading = buffering);
      });
    } catch (e) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _switchLanguage(String url) {
    if (url == videoUrl) return;
    setState(() => videoUrl = url);
    _playVideo(url);
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final epNumber = widget.episode['number'] ?? '';
    final epTitle = widget.episode['title'] ?? 'Episode $epNumber';
    final hasArabic = (widget.episode['video_url_arabic'] ?? '').isNotEmpty;

    if (_isFullscreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(child: Video(controller: _controller)),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Color(0xFFE53935))),
            Positioned(
              top: 16, right: 16,
              child: IconButton(
                icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                onPressed: _toggleFullscreen,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.animeTitle,
              style: const TextStyle(color: Colors.white, fontSize: 14,
                fontWeight: FontWeight.bold)),
            Text('Episode $epNumber',
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Video Player
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                Container(color: Colors.black),
                if (videoUrl != null)
                  Video(controller: _controller),
                if (_isLoading && videoUrl != null)
                  const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE53935))),
                if (_hasError)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 40),
                        const SizedBox(height: 8),
                        const Text('Failed to load video',
                          style: TextStyle(color: Colors.white54)),
                        TextButton(
                          onPressed: () => _playVideo(videoUrl!),
                          child: const Text('Retry',
                            style: TextStyle(color: Color(0xFFE53935))),
                        ),
                      ],
                    ),
                  ),
                if (videoUrl == null)
                  const Center(
                    child: Text('No video available',
                      style: TextStyle(color: Colors.white54))),
                // Fullscreen button
                Positioned(
                  bottom: 8, right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.fullscreen, color: Colors.white70),
                    onPressed: _toggleFullscreen,
                  ),
                ),
              ],
            ),
          ),

          // Info & Controls
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Episode info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46, height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text('$epNumber',
                              style: const TextStyle(color: Color(0xFFE53935),
                                fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.animeTitle,
                                style: const TextStyle(color: Colors.white,
                                  fontSize: 13, fontWeight: FontWeight.bold),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 3),
                              Text(epTitle,
                                style: const TextStyle(color: Colors.white54,
                                  fontSize: 11),
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Language switch
                  if (hasArabic) ...[
                    const Text('Language',
                      style: TextStyle(color: Color(0xFFE53935), fontSize: 14,
                        fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _langButton(
                          '🌐 English', widget.episode['video_url'] ?? '')),
                        const SizedBox(width: 10),
                        Expanded(child: _langButton(
                          '🇸🇦 عربي', widget.episode['video_url_arabic'] ?? '')),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Copy URL
                  if (videoUrl != null) ...[
                    const Text('Video URL',
                      style: TextStyle(color: Color(0xFFE53935), fontSize: 14,
                        fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: videoUrl!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('URL copied!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(videoUrl!,
                                style: const TextStyle(color: Colors.white38,
                                  fontSize: 11),
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.copy, color: Colors.white38, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _langButton(String label, String url) {
    final isSelected = videoUrl == url;
    return GestureDetector(
      onTap: () => _switchLanguage(url),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
            ? const Color(0xFFE53935).withOpacity(0.15)
            : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFE53935) : Colors.white12),
        ),
        child: Center(
          child: Text(label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFE53935) : Colors.white54,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            )),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:better_player/better_player.dart';

class PlayerScreen extends StatefulWidget {
  final Map episode;
  final String animeTitle;

  const PlayerScreen({super.key, required this.episode, required this.animeTitle});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  BetterPlayerController? _controller;
  bool isLoading = true;
  bool hasError = false;
  bool isArabic = false;

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  Future<void> initPlayer({bool arabic = false}) async {
    setState(() { isLoading = true; hasError = false; });

    final url = arabic
        ? (widget.episode['video_url_arabic'] ?? widget.episode['video_url'] ?? '')
        : (widget.episode['video_url'] ?? '');

    if (url.isEmpty) {
      setState(() { hasError = true; isLoading = false; });
      return;
    }

    try {
      _controller?.dispose();

      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url,
        videoFormat: url.contains('.m3u8')
            ? BetterPlayerVideoFormat.hls
            : BetterPlayerVideoFormat.other,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Referer': 'https://hianime.to',
        },
      );

      _controller = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: true,
          looping: false,
          fullScreenByDefault: false,
          allowedScreenSleep: false,
          autoDetectFullscreenDeviceOrientation: true,
          autoDetectFullscreenAspectRatio: true,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enableOverflowMenu: false,
            enableSkips: true,
            progressBarPlayedColor: Color(0xFFE53935),
            progressBarHandleColor: Color(0xFFE53935),
            progressBarBufferedColor: Colors.white30,
            progressBarBackgroundColor: Colors.white12,
            loadingColor: Color(0xFFE53935),
            playIcon: Icons.play_arrow,
            pauseIcon: Icons.pause,
          ),
          aspectRatio: 16 / 9,
          fit: BoxFit.contain,
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 50),
                  SizedBox(height: 10),
                  Text('Failed to load video',
                    style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE53935)),
                    onPressed: () => initPlayer(arabic: isArabic),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          },
        ),
        betterPlayerDataSource: dataSource,
      );

      setState(() { isLoading = false; });
    } catch (e) {
      setState(() { hasError = true; isLoading = false; });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final epNumber = widget.episode['number'] ?? '';
    final epTitle = widget.episode['title'] ?? 'Episode $epNumber';
    final hasArabic = (widget.episode['video_url_arabic'] ?? '').isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.animeTitle,
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            Text('Episode $epNumber',
              style: TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: isLoading
                ? Container(
                    color: Colors.black,
                    child: Center(child: CircularProgressIndicator(color: Color(0xFFE53935))),
                  )
                : hasError
                    ? Container(
                        color: Colors.black,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, color: Colors.red, size: 50),
                              SizedBox(height: 10),
                              Text('Failed to load video',
                                style: TextStyle(color: Colors.white70)),
                              SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFE53935)),
                                onPressed: () => initPlayer(arabic: isArabic),
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : BetterPlayer(controller: _controller!),
          ),
          Expanded(
            child: Container(
              color: Color(0xFF0D0D0D),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Now Playing',
                    style: TextStyle(color: Color(0xFFE53935), fontSize: 13,
                      fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(widget.animeTitle,
                    style: TextStyle(color: Colors.white, fontSize: 16,
                      fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Episode $epNumber - $epTitle',
                    style: TextStyle(color: Colors.white54, fontSize: 13)),
                  if (hasArabic) ...[
                    SizedBox(height: 20),
                    Text('Language',
                      style: TextStyle(color: Color(0xFFE53935), fontSize: 13,
                        fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        _langButton('English', !isArabic, () {
                          setState(() { isArabic = false; });
                          initPlayer(arabic: false);
                        }),
                        SizedBox(width: 10),
                        _langButton('عربي', isArabic, () {
                          setState(() { isArabic = true; });
                          initPlayer(arabic: true);
                        }),
                      ],
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

  Widget _langButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFE53935) : Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Color(0xFFE53935) : Colors.white24),
        ),
        child: Text(label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          )),
      ),
    );
  }
}
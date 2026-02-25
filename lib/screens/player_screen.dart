import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class PlayerScreen extends StatefulWidget {
  final Map episode;
  final String animeTitle;

  const PlayerScreen({super.key, required this.episode, required this.animeTitle});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _controller;
  bool isLoading = true;
  bool hasError = false;
  bool isArabic = false;
  bool showControls = true;
  bool isFullscreen = false;

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  Future<void> initPlayer({bool arabic = false}) async {
    setState(() { isLoading = true; hasError = false; });
    await _controller?.dispose();

    final url = arabic
        ? (widget.episode['video_url_arabic'] ?? widget.episode['video_url'] ?? '')
        : (widget.episode['video_url'] ?? '');

    if (url.isEmpty) {
      setState(() { hasError = true; isLoading = false; });
      return;
    }

    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await _controller!.initialize();
      _controller!.addListener(() { setState(() {}); });
      _controller!.play();
      setState(() { isLoading = false; });
    } catch (e) {
      setState(() { hasError = true; isLoading = false; });
    }
  }

  void toggleFullscreen() {
    setState(() { isFullscreen = !isFullscreen; });
    if (isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}';
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
      appBar: isFullscreen ? null : AppBar(
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
      body: isFullscreen
          ? _buildPlayer(hasArabic, epNumber, epTitle)
          : Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _buildPlayer(hasArabic, epNumber, epTitle),
                ),
                Expanded(
                  child: Container(
                    color: Color(0xFF0D0D0D),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Now Playing',
                          style: TextStyle(color: Color(0xFFE53935), fontSize: 13, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(widget.animeTitle,
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Episode $epNumber - $epTitle',
                          style: TextStyle(color: Colors.white54, fontSize: 13)),
                        if (hasArabic) ...[
                          SizedBox(height: 20),
                          Text('Language',
                            style: TextStyle(color: Color(0xFFE53935), fontSize: 13, fontWeight: FontWeight.bold)),
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

  Widget _buildPlayer(bool hasArabic, dynamic epNumber, String epTitle) {
    if (isLoading) {
      return Container(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator(color: Color(0xFFE53935))),
      );
    }

    if (hasError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 50),
              SizedBox(height: 10),
              Text('Failed to load video', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE53935)),
                onPressed: () => initPlayer(arabic: isArabic),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final position = _controller!.value.position;
    final duration = _controller!.value.duration;
    final isPlaying = _controller!.value.isPlaying;

    return GestureDetector(
      onTap: () => setState(() => showControls = !showControls),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(color: Colors.black),
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
          if (showControls) ...[
            Container(color: Colors.black45),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Column(
                children: [
                  VideoProgressIndicator(
                    _controller!,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: Color(0xFFE53935),
                      bufferedColor: Colors.white30,
                      backgroundColor: Colors.white12,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        Text(formatDuration(position),
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text(' / ', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Text(formatDuration(duration),
                          style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Spacer(),
                        IconButton(
                          icon: Icon(
                            isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                            color: Colors.white),
                          onPressed: toggleFullscreen,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.replay_10, color: Colors.white, size: 36),
                  onPressed: () {
                    final pos = position - Duration(seconds: 10);
                    _controller!.seekTo(pos < Duration.zero ? Duration.zero : pos);
                  },
                ),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: Colors.white, size: 60),
                  onPressed: () {
                    isPlaying ? _controller!.pause() : _controller!.play();
                  },
                ),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(Icons.forward_10, color: Colors.white, size: 36),
                  onPressed: () {
                    final pos = position + Duration(seconds: 10);
                    _controller!.seekTo(pos > duration ? duration : pos);
                  },
                ),
              ],
            ),
          ],
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class PlayerScreen extends StatefulWidget {
  final Map episode;
  final String animeTitle;

  const PlayerScreen({super.key, required this.episode, required this.animeTitle});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool isLoading = true;
  bool hasError = false;
  bool isArabic = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    initPlayer();
  }

  Future<void> initPlayer({bool arabic = false}) async {
    setState(() { isLoading = true; hasError = false; });

    await _chewieController?.pause();
    _chewieController?.dispose();
    await _videoController?.dispose();

    final url = arabic
        ? (widget.episode['video_url_arabic'] ?? widget.episode['video_url'] ?? '')
        : (widget.episode['video_url'] ?? '');

    if (url.isEmpty) {
      setState(() { hasError = true; isLoading = false; });
      return;
    }

    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Color(0xFFE53935),
          handleColor: Color(0xFFE53935),
          bufferedColor: Colors.white30,
          backgroundColor: Colors.white12,
        ),
        placeholder: Container(color: Colors.black),
        errorBuilder: (context, errorMessage) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 50),
              SizedBox(height: 10),
              Text('Failed to load video', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );

      setState(() { isLoading = false; });
    } catch (e) {
      setState(() { hasError = true; isLoading = false; });
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _chewieController?.dispose();
    _videoController?.dispose();
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
            Text('Episode $epNumber - $epTitle',
              style: TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
        actions: [
          if (hasArabic)
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Row(
                children: [
                  Text('AR', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  SizedBox(width: 6),
                  Switch(
                    value: isArabic,
                    activeColor: Color(0xFFE53935),
                    onChanged: (val) {
                      setState(() { isArabic = val; });
                      initPlayer(arabic: val);
                    },
                  ),
                  Text('EN', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: isLoading
                ? Container(
                    color: Colors.black,
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFFE53935)),
                    ),
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
                                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE53935)),
                                onPressed: () => initPlayer(arabic: isArabic),
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Chewie(controller: _chewieController!),
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
                    SizedBox(height: 16),
                    Text('Audio/Subtitle',
                      style: TextStyle(color: Color(0xFFE53935), fontSize: 13, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
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
          border: Border.all(
            color: isSelected ? Color(0xFFE53935) : Colors.white24,
          ),
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
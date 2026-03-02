import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';

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
  String? videoUrl;

  @override
  void initState() {
    super.initState();
    if (widget.episode['video_url'] != null &&
        (widget.episode['video_url'] as String).isNotEmpty) {
      videoUrl = widget.episode['video_url'];
    }
  }

  Future<void> openInPlayer(String playerType) async {
    if (videoUrl == null || videoUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No video URL available'), backgroundColor: Colors.red));
      return;
    }

    String playerName;
    String package;

    switch (playerType) {
      case 'asd':
        playerName = 'ASD Player';
        package = 'com.app_mo.splayer';
        break;
      case 'mx':
        playerName = 'MX Player';
        package = 'com.mxtech.videoplayer.ad';
        break;
      case 'vlc':
        playerName = 'VLC Player';
        package = 'org.videolan.vlc';
        break;
      default:
        playerName = 'Player';
        package = '';
    }

    try {
      final intent = AndroidIntent(
        action: 'action_view',
        data: videoUrl,
        type: 'video/*',
        package: package,
        arguments: {
          'title': widget.animeTitle,
          'headers': [
            'Referer', 'https://hianime.to',
            'User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Origin', 'https://hianime.to',
          ],
        },
      );
      await intent.launch();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$playerName is not installed'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'Install',
            textColor: Colors.white,
            onPressed: () => _openPlayStore(playerType),
          ),
        ),
      );
    }
  }

  Future<void> _openPlayStore(String playerType) async {
    String package;
    switch (playerType) {
      case 'asd':
        package = 'com.app_mo.splayer';
        break;
      case 'mx':
        package = 'com.mxtech.videoplayer.ad';
        break;
      case 'vlc':
        package = 'org.videolan.vlc';
        break;
      default:
        return;
    }
    await launchUrl(
      Uri.parse('https://play.google.com/store/apps/details?id=$package'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final epNumber = widget.episode['number'] ?? '';
    final epTitle = widget.episode['title'] ?? 'Episode $epNumber';
    final hasArabic = (widget.episode['video_url_arabic'] ?? '').isNotEmpty;

    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A1A),
        iconTheme: IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.animeTitle,
              style: TextStyle(color: Colors.white, fontSize: 14,
                fontWeight: FontWeight.bold)),
            Text('Episode $epNumber',
              style: TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFFE53935).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text('$epNumber',
                        style: TextStyle(color: Color(0xFFE53935),
                          fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.animeTitle,
                          style: TextStyle(color: Colors.white, fontSize: 14,
                            fontWeight: FontWeight.bold),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        SizedBox(height: 4),
                        Text(epTitle,
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            if (hasArabic) ...[
              Text('Language',
                style: TextStyle(color: Color(0xFFE53935), fontSize: 15,
                  fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _langButton('🌐 English',
                      widget.episode['video_url'] ?? ''),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _langButton('🇸🇦 عربي',
                      widget.episode['video_url_arabic'] ?? ''),
                  ),
                ],
              ),
              SizedBox(height: 24),
            ],

            Text('Choose Player',
              style: TextStyle(color: Color(0xFFE53935), fontSize: 15,
                fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _playerButton(
              name: 'ASD Player',
              description: 'Recommended',
              color: Colors.blue,
              icon: Icons.play_circle_fill,
              onTap: () => openInPlayer('asd'),
            ),
            SizedBox(height: 10),
            _playerButton(
              name: 'MX Player',
              description: 'Popular choice',
              color: Colors.orange,
              icon: Icons.play_circle_fill,
              onTap: () => openInPlayer('mx'),
            ),
            SizedBox(height: 10),
            _playerButton(
              name: 'VLC Player',
              description: 'Open source',
              color: Colors.deepOrange,
              icon: Icons.play_circle_fill,
              onTap: () => openInPlayer('vlc'),
            ),
            SizedBox(height: 24),

            if (videoUrl != null) ...[
              Text('Video URL',
                style: TextStyle(color: Color(0xFFE53935), fontSize: 15,
                  fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(videoUrl!,
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _langButton(String label, String url) {
    final isSelected = videoUrl == url;
    return GestureDetector(
      onTap: () => setState(() => videoUrl = url),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFE53935).withOpacity(0.15) : Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFFE53935) : Colors.white12),
        ),
        child: Center(
          child: Text(label,
            style: TextStyle(
              color: isSelected ? Color(0xFFE53935) : Colors.white54,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            )),
        ),
      ),
    );
  }

  Widget _playerButton({
    required String name,
    required String description,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 45, height: 45,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                    style: TextStyle(color: Colors.white, fontSize: 14,
                      fontWeight: FontWeight.bold)),
                  Text(description,
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }
}
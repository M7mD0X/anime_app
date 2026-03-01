import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool isLoading = false;
  String? videoUrl;
  String? errorMsg;

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

  Uri uri;
  String playerName;

  switch (playerType) {
    case 'asd':
      uri = Uri.parse(
        'intent:$videoUrl#Intent;package=com.app_mo.splayer;S.title=${Uri.encodeComponent(widget.animeTitle)};end'
      );
      playerName = 'ASD Player';
      break;
    case 'mx':
      uri = Uri.parse(
        'intent:$videoUrl#Intent;package=com.mxtech.videoplayer.ad;S.title=${Uri.encodeComponent(widget.animeTitle)};end'
      );
      playerName = 'MX Player';
      break;
    case 'vlc':
      uri = Uri.parse('vlc://$videoUrl');
      playerName = 'VLC Player';
      break;
    default:
      uri = Uri.parse(videoUrl!);
      playerName = 'Default Player';
  }

  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
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
            // Episode Info
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

            // Choose Language
            if (hasArabic) ...[
              Text('Language',
                style: TextStyle(color: Color(0xFFE53935), fontSize: 15,
                  fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _langButton('🌐 English', true,
                      widget.episode['video_url'] ?? ''),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _langButton('🇸🇦 عربي', false,
                      widget.episode['video_url_arabic'] ?? ''),
                  ),
                ],
              ),
              SizedBox(height: 24),
            ],

            // Choose Player
            Text('Choose Player',
              style: TextStyle(color: Color(0xFFE53935), fontSize: 15,
                fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _playerButton(
              icon: '🎬',
              name: 'ASD Player',
              description: 'Recommended',
              color: Colors.blue,
              onTap: () => openInPlayer('asd'),
            ),
            SizedBox(height: 10),
            _playerButton(
              icon: '▶️',
              name: 'MX Player',
              description: 'Popular choice',
              color: Colors.orange,
              onTap: () => openInPlayer('mx'),
            ),
            SizedBox(height: 10),
            _playerButton(
              icon: '🔵',
              name: 'VLC Player',
              description: 'Open source',
              color: Colors.deepOrange,
              onTap: () => openInPlayer('vlc'),
            ),
            SizedBox(height: 24),

            // Video URL info
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

  Widget _langButton(String label, bool isEnglish, String url) {
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
    required String icon,
    required String name,
    required String description,
    required Color color,
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
              child: Center(
                child: Text(icon, style: TextStyle(fontSize: 22)),
              ),
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
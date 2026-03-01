import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
  InAppWebViewController? _webController;
  bool isLoading = true;

  String get episodeUrl {
    if (widget.aniwatchEpisodeId != null) {
      return 'https://hianime.to/watch/${widget.aniwatchEpisodeId}';
    }
    return widget.episode['video_url'] ?? '';
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final epNumber = widget.episode['number'] ?? '';

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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _webController?.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(episodeUrl),
              headers: {
                'User-Agent': 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/120.0.0.0 Mobile Safari/537.36',
              },
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              useWideViewPort: true,
              loadWithOverviewMode: true,
              supportZoom: false,
              useShouldOverrideUrlLoading: true,
            ),
            onWebViewCreated: (controller) {
              _webController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() { isLoading = true; });
            },
            onLoadStop: (controller, url) async {
              setState(() { isLoading = false; });
              // Hide ads and unnecessary elements
              await controller.evaluateJavascript(source: '''
                var style = document.createElement('style');
                style.innerHTML = `
                  .header, .footer, .sidebar, #sidebar, 
                  .ads, .ad, [class*="ad-"], [id*="ad-"],
                  .navbar, nav, .social-links,
                  .film-detail, .film-description,
                  .seasons, .related,
                  #myModal, .modal-backdrop
                  { display: none !important; }
                  .watch-content { margin: 0 !important; padding: 0 !important; }
                  #player { width: 100vw !important; }
                `;
                document.head.appendChild(style);
              ''');
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              return NavigationActionPolicy.ALLOW;
            },
          ),
          if (isLoading)
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFE53935)),
                    SizedBox(height: 16),
                    Text('Loading episode...',
                      style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
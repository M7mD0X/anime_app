import 'package:flutter/material.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.download_outlined, color: Colors.white24, size: 80),
          SizedBox(height: 16),
          Text('No downloads yet',
            style: TextStyle(color: Colors.white38, fontSize: 16)),
          SizedBox(height: 8),
          Text('Downloaded episodes will appear here',
            style: TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, color: Colors.white24, size: 80),
          SizedBox(height: 16),
          Text('No watch history yet',
            style: TextStyle(color: Colors.white38, fontSize: 16)),
          SizedBox(height: 8),
          Text('Anime you watch will appear here',
            style: TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }
}
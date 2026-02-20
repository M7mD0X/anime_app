import 'package:flutter/material.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _selectedTab = 0;

  final List<String> _tabs = [
    'Watching',
    'Watch Later',
    'Finished',
    'On Hold',
    'Dropped',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Color(0xFF1A1A1A),
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            itemCount: _tabs.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedTab == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedTab = index),
                child: Container(
                  margin: EdgeInsets.only(right: 8),
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFFE53935) : Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_tabs[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white54,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    )),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_outline, color: Colors.white24, size: 80),
                SizedBox(height: 16),
                Text('No anime in ${_tabs[_selectedTab]}',
                  style: TextStyle(color: Colors.white38, fontSize: 16)),
                SizedBox(height: 8),
                Text('Browse anime and add them to your library',
                  style: TextStyle(color: Colors.white24, fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'latest_screen.dart';
import 'anime_list_screen.dart';
import 'library_screen.dart';
import 'history_screen.dart';
import 'downloads_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Map> _tabs = [
    {'title': 'Latest Episodes', 'icon': Icons.play_circle_outline},
    {'title': 'Anime List', 'icon': Icons.list},
    {'title': 'My Library', 'icon': Icons.bookmark_outline},
    {'title': 'History', 'icon': Icons.history},
    {'title': 'Downloads', 'icon': Icons.download_outlined},
    {'title': 'Settings', 'icon': Icons.settings_outlined},
  ];

  final List<Widget> _screens = [
    LatestScreen(),
    AnimeListScreen(),
    LibraryScreen(),
    HistoryScreen(),
    DownloadsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE53935),
              ),
              child: Icon(Icons.play_arrow, color: Colors.white, size: 18),
            ),
            SizedBox(width: 8),
            Text('Anime MT',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Color(0xFFE53935)),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Color(0xFF141414),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                color: Color(0xFF1A1A1A),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE53935),
                      ),
                      child: Icon(Icons.play_arrow, color: Colors.white, size: 30),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Anime MT',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Your Anime World',
                          style: TextStyle(color: Color(0xFFE53935), fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _tabs.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedIndex == index;
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isSelected ? Color(0xFFE53935).withOpacity(0.15) : Colors.transparent,
                      ),
                      child: ListTile(
                        leading: Icon(
                          _tabs[index]['icon'],
                          color: isSelected ? Color(0xFFE53935) : Colors.white54,
                        ),
                        title: Text(
                          _tabs[index]['title'],
                          style: TextStyle(
                            color: isSelected ? Color(0xFFE53935) : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onTap: () {
                          setState(() { _selectedIndex = index; });
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
              Divider(color: Colors.white12),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text('Anime MT v1.0',
                  style: TextStyle(color: Colors.white24, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}
import 'package:flutter/material.dart';
import 'latest_screen.dart';
import 'anime_list_screen.dart';
import 'library_screen.dart';
import 'history_screen.dart';
import 'downloads_screen.dart';
import 'settings_screen.dart';
import 'search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    LatestScreen(),
    AnimeListScreen(),
    LibraryScreen(),
    HistoryScreen(),
    DownloadsScreen(),
    SettingsScreen(),
  ];

  final List<Map> _menuItems = [
    {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
    {'icon': Icons.movie_outlined, 'activeIcon': Icons.movie, 'label': 'Anime'},
    {'icon': Icons.bookmark_outline, 'activeIcon': Icons.bookmark, 'label': 'Library'},
    {'icon': Icons.history, 'activeIcon': Icons.history, 'label': 'History'},
    {'icon': Icons.download_outlined, 'activeIcon': Icons.download, 'label': 'Downloads'},
    {'icon': Icons.settings_outlined, 'activeIcon': Icons.settings, 'label': 'Settings'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Color(0xFF0D0D0D),
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
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: Color(0xFFE53935),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.play_arrow, color: Colors.white, size: 18),
            ),
            SizedBox(width: 8),
            Text('Anime MT',
              style: TextStyle(color: Colors.white, fontSize: 18,
                fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => SearchScreen())),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _screens[_currentIndex],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Color(0xFF1A1A1A),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 45, height: 45,
                    decoration: BoxDecoration(
                      color: Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.play_arrow, color: Colors.white, size: 28),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Anime MT',
                        style: TextStyle(color: Colors.white, fontSize: 18,
                          fontWeight: FontWeight.bold)),
                      Text('Your Anime World',
                        style: TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white12),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  final isSelected = _currentIndex == index;
                  return Container(
                    margin: EdgeInsets.only(bottom: 4),
                    child: ListTile(
                      leading: Icon(
                        isSelected ? item['activeIcon'] : item['icon'],
                        color: isSelected ? Color(0xFFE53935) : Colors.white54,
                      ),
                      title: Text(item['label'],
                        style: TextStyle(
                          color: isSelected ? Color(0xFFE53935) : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        )),
                      selected: isSelected,
                      selectedTileColor: Color(0xFFE53935).withOpacity(0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                      onTap: () {
                        setState(() => _currentIndex = index);
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
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white24, size: 14),
                  SizedBox(width: 6),
                  Text('Anime MT v1.0',
                    style: TextStyle(color: Colors.white24, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
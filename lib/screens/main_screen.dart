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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: _screens[_currentIndex],
      drawer: _buildDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFE53935),
        mini: true,
        child: Icon(Icons.search, color: Colors.white),
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => SearchScreen())),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: Color(0xFF1A1A1A),
        selectedItemColor: Color(0xFFE53935),
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.movie_outlined), activeIcon: Icon(Icons.movie), label: 'Anime'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), activeIcon: Icon(Icons.bookmark), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.download_outlined), activeIcon: Icon(Icons.download), label: 'Downloads'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
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
            _drawerItem(Icons.home, 'Home', 0),
            _drawerItem(Icons.movie, 'Anime List', 1),
            _drawerItem(Icons.bookmark, 'Library', 2),
            _drawerItem(Icons.history, 'History', 3),
            _drawerItem(Icons.download, 'Downloads', 4),
            _drawerItem(Icons.settings, 'Settings', 5),
            Spacer(),
            Divider(color: Colors.white12),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text('Anime MT v1.0',
                style: TextStyle(color: Colors.white24, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(icon,
        color: isSelected ? Color(0xFFE53935) : Colors.white54),
      title: Text(label,
        style: TextStyle(
          color: isSelected ? Color(0xFFE53935) : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        )),
      selected: isSelected,
      selectedTileColor: Color(0xFFE53935).withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context);
      },
    );
  }
}
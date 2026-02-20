import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _language = 'English';
  String _theme = 'Dark';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _sectionTitle('Appearance'),
        _settingsTile(
          icon: Icons.language,
          title: 'Language',
          subtitle: _language,
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: Color(0xFF1A1A1A),
                title: Text('Language', style: TextStyle(color: Colors.white)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: ['English'].map((lang) => ListTile(
                    title: Text(lang, style: TextStyle(color: Colors.white)),
                    trailing: _language == lang
                        ? Icon(Icons.check, color: Color(0xFFE53935))
                        : null,
                    onTap: () {
                      setState(() => _language = lang);
                      Navigator.pop(context);
                    },
                  )).toList(),
                ),
              ),
            );
          },
        ),
        _settingsTile(
          icon: Icons.palette_outlined,
          title: 'Theme',
          subtitle: _theme,
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: Color(0xFF1A1A1A),
                title: Text('Theme', style: TextStyle(color: Colors.white)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: ['Dark', 'Light', 'System'].map((theme) => ListTile(
                    title: Text(theme, style: TextStyle(color: Colors.white)),
                    trailing: _theme == theme
                        ? Icon(Icons.check, color: Color(0xFFE53935))
                        : null,
                    onTap: () {
                      setState(() => _theme = theme);
                      Navigator.pop(context);
                    },
                  )).toList(),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 20),
        _sectionTitle('About'),
        _settingsTile(
          icon: Icons.info_outline,
          title: 'Version',
          subtitle: '1.0.0',
          onTap: () {},
        ),
        _settingsTile(
          icon: Icons.code,
          title: 'Developer',
          subtitle: 'Anime MT Team',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10, top: 10),
      child: Text(title,
        style: TextStyle(
          color: Color(0xFFE53935),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        )),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFFE53935)),
        title: Text(title, style: TextStyle(color: Colors.white, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white38, fontSize: 12)),
        trailing: Icon(Icons.chevron_right, color: Colors.white24),
        onTap: onTap,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail_screen.dart';

class AnimeListScreen extends StatefulWidget {
  const AnimeListScreen({super.key});

  @override
  State<AnimeListScreen> createState() => _AnimeListScreenState();
}

class _AnimeListScreenState extends State<AnimeListScreen> {
  List animeList = [];
  bool isLoading = true;
  String errorMsg = '';
  String sortBy = 'rating';

  @override
  void initState() {
    super.initState();
    fetchAnimeList();
  }

  Future<void> fetchAnimeList() async {
    setState(() { isLoading = true; errorMsg = ''; });
    try {
      final filter = sortBy == 'rating' ? 'bypopularity' : 'title';
      final response = await http.get(
        Uri.parse('https://api.jikan.moe/v4/top/anime?filter=$filter&limit=25'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          animeList = data['data'];
          if (sortBy == 'az') {
            animeList.sort((a, b) => (a['title'] ?? '').compareTo(b['title'] ?? ''));
          }
          isLoading = false;
        });
      } else {
        setState(() { errorMsg = 'Error: ${response.statusCode}'; isLoading = false; });
      }
    } catch (e) {
      setState(() { errorMsg = 'Connection failed'; isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Color(0xFF1A1A1A),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Text('Sort by:', style: TextStyle(color: Colors.white70, fontSize: 14)),
              SizedBox(width: 10),
              _sortButton('Rating', 'rating'),
              SizedBox(width: 8),
              _sortButton('A - Z', 'az'),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: Color(0xFFE53935)))
              : errorMsg.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off, color: Colors.red, size: 60),
                          SizedBox(height: 10),
                          Text(errorMsg, style: TextStyle(color: Colors.white70)),
                          SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE53935)),
                            icon: Icon(Icons.refresh),
                            label: Text('Retry'),
                            onPressed: fetchAnimeList,
                          )
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: animeList.length,
                      itemBuilder: (context, index) {
                        final anime = animeList[index];
                        final cover = anime['images']?['jpg']?['large_image_url'] ?? '';
                        final title = anime['title'] ?? '';
                        final score = anime['score'];
                        final episodes = anime['episodes'];
                        final genres = (anime['genres'] as List?)?.take(2).map((g) => g['name']).join(' • ') ?? '';

                        return GestureDetector(
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => DetailScreen(anime: anime))),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Color(0xFF1A1A1A),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                  child: Image.network(cover,
                                    width: 80, height: 110, fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      width: 80, height: 110, color: Colors.grey[900],
                                      child: Icon(Icons.broken_image, color: Colors.grey))),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${index + 1}. $title',
                                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                          maxLines: 2, overflow: TextOverflow.ellipsis),
                                        SizedBox(height: 6),
                                        Text(genres, style: TextStyle(color: Colors.white38, fontSize: 11)),
                                        SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(Icons.star, color: Colors.amber, size: 14),
                                            SizedBox(width: 4),
                                            Text('${score ?? 'N/A'}',
                                              style: TextStyle(color: Colors.white70, fontSize: 12)),
                                            SizedBox(width: 12),
                                            Icon(Icons.tv, color: Colors.white38, size: 14),
                                            SizedBox(width: 4),
                                            Text('${episodes ?? '?'} eps',
                                              style: TextStyle(color: Colors.white38, fontSize: 12)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: Colors.white24),
                                SizedBox(width: 8),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _sortButton(String label, String value) {
    final isSelected = sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() { sortBy = value; });
        fetchAnimeList();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFE53935) : Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          )),
      ),
    );
  }
}
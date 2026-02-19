import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List animeList = [];
  List filteredList = [];
  bool isLoading = true;
  String errorMsg = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAnime();
  }

  String getStatus(String? status) {
    switch (status) {
      case 'RELEASING': return '🟢 Ongoing';
      case 'FINISHED': return '🔴 Finished';
      case 'NOT_YET_RELEASED': return '🟡 Upcoming';
      case 'CANCELLED': return '⚫ Cancelled';
      case 'HIATUS': return '🟠 Hiatus';
      default: return '❓ Unknown';
    }
  }

  Future<void> fetchAnime() async {
    try {
      final response = await http.post(
        Uri.parse('https://graphql.anilist.co'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': '''
          {
            Page(perPage: 30) {
              media(type: ANIME, sort: TRENDING_DESC) {
                id
                title { romaji }
                coverImage { large }
                bannerImage
                averageScore
                status
                episodes
                genres
                description
              }
            }
          }
          '''
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          animeList = data['data']['Page']['media'];
          filteredList = animeList;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMsg = 'Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = 'Connection failed: $e';
        isLoading = false;
      });
    }
  }

  void searchAnime(String query) {
    setState(() {
      filteredList = animeList.where((anime) {
        final title = anime['title']['romaji'].toLowerCase();
        return title.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE53935),
              ),
              child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
            ),
            SizedBox(width: 10),
            Text('Anime MT',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFFE53935)),
            onPressed: () {
              setState(() { isLoading = true; errorMsg = ''; });
              fetchAnime();
            },
          )
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFE53935)),
                  SizedBox(height: 20),
                  Text('Loading Anime...', style: TextStyle(color: Colors.white70)),
                ],
              ),
            )
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
                        onPressed: () {
                          setState(() { isLoading = true; errorMsg = ''; });
                          fetchAnime();
                        },
                      )
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: TextField(
                        controller: _searchController,
                        onChanged: searchAnime,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search anime...',
                          hintStyle: TextStyle(color: Colors.white38),
                          prefixIcon: Icon(Icons.search, color: Color(0xFFE53935)),
                          filled: true,
                          fillColor: Color(0xFF1A1A1A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.58,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final anime = filteredList[index];
                          final status = getStatus(anime['status']);
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                MaterialPageRoute(builder: (_) => DetailScreen(anime: anime)));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Color(0xFF1A1A1A),
                                boxShadow: [
                                  BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4))
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(
                                            anime['coverImage']['large'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) => Container(
                                              color: Colors.grey[900],
                                              child: Icon(Icons.broken_image, color: Colors.grey),
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE53935),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.star, color: Colors.white, size: 12),
                                                  SizedBox(width: 3),
                                                  Text('${anime['averageScore'] ?? 'N/A'}',
                                                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            anime['title']['romaji'],
                                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(status,
                                            style: TextStyle(color: Colors.white54, fontSize: 10),
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
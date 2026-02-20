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
  bool isSearching = false;
  bool isSearchLoading = false;
  String errorMsg = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAnime();
  }

  String getStatus(String? status) {
    switch (status) {
      case 'Currently Airing': return 'Ongoing';
      case 'Finished Airing': return 'Finished';
      case 'Not yet aired': return 'Upcoming';
      case 'On Hiatus': return 'On Hiatus';
      case 'Discontinued': return 'Discontinued';
      default: return status ?? 'Unknown';
    }
  }

  Color getStatusColor(String? status) {
    switch (status) {
      case 'Currently Airing': return Colors.green;
      case 'Finished Airing': return Colors.redAccent;
      case 'Not yet aired': return Colors.amber;
      default: return Colors.grey;
    }
  }

  Future<void> fetchAnime() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.jikan.moe/v4/top/anime?filter=airing&limit=25'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          animeList = data['data'];
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
        errorMsg = 'Connection failed';
        isLoading = false;
      });
    }
  }

  Future<void> searchAnime(String query) async {
    if (query.isEmpty) {
      setState(() { filteredList = animeList; isSearchLoading = false; });
      return;
    }
    setState(() { isSearchLoading = true; });
    try {
      final response = await http.get(
        Uri.parse('https://api.jikan.moe/v4/anime?q=${Uri.encodeComponent(query)}&limit=20'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() { filteredList = data['data']; isSearchLoading = false; });
      }
    } catch (e) {
      setState(() { isSearchLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 400 ? 3 : screenWidth < 600 ? 3 : 4;

    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        title: isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: searchAnime,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search anime...',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
              )
            : Row(
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
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: Color(0xFFE53935),
            ),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  _searchController.clear();
                  filteredList = animeList;
                }
              });
            },
          ),
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
              : isSearchLoading
                  ? Center(child: CircularProgressIndicator(color: Color(0xFFE53935)))
                  : GridView.builder(
                      padding: EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.55,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final anime = filteredList[index];
                        final status = anime['status'];
                        final score = anime['score'];
                        final cover = anime['images']?['jpg']?['large_image_url'] ?? '';
                        final title = anime['title'] ?? '';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                              MaterialPageRoute(builder: (_) => DetailScreen(anime: anime)));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color(0xFF1A1A1A),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          cover,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Container(
                                            color: Colors.grey[900],
                                            child: Icon(Icons.broken_image, color: Colors.grey),
                                          ),
                                        ),
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.star, color: Colors.amber, size: 10),
                                                SizedBox(width: 2),
                                                Text('${score ?? 'N/A'}',
                                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(title,
                                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 3),
                                        Row(
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: getStatusColor(status),
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Text(getStatus(status),
                                              style: TextStyle(color: Colors.white54, fontSize: 9),
                                            ),
                                          ],
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
    );
  }
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail_screen.dart';

class LatestScreen extends StatefulWidget {
  const LatestScreen({super.key});

  @override
  State<LatestScreen> createState() => _LatestScreenState();
}

class _LatestScreenState extends State<LatestScreen> {
  List animeList = [];
  bool isLoading = true;
  String errorMsg = '';

  @override
  void initState() {
    super.initState();
    fetchLatest();
  }

  Future<void> fetchLatest() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.jikan.moe/v4/top/anime?filter=airing&limit=25'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          animeList = data['data'];
          isLoading = false;
        });
      } else {
        setState(() { errorMsg = 'Error: ${response.statusCode}'; isLoading = false; });
      }
    } catch (e) {
      setState(() { errorMsg = 'Connection failed'; isLoading = false; });
    }
  }

  String getStatus(String? status) {
    switch (status) {
      case 'Currently Airing': return 'Ongoing';
      case 'Finished Airing': return 'Finished';
      case 'Not yet aired': return 'Upcoming';
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 400 ? 3 : screenWidth < 600 ? 3 : 4;

    return isLoading
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
                      onPressed: () {
                        setState(() { isLoading = true; errorMsg = ''; });
                        fetchLatest();
                      },
                    )
                  ],
                ),
              )
            : GridView.builder(
                padding: EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.55,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: animeList.length,
                itemBuilder: (context, index) {
                  final anime = animeList[index];
                  final cover = anime['images']?['jpg']?['large_image_url'] ?? '';
                  final title = anime['title'] ?? '';
                  final score = anime['score'];
                  final status = anime['status'];

                  return GestureDetector(
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => DetailScreen(anime: anime))),
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
                                  Image.network(cover, fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      color: Colors.grey[900],
                                      child: Icon(Icons.broken_image, color: Colors.grey))),
                                  Positioned(
                                    top: 6, right: 6,
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
                                    maxLines: 2, overflow: TextOverflow.ellipsis),
                                  SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Container(
                                        width: 6, height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: getStatusColor(status),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(getStatus(status),
                                        style: TextStyle(color: Colors.white54, fontSize: 9)),
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
              );
  }
}
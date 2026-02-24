import 'package:flutter/material.dart';
import '../services/api_service.dart';
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
      final data = await ApiService.getAnimeList();
      setState(() {
        animeList = data['results'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = 'Connection failed';
        isLoading = false;
      });
    }
  }

  String getStatus(String? status) {
    switch (status) {
      case 'airing': return 'Ongoing';
      case 'finished': return 'Finished';
      case 'upcoming': return 'Upcoming';
      case 'hiatus': return 'On Hiatus';
      default: return status ?? 'Unknown';
    }
  }

  Color getStatusColor(String? status) {
    switch (status) {
      case 'airing': return Colors.green;
      case 'finished': return Colors.redAccent;
      case 'upcoming': return Colors.amber;
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
            : animeList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.movie_outlined, color: Colors.white24, size: 80),
                        SizedBox(height: 16),
                        Text('No anime yet', style: TextStyle(color: Colors.white38, fontSize: 16)),
                        SizedBox(height: 8),
                        Text('Add anime from the Admin app', style: TextStyle(color: Colors.white24, fontSize: 12)),
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
                      final cover = anime['cover'] ?? '';
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
                                      cover.isNotEmpty
                                          ? Image.network(cover, fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) => Container(
                                                color: Colors.grey[900],
                                                child: Icon(Icons.broken_image, color: Colors.grey)))
                                          : Container(color: Colors.grey[900],
                                              child: Icon(Icons.movie, color: Colors.grey)),
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
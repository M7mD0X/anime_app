import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List results = [];
  bool isLoading = false;
  bool hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() { isLoading = true; hasSearched = true; });
    try {
      final data = await ApiService.searchAnime(query);
      setState(() {
        results = data['results'];
        isLoading = false;
      });
    } catch (e) {
      setState(() { isLoading = false; });
    }
  }

  String getStatus(String? status) {
    switch (status) {
      case 'airing': return 'Ongoing';
      case 'finished': return 'Finished';
      case 'upcoming': return 'Upcoming';
      default: return status ?? '';
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
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search anime...',
            hintStyle: TextStyle(color: Colors.white38),
            border: InputBorder.none,
          ),
          onSubmitted: search,
          onChanged: (val) {
            if (val.length >= 2) search(val);
          },
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close, color: Colors.white54),
              onPressed: () {
                _searchController.clear();
                setState(() { results = []; hasSearched = false; });
              },
            ),
        ],
      ),
      body: isLoading
          ? _buildShimmer()
          : !hasSearched
              ? _buildEmptyState()
              : results.isEmpty
                  ? _buildNoResults()
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final anime = results[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => DetailScreen(anime: anime))),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: anime['cover'] ?? '',
                                    width: 70, height: 95, fit: BoxFit.cover,
                                    errorWidget: (c, e, s) => Container(
                                      width: 70, height: 95, color: Colors.grey[900],
                                      child: Icon(Icons.movie, color: Colors.grey)),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(anime['title'] ?? '',
                                          style: TextStyle(color: Colors.white, fontSize: 13,
                                            fontWeight: FontWeight.bold),
                                          maxLines: 2, overflow: TextOverflow.ellipsis),
                                        if ((anime['title_arabic'] ?? '').isNotEmpty) ...[
                                          SizedBox(height: 2),
                                          Text(anime['title_arabic'],
                                            style: TextStyle(color: Colors.white38, fontSize: 11),
                                            textDirection: TextDirection.rtl),
                                        ],
                                        SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Container(
                                              width: 7, height: 7,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: getStatusColor(anime['status']),
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Text(getStatus(anime['status']),
                                              style: TextStyle(color: Colors.white54, fontSize: 11)),
                                            SizedBox(width: 10),
                                            if (anime['score'] != null) ...[
                                              Icon(Icons.star, color: Colors.amber, size: 12),
                                              SizedBox(width: 3),
                                              Text('${anime['score']}',
                                                style: TextStyle(color: Colors.white54, fontSize: 11)),
                                            ],
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text('${anime['episodes_count'] ?? 0} eps • ${anime['type'] ?? 'TV'}',
                                          style: TextStyle(color: Colors.white38, fontSize: 11)),
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, color: Colors.white12, size: 100),
          SizedBox(height: 16),
          Text('Search for anime', style: TextStyle(color: Colors.white38, fontSize: 16)),
          SizedBox(height: 8),
          Text('Type at least 2 characters', style: TextStyle(color: Colors.white24, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_outlined, color: Colors.white12, size: 100),
          SizedBox(height: 16),
          Text('No results found', style: TextStyle(color: Colors.white38, fontSize: 16)),
          SizedBox(height: 8),
          Text('Try a different search term',
            style: TextStyle(color: Colors.white24, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: List.generate(5, (_) => Shimmer.fromColors(
          baseColor: Color(0xFF1A1A1A),
          highlightColor: Color(0xFF2A2A2A),
          child: Container(
            margin: EdgeInsets.only(bottom: 10),
            height: 95,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        )),
      ),
    );
  }
}
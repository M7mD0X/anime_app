import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final Map anime;

  const DetailScreen({super.key, required this.anime});

  String getStatus(String? status) {
    switch (status) {
      case 'RELEASING': return '🟢 Ongoing';
      case 'FINISHED': return '🔴 Finished';
      case 'NOT_YET_RELEASED': return '🟡 Upcoming';
      case 'CANCELLED': return '⚫ Cancelled';
      case 'HIATUS': return '🟠 On Hiatus';
      default: return '❓ Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = anime['title']['romaji'] ?? '';
    final cover = anime['coverImage']['large'] ?? '';
    final banner = anime['bannerImage'];
    final score = anime['averageScore'];
    final status = getStatus(anime['status']);
    final episodes = anime['episodes'];
    final genres = (anime['genres'] as List?)?.join(', ') ?? '';
    final description = (anime['description'] ?? 'No description available.')
        .replaceAll(RegExp(r'<[^>]*>'), '');

    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Color(0xFF1A1A1A),
            flexibleSpace: FlexibleSpaceBar(
              background: banner != null
                  ? Image.network(banner, fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(color: Color(0xFF1A1A1A)))
                  : Image.network(cover, fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(color: Color(0xFF1A1A1A))),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(cover, width: 110, height: 160, fit: BoxFit.cover),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 12),
                            Row(children: [
                              Icon(Icons.star, color: Color(0xFFE53935), size: 18),
                              SizedBox(width: 5),
                              Text('${score ?? 'N/A'}',
                                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                            ]),
                            SizedBox(height: 8),
                            Text(status, style: TextStyle(color: Colors.white70, fontSize: 14)),
                            SizedBox(height: 8),
                            Text('Episodes: ${episodes ?? 'N/A'}',
                              style: TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('Genres', style: TextStyle(color: Color(0xFFE53935), fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (anime['genres'] as List?)?.map((g) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Color(0xFFE53935)),
                      ),
                      child: Text(g, style: TextStyle(color: Colors.white, fontSize: 12)),
                    )).toList() ?? [],
                  ),
                  SizedBox(height: 20),
                  Text('Description', style: TextStyle(color: Color(0xFFE53935), fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(description, style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.6)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
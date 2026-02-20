import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final Map anime;

  const DetailScreen({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    final title = anime['title'] ?? '';
    final cover = anime['images']?['jpg']?['large_image_url'] ?? '';
    final banner = anime['trailer']?['images']?['maximum_image_url'];
    final score = anime['score'];
    final status = anime['status'] ?? 'Unknown';
    final episodes = anime['episodes'];
    final duration = anime['duration'] ?? 'N/A';
    final year = anime['year'];
    final season = anime['season'] ?? '';
    final synopsis = anime['synopsis'] ?? 'No description available.';
    final genres = (anime['genres'] as List?)?.map((g) => g['name']).toList() ?? [];
    final studios = (anime['studios'] as List?)?.map((s) => s['name']).toList() ?? [];
    final rating = anime['rating'] ?? 'N/A';
    final rank = anime['rank'];
    final popularity = anime['popularity'];

    String getStatusText() {
      switch (status) {
        case 'Currently Airing': return 'Ongoing';
        case 'Finished Airing': return 'Finished';
        case 'Not yet aired': return 'Upcoming';
        default: return '$status';
      }
    }

    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Color(0xFF1A1A1A),
            flexibleSpace: FlexibleSpaceBar(
              background: banner != null
                  ? Image.network(banner, fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Image.network(cover, fit: BoxFit.cover))
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
                        child: Image.network(cover, width: 100, height: 150, fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(width: 100, height: 150, color: Colors.grey[900])),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            _infoRow(Icons.star, '${score ?? 'N/A'} / 10', Color(0xFFE53935)),
                            SizedBox(height: 6),
                            _infoRow(Icons.circle, getStatusText(), Colors.white70),
                            SizedBox(height: 6),
                            _infoRow(Icons.tv, 'Episodes: ${episodes ?? 'N/A'}', Colors.white70),
                            SizedBox(height: 6),
                            _infoRow(Icons.timer, duration, Colors.white70),
                            SizedBox(height: 6),
                            if (year != null)
                              _infoRow(Icons.calendar_today, '$season $year', Colors.white70),
                            SizedBox(height: 6),
                            _infoRow(Icons.block, rating, Colors.white70),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      _statBox('Rank', '#${rank ?? 'N/A'}'),
                      SizedBox(width: 10),
                      _statBox('Popularity', '#${popularity ?? 'N/A'}'),
                      SizedBox(width: 10),
                      _statBox('Score', '${score ?? 'N/A'}'),
                    ],
                  ),
                  SizedBox(height: 20),
                  if (genres.isNotEmpty) ...[
                    Text('Genres', style: TextStyle(color: Color(0xFFE53935), fontSize: 15, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: genres.map((g) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Color(0xFFE53935)),
                        ),
                        child: Text(g, style: TextStyle(color: Colors.white, fontSize: 12)),
                      )).toList(),
                    ),
                    SizedBox(height: 20),
                  ],
                  if (studios.isNotEmpty) ...[
                    Text('Studios', style: TextStyle(color: Color(0xFFE53935), fontSize: 15, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: studios.map((s) => Chip(
                        label: Text(s, style: TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: Color(0xFF1A1A1A),
                      )).toList(),
                    ),
                    SizedBox(height: 20),
                  ],
                  Text('Synopsis', style: TextStyle(color: Color(0xFFE53935), fontSize: 15, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(synopsis, style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6)),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        SizedBox(width: 6),
        Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _statBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: Color(0xFFE53935), fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
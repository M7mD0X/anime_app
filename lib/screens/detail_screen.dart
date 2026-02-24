import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'player_screen.dart';

class DetailScreen extends StatefulWidget {
  final Map anime;

  const DetailScreen({super.key, required this.anime});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List episodes = [];
  bool isLoadingEpisodes = true;

  @override
  void initState() {
    super.initState();
    fetchEpisodes();
  }

  Future<void> fetchEpisodes() async {
    try {
      final data = await ApiService.getEpisodes(widget.anime['id']);
      setState(() {
        episodes = data['results'];
        isLoadingEpisodes = false;
      });
    } catch (e) {
      setState(() { isLoadingEpisodes = false; });
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
    final title = widget.anime['title'] ?? '';
    final titleArabic = widget.anime['title_arabic'] ?? '';
    final cover = widget.anime['cover'] ?? '';
    final banner = widget.anime['banner'] ?? '';
    final score = widget.anime['score'];
    final status = widget.anime['status'];
    final episodesCount = widget.anime['episodes_count'] ?? 0;
    final type = widget.anime['type'] ?? '';
    final year = widget.anime['year'];
    final genres = (widget.anime['genres'] as List?) ?? [];
    final description = widget.anime['description'] ?? '';
    final descriptionArabic = widget.anime['description_arabic'] ?? '';

    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Color(0xFF1A1A1A),
            flexibleSpace: FlexibleSpaceBar(
              background: banner.isNotEmpty
                  ? Image.network(banner, fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Image.network(cover, fit: BoxFit.cover))
                  : cover.isNotEmpty
                      ? Image.network(cover, fit: BoxFit.cover)
                      : Container(color: Color(0xFF1A1A1A)),
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
                        child: cover.isNotEmpty
                            ? Image.network(cover, width: 100, height: 150, fit: BoxFit.cover)
                            : Container(width: 100, height: 150, color: Colors.grey[900],
                                child: Icon(Icons.movie, color: Colors.grey)),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            if (titleArabic.isNotEmpty) ...[
                              SizedBox(height: 4),
                              Text(titleArabic,
                                style: TextStyle(color: Colors.white54, fontSize: 13),
                                textDirection: TextDirection.rtl),
                            ],
                            SizedBox(height: 10),
                            _infoRow(Icons.star, '${score ?? 'N/A'} / 10', Colors.amber),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: getStatusColor(status),
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(getStatus(status),
                                  style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                            SizedBox(height: 6),
                            _infoRow(Icons.tv, '$episodesCount Episodes', Colors.white70),
                            SizedBox(height: 6),
                            _infoRow(Icons.movie, type, Colors.white70),
                            if (year != null) ...[
                              SizedBox(height: 6),
                              _infoRow(Icons.calendar_today, '$year', Colors.white70),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      _statBox('Episodes', '$episodesCount'),
                      SizedBox(width: 10),
                      _statBox('Score', '${score ?? 'N/A'}'),
                      SizedBox(width: 10),
                      _statBox('Type', type),
                    ],
                  ),
                  if (genres.isNotEmpty) ...[
                    SizedBox(height: 20),
                    Text('Genres',
                      style: TextStyle(color: Color(0xFFE53935), fontSize: 15, fontWeight: FontWeight.bold)),
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
                  ],
                  if (description.isNotEmpty) ...[
                    SizedBox(height: 20),
                    Text('Synopsis',
                      style: TextStyle(color: Color(0xFFE53935), fontSize: 15, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(description,
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6)),
                  ],
                  if (descriptionArabic.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text('القصة',
                      style: TextStyle(color: Color(0xFFE53935), fontSize: 15, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(descriptionArabic,
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
                      textDirection: TextDirection.rtl),
                  ],
                  SizedBox(height: 20),
                  Text('Episodes',
                    style: TextStyle(color: Color(0xFFE53935), fontSize: 15, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  isLoadingEpisodes
                      ? Center(child: CircularProgressIndicator(color: Color(0xFFE53935)))
                      : episodes.isEmpty
                          ? Center(
                              child: Text('No episodes yet',
                                style: TextStyle(color: Colors.white38)))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: episodes.length,
                              itemBuilder: (context, index) {
                                final ep = episodes[index];
                                final hasArabic = (ep['video_url_arabic'] ?? '').isNotEmpty;
                                return GestureDetector(
                                  onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => PlayerScreen(
                                      episode: ep,
                                      animeTitle: title,
                                    ))),
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF1A1A1A),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        width: 40, height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFE53935).withOpacity(0.15),
                                        ),
                                        child: Center(
                                          child: Text('${ep['number']}',
                                            style: TextStyle(
                                              color: Color(0xFFE53935),
                                              fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      title: Text(ep['title'] ?? 'Episode ${ep['number']}',
                                        style: TextStyle(color: Colors.white, fontSize: 13)),
                                      subtitle: Row(
                                        children: [
                                          if (ep['duration'] != null && ep['duration'] != 0)
                                            Text('${ep['duration']} min',
                                              style: TextStyle(color: Colors.white38, fontSize: 11)),
                                          if (hasArabic) ...[
                                            SizedBox(width: 8),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE53935).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text('AR',
                                                style: TextStyle(color: Color(0xFFE53935), fontSize: 10)),
                                            ),
                                          ],
                                        ],
                                      ),
                                      trailing: Icon(Icons.play_circle, color: Color(0xFFE53935), size: 30),
                                    ),
                                  ),
                                );
                              },
                            ),
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
        Expanded(child: Text(text,
          style: TextStyle(color: color, fontSize: 12),
          maxLines: 1, overflow: TextOverflow.ellipsis)),
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
            Text(value,
              style: TextStyle(color: Color(0xFFE53935), fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
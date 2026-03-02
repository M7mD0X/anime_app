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
  List aniwatchEpisodes = [];
  bool isLoadingEpisodes = true;
  String errorMsg = '';

  @override
  void initState() {
    super.initState();
    fetchEpisodes();
  }

  Future<void> fetchEpisodes() async {
    final aniwatchId = widget.anime['aniwatch_id'] ?? '';
    try {
      if (aniwatchId.isNotEmpty) {
        final data = await ApiService.aniwatchGetSources('$episodeId&server=hd-2&category=sub');
        final eps = data['data']?['episodes'] as List? ?? [];
        setState(() {
          aniwatchEpisodes = eps;
          isLoadingEpisodes = false;
        });
      } else {
        final data = await ApiService.getEpisodes(widget.anime['id']);
        setState(() {
          episodes = data['results'];
          isLoadingEpisodes = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = 'Failed to load episodes';
        isLoadingEpisodes = false;
      });
    }
  }

  Future<void> playEpisode(Map ep, bool isAniwatch) async {
    if (isAniwatch) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator(color: Color(0xFFE53935))),
      );
      try {
        final episodeId = ep['episodeId'] ?? '';
        final data = await ApiService.aniwatchGetSources('$episodeId&server=hd-1&category=sub');
        final sources = data['data']?['sources'] as List? ?? [];

        if (sources.isEmpty) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No sources found'), backgroundColor: Colors.red));
          return;
        }

        final rawUrl = sources[0]['url'] ?? '';
        final videoUrl = await ApiService.storeProxyUrl(rawUrl);
        Navigator.pop(context);

        Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(
          episode: {
            'number': ep['number'],
            'title': ep['title'] ?? '',
            'video_url': videoUrl,
            'video_url_arabic': '',
          },
          animeTitle: widget.anime['title'] ?? '',
        )));
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load sources'), backgroundColor: Colors.red));
      }
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(
        episode: ep,
        animeTitle: widget.anime['title'] ?? '',
      )));
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
    final hasAniwatch = (widget.anime['aniwatch_id'] ?? '').isNotEmpty;
    final displayEpisodes = hasAniwatch ? aniwatchEpisodes : episodes;

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
                              style: TextStyle(color: Colors.white, fontSize: 16,
                                fontWeight: FontWeight.bold)),
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
                      _statBox('Episodes', hasAniwatch
                        ? '${aniwatchEpisodes.length}'
                        : '$episodesCount'),
                      SizedBox(width: 10),
                      _statBox('Score', '${score ?? 'N/A'}'),
                      SizedBox(width: 10),
                      _statBox('Type', type),
                    ],
                  ),
                  if (genres.isNotEmpty) ...[
                    SizedBox(height: 20),
                    Text('Genres',
                      style: TextStyle(color: Color(0xFFE53935), fontSize: 15,
                        fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
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
                      style: TextStyle(color: Color(0xFFE53935), fontSize: 15,
                        fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(description,
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6)),
                  ],
                  if (descriptionArabic.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text('القصة',
                      style: TextStyle(color: Color(0xFFE53935), fontSize: 15,
                        fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(descriptionArabic,
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
                      textDirection: TextDirection.rtl),
                  ],
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text('Episodes',
                        style: TextStyle(color: Color(0xFFE53935), fontSize: 15,
                          fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      if (hasAniwatch)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('Auto', style: TextStyle(color: Colors.green, fontSize: 11)),
                        ),
                    ],
                  ),
                  SizedBox(height: 10),
                  isLoadingEpisodes
                      ? Center(child: CircularProgressIndicator(color: Color(0xFFE53935)))
                      : errorMsg.isNotEmpty
                          ? Center(child: Text(errorMsg,
                              style: TextStyle(color: Colors.red)))
                          : displayEpisodes.isEmpty
                              ? Center(child: Text('No episodes yet',
                                  style: TextStyle(color: Colors.white38)))
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: displayEpisodes.length,
                                  itemBuilder: (context, index) {
                                    final ep = displayEpisodes[index];
                                    final epNum = ep['number'];
                                    final epTitle = ep['title'] ?? 'Episode $epNum';
                                    return GestureDetector(
                                      onTap: () => playEpisode(ep, hasAniwatch),
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
                                              child: Text('$epNum',
                                                style: TextStyle(color: Color(0xFFE53935),
                                                  fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                          title: Text(epTitle,
                                            style: TextStyle(color: Colors.white, fontSize: 13)),
                                          trailing: Icon(Icons.play_circle,
                                            color: Color(0xFFE53935), size: 30),
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
              style: TextStyle(color: Color(0xFFE53935), fontSize: 16,
                fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
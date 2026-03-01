import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';
import '../widgets/shimmer_widget.dart';
import 'detail_screen.dart';

class LatestScreen extends StatefulWidget {
  const LatestScreen({super.key});

  @override
  State<LatestScreen> createState() => _LatestScreenState();
}

class _LatestScreenState extends State<LatestScreen> {
  List animeList = [];
  List bannerList = [];
  bool isLoading = true;
  int currentBanner = 0;
  final PageController _bannerController = PageController();

  @override
  void initState() {
    super.initState();
    fetchAnime();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> fetchAnime() async {
    try {
      final data = await ApiService.getAnimeList(limit: 50);
      final List results = data['results'];
      setState(() {
        animeList = results;
        bannerList = results.where((a) => (a['banner'] ?? '').isNotEmpty).take(5).toList();
        if (bannerList.isEmpty) bannerList = results.take(5).toList();
        isLoading = false;
      });
      _startBannerTimer();
    } catch (e) {
      setState(() { isLoading = false; });
    }
  }

  void _startBannerTimer() {
    Future.delayed(Duration(seconds: 4), () {
      if (mounted && bannerList.isNotEmpty) {
        final next = (currentBanner + 1) % bannerList.length;
        _bannerController.animateToPage(next,
          duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
        _startBannerTimer();
      }
    });
  }

  String getStatus(String? status) {
    switch (status) {
      case 'airing': return 'Ongoing';
      case 'finished': return 'Finished';
      case 'upcoming': return 'Upcoming';
      case 'hiatus': return 'On Hiatus';
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
    final airing = animeList.where((a) => a['status'] == 'airing').toList();
    final finished = animeList.where((a) => a['status'] == 'finished').toList();

    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: isLoading
          ? _buildShimmer()
          : RefreshIndicator(
              color: Color(0xFFE53935),
              onRefresh: fetchAnime,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Color(0xFF0D0D0D),
                    floating: true,
                    title: Row(
                      children: [
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(Icons.play_arrow, color: Colors.white, size: 18),
                        ),
                        SizedBox(width: 8),
                        Text('Anime MT',
                          style: TextStyle(color: Colors.white, fontSize: 18,
                            fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (bannerList.isNotEmpty) _buildBanner(),
                        SizedBox(height: 24),
                        if (airing.isNotEmpty) ...[
                          _sectionHeader('🔥 Currently Airing', airing.length),
                          SizedBox(height: 12),
                          _buildHorizontalList(airing),
                          SizedBox(height: 24),
                        ],
                        if (finished.isNotEmpty) ...[
                          _sectionHeader('✅ Finished', finished.length),
                          SizedBox(height: 12),
                          _buildHorizontalList(finished),
                          SizedBox(height: 24),
                        ],
                        _sectionHeader('📺 All Anime', animeList.length),
                        SizedBox(height: 12),
                        _buildListView(animeList),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 220,
          child: Stack(
            children: [
              PageView.builder(
                controller: _bannerController,
                onPageChanged: (i) => setState(() => currentBanner = i),
                itemCount: bannerList.length,
                itemBuilder: (context, index) {
                  final anime = bannerList[index];
                  final img = (anime['banner'] ?? '').isNotEmpty
                      ? anime['banner']
                      : anime['cover'] ?? '';
                  return GestureDetector(
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => DetailScreen(anime: anime))),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: img,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorWidget: (c, e, s) => Container(
                            color: Color(0xFF1A1A1A),
                            child: Icon(Icons.movie, color: Colors.grey, size: 50)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black87],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16, left: 16, right: 60,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: getStatusColor(anime['status']),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(getStatus(anime['status']),
                                  style: TextStyle(color: Colors.white, fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(height: 6),
                              Text(anime['title'] ?? '',
                                style: TextStyle(color: Colors.white, fontSize: 18,
                                  fontWeight: FontWeight.bold),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                              if ((anime['title_arabic'] ?? '').isNotEmpty)
                                Text(anime['title_arabic'],
                                  style: TextStyle(color: Colors.white60, fontSize: 12),
                                  textDirection: TextDirection.rtl,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 20, right: 16,
                          child: GestureDetector(
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => DetailScreen(anime: anime))),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(0xFFE53935),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 8, left: 0, right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(bannerList.length, (i) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 3),
                    width: i == currentBanner ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == currentBanner ? Color(0xFFE53935) : Colors.white30,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, int count) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(title,
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Color(0xFFE53935).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count', style: TextStyle(color: Color(0xFFE53935), fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List list) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final anime = list[index];
          return GestureDetector(
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => DetailScreen(anime: anime))),
            child: Container(
              width: 130,
              margin: EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: anime['cover'] ?? '',
                      width: 130, height: 170, fit: BoxFit.cover,
                      placeholder: (c, u) => Shimmer.fromColors(
                        baseColor: Color(0xFF1A1A1A),
                        highlightColor: Color(0xFF2A2A2A),
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (c, e, s) => Container(
                        color: Color(0xFF1A1A1A),
                        child: Icon(Icons.movie, color: Colors.grey)),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(anime['title'] ?? '',
                    style: TextStyle(color: Colors.white, fontSize: 12,
                      fontWeight: FontWeight.bold),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListView(List list) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final anime = list[index];
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
                            textDirection: TextDirection.rtl,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
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
                            Icon(Icons.play_circle_outline, color: Colors.white38, size: 13),
                            SizedBox(width: 4),
                            Text('${anime['episodes_count'] ?? 0} eps',
                              style: TextStyle(color: Colors.white38, fontSize: 11)),
                          ],
                        ),
                        if (anime['score'] != null) ...[
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 13),
                              SizedBox(width: 4),
                              Text('${anime['score']}',
                                style: TextStyle(color: Colors.white54, fontSize: 11)),
                            ],
                          ),
                        ],
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
    );
  }

  Widget _buildShimmer() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ShimmerBanner(),
          SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(5, (_) => ShimmerListTile()),
            ),
          ),
        ],
      ),
    );
  }
}
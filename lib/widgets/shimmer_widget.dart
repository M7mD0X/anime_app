import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerAnimeCard extends StatelessWidget {
  const ShimmerAnimeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Color(0xFF1A1A1A),
      highlightColor: Color(0xFF2A2A2A),
      child: Container(
        width: 130,
        margin: EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(height: 8),
            Container(height: 12, width: 100, color: Colors.white,
              margin: EdgeInsets.only(bottom: 4)),
            Container(height: 10, width: 70, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class ShimmerBanner extends StatelessWidget {
  const ShimmerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Color(0xFF1A1A1A),
      highlightColor: Color(0xFF2A2A2A),
      child: Container(
        height: 220,
        decoration: BoxDecoration(color: Colors.white),
      ),
    );
  }
}

class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Color(0xFF1A1A1A),
      highlightColor: Color(0xFF2A2A2A),
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(width: 60, height: 80, color: Colors.white,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8))),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, color: Colors.white, margin: EdgeInsets.only(bottom: 8)),
                  Container(height: 12, width: 150, color: Colors.white, margin: EdgeInsets.only(bottom: 8)),
                  Container(height: 10, width: 100, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
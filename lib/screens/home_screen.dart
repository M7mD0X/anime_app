import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List animeList = [];
  bool isLoading = true;
  String errorMsg = '';

  @override
  void initState() {
    super.initState();
    fetchAnime();
  }

  Future<void> fetchAnime() async {
    try {
      final response = await http.post(
        Uri.parse('https://graphql.anilist.co'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': '''
          {
            Page(perPage: 20) {
              media(type: ANIME, sort: TRENDING_DESC) {
                id
                title { romaji }
                coverImage { large }
                averageScore
              }
            }
          }
          '''
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          animeList = data['data']['Page']['media'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMsg = 'خطأ: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = 'تعذر الاتصال: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A1A),
        title: Text(
          'أنمي سلاير',
          style: TextStyle(
            color: Color(0xFFE53935),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() { isLoading = true; errorMsg = ''; });
              fetchAnime();
            },
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFE53935)))
          : errorMsg.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 60),
                      SizedBox(height: 10),
                      Text(errorMsg, style: TextStyle(color: Colors.white)),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() { isLoading = true; errorMsg = ''; });
                          fetchAnime();
                        },
                        child: Text('إعادة المحاولة'),
                      )
                    ],
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: animeList.length,
                  itemBuilder: (context, index) {
                    final anime = animeList[index];
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xFF1A1A1A),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10)),
                            child: Image.network(
                              anime['coverImage']['large'],
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                height: 180,
                                color: Colors.grey[900],
                                child: Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              anime['title']['romaji'],
                              style: TextStyle(color: Colors.white, fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '⭐ ${anime['averageScore'] ?? 'N/A'}',
                              style: TextStyle(color: Color(0xFFE53935), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
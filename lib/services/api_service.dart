import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://anime-mt-server.onrender.com';
  static const String aniwatchUrl = 'https://aniwatch-api-two-rosy.vercel.app';

  static Future<Map<String, dynamic>> getAnimeList({int limit = 20, int skip = 0}) async {
    final response = await http.get(Uri.parse('$baseUrl/anime?limit=$limit&skip=$skip'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load anime list');
  }

  static Future<Map<String, dynamic>> searchAnime(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/anime/search?q=${Uri.encodeComponent(query)}'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to search anime');
  }

  static Future<Map<String, dynamic>> getAnimeById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/anime/$id'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load anime');
  }

  static Future<Map<String, dynamic>> getEpisodes(String animeId) async {
    final response = await http.get(Uri.parse('$baseUrl/episodes/$animeId'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load episodes');
  }

  static Future<Map<String, dynamic>> aniwatchGetEpisodes(String aniwatchId) async {
    final response = await http.get(
      Uri.parse('$aniwatchUrl/api/v2/hianime/anime/$aniwatchId/episodes'),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load aniwatch episodes');
  }

  static Future<Map<String, dynamic>> aniwatchGetSources(String episodeId) async {
    final response = await http.get(
      Uri.parse('$aniwatchUrl/api/v2/hianime/episode/sources?animeEpisodeId=$episodeId'),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load sources');
  }

  static Future<String> storeProxyUrl(String videoUrl) async {
    final response = await http.post(
      Uri.parse('$aniwatchUrl/proxy/store'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'url': videoUrl}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return '$aniwatchUrl/proxy/play/${data['token']}';
    }
    throw Exception('Failed to store URL');
  }
}
import 'package:http/http.dart' as http;
import 'dart:convert';

const String BASE_URL = 'https://anime-mt-server.onrender.com';
const String ANIWATCH_URL = 'https://aniwatch-api-two-rosy.vercel.app/api/v2/hianime';

class ApiService {
  // ===== Our Server =====
  static Future<Map> getAnimeList({int page = 1, int limit = 20}) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/anime?page=$page&limit=$limit'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Failed to load anime');
  }

  static Future<Map> getAnimeDetails(String id) async {
    final response = await http.get(Uri.parse('$BASE_URL/anime/$id'));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Failed to load anime details');
  }

  static Future<Map> getEpisodes(String animeId) async {
    final response = await http.get(Uri.parse('$BASE_URL/episodes/$animeId'));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Failed to load episodes');
  }

  static Future<Map> searchAnime(String query) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/anime/search?q=${Uri.encodeComponent(query)}'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Failed to search anime');
  }

  // ===== Aniwatch API =====
  static Future<Map> aniwatchSearch(String query) async {
    final response = await http.get(
      Uri.parse('$ANIWATCH_URL/search?q=${Uri.encodeComponent(query)}'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Failed to search aniwatch');
  }

  static Future<Map> aniwatchGetEpisodes(String animeId) async {
    final response = await http.get(
      Uri.parse('$ANIWATCH_URL/anime/$animeId/episodes'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Failed to load episodes');
  }

  static Future<Map> aniwatchGetSources(String episodeId) async {
    final response = await http.get(
      Uri.parse('$ANIWATCH_URL/episode/sources?animeEpisodeId=$episodeId'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Failed to load sources');
  }
}
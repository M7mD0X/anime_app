import 'package:http/http.dart' as http;
import 'dart:convert';

const String BASE_URL = 'https://anime-mt-server-production.up.railway.app';

class ApiService {
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
    final response = await http.get(
      Uri.parse('$BASE_URL/anime/$id'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Failed to load anime details');
  }

  static Future<Map> getEpisodes(String animeId) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/episodes/$animeId'),
    );
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

  static Future<Map> getTrending() async {
    final response = await http.get(
      Uri.parse('$BASE_URL/anime/trending'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Failed to load trending');
  }
}
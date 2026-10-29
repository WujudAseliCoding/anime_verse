import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:anime_verse/models/anime.dart';

class AnimeRepository {
  static const _baseUrl = 'https://api.tenrai.org/v1';
  final http.Client _client = http.Client();

  // Asynchronous Method
  Future<List<Anime>> getTopAnime({int page = 1}) async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/top/anime'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        final List<dynamic> animeList = decodedData['data'];
        return animeList.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Error Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error $e');
    }
  }
}

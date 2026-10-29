import 'package:flutter/cupertino.dart';

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/anime.dart';
import '../data/dummy_data.dart';

class AppStateProvider extends ChangeNotifier {
  static const String _storageKey = 'favorite_anime_list';

  //data
  List<Anime> _favorites = [];
  String _selectedGenre = "All";
  String _homeSearchQuery = "";
  String _favoriteSearchQuery = "";
  bool _isLoading = false;

  //getter
  List<Anime> get favorites => _favorites;
  String get selectedGenre => _selectedGenre;
  String get homeSearchQuery => _homeSearchQuery;
  String get favoriteSearchQuery => _favoriteSearchQuery;

  // Constructor
  AppStateProvider() {
    _loadFavorites();
  }

  //helper
  bool isFavorite(String id) {
    return _favorites.any((anime) => anime.id == id);
  }

  void toggleFavorite(Anime anime) {
    if (isFavorite(anime.id)) {
      removeFavorite(anime.id);
    } else {
      addFavorite(anime);
    }
  }

  void addFavorite(Anime anime) {
    if (!isFavorite(anime.id)) {
      _favorites.add(anime);
      notifyListeners();
      _saveFavorites();
    }
  }

  void removeFavorite(String id) {
    _favorites.removeWhere((anime) => anime.id == id);
    notifyListeners();
    _saveFavorites();
  }

  // Genre filter
  void setSelectedGenre(String genre) {
    _selectedGenre = genre;
    notifyListeners();
  }

  // Search query setters
  void setHomeSearchQuery(String query) {
    _homeSearchQuery = query;
    notifyListeners();
  }

  void setFavoriteSearchQuery(String query) {
    _favoriteSearchQuery = query;
    notifyListeners();
  }

  // Get filtered anime for home screen
  List<Anime> getFilteredAnimeForHome() {
    var filteredList = DummyData.animeList;

    // Filter by genre
    if (_selectedGenre != "All") {
      filteredList = filteredList.where((anime) {
        final genres = anime.genre.split(',').map((g) => g.trim()).toList();
        return genres.contains(_selectedGenre);
      }).toList();
    }

    // Filter by search query
    if (_homeSearchQuery.isNotEmpty) {
      filteredList = filteredList.where((anime) {
        return anime.title.toLowerCase().contains(
          _homeSearchQuery.toLowerCase(),
        );
      }).toList();
    }

    return filteredList;
  }

  // Get filtered favorites
  List<Anime> getFilteredFavorites() {
    if (_favoriteSearchQuery.isEmpty) {
      return _favorites;
    }

    return _favorites.where((anime) {
      return anime.title.toLowerCase().contains(
        _favoriteSearchQuery.toLowerCase(),
      );
    }).toList();
  }

  // Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> favoritesJson = _favorites.map((anime) {
        return {
          'id': anime.id,
          'title': anime.title,
          'imagePath': anime.imagePath,
          'genre': anime.genre,
          'rating': anime.rating,
          'totalEpisodes': anime.totalEpisodes,
          'description': anime.description,
        };
      }).toList();

      final String jsonString = jsonEncode(favoritesJson);
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  // Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final List<Anime> loadedFavorites = jsonList.map((json) {
          return Anime(
            id: json['id']?.toString() ?? '',
            title: json['title']?.toString() ?? '',
            imagePath: json['imagePath']?.toString() ?? '',
            genre: json['genre']?.toString() ?? '',
            rating: json['rating']?.toString() ?? '',
            totalEpisodes: json['totalEpisodes']?.toString() ?? '',
            description: json['description']?.toString() ?? '',
          );
        }).toList();

        _favorites = loadedFavorites;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      _isLoading = false;
    }
  }
}

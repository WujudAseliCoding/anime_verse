import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anime_verse/providers/app_state_provider.dart';
import 'package:anime_verse/models/anime.dart';
import 'package:anime_verse/data/dummy_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Setup shared preferences mock
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppStateProvider Tests', () {
    test('Initial state should be empty', () {
      final provider = AppStateProvider();
      expect(provider.favorites, isEmpty);
      expect(provider.selectedGenre, 'All');
      expect(provider.homeSearchQuery, '');
      expect(provider.favoriteSearchQuery, '');
    });

    test('Can add favorite anime', () {
      final provider = AppStateProvider();
      final anime = DummyData.animeList.first;

      provider.addFavorite(anime);

      expect(provider.favorites.length, 1);
      expect(provider.isFavorite(anime.id), isTrue);
    });

    test('Can remove favorite anime', () {
      final provider = AppStateProvider();
      final anime = DummyData.animeList.first;

      provider.addFavorite(anime);
      expect(provider.favorites.length, 1);

      provider.removeFavorite(anime.id);
      expect(provider.favorites.length, 0);
      expect(provider.isFavorite(anime.id), isFalse);
    });

    test('Toggle favorite works correctly', () {
      final provider = AppStateProvider();
      final anime = DummyData.animeList.first;

      // Add via toggle
      provider.toggleFavorite(anime);
      expect(provider.isFavorite(anime.id), isTrue);

      // Remove via toggle
      provider.toggleFavorite(anime);
      expect(provider.isFavorite(anime.id), isFalse);
    });

    test('Cannot add duplicate favorites', () {
      final provider = AppStateProvider();
      final anime = DummyData.animeList.first;

      provider.addFavorite(anime);
      provider.addFavorite(anime);

      expect(provider.favorites.length, 1);
    });

    test('Genre filter works - All returns all anime', () {
      final provider = AppStateProvider();

      provider.setSelectedGenre('All');
      final filtered = provider.getFilteredAnimeForHome();

      expect(filtered.length, DummyData.animeList.length);
    });

    test('Genre filter works - Action returns only action anime', () {
      final provider = AppStateProvider();

      provider.setSelectedGenre('Action');
      final filtered = provider.getFilteredAnimeForHome();

      // All filtered anime should contain "Action" in their genre
      for (final anime in filtered) {
        final genres = anime.genre.split(',').map((g) => g.trim()).toList();
        expect(genres.contains('Action'), isTrue);
      }
    });

    test('Genre filter works with multiple genres', () {
      final provider = AppStateProvider();

      provider.setSelectedGenre('Fantasy');
      final filtered = provider.getFilteredAnimeForHome();

      // All filtered anime should contain "Fantasy" in their genre
      for (final anime in filtered) {
        final genres = anime.genre.split(',').map((g) => g.trim()).toList();
        expect(genres.contains('Fantasy'), isTrue);
      }
    });

    test('Home search query is case-insensitive', () {
      final provider = AppStateProvider();

      provider.setHomeSearchQuery('HUNTER');
      final filtered = provider.getFilteredAnimeForHome();

      // Should find Hunter x Hunter regardless of case
      expect(
          filtered.any((anime) =>
              anime.title.toLowerCase().contains('hunter'.toLowerCase())),
          isTrue);
    });

    test('Home search query filters correctly', () {
      final provider = AppStateProvider();

      provider.setHomeSearchQuery('One');
      final filtered = provider.getFilteredAnimeForHome();

      // All results should contain "One" in title
      for (final anime in filtered) {
        expect(anime.title.toLowerCase().contains('one'), isTrue);
      }
    });

    test('Favorite search query is independent from home search', () {
      final provider = AppStateProvider();
      final anime1 = DummyData.animeList[0];
      final anime2 = DummyData.animeList[1];

      provider.addFavorite(anime1);
      provider.addFavorite(anime2);

      provider.setHomeSearchQuery('test home');
      provider.setFavoriteSearchQuery('test favorite');

      expect(provider.homeSearchQuery, 'test home');
      expect(provider.favoriteSearchQuery, 'test favorite');
    });

    test('Favorite search query filters favorites', () {
      final provider = AppStateProvider();

      // Add multiple favorites
      for (int i = 0; i < 3 && i < DummyData.animeList.length; i++) {
        provider.addFavorite(DummyData.animeList[i]);
      }

      final firstAnimeTitle = DummyData.animeList[0].title;
      provider.setFavoriteSearchQuery(firstAnimeTitle.substring(0, 3));
      final filtered = provider.getFilteredFavorites();

      // Should find at least the first anime
      expect(filtered.isNotEmpty, isTrue);
      for (final anime in filtered) {
        expect(
            anime.title
                .toLowerCase()
                .contains(firstAnimeTitle.substring(0, 3).toLowerCase()),
            isTrue);
      }
    });

    test('Genre and search filters work together', () {
      final provider = AppStateProvider();

      provider.setSelectedGenre('Action');
      provider.setHomeSearchQuery('a');
      final filtered = provider.getFilteredAnimeForHome();

      // All results should be Action AND contain "a" in title
      for (final anime in filtered) {
        final genres = anime.genre.split(',').map((g) => g.trim()).toList();
        expect(genres.contains('Action'), isTrue);
        expect(anime.title.toLowerCase().contains('a'), isTrue);
      }
    });

    test('Empty search query returns all results', () {
      final provider = AppStateProvider();

      provider.setHomeSearchQuery('');
      final filtered = provider.getFilteredAnimeForHome();

      expect(filtered.length, DummyData.animeList.length);
    });

    test('Empty favorite search returns all favorites', () {
      final provider = AppStateProvider();

      for (int i = 0; i < 3 && i < DummyData.animeList.length; i++) {
        provider.addFavorite(DummyData.animeList[i]);
      }

      provider.setFavoriteSearchQuery('');
      final filtered = provider.getFilteredFavorites();

      expect(filtered.length, 3);
    });
  });

  group('Anime Model Tests', () {
    test('Anime toJson works correctly', () {
      final anime = Anime(
        id: '1',
        title: 'Test Anime',
        imagePath: 'path/to/image',
        genre: 'Action, Adventure',
        rating: '8.5',
        totalEpisodes: '24',
        description: 'Test description',
      );

      final json = anime.toJson();

      expect(json['id'], '1');
      expect(json['title'], 'Test Anime');
      expect(json['imagePath'], 'path/to/image');
      expect(json['genre'], 'Action, Adventure');
      expect(json['rating'], '8.5');
      expect(json['totalEpisodes'], '24');
      expect(json['description'], 'Test description');
    });

    test('Anime fromJson works correctly', () {
      final json = {
        'id': '1',
        'title': 'Test Anime',
        'imagePath': 'path/to/image',
        'genre': 'Action, Adventure',
        'rating': '8.5',
        'totalEpisodes': '24',
        'description': 'Test description',
      };

      final anime = Anime.fromJson(json);

      expect(anime.id, '1');
      expect(anime.title, 'Test Anime');
      expect(anime.imagePath, 'path/to/image');
      expect(anime.genre, 'Action, Adventure');
      expect(anime.rating, '8.5');
      expect(anime.totalEpisodes, '24');
      expect(anime.description, 'Test description');
    });

    test('Anime fromJson handles missing fields', () {
      final json = {
        'id': '1',
        'title': 'Test Anime',
      };

      final anime = Anime.fromJson(json);

      expect(anime.id, '1');
      expect(anime.title, 'Test Anime');
      expect(anime.imagePath, '');
      expect(anime.genre, '');
      expect(anime.rating, '');
      expect(anime.totalEpisodes, '');
      expect(anime.description, '');
    });
  });

  group('Data Persistence Tests', () {
    test('Favorites are saved to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});

      final provider = AppStateProvider();
      final anime = DummyData.animeList.first;

      provider.addFavorite(anime);

      // Wait for async save
      await Future.delayed(Duration(milliseconds: 100));

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('favorite_anime_list');

      expect(saved, isNotNull);
      expect(saved!.contains(anime.id), isTrue);
    });

    test('Favorites are loaded from SharedPreferences', () async {
      final anime = DummyData.animeList.first;
      final json = [anime.toJson()];
      final jsonString = '[${json.map((e) => '{"id":"${e['id']}","title":"${e['title']}","imagePath":"${e['imagePath']}","genre":"${e['genre']}","rating":"${e['rating']}","totalEpisodes":"${e['totalEpisodes']}","description":"${e['description']}"}').join(',')}]';

      SharedPreferences.setMockInitialValues({
        'favorite_anime_list': jsonString,
      });

      final provider = AppStateProvider();

      // Wait for async load
      await Future.delayed(Duration(milliseconds: 100));

      expect(provider.favorites.isNotEmpty, isTrue);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state_provider.dart';
import '../widget/app_scaffold.dart';
import '../widget/favorite_anime_card.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          "Favorite Anime",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: screenWidth * 0.06,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Consumer<AppStateProvider>(
              builder: (context, provider, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenWidth * 0.075),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: screenWidth * 0.02,
                        offset: Offset(0, screenHeight * 0.005),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      provider.setFavoriteSearchQuery(value);
                    },
                    decoration: InputDecoration(
                      hintText: "Search favorite anime",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: screenWidth * 0.04,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: screenWidth * 0.06,
                      ),
                      suffixIcon: provider.favoriteSearchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.grey,
                                size: screenWidth * 0.06,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                provider.setFavoriteSearchQuery('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          screenWidth * 0.075,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          screenWidth * 0.075,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          screenWidth * 0.075,
                        ),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      filled: true,
                      fillColor: Color(0xFF0b395e),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.015,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),

          // Favorite Anime List
          Expanded(
            child: Consumer<AppStateProvider>(
              builder: (context, favoriteProvider, child) {
                final favorites = favoriteProvider.getFilteredFavorites();
                final allFavorites = favoriteProvider.favorites;

                if (allFavorites.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 32,
                          color: Colors.white70,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Belum ada anime favorit',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                if (favorites.isEmpty && allFavorites.isNotEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 32, color: Colors.white70),
                        SizedBox(height: 8),
                        Text(
                          'Tidak ada hasil pencarian',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final anime = favorites[index];
                    return FavoriteAnimeCard(
                      id: anime.id,
                      title: anime.title,
                      genre: anime.genre,
                      rating: anime.rating,
                      imagePath: anime.imagePath,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

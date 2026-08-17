import 'package:flutter/material.dart';

import '../services/favorites_service.dart';
import '../widgets/movie_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final double cardWidth =
        (screenWidth * 0.42).clamp(130.0, 200.0).toDouble();

    final double cardHeight = cardWidth * 1.5;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: FavoritesService.instance,
        builder: (context, child) {
          final favorites = FavoritesService.instance.favorites;

          if (favorites.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await FavoritesService.instance.loadFavorites();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      4,
                      16,
                      18,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Colors.redAccent,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${favorites.length} '
                          '${favorites.length == 1 ? 'Movie' : 'Movies'}',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    24,
                  ),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final movie = favorites[index];

                        return MovieCard(
                          movie: movie,
                          width: cardWidth,
                          height: cardHeight,
                        );
                      },
                      childCount: favorites.length,
                    ),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          screenWidth > 700 ? 4 : 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 20,
                      childAspectRatio:
                          cardWidth / (cardHeight + 55),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent.withValues(
                  alpha: 0.10,
                ),
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 70,
                color: Colors.redAccent,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'No Favorites Yet',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Movies you add to your favorites '
              'will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
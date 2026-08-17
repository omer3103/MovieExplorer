import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../screens/movie_details_screen.dart';
import '../services/favorites_service.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final double width;
  final double height;

  const MovieCard({
    super.key,
    required this.movie,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FavoritesService.instance,
      builder: (context, child) {
        final isFavorite =
            FavoritesService.instance.isFavorite(movie);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailsScreen(
                  movie: movie,
                ),
              ),
            );
          },
          child: SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPoster(context, isFavorite),

                const SizedBox(height: 9),

                Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 17,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      movie.rating.toStringAsFixed(1),
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(width: 8),

                    if (movie.releaseDate.isNotEmpty &&
                        movie.releaseDate != 'Unknown')
                      Expanded(
                        child: Text(
                          movie.releaseDate.length >= 4
                              ? movie.releaseDate.substring(0, 4)
                              : movie.releaseDate,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPoster(
    BuildContext context,
    bool isFavorite,
  ) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Poster
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: width,
              height: height,
              child: movie.posterUrl.isEmpty
                  ? _buildPlaceholder()
                  : Image.network(
                      movie.posterUrl,
                      width: width,
                      height: height,
                      fit: BoxFit.cover,
                      loadingBuilder: (
                        context,
                        child,
                        loadingProgress,
                      ) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return _buildLoadingPlaceholder();
                      },
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return _buildPlaceholder();
                      },
                    ),
            ),
          ),

          // Bottom gradient
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: height * 0.25,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Favorite button
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.black.withValues(alpha: 0.70),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  FavoritesService.instance.toggleFavorite(movie);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (
                      child,
                      animation,
                    ) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      key: ValueKey(isFavorite),
                      color: isFavorite
                          ? Colors.redAccent
                          : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Rating badge
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                    size: 14,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    movie.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade800,
      child: const Center(
        child: Icon(
          Icons.movie_outlined,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey.shade900,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
}
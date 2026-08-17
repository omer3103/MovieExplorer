import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../widgets/movie_card.dart';

class MovieListScreen extends StatelessWidget {
  final String title;
  final List<Movie> movies;

  const MovieListScreen({
    super.key,
    required this.title,
    required this.movies,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final double cardWidth =
        (screenWidth * 0.42).clamp(130.0, 200.0).toDouble();

    final double cardHeight = cardWidth * 1.5;

    final int columns = screenWidth > 1000
        ? 5
        : screenWidth > 700
            ? 4
            : 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: movies.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: movies.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 14,
                mainAxisSpacing: 20,
                childAspectRatio:
                    cardWidth / (cardHeight + 60),
              ),
              itemBuilder: (context, index) {
                final movie = movies[index];

                return MovieCard(
                  movie: movie,
                  width: cardWidth,
                  height: cardHeight,
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_outlined,
            size: 70,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 16),
          const Text(
            'No movies available',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
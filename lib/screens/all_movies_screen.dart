import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../widgets/movie_card.dart';

class AllMoviesScreen extends StatelessWidget {
  final String title;
  final List<Movie> movies;

  const AllMoviesScreen({
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: movies.isEmpty
          ? const Center(
              child: Text('No movies available.'),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: movies.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: screenWidth > 700 ? 4 : 2,
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
}
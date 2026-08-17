import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/api_service.dart';
import '../widgets/movie_card.dart';

class GenreMoviesScreen extends StatefulWidget {
  final String genreName;
  final int genreId;

  const GenreMoviesScreen({
    super.key,
    required this.genreName,
    required this.genreId,
  });

  @override
  State<GenreMoviesScreen> createState() => _GenreMoviesScreenState();
}

class _GenreMoviesScreenState extends State<GenreMoviesScreen> {
  final ApiService _apiService = ApiService();

  List<Movie> _movies = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGenreMovies();
  }

  Future<void> _loadGenreMovies() async {
    try {
      final movies =
          await _apiService.getMoviesByGenre(widget.genreId);

      if (!mounted) return;

      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Failed to load ${widget.genreName} movies.';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshMovies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await _loadGenreMovies();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final double cardWidth =
        (screenWidth * 0.42).clamp(130.0, 200.0).toDouble();

    final double cardHeight = cardWidth * 1.5;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.genreName} Movies',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMovies,
        child: _buildBody(
          screenWidth,
          cardWidth,
          cardHeight,
        ),
      ),
    );
  }

  Widget _buildBody(
    double screenWidth,
    double cardWidth,
    double cardHeight,
  ) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_movies.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _movies.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth > 700 ? 4 : 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 20,
        childAspectRatio:
            cardWidth / (cardHeight + 60),
      ),
      itemBuilder: (context, index) {
        final movie = _movies[index];

        return MovieCard(
          movie: movie,
          width: cardWidth,
          height: cardHeight,
        );
      },
    );
  }

  Widget _buildErrorState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _refreshMovies,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.movie_filter_outlined,
                  size: 70,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Movies Found',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No ${widget.genreName} movies are available.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
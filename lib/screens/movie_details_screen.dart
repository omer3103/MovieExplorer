import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final ApiService _apiService = ApiService();

  Movie? _movie;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
  }

  Future<void> _loadMovieDetails() async {
    try {
      final movie = await _apiService.getMovieDetails(widget.movie.id);

      if (!mounted) return;

      setState(() {
        _movie = movie;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Failed to load movie details.';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(Movie movie) async {
    await FavoritesService.instance.toggleFavorite(movie);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_movie == null) {
      return const Center(
        child: Text('Movie details unavailable.'),
      );
    }

    final movie = _movie!;

    return CustomScrollView(
      slivers: [
        _buildAppBar(movie),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              22,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(movie),

                const SizedBox(height: 18),

                _buildMovieInfo(movie),

                if (movie.genres.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  _buildGenres(movie),
                ],

                const SizedBox(height: 30),

                _buildOverview(movie),

                const SizedBox(height: 30),

                _buildFavoriteButton(movie),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(Movie movie) {
    final isFavorite =
        FavoritesService.instance.isFavorite(movie);

    return SliverAppBar(
      expandedHeight: 460,
      pinned: true,
      backgroundColor: Colors.black,
      elevation: 0,

      leading: Padding(
        padding: const EdgeInsets.all(6),
        child: Material(
          color: Colors.black.withValues(alpha: 0.65),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
      ),

      actions: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: Material(
            color: Colors.black.withValues(alpha: 0.65),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                _toggleFavorite(movie);
              },
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: Icon(
                  isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: isFavorite
                      ? Colors.redAccent
                      : Colors.white,
                  size: 21,
                ),
              ),
            ),
          ),
        ),
      ],

      flexibleSpace: FlexibleSpaceBar(
        background: _buildPoster(movie),
      ),
    );
  }

  Widget _buildTitle(Movie movie) {
    return Text(
      movie.title,
      style: const TextStyle(
        fontSize: 29,
        height: 1.15,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMovieInfo(Movie movie) {
    return Wrap(
      spacing: 18,
      runSpacing: 12,
      children: [
        _infoItem(
          icon: Icons.star_rounded,
          iconColor: Colors.amber,
          text: movie.rating.toStringAsFixed(1),
        ),

        _infoItem(
          icon: Icons.calendar_today_rounded,
          text: _getReleaseYear(movie.releaseDate),
        ),

        if (movie.runtime > 0)
          _infoItem(
            icon: Icons.access_time_rounded,
            text: movie.formattedRuntime,
          ),

        if (movie.popularity > 0)
          _infoItem(
            icon: Icons.trending_up_rounded,
            text: movie.popularity.toStringAsFixed(0),
          ),
      ],
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String text,
    Color? iconColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 19,
          color: iconColor ?? Colors.grey.shade300,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Widget _buildGenres(Movie movie) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: movie.genres.map((genre) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.shade800,
            ),
          ),
          child: Text(
            genre,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOverview(Movie movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          movie.overview.isEmpty
              ? 'No overview available.'
              : movie.overview,
          style: TextStyle(
            fontSize: 15.5,
            height: 1.65,
            color: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteButton(Movie movie) {
    final isFavorite =
        FavoritesService.instance.isFavorite(movie);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          _toggleFavorite(movie);
        },
        icon: Icon(
          isFavorite
              ? Icons.favorite
              : Icons.favorite_border,
        ),
        label: Text(
          isFavorite
              ? 'Remove from Favorites'
              : 'Add to Favorites',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isFavorite
              ? Colors.redAccent.withValues(alpha: 0.15)
              : Colors.redAccent,
          foregroundColor: isFavorite
              ? Colors.redAccent
              : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: isFavorite
              ? const BorderSide(
                  color: Colors.redAccent,
                )
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPoster(Movie movie) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 300,
            maxHeight: 430,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: movie.posterUrl.isEmpty
                ? _buildPosterPlaceholder()
                : Image.network(
                    movie.posterUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (
                      context,
                      child,
                      loadingProgress,
                    ) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return _buildPosterLoading();
                    },
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return _buildPosterPlaceholder();
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildPosterLoading() {
    return Container(
      color: Colors.grey.shade900,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildPosterPlaceholder() {
    return Container(
      color: Colors.grey.shade900,
      child: const Center(
        child: Icon(
          Icons.movie_outlined,
          size: 80,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
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
              _errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: _loadMovieDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  String _getReleaseYear(String date) {
    if (date.isEmpty || date == 'Unknown') {
      return 'Unknown';
    }

    if (date.length >= 4) {
      return date.substring(0, 4);
    }

    return date;
  }
}
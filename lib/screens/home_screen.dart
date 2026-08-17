import 'package:flutter/material.dart';

import 'all_movies_screen.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../widgets/movie_card.dart';
import 'genre_movies_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();

  // --------------------------------------------------
  // Movie Lists
  // --------------------------------------------------

  List<Movie> _popularMovies = [];
  List<Movie> _trendingMovies = [];

  // --------------------------------------------------
  // Scroll Controllers
  // --------------------------------------------------

  final ScrollController _popularScrollController =
      ScrollController();

  final ScrollController _trendingScrollController =
      ScrollController();

  // --------------------------------------------------
  // Popular Pagination
  // --------------------------------------------------

  int _popularPage = 1;
  bool _popularLoadingMore = false;
  bool _popularHasMore = true;

  // --------------------------------------------------
  // Trending Pagination
  // --------------------------------------------------

  int _trendingPage = 1;
  bool _trendingLoadingMore = false;
  bool _trendingHasMore = true;

  // --------------------------------------------------
  // Initial Loading
  // --------------------------------------------------

  bool _isLoading = true;
  String? _errorMessage;

  // --------------------------------------------------
  // Init
  // --------------------------------------------------

  @override
  void initState() {
    super.initState();

    _popularScrollController.addListener(
      _onPopularScroll,
    );

    _trendingScrollController.addListener(
      _onTrendingScroll,
    );

    _loadInitialMovies();
  }

  // --------------------------------------------------
  // Initial Movies
  // --------------------------------------------------

  Future<void> _loadInitialMovies() async {
    try {
      final results = await Future.wait([
        _apiService.getPopularMovies(page: 1),
        _apiService.getTrendingMovies(page: 1),
      ]);

      if (!mounted) return;

      final popular = results[0];
      final trending = results[1];

      setState(() {
        _popularMovies = popular;
        _trendingMovies = trending;

        _popularPage = 1;
        _trendingPage = 1;

        _popularHasMore = popular.isNotEmpty;
        _trendingHasMore = trending.isNotEmpty;

        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load movies.';
      });
    }
  }

  // --------------------------------------------------
  // Popular Scroll
  // --------------------------------------------------

  void _onPopularScroll() {
    if (!_popularScrollController.hasClients) {
      return;
    }

    final position = _popularScrollController.position;

    // Load next page when user is close to the end.
    if (position.pixels >= position.maxScrollExtent - 300) {
      _loadMorePopularMovies();
    }
  }

  // --------------------------------------------------
  // Trending Scroll
  // --------------------------------------------------

  void _onTrendingScroll() {
    if (!_trendingScrollController.hasClients) {
      return;
    }

    final position = _trendingScrollController.position;

    // Load next page when user is close to the end.
    if (position.pixels >= position.maxScrollExtent - 300) {
      _loadMoreTrendingMovies();
    }
  }

  // --------------------------------------------------
  // Load More Popular Movies
  // --------------------------------------------------

  Future<void> _loadMorePopularMovies() async {
    if (_popularLoadingMore || !_popularHasMore) {
      return;
    }

    setState(() {
      _popularLoadingMore = true;
    });

    try {
      final nextPage = _popularPage + 1;

      final movies = await _apiService.getPopularMovies(
        page: nextPage,
      );

      if (!mounted) return;

      setState(() {
        if (movies.isEmpty) {
          _popularHasMore = false;
        } else {
          _popularMovies.addAll(movies);
          _popularPage = nextPage;
        }

        _popularLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _popularLoadingMore = false;
      });
    }
  }

  // --------------------------------------------------
  // Load More Trending Movies
  // --------------------------------------------------

  Future<void> _loadMoreTrendingMovies() async {
    if (_trendingLoadingMore || !_trendingHasMore) {
      return;
    }

    setState(() {
      _trendingLoadingMore = true;
    });

    try {
      final nextPage = _trendingPage + 1;

      final movies = await _apiService.getTrendingMovies(
        page: nextPage,
      );

      if (!mounted) return;

      setState(() {
        if (movies.isEmpty) {
          _trendingHasMore = false;
        } else {
          _trendingMovies.addAll(movies);
          _trendingPage = nextPage;
        }

        _trendingLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _trendingLoadingMore = false;
      });
    }
  }

  // --------------------------------------------------
  // Refresh
  // --------------------------------------------------

  Future<void> _refreshMovies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;

      _popularMovies = [];
      _trendingMovies = [];

      _popularPage = 1;
      _trendingPage = 1;

      _popularHasMore = true;
      _trendingHasMore = true;

      _popularLoadingMore = false;
      _trendingLoadingMore = false;
    });

    await _loadInitialMovies();
  }

  // --------------------------------------------------
  // Open Genre
  // --------------------------------------------------

  void _openGenre(String name, int genreId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenreMoviesScreen(
          genreName: name,
          genreId: genreId,
        ),
      ),
    );
  }

  // --------------------------------------------------
  // Dispose
  // --------------------------------------------------

  @override
  void dispose() {
    _popularScrollController.dispose();
    _trendingScrollController.dispose();

    super.dispose();
  }

  // --------------------------------------------------
  // Build
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final double cardWidth =
        (screenWidth * 0.42).clamp(130.0, 200.0).toDouble();

    final double cardHeight = cardWidth * 1.5;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Movie Explorer',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMovies,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Good Evening 👋',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Discover your next favorite movie',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade400,
                  ),
                ),

                const SizedBox(height: 20),

                // --------------------------------------------------
                // Search
                // --------------------------------------------------

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SearchScreen(),
                      ),
                    );
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search movies...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade900,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // --------------------------------------------------
                // Loading
                // --------------------------------------------------

                if (_isLoading)
                  _buildLoadingState()

                // --------------------------------------------------
                // Error
                // --------------------------------------------------

                else if (_errorMessage != null)
                  _buildErrorState()

                // --------------------------------------------------
                // Content
                // --------------------------------------------------

                else ...[
                  // Popular Movies
                  _buildMovieSection(
                    title: 'Popular Movies',
                    movies: _popularMovies,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                    controller: _popularScrollController,
                    isLoadingMore: _popularLoadingMore,
                    hasMore: _popularHasMore,
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AllMoviesScreen(
                            title: 'Popular Movies',
                            movies: _popularMovies,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Genres
                  _buildGenres(),

                  const SizedBox(height: 28),

                  // Trending Movies
                  _buildMovieSection(
                    title: 'Trending Now',
                    movies: _trendingMovies,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                    controller: _trendingScrollController,
                    isLoadingMore: _trendingLoadingMore,
                    hasMore: _trendingHasMore,
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AllMoviesScreen(
                            title: 'Trending Movies',
                            movies: _trendingMovies,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // Movie Section
  // --------------------------------------------------

  Widget _buildMovieSection({
    required String title,
    required List<Movie> movies,
    required double cardWidth,
    required double cardHeight,
    required ScrollController controller,
    required bool isLoadingMore,
    required bool hasMore,
    required VoidCallback onSeeAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          title,
          onSeeAll: onSeeAll,
        ),

        const SizedBox(height: 12),

        if (movies.isEmpty)
          const Text('No movies available.')
        else
          SizedBox(
            height: cardHeight + 60,
            child: ListView.builder(
              controller: controller,
              scrollDirection: Axis.horizontal,
              itemCount: movies.length +
                  (isLoadingMore || hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Loading indicator at the end.
                if (index >= movies.length) {
                  return SizedBox(
                    width: 60,
                    child: Center(
                      child: isLoadingMore
                          ? const SizedBox(
                              width: 28,
                              height: 28,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  );
                }

                final movie = movies[index];

                return Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: MovieCard(
                    movie: movie,
                    width: cardWidth,
                    height: cardHeight,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // --------------------------------------------------
  // Loading State
  // --------------------------------------------------

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 400,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // --------------------------------------------------
  // Error State
  // --------------------------------------------------

  Widget _buildErrorState() {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
            ),

            const SizedBox(height: 16),

            Text(
              _errorMessage ??
                  'Something went wrong.',
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
    );
  }

  // --------------------------------------------------
  // Genres
  // --------------------------------------------------

  Widget _buildGenres() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Genres',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 45,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _genreChip('Action', 28),
              _genreChip('Comedy', 35),
              _genreChip('Drama', 18),
              _genreChip('Horror', 27),
              _genreChip('Sci-Fi', 878),
            ],
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // Section Header
  // --------------------------------------------------

  Widget _sectionHeader(
    String title, {
    required VoidCallback onSeeAll,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        TextButton(
          onPressed: onSeeAll,
          child: const Text('See All'),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // Genre Chip
  // --------------------------------------------------

  Widget _genreChip(
    String name,
    int genreId,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(name),
        selected: false,
        onSelected: (_) {
          _openGenre(name, genreId);
        },
        backgroundColor:
            Colors.grey.shade900,
        labelStyle: const TextStyle(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(20),
          side: BorderSide.none,
        ),
      ),
    );
  }
}
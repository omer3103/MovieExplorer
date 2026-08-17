import 'dart:async';

import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/api_service.dart';
import '../widgets/movie_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  final ApiService _apiService = ApiService();

  Timer? _debounce;

  List<Movie> _searchResults = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMorePages = true;

  String? _errorMessage;

  int _currentPage = 1;

  String _lastQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);
  }

  // --------------------------------------------------
  // Search text changed
  // --------------------------------------------------

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    _debounce?.cancel();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _isLoadingMore = false;
        _hasMorePages = true;
        _currentPage = 1;
        _errorMessage = null;
        _lastQuery = '';
      });

      return;
    }

    setState(() {});

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () {
        _startNewSearch(query);
      },
    );
  }

  // --------------------------------------------------
  // Start a completely new search
  // --------------------------------------------------

  Future<void> _startNewSearch(String query) async {
    if (query.isEmpty) return;

    _currentPage = 1;
    _hasMorePages = true;
    _lastQuery = query;

    setState(() {
      _searchResults = [];
      _isLoading = true;
      _isLoadingMore = false;
      _errorMessage = null;
    });

    try {
      final results = await _apiService.searchMovies(
        query,
        page: _currentPage,
      );

      if (!mounted) return;

      // Prevent old searches from updating the screen.
      if (_searchController.text.trim() != query) {
        return;
      }

      setState(() {
        _searchResults = results;
        _isLoading = false;

        if (results.isEmpty) {
          _hasMorePages = false;
        }
      });
    } catch (e) {
      if (!mounted) return;

      if (_searchController.text.trim() != query) {
        return;
      }

      setState(() {
        _searchResults = [];
        _isLoading = false;
        _errorMessage = 'Failed to search movies.';
      });
    }
  }

  // --------------------------------------------------
  // Load next page
  // --------------------------------------------------

  Future<void> _loadMoreMovies() async {
    if (_isLoading ||
        _isLoadingMore ||
        !_hasMorePages ||
        _lastQuery.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    final nextPage = _currentPage + 1;

    try {
      final results = await _apiService.searchMovies(
        _lastQuery,
        page: nextPage,
      );

      if (!mounted) return;

      // Make sure the user hasn't started another search.
      if (_searchController.text.trim() != _lastQuery) {
        return;
      }

      setState(() {
        // Avoid duplicate movies.
        final existingIds =
            _searchResults.map((movie) => movie.id).toSet();

        final newMovies = results.where(
          (movie) => !existingIds.contains(movie.id),
        );

        _searchResults.addAll(newMovies);

        _currentPage = nextPage;
        _isLoadingMore = false;

        // TMDB normally returns fewer results on the final page.
        if (results.isEmpty || results.length < 20) {
          _hasMorePages = false;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  // --------------------------------------------------
  // Clear search
  // --------------------------------------------------

  void _clearSearch() {
    _debounce?.cancel();

    _searchController.clear();

    setState(() {
      _searchResults = [];
      _errorMessage = null;
      _isLoading = false;
      _isLoadingMore = false;
      _hasMorePages = true;
      _currentPage = 1;
      _lastQuery = '';
    });
  }

  // --------------------------------------------------
  // Retry
  // --------------------------------------------------

  Future<void> _retrySearch() async {
    final query = _searchController.text.trim();

    if (query.isNotEmpty) {
      await _startNewSearch(query);
    }
  }

  // --------------------------------------------------
  // Dispose
  // --------------------------------------------------

  @override
  void dispose() {
    _debounce?.cancel();

    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();

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
          'Search Movies',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),

            const SizedBox(height: 16),

            Expanded(
              child: _buildSearchContent(
                screenWidth,
                cardWidth,
                cardHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // Search bar
  // --------------------------------------------------

  Widget _buildSearchBar() {
    final hasText = _searchController.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        0,
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search movies...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: hasText
              ? IconButton(
                  onPressed: _clearSearch,
                  tooltip: 'Clear',
                  icon: const Icon(Icons.clear),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF1C1C1C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.redAccent,
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // Search content
  // --------------------------------------------------

  Widget _buildSearchContent(
    double screenWidth,
    double cardWidth,
    double cardHeight,
  ) {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      return _buildInitialState();
    }

    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_searchResults.isEmpty) {
      return _buildNoResults(query);
    }

    return RefreshIndicator(
      onRefresh: _retrySearch,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification ||
              notification is OverscrollNotification) {
            final metrics = notification.metrics;

            // Load more when the user gets close to the bottom.
            if (metrics.pixels >=
                metrics.maxScrollExtent - 500) {
              _loadMoreMovies();
            }
          }

          return false;
        },
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            16,
            4,
            16,
            24,
          ),
          itemCount:
              _searchResults.length +
              (_isLoadingMore ? 2 : 0),
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: screenWidth > 700 ? 4 : 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 20,
            childAspectRatio:
                cardWidth / (cardHeight + 60),
          ),
          itemBuilder: (context, index) {
            if (index >= _searchResults.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final movie = _searchResults[index];

            return MovieCard(
              movie: movie,
              width: cardWidth,
              height: cardHeight,
            );
          },
        ),
      ),
    );
  }

  // --------------------------------------------------
  // Loading
  // --------------------------------------------------

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // --------------------------------------------------
  // Initial state
  // --------------------------------------------------

  Widget _buildInitialState() {
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
                Icons.search,
                size: 65,
                color: Colors.redAccent,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Search for a movie',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Find movies from the TMDB database.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // No results
  // --------------------------------------------------

  Widget _buildNoResults(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_filter_outlined,
              size: 70,
              color: Colors.grey.shade600,
            ),

            const SizedBox(height: 18),

            const Text(
              'No Movies Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'No results found for "$query".',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade500,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Try a different movie title.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // Error
  // --------------------------------------------------

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

            const SizedBox(height: 18),

            Text(
              _errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: _retrySearch,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
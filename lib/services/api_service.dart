import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/movie.dart';

class ApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // --------------------------------------------------
  // TMDB API KEY
  // --------------------------------------------------

  static const String _apiKey = '55f815937e450a751d388941f7fa4d8b';

  // --------------------------------------------------
  // Helper: GET request
  // --------------------------------------------------

  Future<Map<String, dynamic>> _get(
    String endpoint,
  ) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'TMDB request failed: ${response.statusCode}',
    );
  }

  // --------------------------------------------------
  // Helper: Convert results to movies
  // --------------------------------------------------

  List<Movie> _parseMovies(Map<String, dynamic> data) {
    final List results = data['results'] ?? [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .toList();
  }

  // --------------------------------------------------
  // Popular Movies
  // --------------------------------------------------

  Future<List<Movie>> getPopularMovies({
    int page = 1,
  }) async {
    final data = await _get(
      '/movie/popular'
      '?api_key=$_apiKey'
      '&language=en-US'
      '&page=$page',
    );

    return _parseMovies(data);
  }

  // --------------------------------------------------
  // Trending Movies
  // --------------------------------------------------

  Future<List<Movie>> getTrendingMovies({
    int page = 1,
  }) async {
    final data = await _get(
      '/trending/movie/week'
      '?api_key=$_apiKey'
      '&language=en-US'
      '&page=$page',
    );

    return _parseMovies(data);
  }

  // --------------------------------------------------
  // Search Movies
  // --------------------------------------------------

  Future<List<Movie>> searchMovies(
    String query, {
    int page = 1,
  }) async {
    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      return [];
    }

    final data = await _get(
      '/search/movie'
      '?api_key=$_apiKey'
      '&language=en-US'
      '&query=${Uri.encodeComponent(cleanQuery)}'
      '&page=$page'
      '&include_adult=false',
    );

    return _parseMovies(data);
  }

  // --------------------------------------------------
  // Movie Details
  // --------------------------------------------------

  Future<Movie> getMovieDetails(int movieId) async {
    final data = await _get(
      '/movie/$movieId'
      '?api_key=$_apiKey'
      '&language=en-US',
    );

    return Movie.fromJson(data);
  }

  // --------------------------------------------------
  // Movies by Genre
  // --------------------------------------------------

  Future<List<Movie>> getMoviesByGenre(
    int genreId, {
    int page = 1,
  }) async {
    final data = await _get(
      '/discover/movie'
      '?api_key=$_apiKey'
      '&language=en-US'
      '&with_genres=$genreId'
      '&sort_by=popularity.desc'
      '&page=$page'
      '&include_adult=false',
    );

    return _parseMovies(data);
  }

  // --------------------------------------------------
  // Top Rated Movies
  // --------------------------------------------------

  Future<List<Movie>> getTopRatedMovies({
    int page = 1,
  }) async {
    final data = await _get(
      '/movie/top_rated'
      '?api_key=$_apiKey'
      '&language=en-US'
      '&page=$page',
    );

    return _parseMovies(data);
  }

  // --------------------------------------------------
  // Now Playing Movies
  // --------------------------------------------------

  Future<List<Movie>> getNowPlayingMovies({
    int page = 1,
  }) async {
    final data = await _get(
      '/movie/now_playing'
      '?api_key=$_apiKey'
      '&language=en-US'
      '&page=$page',
    );

    return _parseMovies(data);
  }

  // --------------------------------------------------
  // Upcoming Movies
  // --------------------------------------------------

  Future<List<Movie>> getUpcomingMovies({
    int page = 1,
  }) async {
    final data = await _get(
      '/movie/upcoming'
      '?api_key=$_apiKey'
      '&language=en-US'
      '&page=$page',
    );

    return _parseMovies(data);
  }
}
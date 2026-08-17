import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie.dart';

class FavoritesService extends ChangeNotifier {
  FavoritesService._();

  static final FavoritesService instance = FavoritesService._();

  static const String _favoritesKey = 'favorite_movies';

  final List<Movie> _favorites = [];

  List<Movie> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(Movie movie) {
    return _favorites.any((item) => item.id == movie.id);
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final savedFavorites = prefs.getStringList(_favoritesKey);

    if (savedFavorites == null) {
      return;
    }

    _favorites.clear();

    for (final movieJson in savedFavorites) {
      try {
        final movieMap =
            jsonDecode(movieJson) as Map<String, dynamic>;

        _favorites.add(Movie.fromJson(movieMap));
      } catch (_) {
        // Ignore invalid saved movie data.
      }
    }

    notifyListeners();
  }

  Future<void> toggleFavorite(Movie movie) async {
    if (isFavorite(movie)) {
      _favorites.removeWhere(
        (item) => item.id == movie.id,
      );
    } else {
      _favorites.add(movie);
    }

    await _saveFavorites();

    notifyListeners();
  }

  Future<void> removeFavorite(Movie movie) async {
    _favorites.removeWhere(
      (item) => item.id == movie.id,
    );

    await _saveFavorites();

    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final favoriteMovies = _favorites.map((movie) {
      return jsonEncode({
        'id': movie.id,
        'title': movie.title,
        'vote_average': movie.rating,
        'overview': movie.overview,
        'poster_path': movie.posterPath,
        'release_date': movie.releaseDate,

        // Movie genres
        'genres': movie.genres.map((genre) {
          return {
            'name': genre,
          };
        }).toList(),

        // Additional movie details
        'runtime': movie.runtime,
        'popularity': movie.popularity,
      });
    }).toList();

    await prefs.setStringList(
      _favoritesKey,
      favoriteMovies,
    );
  }
}
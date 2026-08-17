class Movie {
  final int id;
  final String title;
  final double rating;
  final String overview;
  final String posterPath;
  final String releaseDate;
  final List<String> genres;
  final int runtime;
  final double popularity;

  const Movie({
    required this.id,
    required this.title,
    required this.rating,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.genres,
    required this.runtime,
    required this.popularity,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    List<String> movieGenres = [];

    if (json['genres'] is List) {
      movieGenres = (json['genres'] as List)
          .map((genre) => genre['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
    }

    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Title',
      rating: (json['vote_average'] ?? 0).toDouble(),
      overview: json['overview'] ?? 'No overview available.',
      posterPath: json['poster_path'] ?? '',
      releaseDate: json['release_date'] ?? 'Unknown',
      genres: movieGenres,
      runtime: json['runtime'] ?? 0,
      popularity: (json['popularity'] ?? 0).toDouble(),
    );
  }

  String get posterUrl {
    if (posterPath.isEmpty) {
      return '';
    }

    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String get formattedRuntime {
    if (runtime <= 0) {
      return 'Unknown';
    }

    final hours = runtime ~/ 60;
    final minutes = runtime % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }

    return '${minutes}m';
  }
}
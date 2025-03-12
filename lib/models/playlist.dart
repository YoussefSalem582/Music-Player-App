import 'song.dart';

enum PlaylistCategory {
  all,
  favorites,
  recent,
  custom,
  downloaded,
  mostPlayed,
  // Genre-based categories
  pop,
  rock,
  jazz,
  classical,
  electronic,
  hiphop,
  rnb,
  country,
  latino,
  // Mood-based categories
  party,
  workout,
  relaxation,
  focus,
  meditation,
  // Time-based categories
  topCharts,
  newReleases,
  discover,
  trending
}

class Playlist {
  final String name;
  final List<Song> songs;
  final PlaylistCategory category;
  final String? description;
  final String? coverUrl;
  final DateTime? createdAt;
  final DateTime? lastModified;

  Playlist({
    required this.name,
    required this.songs,
    this.category = PlaylistCategory.custom,
    this.description,
    this.coverUrl,
    this.createdAt,
    this.lastModified,
  });

  int get songCount => songs.length;

  Duration getTotalDuration() {
    return songs.fold(
      Duration.zero,
      (total, song) => total + (song.duration ?? Duration.zero),
    );
  }

  bool get isEmpty => songs.isEmpty;
  bool get isNotEmpty => songs.isNotEmpty;

  List<Song> get shuffledSongs => List.from(songs)..shuffle();
}
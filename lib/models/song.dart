enum MusicGenre {
  pop,
  rock,
  jazz,
  classical,
  electronic,
  hiphop,
  rnb,
  country,
  latino,
  indie,
  metal,
  blues,
  folk,
  reggae,
  soul,
  funk
}

enum MusicMood {
  happy,
  sad,
  energetic,
  relaxed,
  romantic,
  angry,
  peaceful,
  dreamy
}

class Song {
  final String title;
  final String artist;
  final String url;
  final String coverUrl;
  final Duration? duration;
  final MusicGenre? genre;
  final bool isDownloaded;
  final String? albumName;
  final int? releaseYear;
  final List<MusicMood>? moods;
  final double? bpm;
  final String? language;
  final bool isFavorite;
  final int playCount;
  final DateTime? lastPlayed;
  final String? lyrics;

  Song({
    required this.title,
    required this.artist,
    required this.url,
    required this.coverUrl,
    this.duration,
    this.genre,
    this.isDownloaded = false,
    this.albumName,
    this.releaseYear,
    this.moods,
    this.bpm,
    this.language,
    this.isFavorite = false,
    this.playCount = 0,
    this.lastPlayed,
    this.lyrics,
  });

  Song copyWith({
    String? title,
    String? artist,
    String? url,
    String? coverUrl,
    Duration? duration,
    MusicGenre? genre,
    bool? isDownloaded,
    String? albumName,
    int? releaseYear,
    List<MusicMood>? moods,
    double? bpm,
    String? language,
    bool? isFavorite,
    int? playCount,
    DateTime? lastPlayed,
    String? lyrics,
  }) {
    return Song(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      url: url ?? this.url,
      coverUrl: coverUrl ?? this.coverUrl,
      duration: duration ?? this.duration,
      genre: genre ?? this.genre,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      albumName: albumName ?? this.albumName,
      releaseYear: releaseYear ?? this.releaseYear,
      moods: moods ?? this.moods,
      bpm: bpm ?? this.bpm,
      language: language ?? this.language,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      lyrics: lyrics ?? this.lyrics,
    );
  }
}
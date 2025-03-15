import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song.dart';

class MusicApiService {
  static const String _baseUrl =
      'https://storage.googleapis.com/uamp/catalog.json';

  Future<List<Song>> fetchSongs({int limit = 200}) async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['music'] != null) {
          final songs =
              (data['music'] as List)
                  .take(limit)
                  .map(
                    (track) => Song(
                      title: track['title'] ?? 'Unknown',
                      artist: track['artist'] ?? 'Unknown Artist',
                      url: track['source'] ?? '',
                      coverUrl:
                          track['image'] ??
                          'https://picsum.photos/300/300?random=${track['id']}',
                      genre: _mapGenre(track['genre']),
                    ),
                  )
                  .toList();

          if (songs.isNotEmpty) return songs;
        }
      }
    } catch (e) {
      print('Error fetching songs: $e');
    }

    return _fallbackSongs;
  }

  MusicGenre? _mapGenre(String? genre) {
    switch (genre?.toLowerCase()) {
      case 'pop':
        return MusicGenre.pop;
      case 'rock':
        return MusicGenre.rock;
      case 'jazz':
        return MusicGenre.jazz;
      case 'classical':
        return MusicGenre.classical;
      case 'electronic':
        return MusicGenre.electronic;
      case 'hiphop':
        return MusicGenre.hiphop;
      case 'rnb':
        return MusicGenre.rnb;
      case 'country':
        return MusicGenre.country;
      case 'latino':
        return MusicGenre.latino;
      case 'indie':
        return MusicGenre.indie;
      case 'metal':
        return MusicGenre.metal;
      case 'blues':
        return MusicGenre.blues;
      case 'folk':
        return MusicGenre.folk;
      case 'reggae':
        return MusicGenre.reggae;
      case 'soul':
        return MusicGenre.soul;
      case 'funk':
        return MusicGenre.funk;
      default:
        return null;
    }
  }

  List<Song> get _fallbackSongs => [
    Song(
      title: 'Lost in the City',
      artist: 'Urban Beats',
      url: 'https://storage.googleapis.com/music-samples/lost-in-city.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500',
      genre: MusicGenre.electronic,
      moods: [MusicMood.energetic, MusicMood.dreamy],
      bpm: 128,
    ),
    Song(
      title: 'Midnight Jazz',
      artist: 'The Jazz Quartet',
      url: 'https://storage.googleapis.com/music-samples/midnight-jazz.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1511192336575-5a79af67a629?w=500',
      genre: MusicGenre.jazz,
      moods: [MusicMood.relaxed, MusicMood.peaceful],
      bpm: 90,
    ),
    Song(
      title: 'Rock Revolution',
      artist: 'Thunder Strike',
      url: 'https://storage.googleapis.com/music-samples/rock-revolution.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?w=500',
      genre: MusicGenre.rock,
      moods: [MusicMood.energetic, MusicMood.angry],
      bpm: 140,
    ),
    Song(
      title: 'Classical Dreams',
      artist: 'Symphony Orchestra',
      url: 'https://storage.googleapis.com/music-samples/classical-dreams.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1507838153414-b4b713384a76?w=500',
      genre: MusicGenre.classical,
      moods: [MusicMood.peaceful, MusicMood.romantic],
      bpm: 75,
    ),
    Song(
      title: 'Hip Hop Streets',
      artist: 'Urban Flow',
      url: 'https://storage.googleapis.com/music-samples/hiphop-streets.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=500',
      genre: MusicGenre.hiphop,
      moods: [MusicMood.energetic],
      bpm: 95,
    ),
    Song(
      title: 'Country Roads',
      artist: 'Southern Stars',
      url: 'https://storage.googleapis.com/music-samples/country-roads.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1506157786151-b8491531f063?w=500',
      genre: MusicGenre.country,
      moods: [MusicMood.happy, MusicMood.peaceful],
      bpm: 110,
    ),
    Song(
      title: 'Pop Paradise',
      artist: 'The Melody Makers',
      url: 'https://storage.googleapis.com/music-samples/pop-paradise.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=500',
      genre: MusicGenre.pop,
      moods: [MusicMood.happy, MusicMood.energetic],
      bpm: 120,
    ),
    Song(
      title: 'Blues Night',
      artist: 'Soul Brothers',
      url: 'https://storage.googleapis.com/music-samples/blues-night.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1415201364774-f6f0bb35f28f?w=500',
      genre: MusicGenre.blues,
      moods: [MusicMood.sad, MusicMood.relaxed],
      bpm: 85,
    ),
    Song(
      title: 'Reggae Vibes',
      artist: 'Island Crew',
      url: 'https://storage.googleapis.com/music-samples/reggae-vibes.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=500',
      genre: MusicGenre.reggae,
      moods: [MusicMood.happy, MusicMood.peaceful],
      bpm: 90,
    ),
    Song(
      title: 'Metal Storm',
      artist: 'Dark Knights',
      url: 'https://storage.googleapis.com/music-samples/metal-storm.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1519892300165-cb5542fb47c7?w=500',
      genre: MusicGenre.metal,
      moods: [MusicMood.energetic, MusicMood.angry],
      bpm: 160,
    ),
    Song(
      title: 'Indie Waves',
      artist: 'The Indie Band',
      url: 'https://storage.googleapis.com/music-samples/indie-waves.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=500',
      genre: MusicGenre.indie,
      moods: [MusicMood.dreamy, MusicMood.peaceful],
      bpm: 100,
    ),
    Song(
      title: 'Soulful Evening',
      artist: 'Soul Singers',
      url: 'https://storage.googleapis.com/music-samples/soulful-evening.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=500',
      genre: MusicGenre.soul,
      moods: [MusicMood.relaxed, MusicMood.romantic],
      bpm: 80,
    ),
    Song(
      title: 'Folk Tales',
      artist: 'Folk Band',
      url: 'https://storage.googleapis.com/music-samples/folk-tales.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=500',
      genre: MusicGenre.folk,
      moods: [MusicMood.happy, MusicMood.peaceful],
      bpm: 95,
    ),
    Song(
      title: 'Funky Beats',
      artist: 'Funk Masters',
      url: 'https://storage.googleapis.com/music-samples/funky-beats.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=500',
      genre: MusicGenre.funk,
      moods: [MusicMood.energetic, MusicMood.happy],
      bpm: 115,
    ),
    // Additional songs
    Song(
      title: 'Chill Vibes',
      artist: 'Chillout Lounge',
      url: 'https://storage.googleapis.com/music-samples/chill-vibes.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=500',
      genre: MusicGenre.electronic,
      moods: [MusicMood.relaxed, MusicMood.dreamy],
      bpm: 90,
    ),
    Song(
      title: 'Dance Party',
      artist: 'DJ Mix',
      url: 'https://storage.googleapis.com/music-samples/dance-party.mp3',
      coverUrl:
          'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=500',
      genre: MusicGenre.electronic,
      moods: [MusicMood.energetic, MusicMood.happy],
      bpm: 130,
    ),
  ];
}
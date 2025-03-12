import 'dart:convert';
                    import 'package:http/http.dart' as http;
                    import '../models/song.dart';

                    class MusicApiService {
                      static const String _baseUrl = 'https://storage.googleapis.com/uamp/catalog.json';

                      Future<List<Song>> fetchSongs({int limit = 10}) async {
                        try {
                          final response = await http.get(Uri.parse(_baseUrl));

                          if (response.statusCode == 200) {
                            final data = json.decode(response.body);
                            if (data['music'] != null) {
                              final songs = (data['music'] as List).take(limit).map((track) => Song(
                                title: track['title'] ?? 'Unknown',
                                artist: track['artist'] ?? 'Unknown Artist',
                                url: track['source'] ?? '',
                                coverUrl: track['image'] ?? 'https://picsum.photos/300/300?random=${track['id']}',
                              )).toList();

                              if (songs.isNotEmpty) return songs;
                            }
                          }
                        } catch (e) {
                          print('Error fetching songs: $e');
                        }

                        return _fallbackSongs;
                      }

                      List<Song> get _fallbackSongs => [
                        Song(
                          title: 'Lost in the City',
                          artist: 'Urban Beats',
                          url: 'https://storage.googleapis.com/music-samples/lost-in-city.mp3',
                          coverUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500',
                        ),
                        Song(
                          title: 'Neon Dreams',
                          artist: 'Synthwave Collective',
                          url: 'https://storage.googleapis.com/music-samples/neon-dreams.mp3',
                          coverUrl: 'https://images.unsplash.com/photo-1614149162883-504ce4d13909?w=500',
                        ),
                        Song(
                          title: 'Midnight Rain',
                          artist: 'Ambient Waves',
                          url: 'https://storage.googleapis.com/music-samples/midnight-rain.mp3',
                          coverUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500',
                        ),
                        Song(
                          title: 'Desert Wind',
                          artist: 'Nature Sounds',
                          url: 'https://storage.googleapis.com/music-samples/desert-wind.mp3',
                          coverUrl: 'https://images.unsplash.com/photo-1682687220742-aba13b6e50ba?w=500',
                        ),
                        Song(
                          title: 'Ocean Waves',
                          artist: 'Relaxation Music',
                          url: 'https://storage.googleapis.com/music-samples/ocean-waves.mp3',
                          coverUrl: 'https://images.unsplash.com/photo-1682687220063-4742bd7c8889?w=500',
                        ),
                        Song(
                          title: 'Mountain Air',
                          artist: 'Meditation Masters',
                          url: 'https://storage.googleapis.com/music-samples/mountain-air.mp3',
                          coverUrl: 'https://images.unsplash.com/photo-1682687219640-b3f11f4b7234?w=500',
                        ),
                        Song(
                          title: 'Forest Dreams',
                          artist: 'Nature Sounds',
                          url: 'https://storage.googleapis.com/music-samples/forest-dreams.mp3',
                          coverUrl: 'https://images.unsplash.com/photo-1682687220199-d0124f48f95b?w=500',
                        ),
                        Song(
                          title: 'Calm Waters',
                          artist: 'Ocean Sounds',
                          url: 'https://storage.googleapis.com/music-samples/calm-waters.mp3',
                          coverUrl: 'https://images.unsplash.com/photo-1682695796954-bad0d0f59ff1?w=500',
                        ),
                      ];
                    }
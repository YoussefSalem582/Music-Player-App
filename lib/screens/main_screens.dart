import 'package:flutter/material.dart';
                   import '../models/song.dart';
                   import '../services/audio_player_service.dart';
                   import '../services/music_api_service.dart';
                   import 'music_player_screen.dart';
                   import 'playlist_screen.dart';
                   import '../models/playlist.dart';

                   class MainScreen extends StatefulWidget {
                     @override
                     _MainScreenState createState() => _MainScreenState();
                   }

                   class _MainScreenState extends State<MainScreen> {
                     int _selectedIndex = 0;
                     final AudioPlayerService _audioPlayerService = AudioPlayerService();
                     final MusicApiService _musicApiService = MusicApiService();
                     bool isPlaying = false;
                     bool isLoading = true;
                     String? errorMessage;
                     List<Playlist> playlists = [];

                     @override
                     void initState() {
                       super.initState();
                       _loadSongs();
                     }

                     Future<void> _loadSongs() async {
                       try {
                         final songs = await _musicApiService.fetchSongs();
                         if (songs.isEmpty) {
                           throw Exception('No songs available');
                         }

                         if (mounted) {
                           setState(() {
                             playlists = [
                               Playlist(
                                 name: 'Trending Songs',
                                 songs: songs,
                               ),
                             ];
                             isLoading = false;
                             errorMessage = null;
                           });
                           await _initializePlayer();
                         }
                       } catch (e) {
                         if (mounted) {
                           setState(() {
                             isLoading = false;
                             errorMessage = 'Failed to load songs: ${e.toString()}';
                           });
                         }
                       }
                     }

                     Future<void> _initializePlayer() async {
                       if (playlists.isNotEmpty && playlists[0].songs.isNotEmpty) {
                         await _audioPlayerService.setPlaylist(playlists[0].songs);
                         _listenToPlayerState();
                       }
                     }

                     void _listenToPlayerState() {
                       _audioPlayerService.playerStateStream.listen((state) {
                         if (mounted) {
                           setState(() => isPlaying = state.playing);
                         }
                       });
                     }

                     Future<void> _handleSongTap(Song song) async {
                       if (playlists.isEmpty || playlists[0].songs.isEmpty) {
                         return;
                       }

                       final songIndex = playlists[0].songs.indexWhere((s) => s.url == song.url);
                       if (songIndex != -1) {
                         await _audioPlayerService.setPlaylist(playlists[0].songs, initialIndex: songIndex);
                         await _audioPlayerService.play();
                         setState(() => _selectedIndex = 2);
                       }
                     }

                     Widget _buildHomeScreen() {
                       if (errorMessage != null) {
                         return Center(
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Text(errorMessage!),
                               const SizedBox(height: 16),
                               ElevatedButton(
                                 onPressed: () {
                                   setState(() {
                                     isLoading = true;
                                     errorMessage = null;
                                   });
                                   _loadSongs();
                                 },
                                 child: const Text('Retry'),
                               ),
                             ],
                           ),
                         );
                       }

                       if (playlists.isEmpty || playlists[0].songs.isEmpty) {
                         return const Center(
                           child: Text('No songs available'),
                         );
                       }

                       return CustomScrollView(
                         slivers: [
                           const SliverAppBar(
                             floating: true,
                             title: Text('Music Player'),
                           ),
                           SliverPadding(
                             padding: const EdgeInsets.all(16),
                             sliver: SliverGrid(
                               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                 crossAxisCount: 2,
                                 mainAxisSpacing: 16,
                                 crossAxisSpacing: 16,
                                 childAspectRatio: 0.8,
                               ),
                               delegate: SliverChildBuilderDelegate(
                                 (context, index) {
                                   final song = playlists[0].songs[index];
                                   return InkWell(
                                     onTap: () => _handleSongTap(song),
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         Expanded(
                                           child: ClipRRect(
                                             borderRadius: BorderRadius.circular(8),
                                             child: Image.network(
                                               song.coverUrl,
                                               fit: BoxFit.cover,
                                               width: double.infinity,
                                               errorBuilder: (context, error, stackTrace) {
                                                 return Container(
                                                   color: Colors.grey[300],
                                                   child: const Icon(Icons.music_note),
                                                 );
                                               },
                                             ),
                                           ),
                                         ),
                                         const SizedBox(height: 8),
                                         Text(
                                           song.title,
                                           style: Theme.of(context).textTheme.titleMedium,
                                           maxLines: 1,
                                           overflow: TextOverflow.ellipsis,
                                         ),
                                         Text(
                                           song.artist,
                                           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                             color: Colors.grey[600],
                                           ),
                                           maxLines: 1,
                                           overflow: TextOverflow.ellipsis,
                                         ),
                                       ],
                                     ),
                                   );
                                 },
                                 childCount: playlists[0].songs.length,
                               ),
                             ),
                           ),
                         ],
                       );
                     }

                     @override
                     Widget build(BuildContext context) {
                       if (isLoading) {
                         return const Scaffold(
                           body: Center(
                             child: CircularProgressIndicator(),
                           ),
                         );
                       }

                       return Scaffold(
                         body: IndexedStack(
                           index: _selectedIndex,
                           children: [
                             _buildHomeScreen(),
                             if (playlists.isNotEmpty)
                               PlaylistScreen(
                                 playlist: playlists[0],
                                 onSongTap: _handleSongTap,
                                 currentSong: _audioPlayerService.currentSong,
                                 isPlaying: isPlaying,
                                 onPlayPause: () async {
                                   if (isPlaying) {
                                     await _audioPlayerService.pause();
                                   } else {
                                     await _audioPlayerService.play();
                                   }
                                 },
                               )
                             else
                               const Center(child: Text('No playlist available')),
                             MusicPlayerScreen(),
                           ],
                         ),
                         bottomNavigationBar: NavigationBar(
                           selectedIndex: _selectedIndex,
                           onDestinationSelected: (index) {
                             setState(() => _selectedIndex = index);
                           },
                           destinations: const [
                             NavigationDestination(
                               icon: Icon(Icons.home),
                               label: 'Home',
                             ),
                             NavigationDestination(
                               icon: Icon(Icons.playlist_play),
                               label: 'Playlist',
                             ),
                             NavigationDestination(
                               icon: Icon(Icons.play_circle),
                               label: 'Player',
                             ),
                           ],
                         ),
                       );
                     }

                     @override
                     void dispose() {
                       _audioPlayerService.dispose();
                       super.dispose();
                     }
                   }
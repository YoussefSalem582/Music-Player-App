import 'package:flutter/material.dart';
    import '../models/song.dart';
    import '../services/audio_player_service.dart';
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
      bool isPlaying = false;

      final List<Playlist> playlists = [
        Playlist(
          name: 'My Playlist',
          songs: [
            Song(
              title: 'Song 1',
              artist: 'Artist 1',
              url: 'https://example.com/song1.mp3',
              coverUrl: 'https://example.com/cover1.jpg',
            ),
            // Add more songs
          ],
        ),
      ];

      @override
      void initState() {
        super.initState();
        _initializePlayer();
        _listenToPlayerState();
      }

      Future<void> _initializePlayer() async {
        await _audioPlayerService.setPlaylist(playlists[0].songs);
      }

      void _listenToPlayerState() {
        _audioPlayerService.playerStateStream.listen((state) {
          setState(() => isPlaying = state.playing);
        });
      }

      void _handleSongTap(Song song) async {
        final songIndex = playlists[0].songs.indexWhere((s) => s.url == song.url);
        if (songIndex != -1) {
          await _audioPlayerService.setPlaylist(playlists[0].songs, initialIndex: songIndex);
          await _audioPlayerService.play();
          setState(() => _selectedIndex = 0);
        }
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              MusicPlayerScreen(),
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
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.play_circle),
                label: 'Player',
              ),
              NavigationDestination(
                icon: Icon(Icons.playlist_play),
                label: 'Playlist',
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
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../services/audio_player_service.dart';
import '../services/music_api_service.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/mini_player.dart';
import 'music_player_screen.dart';
import 'playlist_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AudioPlayerService _audioPlayerService = AudioPlayerService();
  final MusicApiService _musicApiService = MusicApiService();
  int _selectedIndex = 0;
  bool isPlaying = false;
  List<Playlist> playlists = [];
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadSongs();
    _listenToPlayerState();
  }

  void _listenToPlayerState() {
    _audioPlayerService.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
      });
    });
  }

  Future<void> _loadSongs() async {
    try {
      final songs = await _musicApiService.fetchSongs();
      setState(() {
        playlists = [
          Playlist(name: 'All Songs', songs: songs),
        ];
      });
    } catch (e) {
      print('Error loading songs: $e');
    }
  }

  Future<void> _handleSongTap(Song song) async {
    final currentPlaylist = playlists[0];
    final songIndex = currentPlaylist.songs.indexOf(song);
    await _audioPlayerService.setPlaylist(
        currentPlaylist.songs, initialIndex: songIndex);
    await _audioPlayerService.play();
  }

  Widget _buildHomeScreen() {
    if (playlists.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final songs = playlists[0].songs;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return GestureDetector(
          onTap: () => _handleSongTap(song),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12)),
                    child: Image.network(
                      song.coverUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: Theme
                            .of(context)
                            .textTheme
                            .titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        song.artist,
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(title: 'Music Player'),
        body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
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
      audioPlayerService: _audioPlayerService, // Add this line
    )

    else
    const Center(child: Text('No playlist available')),
    // Pass the necessary data to MusicPlayerScreen
    MusicPlayerScreen(
    audioPlayerService: _audioPlayerService,
    onPlayPause: () async {
    if (isPlaying) {
    await _audioPlayerService.pause();
    } else {
    await _audioPlayerService.play();
    }
    },
    currentSong: _audioPlayerService.currentSong,
    isPlaying: isPlaying,
    ),
    ],
    ),
    bottomNavigationBar: BottomNavigationBar(
    currentIndex: _selectedIndex,
    onTap: _onItemTapped,
    items: const [
    BottomNavigationBarItem(
    icon: Icon(Icons.home),
    label: 'Home',
    ),
    BottomNavigationBarItem(
    icon: Icon(Icons.playlist_play),
    label: 'Playlist',
    ),
    BottomNavigationBarItem(
    icon: Icon(Icons.play_circle),
    label: 'Player',
    ),
    ],
    ),
    // Add mini player at the bottom if a song is playing
    bottomSheet: _audioPlayerService.currentSong != null
    ? MiniPlayer(
    currentSong: _audioPlayerService.currentSong,
    isPlaying: isPlaying,
    onPlayPause: () async {
    if (isPlaying) {
    await _audioPlayerService.pause();
    } else {
    await _audioPlayerService.play();
    }
    },
    onTap: () => _pageController.jumpToPage(2), // Jump to player screen
    )
        : null,
    );
    }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayerService.dispose();
    super.dispose();
  }
}
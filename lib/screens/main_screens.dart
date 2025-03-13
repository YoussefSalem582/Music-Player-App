import 'package:flutter/material.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../services/audio_player_service.dart';
import '../services/music_api_service.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/gradient_bottom_navigation_bar.dart';
import '../widgets/mini_player.dart';
import 'music_player_screen.dart';
import 'playlist_screen.dart';

// Custom theme data
final ThemeData customTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Colors.purple.shade400,
    secondary: Colors.tealAccent,
    surface: Colors.grey.shade900,
    background: Colors.black,
  ),
  cardTheme: CardTheme(
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16),
  ),
);

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayerService _audioPlayerService = AudioPlayerService();
  final MusicApiService _musicApiService = MusicApiService();
  late AnimationController _animationController;
  int _selectedIndex = 0;
  bool isPlaying = false;
  List<Playlist> playlists = [];
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _loadSongs();
    _listenToPlayerState();
  }

  void _listenToPlayerState() {
    _audioPlayerService.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
        if (isPlaying) {
          _animationController.repeat();
        } else {
          _animationController.stop();
        }
      });
    });
  }

  Future<void> _loadSongs() async {
    try {
      final songs = await _musicApiService.fetchSongs();
      final genrePlaylists = _createGenrePlaylists(songs);
      setState(() {
        playlists = [
          Playlist(name: 'All Songs', songs: songs),
          ...genrePlaylists,
        ];
      });
    } catch (e) {
      print('Error loading songs: $e');
    }
  }

  List<Playlist> _createGenrePlaylists(List<Song> songs) {
    final Map<MusicGenre, List<Song>> genreSongs = {};

    for (var song in songs) {
      if (song.genre != null) {
        genreSongs.putIfAbsent(song.genre!, () => []).add(song);
      }
    }

    return genreSongs.entries
        .map(
          (entry) => Playlist(
            name: entry.key.toString().split('.').last,
            songs: entry.value,
            category: PlaylistCategory.values.firstWhere(
              (cat) =>
                  cat.toString().split('.').last ==
                  entry.key.toString().split('.').last,
              orElse: () => PlaylistCategory.custom,
            ),
          ),
        )
        .toList();
  }

  Future<void> _handleSongTap(Song song) async {
    final currentPlaylist = playlists[0];
    final songIndex = currentPlaylist.songs.indexOf(song);
    await _audioPlayerService.setPlaylist(
      currentPlaylist.songs,
      initialIndex: songIndex,
    );
    await _audioPlayerService.play();
  }

  Widget _buildHomeScreen() {
    if (playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading your music...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildFeaturedSection(),
        _buildRecentlyPlayedSection(),
        _buildGenresSection(),
        _buildAllSongsSection(),
      ],
    );
  }

  Widget _buildFeaturedSection() {
    return SliverToBoxAdapter(
      child: Container(
        height: 300,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(playlists[0].songs[0].coverUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Featured',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                playlists[0].songs[0].title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _handleSongTap(playlists[0].songs[0]),
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text(
                  'Play Now',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade400,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentlyPlayedSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 8),
            child: Text(
              'Recently Played',
              style: Theme.of(context).primaryTextTheme.headlineMedium,
            ),
          ),
          SizedBox(
            height: 220,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: playlists[0].songs.take(5).length,
              itemBuilder:
                  (context, index) =>
                      _buildRecentSongCard(playlists[0].songs[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenresSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 0),
            child: Text(
              'Genres',
              style: Theme.of(context).primaryTextTheme.headlineMedium,
            ),
          ),
          SizedBox(
            height: 0,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: playlists.length - 1,
              // Exclude 'All Songs' playlist
              itemBuilder:
                  (context, index) => _buildGenreCard(playlists[index + 1]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllSongsSection() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildSongCard(playlists[0].songs[index]),
          childCount: playlists[0].songs.length,
        ),
      ),
    );
  }

Widget _buildGenreCard(Playlist playlist) {
  return GestureDetector(
    onTap: () {
      // Navigate to genre-specific playlist
    },
    child: Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.7),
                    Theme.of(context).primaryColor.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Content
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    playlist.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${playlist.songCount} songs',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
  Widget _buildRecentSongCard(Song song) {
    return GestureDetector(
      onTap: () => _handleSongTap(song),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Image.network(
                song.coverUrl,
                width: 140,
                height: 140,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Colors.purple.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Text(
                  song.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSongCard(Song song) {
    final isCurrentSong = _audioPlayerService.currentSong?.url == song.url;

    return GestureDetector(
      onTap: () => _handleSongTap(song),
      child: Card(
        elevation: isCurrentSong ? 8 : 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient:
                isCurrentSong
                    ? LinearGradient(
                      colors: [
                        Colors.purple.shade400.withOpacity(0.2),
                        Colors.transparent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    song.coverUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      song.artist,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
@override
Widget build(BuildContext context) {
  return Theme(
    data: customTheme,
    child: Scaffold(
      appBar: CustomAppBar(title: 'MusicHub'),
      body: Stack(
        children: [
          PageView(
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
                  onPlayPause: _handlePlayPause,
                  audioPlayerService: _audioPlayerService,
                )
              else
                const Center(child: Text('No playlist available')),
              MusicPlayerScreen(
                audioPlayerService: _audioPlayerService,
                onPlayPause: _handlePlayPause,
                currentSong: _audioPlayerService.currentSong,
                isPlaying: isPlaying,
              ),
            ],
          ),
          if (_audioPlayerService.currentSong != null && _selectedIndex != 2)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayer(
                currentSong: _audioPlayerService.currentSong,
                isPlaying: isPlaying,
                onPlayPause: _handlePlayPause,
                onTap: () => _pageController.jumpToPage(2),
              ),
            ),
        ],
      ),
      bottomNavigationBar: GradientBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
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
    ),
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
    _animationController.dispose();
    _pageController.dispose();
    _audioPlayerService.dispose();
    super.dispose();
  }

  Future<void> _handlePlayPause() async {
    if (isPlaying) {
      await _audioPlayerService.pause();
    } else {
      await _audioPlayerService.play();
    }
  }
}

import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/audio_player_service.dart';

class LikedSongsScreen extends StatefulWidget {
  final AudioPlayerService audioPlayerService;

  const LikedSongsScreen({
    Key? key,
    required this.audioPlayerService,
  }) : super(key: key);

  @override
  State<LikedSongsScreen> createState() => _LikedSongsScreenState();
}

class _LikedSongsScreenState extends State<LikedSongsScreen> {
  late ScrollController _scrollController;
  double _headerOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _headerOpacity = (1 - (_scrollController.offset / 200)).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final likedSongs = widget.audioPlayerService.likedSongs;
    final totalDuration = likedSongs.fold(
      Duration.zero,
      (total, song) => total + (song.duration ?? Duration.zero),
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.purple.shade900,
            Colors.black,
          ],
        ),
      ),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(likedSongs.length, totalDuration),
          _buildPlaylistControls(likedSongs),
          _buildSongsList(likedSongs),
        ],
      ),
    );
  }

  Widget _buildHeader(int songCount, Duration totalDuration) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Opacity(
              opacity: _headerOpacity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.purple.shade700,
                      Colors.purple.shade900.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.favorite,
                    size: 120,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Liked Songs',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$songCount songs • ${_formatDuration(totalDuration)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistControls(List<Song> songs) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.purple.shade700],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () => _playAllSongs(songs),
              ),
            ),
            const SizedBox(width: 20),
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.shuffle,
                  color: Colors.white.withOpacity(0.7),
                  size: 24,
                ),
                onPressed: () => _shuffleAndPlay(songs),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongsList(List<Song> songs) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final song = songs[index];
          final isCurrentSong =
              widget.audioPlayerService.currentSong?.url == song.url;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: Hero(
              tag: song.url,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    song.coverUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            title: Text(
              song.title,
              style: TextStyle(
                color: isCurrentSong ? Colors.purple[400] : Colors.white,
                fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              song.artist,
              style: TextStyle(
                color: isCurrentSong
                    ? Colors.purple[400]?.withOpacity(0.7)
                    : Colors.white.withOpacity(0.7),
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.favorite,
                color: Colors.purple[400],
              ),
              onPressed: () => _unlikeSong(song),
            ),
            onTap: () => _playSong(song),
          );
        },
        childCount: songs.length,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes;

    if (hours > 0) {
      return '$hours hr ${minutes % 60} min';
    } else {
      return '${minutes % 60} min';
    }
  }

  void _playAllSongs(List<Song> songs) async {
    if (songs.isNotEmpty) {
      await widget.audioPlayerService.setPlaylist(songs);
      await widget.audioPlayerService.play();
    }
  }

  void _shuffleAndPlay(List<Song> songs) async {
    if (songs.isNotEmpty) {
      final shuffledSongs = List<Song>.from(songs)..shuffle();
      await widget.audioPlayerService.setPlaylist(shuffledSongs);
      await widget.audioPlayerService.play();
    }
  }

  void _playSong(Song song) async {
    final songs = widget.audioPlayerService.likedSongs;
    final index = songs.indexWhere((s) => s.url == song.url);
    if (index != -1) {
      await widget.audioPlayerService.setPlaylist(songs, initialIndex: index);
      await widget.audioPlayerService.play();
    }
  }

  void _unlikeSong(Song song) {
    widget.audioPlayerService.toggleFavorite(song);
    setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
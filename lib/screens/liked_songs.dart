import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/audio_player_service.dart';

class LikedSongsScreen extends StatefulWidget {
  final AudioPlayerService audioPlayerService;

  const LikedSongsScreen({
    super.key,
    required this.audioPlayerService,
  });

  @override
  State<LikedSongsScreen> createState() => _LikedSongsScreenState();
}

class _LikedSongsScreenState extends State<LikedSongsScreen> {
  bool isPlaying = false;
  List<Song> likedSongs = [];

  @override
  void initState() {
    super.initState();
    _loadLikedSongs();
    _listenToPlayerState();
  }

  void _loadLikedSongs() {
    setState(() {
      likedSongs = widget.audioPlayerService.likedSongs;
    });
  }

  void _listenToPlayerState() {
    widget.audioPlayerService.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state.playing;
        });
      }
    });
  }

  Future<void> _handleSongTap(Song song) async {
    final songIndex = likedSongs.indexOf(song);
    await widget.audioPlayerService.setPlaylist(likedSongs, initialIndex: songIndex);
    await widget.audioPlayerService.play();
  }

  Future<void> _handlePlayPause() async {
    if (isPlaying) {
      await widget.audioPlayerService.pause();
    } else {
      await widget.audioPlayerService.play();
    }
  }

  Future<void> _removeSongFromLiked(Song song) async {
    await widget.audioPlayerService.toggleFavorite(song);
    _loadLikedSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.purple.shade800,
          ],
        ),
      ),
      child: likedSongs.isEmpty ? _buildEmptyState() : _buildLikedSongsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 72,
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No liked songs yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Like songs to see them appear here',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikedSongsList() {
    final currentSong = widget.audioPlayerService.currentSong;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: likedSongs.length,
      itemBuilder: (context, index) {
        final song = likedSongs[index];
        final isCurrentSong = currentSong?.url == song.url;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
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
              Icons.more_vert,
              color: Colors.white.withOpacity(0.7),
            ),
            onPressed: () => _showSongOptions(context, song),
          ),
          onTap: () => _handleSongTap(song),
        );
      },
    );
  }

  void _showSongOptions(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.playlist_add, color: Colors.white),
            title: const Text(
              'Add to playlist',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.white),
            title: const Text(
              'Remove from liked songs',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              _removeSongFromLiked(song);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share, color: Colors.white),
            title: const Text(
              'Share',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
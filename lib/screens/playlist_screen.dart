import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../services/audio_player_service.dart';

class PlaylistScreen extends StatelessWidget {
  final Playlist playlist;
  final Function(Song) onSongTap;
  final Song? currentSong;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final AudioPlayerService audioPlayerService;

  const PlaylistScreen({
    required this.playlist,
    required this.onSongTap,
    required this.currentSong,
    required this.isPlaying,
    required this.onPlayPause,
    required this.audioPlayerService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPlaylistHeader(context),
        Expanded(child: _buildSongsList(context)),
      ],
    );
  }

  Widget _buildPlaylistHeader(BuildContext context) {
    return Container(
      height: 200,
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              playlist.name,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${playlist.songCount} songs',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                ),
                const SizedBox(width: 16),
                Text(
                  _formatDuration(playlist.getTotalDuration()),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildPlayButton(context),
                const SizedBox(width: 16),
                _buildShuffleButton(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => onSongTap(playlist.songs.first),
      icon: const Icon(Icons.play_arrow, color: Colors.white),
      label: const Text(
        'Play All',
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple.shade400,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }

  Widget _buildShuffleButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        final shuffledSongs = playlist.shuffledSongs;
        onSongTap(shuffledSongs.first);
      },
      icon: const Icon(Icons.shuffle, color: Colors.white),
      label: const Text(
        'Shuffle',
        style: TextStyle(color: Colors.white),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }

  Widget _buildSongsList(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: playlist.songs.length,
      itemBuilder: (context, index) {
        final song = playlist.songs[index];
        final isCurrentSong = currentSong?.url == song.url;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Image.network(
                  song.coverUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
                if (isCurrentSong)
                  Container(
                    width: 56,
                    height: 56,
                    color: Colors.black.withOpacity(0.5),
                    child: Icon(
                      isPlaying ? Icons.equalizer : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
          title: Text(
            song.title,
            style: TextStyle(
              color: isCurrentSong ? Colors.purple.shade400 : Colors.white,
              fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            song.artist,
            style: TextStyle(
              color: isCurrentSong
                  ? Colors.purple.shade400.withOpacity(0.7)
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
          onTap: () => onSongTap(song),
        );
      },
    );
  }

  void _showSongOptions(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
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
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement add to playlist
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border, color: Colors.white),
            title: const Text(
              'Add to favorites',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement add to favorites
            },
          ),
          ListTile(
            leading: const Icon(Icons.share, color: Colors.white),
            title: const Text(
              'Share',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement share
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final hours = duration.inHours;

    if (hours > 0) {
      return '$hours hr ${minutes % 60} min';
    } else {
      return '$minutes min';
    }
  }
}
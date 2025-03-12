import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../widgets/mini_player.dart';
import 'music_player_screen.dart';

class PlaylistScreen extends StatelessWidget {
  final Playlist playlist;
  final Function(Song) onSongTap;
  final Song? currentSong;
  final bool isPlaying;
  final VoidCallback onPlayPause;

  const PlaylistScreen({
    required this.playlist,
    required this.onSongTap,
    this.currentSong,
    required this.isPlaying,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(playlist.name)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: playlist.songs.length,
              itemBuilder: (context, index) {
                final song = playlist.songs[index];
                final isCurrentSong = currentSong?.url == song.url;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(song.coverUrl),
                  ),
                  title: Text(
                    song.title,
                    style: isCurrentSong
                        ? TextStyle(color: Theme.of(context).primaryColor)
                        : null,
                  ),
                  subtitle: Text(song.artist),
                  trailing: isCurrentSong && isPlaying
                      ? Icon(
                          Icons.equalizer,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                  onTap: () => onSongTap(song),
                );
              },
            ),
          ),
          if (currentSong != null)
            MiniPlayer(
              currentSong: currentSong,
              isPlaying: isPlaying,
              onPlayPause: onPlayPause,
              onTap: () {
                // Navigate to player screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => MusicPlayerScreen(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
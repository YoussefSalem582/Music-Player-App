import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../services/audio_player_service.dart';

class PlaylistScreen extends StatefulWidget {
  final Playlist playlist;
  final Function(Song) onSongTap;
  final Song? currentSong;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final AudioPlayerService audioPlayerService;

  const PlaylistScreen({
    super.key,
    required this.playlist,
    required this.onSongTap,
    required this.currentSong,
    required this.isPlaying,
    required this.onPlayPause,
    required this.audioPlayerService,
  });

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  late ScrollController _scrollController;
  double _headerOpacity = 1.0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(_onScroll);
    _isPlaying = widget.isPlaying;
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    setState(() {
      _headerOpacity = (1 - (offset / 200)).clamp(0.0, 1.0);
    });
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

  @override
  Widget build(BuildContext context) {
    final totalDuration = widget.playlist.getTotalDuration();

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
          _buildHeader(totalDuration),
          _buildPlaylistControls(),
          _buildSongsList(),
        ],
      ),
    );
  }

  Widget _buildHeader(Duration totalDuration) {
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
                  image: DecorationImage(
                    image: NetworkImage(
                      widget.playlist.coverUrl ??
                          widget.playlist.songs.first.coverUrl,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
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
                  Text(
                    widget.playlist.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.playlist.songs.length} songs • ${_formatDuration(totalDuration)}',
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

  Widget _buildPlaylistControls() {
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
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () {
                  setState(() => _isPlaying = !_isPlaying);
                  widget.onPlayPause();
                },
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
                onPressed: () => widget.audioPlayerService.shuffle(),
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
                icon: const Icon(
                  Icons.repeat,
                  color: Colors.white70,
                  size: 24,
                ),
                onPressed: () => widget.audioPlayerService
                    .setLoopMode(LoopMode.all),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final song = widget.playlist.songs[index];
          final isCurrentSong = widget.currentSong?.url == song.url;

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
                Icons.more_vert,
                color: Colors.white.withOpacity(0.7),
              ),
              onPressed: () => _showSongOptions(context, song),
            ),
            onTap: () => widget.onSongTap(song),
          );
        },
        childCount: widget.playlist.songs.length,
      ),
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
            leading: const Icon(Icons.favorite_border, color: Colors.white),
            title: const Text(
              'Like',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              widget.audioPlayerService.toggleFavorite(song);
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
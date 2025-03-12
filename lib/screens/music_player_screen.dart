import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/audio_player_service.dart';

class MusicPlayerScreen extends StatefulWidget {
  final AudioPlayerService audioPlayerService;
  final VoidCallback onPlayPause;
  final Song? currentSong;
  final bool isPlaying;

  const MusicPlayerScreen({
    required this.audioPlayerService,
    required this.onPlayPause,
    required this.currentSong,
    required this.isPlaying,
  });

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  bool isPlaying = false;
  Duration? duration;
  Duration position = Duration.zero;
  Song? currentSong;
  double _currentVolume = 1.0;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _listenToPlayerChanges();
  }

  Future<void> _initializePlayer() async {
    setState(() {
      currentSong = widget.currentSong;
      isPlaying = widget.isPlaying;
    });
    await widget.audioPlayerService.setVolume(_currentVolume);
  }

  void _listenToPlayerChanges() {
    widget.audioPlayerService.positionStream.listen((p) {
      if (mounted) {
        setState(() => position = p ?? Duration.zero);
      }
    });

    widget.audioPlayerService.durationStream.listen((d) {
      if (mounted) {
        setState(() => duration = d);
      }
    });

    widget.audioPlayerService.playerStateStream.listen((state) {
      if (mounted) {
        setState(() => isPlaying = state.playing);
      }
    });

    widget.audioPlayerService.volumeStream.listen((volume) {
      if (mounted) {
        setState(() => _currentVolume = volume);
      }
    });
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    currentSong = widget.audioPlayerService.currentSong;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 8),
                      blurRadius: 16,
                    ),
                  ],
                  image:
                      currentSong?.coverUrl != null
                          ? DecorationImage(
                            image: NetworkImage(currentSong!.coverUrl),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                currentSong?.title ?? 'No Track Selected',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                currentSong?.artist ?? 'Unknown Artist',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(position)),
                  Expanded(
                    child: Slider(
                      value: position.inSeconds.toDouble(),
                      min: 0,
                      max: duration?.inSeconds.toDouble() ?? 0,
                      onChanged: (value) {
                        widget.audioPlayerService.seek(
                          Duration(seconds: value.toInt()),
                        );
                      },
                    ),
                  ),
                  Text(_formatDuration(duration)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.volume_down),
                  Expanded(
                    child: Slider(
                      value: _currentVolume,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (value) {
                        setState(() => _currentVolume = value);
                        widget.audioPlayerService.setVolume(value);
                      },
                    ),
                  ),
                  const Icon(Icons.volume_up),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 48,
                    icon: const Icon(Icons.skip_previous),
                    onPressed: widget.audioPlayerService.previous,
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: IconButton(
                      iconSize: 48,
                      color: Colors.white,
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: widget.onPlayPause,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    iconSize: 48,
                    icon: const Icon(Icons.skip_next),
                    onPressed: widget.audioPlayerService.next,
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Remove the dispose call since we don't own the AudioPlayerService
    super.dispose();
  }
}

import 'package:flutter/material.dart';
  import '../models/song.dart';
  import '../services/audio_player_service.dart';

  class MusicPlayerScreen extends StatefulWidget {
    @override
    _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
  }

  class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
    final AudioPlayerService _audioPlayerService = AudioPlayerService();
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
      currentSong = _audioPlayerService.currentSong;
      await _audioPlayerService.setVolume(_currentVolume);
    }

    void _listenToPlayerChanges() {
      _audioPlayerService.positionStream.listen((p) {
        setState(() => position = p ?? Duration.zero);
      });

      _audioPlayerService.durationStream.listen((d) {
        setState(() => duration = d);
      });

      _audioPlayerService.playerStateStream.listen((state) {
        setState(() => isPlaying = state.playing);
      });

      _audioPlayerService.volumeStream.listen((volume) {
        setState(() => _currentVolume = volume);
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
      currentSong = _audioPlayerService.currentSong;

      return Scaffold(
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
                    image: currentSong?.coverUrl != null
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  currentSong?.artist ?? 'Unknown Artist',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
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
                          _audioPlayerService.seek(Duration(seconds: value.toInt()));
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
                          _audioPlayerService.setVolume(value);
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
                      onPressed: _audioPlayerService.previous,
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
                        onPressed: () async {
                          if (isPlaying) {
                            await _audioPlayerService.pause();
                          } else {
                            await _audioPlayerService.play();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.skip_next),
                      onPressed: _audioPlayerService.next,
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
      _audioPlayerService.dispose();
      super.dispose();
    }
  }
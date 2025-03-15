import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import '../services/audio_player_service.dart';

class MusicPlayerScreen extends StatefulWidget {
  final AudioPlayerService audioPlayerService;
  final VoidCallback onPlayPause;
  final Song? currentSong;
  final bool isPlaying;

  const MusicPlayerScreen({
    super.key,
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
  bool _isShuffleOn = false;
  LoopMode _loopMode = LoopMode.off;

  @override
  void initState() {
    super.initState();
    isPlaying = widget.isPlaying;
    currentSong = widget.currentSong;
    _initializePlayer();
    _listenToPlayerChanges();
  }

  Future<void> _initializePlayer() async {
    final volume = await widget.audioPlayerService.volumeStream.first;
    if (mounted) {
      setState(() => _currentVolume = volume);
    }
  }

  void _listenToPlayerChanges() {
    widget.audioPlayerService.positionStream.listen((pos) {
      if (mounted) setState(() => position = pos ?? Duration.zero);
    });

    widget.audioPlayerService.durationStream.listen((dur) {
      if (mounted) setState(() => duration = dur);
    });

    widget.audioPlayerService.playerStateStream.listen((state) {
      if (mounted) setState(() => isPlaying = state.playing);
    });
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

void _showVolumeDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: StatefulBuilder(
          builder: (context, setState) => Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple,
                  Colors.black,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Volume',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _getVolumeIcon(),
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _currentVolume = _currentVolume == 0 ? 1.0 : 0.0;
                        });
                        widget.audioPlayerService.setVolume(_currentVolume);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.grey.withOpacity(0.3),
                    thumbColor: Colors.white,
                    overlayColor: Colors.purple.withOpacity(0.3),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _currentVolume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) {
                      setState(() {
                        _currentVolume = value;
                      });
                      widget.audioPlayerService.setVolume(value);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${(_currentVolume * 100).round()}%',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }  IconData _getVolumeIcon() {
    if (_currentVolume == 0) return Icons.volume_off;
    if (_currentVolume < 0.5) return Icons.volume_down;
    return Icons.volume_up;
  }

  @override
@override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;
    final artworkSize = screenWidth * 0.75;

    return Container(
      height: screenHeight - safeAreaTop,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.purple.shade800,
            Colors.transparent,
          ],
          stops: const [0.2, 0.8],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(height: 20),
            Hero(
              tag: 'album-art',
              child: Container(
                width: artworkSize,
                height: artworkSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    currentSong?.coverUrl ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[900],
                      child: const Icon(Icons.music_note, size: 80),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    currentSong?.title ?? 'No Track Selected',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentSong?.artist ?? 'Unknown Artist',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.purple[400],
                      inactiveTrackColor: Colors.white.withOpacity(0.2),
                      thumbColor: Colors.white,
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style: TextStyle(color: Colors.white.withOpacity(0.7)),
                        ),
                        Text(
                          _formatDuration(duration),
                          style: TextStyle(color: Colors.white.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _getVolumeIcon(),
                    color: Colors.white.withOpacity(0.7),
                    size: 24,
                  ),
                  onPressed: _showVolumeDialog,
                ),
                IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: currentSong?.isFavorite ?? false
                        ? Colors.purple[400]
                        : Colors.white.withOpacity(0.7),
                    size: 24,
                  ),
                  onPressed: () {
                    if (currentSong != null) {
                      widget.audioPlayerService.toggleFavorite(currentSong!);
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.shuffle,
                    color: _isShuffleOn
                        ? Colors.purple[400]
                        : Colors.white.withOpacity(0.7),
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() => _isShuffleOn = !_isShuffleOn);
                    widget.audioPlayerService.shuffle();
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.skip_previous,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: widget.audioPlayerService.previous,
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.purple[300]!, Colors.purple[700]!],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 48,
                    ),
                    onPressed: widget.onPlayPause,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.skip_next,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: widget.audioPlayerService.next,
                ),
                IconButton(
                  icon: Icon(
                    _loopMode == LoopMode.off
                        ? Icons.repeat
                        : _loopMode == LoopMode.one
                            ? Icons.repeat_one
                            : Icons.repeat,
                    color: _loopMode != LoopMode.off
                        ? Colors.purple[400]
                        : Colors.white.withOpacity(0.7),
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      _loopMode = _loopMode == LoopMode.off
                          ? LoopMode.all
                          : _loopMode == LoopMode.all
                              ? LoopMode.one
                              : LoopMode.off;
                    });
                    widget.audioPlayerService.setLoopMode(_loopMode);
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  IconData _getLoopModeIcon() {
    switch (_loopMode) {
      case LoopMode.off:
        return Icons.repeat;
      case LoopMode.one:
        return Icons.repeat_one;
      case LoopMode.all:
        return Icons.repeat;
      default:
        return Icons.repeat;
    }
  }

  void _toggleLoopMode() {
    setState(() {
      switch (_loopMode) {
        case LoopMode.off:
          _loopMode = LoopMode.all;
          break;
        case LoopMode.all:
          _loopMode = LoopMode.one;
          break;
        case LoopMode.one:
          _loopMode = LoopMode.off;
          break;
      }
    });
    widget.audioPlayerService.setLoopMode(_loopMode);
  }
}
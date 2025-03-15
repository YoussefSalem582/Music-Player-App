import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late List<Song> _playlist = [];
  int _currentIndex = 0;

  // Streams
  Stream<Duration?> get positionStream => _audioPlayer.positionStream;

  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  Stream<double> get volumeStream => _audioPlayer.volumeStream;

  // Getters
  List<Song> get currentPlaylist => _playlist;

  Song? get currentSong =>
      _playlist.isNotEmpty ? _playlist[_currentIndex] : null;

  int get currentIndex => _currentIndex;

  // Basic playback control
  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  // Playlist management
  Future<void> setUrl(String url) async {
    await _audioPlayer.setUrl(url);
  }

  Future<void> setPlaylist(List<Song> songs, {int initialIndex = 0}) async {
    _playlist = songs;
    _currentIndex = initialIndex;
    if (_playlist.isNotEmpty) {
      await setUrl(_playlist[_currentIndex].url);
    }
  }

  // Navigation
  Future<void> next() async {
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      await setUrl(_playlist[_currentIndex].url);
      await play();
    }
  }

  Future<void> previous() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await setUrl(_playlist[_currentIndex].url);
      await play();
    }
  }

  Future<void> skipToIndex(int index) async {
    if (index >= 0 && index < _playlist.length) {
      _currentIndex = index;
      await setUrl(_playlist[_currentIndex].url);
      await play();
    }
  }

  // Shuffle
  Future<void> shuffle() async {
    final currentSong = _playlist[_currentIndex];
    _playlist.shuffle();
    _currentIndex = _playlist.indexOf(currentSong);
  }

  // Repeat modes
  Future<void> setLoopMode(LoopMode mode) async {
    await _audioPlayer.setLoopMode(mode);
  }

  Future<void> toggleFavorite(Song song) async {
    final index = _playlist.indexWhere((s) => s.url == song.url);
    if (index != -1) {
      _playlist[index] = _playlist[index].copyWith(
        isFavorite: !song.isFavorite,
      );
    }
  }

  List<Song> get likedSongs =>
      _playlist.where((song) => song.isFavorite).toList();

  // Cleanup
  void dispose() {
    _audioPlayer.dispose();
  }
}

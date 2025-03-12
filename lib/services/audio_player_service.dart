import 'package:just_audio/just_audio.dart';
    import '../models/song.dart';

    class AudioPlayerService {
      final AudioPlayer _audioPlayer = AudioPlayer();
      late List<Song> _playlist = [];
      int _currentIndex = 0;

      Stream<Duration?> get positionStream => _audioPlayer.positionStream;
      Stream<Duration?> get durationStream => _audioPlayer.durationStream;
      Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
      Stream<double> get volumeStream => _audioPlayer.volumeStream;

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

      Future<void> play() async {
        await _audioPlayer.play();
      }

      Future<void> pause() async {
        await _audioPlayer.pause();
      }

      Future<void> seek(Duration position) async {
        await _audioPlayer.seek(position);
      }

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

      Future<void> setVolume(double volume) async {
        await _audioPlayer.setVolume(volume);
      }

      Future<void> dispose() async {
        await _audioPlayer.dispose();
      }

      Song? get currentSong =>
          _playlist.isNotEmpty ? _playlist[_currentIndex] : null;
    }
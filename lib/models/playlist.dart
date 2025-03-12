import 'song.dart';

class Playlist {
  final String name;
  final List<Song> songs;

  Playlist({
    required this.name,
    required this.songs,
  });
}
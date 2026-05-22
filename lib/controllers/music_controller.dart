import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class MusicManager {
  final AudioPlayer _player = AudioPlayer();
  final Random _random = Random();

  final ValueNotifier<String> currentTrackName = ValueNotifier<String>("None");
  int _currentIndex = 0;

  final ValueNotifier<double> volume =
      ValueNotifier<double>(0.5); // Default 50%

  void setVolume(double val) async {
    volume.value = val;
    await _player.setVolume(val);
  }

  final List<String> _tracks = [
    'music/little break.mp3',
    'music/Lovely.mp3',
    'music/Breakfast.mp3',
    'music/Tomato farm.mp3',
    'music/On The Top.mp3',
    'music/One Thing.mp3',
    'music/Dreamy Mode.mp3',
    'music/Loading.mp3',
    'music/Purple.mp3',
    'music/Gameplay.mp3',
    'music/Taiyaki.mp3',
    'music/2_00 AM.mp3',
    'music/In Dreamland.mp3',
  ];

  MusicManager() {
    _player.onPlayerComplete.listen((_) => _playNext());

    _player.onPlayerComplete.listen((_) => _playNext());
  }

  void seek(Duration pos) async {
    await _player.seek(pos);
  }

  // Plays the next track in the list sequence
  void _playNext() async {
    _currentIndex = (_currentIndex + 1) % _tracks.length;
    String trackPath = _tracks[_currentIndex];

    await _player.play(AssetSource(trackPath));
    currentTrackName.value = trackPath.split('/').last.replaceAll('.mp3', '');
  }

  // Replaced random logic with a simple "play at current index" approach
  void playNextTrack() async {
    _playNext();
  }

  void togglePlayPause() async {
    if (_player.state == PlayerState.playing) {
      await _player.pause();
    } else if (_player.state == PlayerState.paused) {
      await _player.resume();
    } else {
      _playNext();
    }
  }

  void stop() async {
    await _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}

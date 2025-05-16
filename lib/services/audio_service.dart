import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../models/song.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';

class AudioService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Song? _currentSong;
  bool _isInitialized = false;

  AudioService() {
    _audioPlayer.positionStream.listen((_) => notifyListeners());
    _audioPlayer.durationStream.listen((_) => notifyListeners());
    _audioPlayer.playerStateStream.listen((_) => notifyListeners());
  }

  Future<void> initialize() async {
    if (!_isInitialized) {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
      _isInitialized = true;
    }
  }

  Future<String> _getPlayablePath(String assetPath) async {
    if (!assetPath.startsWith('assets/')) return assetPath; // Already a file
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${assetPath.split('/').last}');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }

  Future<void> playSong(Song song) async {
    await initialize();
    String path = await _getPlayablePath(song.filePath);
    if (_currentSong?.id != song.id) {
      await _audioPlayer.setFilePath(path);
      _currentSong = song;
    }
    await _audioPlayer.play();
    notifyListeners();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    notifyListeners();
  }

  Future<void> resume() async {
    await _audioPlayer.play();
    notifyListeners();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
    notifyListeners();
  }

  Stream<Duration?> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  Song? get currentSong => _currentSong;
  bool get isPlaying => _audioPlayer.playing;
  Duration get position => _audioPlayer.position;
  Duration? get duration => _audioPlayer.duration;

  Future<void> dispose() async {
    await _audioPlayer.dispose();
    super.dispose();
  }
} 
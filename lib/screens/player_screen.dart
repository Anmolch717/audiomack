import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../services/audio_service.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

class PlayerScreen extends StatefulWidget {
  final List<Song> songs;
  final int initialIndex;
  const PlayerScreen({super.key, required this.songs, required this.initialIndex});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(minutes: 3, seconds: 30);
  late int _currentIndex;
  Song get currentSong => widget.songs[_currentIndex];
  User? _currentUser;
  StorageService? _storageService;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    _storageService = Provider.of<StorageService>(context, listen: false);
    _loadUser();
    _initAudio();
  }

  Future<void> _loadUser() async {
    final users = await _storageService!.getUsers();
    if (mounted) {
      setState(() {
        _currentUser = users.first;
      });
    }
  }

  bool get _isFavorite => _currentUser?.favoriteSongIds.contains(currentSong.id) ?? false;

  Future<void> _toggleFavorite() async {
    if (_currentUser == null) return;
    final favs = List<String>.from(_currentUser!.favoriteSongIds);
    if (favs.contains(currentSong.id)) {
      favs.remove(currentSong.id);
    } else {
      favs.add(currentSong.id);
    }
    final updatedUser = _currentUser!.copyWith(favoriteSongIds: favs);
    await _storageService!.updateUser(updatedUser);
    setState(() {
      _currentUser = updatedUser;
    });
  }

  Future<void> _initAudio() async {
    final audioService = Provider.of<AudioService>(context, listen: false);
    await audioService.playSong(currentSong);
    setState(() {
      _isPlaying = audioService.isPlaying;
      _duration = audioService.duration ?? currentSong.duration;
    });
    audioService.positionStream.listen((pos) {
      if (pos != null && mounted) {
        setState(() => _position = pos);
      }
    });
    audioService.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = audioService.isPlaying;
        if (_isPlaying) {
          _rotationController.repeat();
        } else {
          _rotationController.stop();
        }
      });
    });
    if (_isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _onSeek(double value) async {
    final audioService = Provider.of<AudioService>(context, listen: false);
    final newPosition = Duration(milliseconds: value.toInt());
    await audioService.seekTo(newPosition);
    setState(() => _position = newPosition);
  }

  void _playPrevious() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + widget.songs.length) % widget.songs.length;
      // ... play currentSong ...
    });
  }

  void _playNext() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.songs.length;
      // ... play currentSong ...
    });
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.songs[widget.initialIndex];
    final cover = song.coverImagePath;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Center(
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (_, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
                    child: child,
                  );
                },
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: cover != null && (cover.endsWith('.jpg') || cover.endsWith('.png') || cover.endsWith('.webp'))
                        ? (cover.startsWith('assets/')
                            ? Image.asset(cover, fit: BoxFit.cover)
                            : Image.file(File(cover), fit: BoxFit.cover))
                        : Container(color: theme.colorScheme.primary, child: const Icon(Icons.music_note, size: 100)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(song.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(song.artist, style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[400])),
            if (song.album.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(song.album, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[500])),
            ],
            const SizedBox(height: 32),
            Slider(
              value: _position.inMilliseconds.clamp(0, _duration.inMilliseconds).toDouble(),
              min: 0,
              max: _duration.inMilliseconds.toDouble(),
              onChanged: _onSeek,
              activeColor: theme.colorScheme.primary,
              inactiveColor: Colors.grey[800],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(_position), style: theme.textTheme.bodySmall),
                  Text(_formatDuration(_duration), style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 36),
                  onPressed: _playPrevious,
                ),
                const SizedBox(width: 24),
                CircleAvatar(
                  radius: 32,
                  backgroundColor: theme.colorScheme.primary,
                  child: IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 36, color: Colors.white),
                    onPressed: () async {
                      final audioService = Provider.of<AudioService>(context, listen: false);
                      if (_isPlaying) {
                        await audioService.pause();
                        _rotationController.stop();
                      } else {
                        await audioService.resume();
                        _rotationController.repeat();
                      }
                      setState(() => _isPlaying = !_isPlaying);
                    },
                  ),
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 36),
                  onPressed: _playNext,
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
} 
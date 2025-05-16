import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../models/song.dart';
import '../models/user.dart';
import 'admin_screen.dart';
import 'upload_screen.dart';
import 'premium_screen.dart';
import 'player_screen.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  User? _currentUser;
  List<Song> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    final storageService = Provider.of<StorageService>(context, listen: false);
    final users = await storageService.getUsers();
    final songs = await storageService.getSongs();

    if (!mounted) return;

    setState(() {
      _currentUser = users.first;
      _songs = songs;
      _isLoading = false;
    });
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AudioMack'),
        actions: [
          if (_currentUser?.role == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminScreen()),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UploadScreen()),
              ).then((_) => _loadData());
            },
          ),
          IconButton(
            icon: Icon(
              _currentUser?.isPremium == true
                  ? Icons.star
                  : Icons.star_border,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PremiumScreen(
                    onPremiumStatusChanged: () {
                      _loadData(); // Refresh data when premium status changes
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildLibraryTab(),
          _buildSearchTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      bottomSheet: _buildMiniPlayer(),
    );
  }

  Widget _buildLibraryTab() {
    final isPremiumUser = _currentUser?.isPremium ?? false;
    final visibleSongs = isPremiumUser ? _songs : _songs.where((s) => !s.isPremium).toList();
    return Consumer<AudioService>(
      builder: (context, audioService, _) {
        final currentSong = audioService.currentSong;
        final isPlaying = audioService.isPlaying;

        if (visibleSongs.isEmpty) {
          return const Center(
            child: Text('No songs in your library'),
          );
        }

        return ListView.builder(
          itemCount: visibleSongs.length,
          itemBuilder: (context, index) {
            final song = visibleSongs[index];
            final isCurrent = currentSong?.id == song.id;
            return ListTile(
              leading: SizedBox(
                width: 48,
                height: 48,
                child: song.coverImagePath != null
                    ? (song.coverImagePath!.startsWith('assets/')
                        ? Image.asset(
                            song.coverImagePath!,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(song.coverImagePath!),
                            fit: BoxFit.cover,
                          ))
                    : Container(
                        color: Theme.of(context).colorScheme.primary,
                        child: const Icon(Icons.music_note),
                      ),
              ),
              title: Text(song.title),
              subtitle: Text(song.artist),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerScreen(
                      songs: visibleSongs,
                      initialIndex: index,
                    ),
                  ),
                ).then((_) => _loadData());
              },
              trailing: IconButton(
                icon: Icon(
                  isCurrent && isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                onPressed: () {
                  if (isCurrent && isPlaying) {
                    audioService.pause();
                  } else {
                    audioService.playSong(song);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchTab() {
    final isPremiumUser = _currentUser?.isPremium ?? false;
    final visibleSongs = isPremiumUser ? _songs : _songs.where((s) => !s.isPremium).toList();
    return _SearchTab(songs: visibleSongs);
  }

  Widget _buildProfileTab() {
    final favoriteSongs = _currentUser == null
        ? []
        : _songs.where((song) => _currentUser!.favoriteSongIds.contains(song.id)).toList();
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            Text(
              _currentUser?.username ?? 'Unknown User',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _currentUser?.email ?? '',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            if (_currentUser?.isPremium == true)
              const Chip(
                label: Text('Premium User'),
                backgroundColor: Colors.amber,
              ),
            const SizedBox(height: 32),
            if (favoriteSongs.isNotEmpty) ...[
              Text('Favorite Songs', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: favoriteSongs.length,
                itemBuilder: (context, index) {
                  final song = favoriteSongs[index];
                  return ListTile(
                    leading: SizedBox(
                      width: 48,
                      height: 48,
                      child: song.coverImagePath != null
                          ? (song.coverImagePath!.startsWith('assets/')
                              ? Image.asset(
                                  song.coverImagePath!,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(song.coverImagePath!),
                                  fit: BoxFit.cover,
                                ))
                          : Container(
                              color: Theme.of(context).colorScheme.primary,
                              child: const Icon(Icons.music_note),
                            ),
                    ),
                    title: Text(song.title),
                    subtitle: Text(song.artist),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayerScreen(
                            songs: _songs,
                            initialIndex: _songs.indexWhere((s) => s.id == song.id),
                          ),
                        ),
                      ).then((_) => _loadData());
                    },
                  );
                },
              ),
            ],
            if (favoriteSongs.isEmpty)
              const Text('No favorite songs yet.'),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Log Out'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: const Text('Log Out'),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true && mounted) {
                  // Clear the current user
                  final storageService = Provider.of<StorageService>(context, listen: false);
                  final users = await storageService.getUsers();
                  if (users.isNotEmpty) {
                    final updatedUser = users.first.copyWith(lastLogin: null);
                    users[0] = updatedUser;
                    await storageService.saveUsers(users);
                  }

                  // Stop any playing audio
                  final audioService = Provider.of<AudioService>(context, listen: false);
                  await audioService.stop();

                  // Navigate to auth screen
                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
                  }
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPlayer() {
    return Consumer<AudioService>(
      builder: (context, audioService, _) {
        final currentSong = audioService.currentSong;
        final isPlaying = audioService.isPlaying;
        final position = audioService.position;
        final duration = audioService.duration ?? currentSong?.duration ?? Duration.zero;

        if (currentSong == null) return const SizedBox.shrink();

        // Find the index of the current song
        final currentIndex = _songs.indexWhere((s) => s.id == currentSong.id);
        // Helper to play next song
        void playNext() {
          if (_songs.isEmpty) return;
          int nextIndex = (currentIndex + 1) % _songs.length;
          final nextSong = _songs[nextIndex];
          audioService.playSong(nextSong);
        }

        return Container(
          height: 92,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                value: duration.inMilliseconds > 0
                    ? position.inMilliseconds / duration.inMilliseconds
                    : 0.0,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerScreen(
                          songs: _songs,
                          initialIndex: currentIndex,
                        ),
                      ),
                    ).then((_) => _loadData());
                  },
                  child: ListTile(
                    leading: SizedBox(
                      width: 48,
                      height: 48,
                      child: currentSong.coverImagePath != null
                          ? (currentSong.coverImagePath!.startsWith('assets/')
                              ? Image.asset(
                                  currentSong.coverImagePath!,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(currentSong.coverImagePath!),
                                  fit: BoxFit.cover,
                                ))
                          : Container(
                              color: Theme.of(context).colorScheme.primary,
                              child: const Icon(Icons.music_note),
                            ),
                    ),
                    title: Text(currentSong.title),
                    subtitle: Text(currentSong.artist),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                          ),
                          onPressed: () {
                            if (isPlaying) {
                              audioService.pause();
                            } else {
                              audioService.resume();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          onPressed: playNext,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> _getPlayablePath(String assetPath) async {
    if (!assetPath.startsWith('assets/')) return assetPath; // Already a file
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${assetPath.split('/').last}');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }
}

// Add the search tab widget
class _SearchTab extends StatefulWidget {
  final List<Song> songs;
  const _SearchTab({required this.songs});

  @override
  State<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<_SearchTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.songs.where((song) {
      final q = _query.toLowerCase();
      return song.title.toLowerCase().contains(q) ||
          song.artist.toLowerCase().contains(q) ||
          song.album.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by title, artist, or album',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() => _query = value);
            },
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No results found'))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final song = filtered[index];
                    return ListTile(
                      leading: SizedBox(
                        width: 48,
                        height: 48,
                        child: song.coverImagePath != null
                            ? (song.coverImagePath!.startsWith('assets/')
                                ? Image.asset(
                                    song.coverImagePath!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(song.coverImagePath!),
                                    fit: BoxFit.cover,
                                  ))
                            : Container(
                                color: Theme.of(context).colorScheme.primary,
                                child: const Icon(Icons.music_note),
                              ),
                      ),
                      title: Text(song.title),
                      subtitle: Text(song.artist),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayerScreen(
                              songs: widget.songs,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
} 
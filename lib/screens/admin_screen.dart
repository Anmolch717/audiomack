import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../models/user.dart';
import '../models/song.dart';
import 'dart:io';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<User> _users = [];
  List<Song> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final storageService = Provider.of<StorageService>(context, listen: false);
    final users = await storageService.getUsers();
    final songs = await storageService.getSongs();

    if (!mounted) return;

    setState(() {
      _users = users;
      _songs = songs;
      _isLoading = false;
    });
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('Are you sure you want to clear all data? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final storageService = Provider.of<StorageService>(context, listen: false);
      await storageService.clearAllData();
      if (!mounted) return;
      Navigator.pop(context);
    }
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
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Songs'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _clearAllData,
            tooltip: 'Clear All Data',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTab(),
          _buildSongsTab(),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text(user.username),
          subtitle: Text(user.email),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user.isPremium)
                const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 8),
              Text(user.role),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSongsTab() {
    return ListView.builder(
      itemCount: _songs.length,
      itemBuilder: (context, index) {
        final song = _songs[index];
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
          subtitle: Text('${song.artist} - ${song.album}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (song.isPremium)
                const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Song'),
                      content: const Text('Are you sure you want to delete this song?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    final storageService = Provider.of<StorageService>(context, listen: false);
                    await storageService.deleteSong(song.id);
                    _loadData();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
} 
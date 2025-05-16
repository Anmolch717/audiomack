import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../models/song.dart';

class StorageService {
  static const String _usersFileName = 'users.json';
  static const String _songsFileName = 'songs.json';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _usersFile async {
    final path = await _localPath;
    return File('$path/$_usersFileName');
  }

  Future<File> get _songsFile async {
    final path = await _localPath;
    return File('$path/$_songsFileName');
  }

  // User operations
  Future<List<User>> getUsers() async {
    try {
      final file = await _usersFile;
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveUsers(List<User> users) async {
    final file = await _usersFile;
    final jsonList = users.map((user) => user.toJson()).toList();
    await file.writeAsString(json.encode(jsonList));
  }

  Future<void> addUser(User user) async {
    final users = await getUsers();
    users.add(user);
    await saveUsers(users);
  }

  Future<void> updateUser(User updatedUser) async {
    final users = await getUsers();
    final index = users.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      users[index] = updatedUser;
      await saveUsers(users);
    }
  }

  // Song operations
  Future<List<Song>> getSongs() async {
    try {
      final file = await _songsFile;
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => Song.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveSongs(List<Song> songs) async {
    final file = await _songsFile;
    final jsonList = songs.map((song) => song.toJson()).toList();
    await file.writeAsString(json.encode(jsonList));
  }

  Future<void> addSong(Song song) async {
    final songs = await getSongs();
    songs.add(song);
    await saveSongs(songs);
  }

  Future<void> updateSong(Song updatedSong) async {
    final songs = await getSongs();
    final index = songs.indexWhere((song) => song.id == updatedSong.id);
    if (index != -1) {
      songs[index] = updatedSong;
      await saveSongs(songs);
    }
  }

  Future<void> deleteSong(String songId) async {
    final songs = await getSongs();
    songs.removeWhere((song) => song.id == songId);
    await saveSongs(songs);
  }

  // Clear all data
  Future<void> clearAllData() async {
    final usersFile = await _usersFile;
    final songsFile = await _songsFile;
    if (await usersFile.exists()) {
      await usersFile.delete();
    }
    if (await songsFile.exists()) {
      await songsFile.delete();
    }
    // Reseed default songs after clearing
    await seedDefaultSongs();
  }

  // Seed default songs if empty
  Future<void> seedDefaultSongs() async {
    final songs = await getSongs();
    if (songs.isNotEmpty) return;
    final now = DateTime.now();
    final List<Song> defaultSongs = [
      Song(
        id: '1',
        title: 'Angela',
        artist: 'Flower Face',
        album: 'Flower Face',
        filePath: 'assets/default_songs/Angela.mp3',
        coverImagePath: 'assets/default_songs/angela_cover.jpg',
        duration: const Duration(minutes: 3, seconds: 30),
        uploadedBy: 'system',
        uploadedAt: now,
      ),
      Song(
        id: '2',
        title: 'The Reason',
        artist: 'Hoobastank',
        album: 'Hoobastank',
        filePath: 'assets/default_songs/The Reason (Radio Edit).mp3',
        coverImagePath: 'assets/default_songs/Hoobastank_-_The_Reason_(song).jpg',
        duration: const Duration(minutes: 3, seconds: 30),
        uploadedBy: 'system',
        uploadedAt: now,
      ),
      Song(
        id: '3',
        title: 'Cradled in Love',
        artist: 'Poets of the Fall',
        album: 'POTF',
        filePath: 'assets/default_songs/Cradled in Love.mp3',
        coverImagePath: 'assets/default_songs/CradledInLoveSingle.webp',
        duration: const Duration(minutes: 3, seconds: 30),
        uploadedBy: 'system',
        uploadedAt: now,
      ),
      Song(
        id: '4',
        title: 'You Are My Sunshine',
        artist: 'Jimmie Davis',
        album: 'Default',
        filePath: 'assets/default_songs/Jimmie Davis - You Are My Sunshine (1940)..mp3',
        coverImagePath: 'assets/default_songs/you_Are_my_sunshine_cover.jpg',
        duration: const Duration(minutes: 3, seconds: 30),
        uploadedBy: 'system',
        uploadedAt: now,
      ),
    ];
    await saveSongs(defaultSongs);
  }
} 
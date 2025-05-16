import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/storage_service.dart';
import '../models/song.dart';
import '../models/user.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _albumController = TextEditingController();
  bool _isPremium = false;
  bool _isLoading = false;
  File? _audioFile;
  File? _coverImageFile;

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    super.dispose();
  }

  Future<bool> _requestAudioPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.audio.isGranted) return true;
      final status = await Permission.audio.request();
      if (status.isPermanentlyDenied) {
        openAppSettings();
        return false;
      }
      return status.isGranted;
    }
    // For iOS or other platforms, return true or handle accordingly
    return true;
  }

  Future<bool> _requestImagePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.photos.isGranted) return true;
      final status = await Permission.photos.request();
      if (status.isPermanentlyDenied) {
        openAppSettings();
        return false;
      }
      return status.isGranted;
    }
    // For iOS or other platforms, return true or handle accordingly
    return true;
  }

  Future<void> _pickAudioFile() async {
    if (await _requestAudioPermission()) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'aac'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _audioFile = File(result.files.single.path!);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio permission is required to pick audio files. Please enable it in app settings.')),
      );
    }
  }

  Future<void> _pickCoverImage() async {
    if (await _requestImagePermission()) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _coverImageFile = File(result.files.single.path!);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image permission is required to pick images')),
      );
    }
  }

  Future<void> _uploadSong() async {
    if (!_formKey.currentState!.validate()) return;
    if (_audioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an audio file')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final storageService = Provider.of<StorageService>(context, listen: false);
      final users = await storageService.getUsers();
      final currentUser = users.first;

      final song = Song(
        id: const Uuid().v4(),
        title: _titleController.text,
        artist: _artistController.text,
        album: _albumController.text,
        filePath: _audioFile!.path,
        coverImagePath: _coverImageFile?.path,
        duration: const Duration(minutes: 3, seconds: 30),
        uploadedBy: currentUser.id,
        uploadedAt: DateTime.now(),
        isPremium: _isPremium,
      );

      await storageService.addSong(song);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Song'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _artistController,
                decoration: const InputDecoration(
                  labelText: 'Artist',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an artist name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _albumController,
                decoration: const InputDecoration(
                  labelText: 'Album',
                  prefixIcon: Icon(Icons.album),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an album name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _pickAudioFile,
                icon: const Icon(Icons.audio_file),
                label: Text(_audioFile == null ? 'Select Audio File' : _audioFile!.path.split('/').last),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickCoverImage,
                icon: const Icon(Icons.image),
                label: Text(_coverImageFile == null ? 'Select Cover Image' : _coverImageFile!.path.split('/').last),
              ),
              if (_coverImageFile != null) ...[
                const SizedBox(height: 16),
                Center(
                  child: Image.file(
                    _coverImageFile!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Premium Content'),
                subtitle: const Text('Make this song available only to premium users'),
                value: _isPremium,
                onChanged: (value) {
                  setState(() => _isPremium = value);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _uploadSong,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Upload Song'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
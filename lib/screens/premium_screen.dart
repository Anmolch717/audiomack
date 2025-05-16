import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../models/user.dart';

class PremiumScreen extends StatefulWidget {
  final VoidCallback? onPremiumStatusChanged;
  const PremiumScreen({super.key, this.onPremiumStatusChanged});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isPremium = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    final storageService = Provider.of<StorageService>(context, listen: false);
    final users = await storageService.getUsers();
    if (!mounted) return;

    setState(() {
      _isPremium = users.first.isPremium;
      _isLoading = false;
    });
  }

  Future<void> _togglePremium() async {
    setState(() => _isLoading = true);
    final storageService = Provider.of<StorageService>(context, listen: false);
    final users = await storageService.getUsers();
    if (users.isEmpty) return;

    final user = users.first;
    user.isPremium = !user.isPremium;
    await storageService.saveUsers(users);
    
    if (!mounted) return;
    setState(() {
      _isPremium = user.isPremium;
      _isLoading = false;
    });
    
    // Notify parent about premium status change
    widget.onPremiumStatusChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = _isPremium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      isPremium ? Icons.star : Icons.star_border,
                      size: 64,
                      color: isPremium ? Colors.amber : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isPremium ? 'Premium Member' : 'Free User',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPremium
                          ? 'Enjoy all premium features'
                          : 'Upgrade to premium for exclusive content',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Features',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.music_note,
                      title: 'Exclusive Content',
                      description: 'Access to premium songs and albums',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.high_quality,
                      title: 'High Quality Audio',
                      description: 'Listen to music in the highest quality',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.download,
                      title: 'Offline Listening',
                      description: 'Download songs for offline playback',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.block,
                      title: 'Ad-Free Experience',
                      description: 'Enjoy music without interruptions',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _togglePremium,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPremium ? Colors.red : Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      isPremium ? 'Cancel Premium' : 'Upgrade to Premium',
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 
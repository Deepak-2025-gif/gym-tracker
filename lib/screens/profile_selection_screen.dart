import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/exercise_provider.dart';
import 'home_screen.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  late TextEditingController _nameController;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadProfiles();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfiles() async {
    await Provider.of<ProfileProvider>(context, listen: false).loadProfiles();
  }

  void _createProfile() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showErrorDialog('Profile name cannot be empty');
      return;
    }

    if (name.length < 2) {
      _showErrorDialog('Profile name must be at least 2 characters');
      return;
    }

    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);

    final success = await profileProvider.createProfile(name);

    if (success) {
      _nameController.clear();
      setState(() {
        _isCreating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      _showErrorDialog('Profile name already exists. Please choose another name.');
    }
  }

  void _selectProfile(String profileId) async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final profile = profileProvider.profiles
        .firstWhere((p) => p.id == profileId);

    await profileProvider.selectProfile(profile);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Tracker - Profiles'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Select or Create Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 24),

                // Existing Profiles
                if (profileProvider.profiles.isNotEmpty) ...[
                  const Text(
                    'Your Profiles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: profileProvider.profiles.length,
                    itemBuilder: (context, index) {
                      final profile = profileProvider.profiles[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.person, color: Colors.deepPurple),
                          title: Text(profile.name),
                          subtitle: Text(
                            'Created: ${profile.createdAt.toString().split('.')[0]}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () => _selectProfile(profile.id),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // Create New Profile Section
                const Text(
                  'Create New Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                if (_isCreating) ...[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter profile name',
                      labelText: 'Profile Name',
                      prefixIcon: const Icon(Icons.person_add),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) => _createProfile(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _createProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Create'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _isCreating = false;
                              _nameController.clear();
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isCreating = true;
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create New Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],

                if (profileProvider.profiles.isEmpty && !_isCreating) ...[
                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No profiles yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first profile to get started!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/profile.dart';
import '../services/database_service.dart';

class ProfileProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  Profile? _currentProfile;
  List<Profile> _profiles = [];

  Profile? get currentProfile => _currentProfile;
  List<Profile> get profiles => _profiles;

  // Load all profiles from database
  Future<void> loadProfiles() async {
    _profiles = await _dbService.getAllProfiles();
    notifyListeners();
  }

  // Select a profile
  Future<void> selectProfile(Profile profile) async {
    _currentProfile = profile;
    notifyListeners();
  }

  // Create a new profile with validation
  Future<bool> createProfile(String name) async {
    // Check for duplicate name
    final exists = await _dbService.profileNameExists(name);
    if (exists) {
      return false; // Profile name already exists
    }

    try {
      const uuid = Uuid();
      final newProfile = Profile(
        id: uuid.v4(),
        name: name.trim(),
        createdAt: DateTime.now(),
      );

      await _dbService.createProfile(newProfile);
      _profiles.add(newProfile);
      _currentProfile = newProfile;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get profile by name
  Future<Profile?> getProfileByName(String name) async {
    return await _dbService.getProfileByName(name);
  }

  // Clear current profile
  void clearProfile() {
    _currentProfile = null;
    notifyListeners();
  }
}

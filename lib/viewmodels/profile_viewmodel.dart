import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class ProfileViewmodel extends ChangeNotifier {
  ProfileViewmodel({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  bool _isLoading = false;
  String? _errorMessage;
  Profile? _profile;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Profile? get profile => _profile;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      _profile = null;
      _errorMessage = 'No authenticated user.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    _errorMessage = null;
    try {
      final row = await _client
          .from('profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (row == null) {
        _profile = null;
        _errorMessage = 'Profile not found. Please contact support.';
      } else {
        _profile = Profile.fromJson(row);
      }
    } on PostgrestException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Unable to load your profile. Check your connection.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProfile({
    required String name,
    required String email,
    String studentNumber = '',
    String imageUrl = '',
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      _errorMessage = 'You must be signed in to create a profile.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;
    try {
      final row = await _client
          .from('profiles')
          .upsert({
            'user_id': user.id,
            'name': name.trim(),
            'email': email.trim(),
            'student_number': studentNumber.trim(),
            'image_url': imageUrl.trim(),
          }, onConflict: 'user_id')
          .select()
          .single();

      _profile = Profile.fromJson(row);
      return true;
    } on PostgrestException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to create your profile.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String studentNumber,
    required String imageUrl,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      _errorMessage = 'You must be signed in to update your profile.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;
    try {
      final row = await _client
          .from('profiles')
          .update({
            'name': name.trim(),
            'email': email.trim(),
            'student_number': studentNumber.trim(),
            'image_url': imageUrl.trim(),
          })
          .eq('user_id', user.id)
          .select()
          .single();

      _profile = Profile.fromJson(row);
      return true;
    } on PostgrestException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to update your profile.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearProfile() {
    _profile = null;
    _errorMessage = null;
    notifyListeners();
  }
}

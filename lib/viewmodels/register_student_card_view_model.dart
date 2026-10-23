import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterStudentCardViewModel extends ChangeNotifier {
  RegisterStudentCardViewModel({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const Set<String> _approvedStatuses = {
    'approved',
    'ready_for_collection',
    'collected',
  };

  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _hasLoaded = false;
  String? _errorMessage;
  String? _status;
  String? _rejectionReason;
  String? _submittedAt;

  String fullName = '';
  String studentNumber = '';
  String programme = '';

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;
  String? get status => _status;
  String? get rejectionReason => _rejectionReason;
  String? get submittedAt => _submittedAt;
  bool get hasCard => _status != null;
  bool get isApproved => _status == 'approved';
  bool get isPending => _status == 'pending';
  bool get isRejected => _status == 'rejected';
  bool get canRegister => _hasLoaded && (!hasCard || isRejected);

  String _normalise(String? raw) {
    final value = (raw ?? 'pending').toLowerCase();
    if (_approvedStatuses.contains(value)) return 'approved';
    if (value == 'rejected') return 'rejected';
    return 'pending';
  }

  Future<void> _fetchStatus(String userId) async {
    final row = await _client
        .from('student_cards')
        .select('status, created_at, rejection_reason')
        .eq('user_id', userId)
        .maybeSingle();

    if (row == null) {
      _status = null;
      _rejectionReason = null;
      _submittedAt = null;
    } else {
      _status = _normalise(row['status'] as String?);
      _rejectionReason = row['rejection_reason'] as String?;
      _submittedAt = row['created_at'] as String?;
    }
    _hasLoaded = true;
  }

  Future<void> loadStatus() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      clear();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _fetchStatus(user.id);
    } on PostgrestException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Could not load your status. Check your connection.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setDetails({
    required String fullName,
    required String studentNumber,
    required String programme,
  }) {
    this.fullName = fullName.trim();
    this.studentNumber = studentNumber.trim();
    this.programme = programme.trim();
  }

  Future<bool> submit({
    required Uint8List photoBytes,
    required String photoExtension,
    required Uint8List proofBytes,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      _errorMessage = 'You are not logged in. Please log in again.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ext = photoExtension.toLowerCase().replaceAll('.', '') == 'png'
          ? 'png'
          : 'jpg';
      final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
      final photoPath = '${user.id}/photo.$ext';
      final proofPath = '${user.id}/proof.pdf';
      final avatarPath = '${user.id}/avatar.$ext';

      final uploads = _client.storage.from('student-uploads');
      final avatars = _client.storage.from('profile-images');

      await uploads.uploadBinary(
        photoPath,
        photoBytes,
        fileOptions: FileOptions(upsert: true, contentType: contentType),
      );
      await uploads.uploadBinary(
        proofPath,
        proofBytes,
        fileOptions: const FileOptions(
          upsert: true,
          contentType: 'application/pdf',
        ),
      );
      await avatars.uploadBinary(
        avatarPath,
        photoBytes,
        fileOptions: FileOptions(upsert: true, contentType: contentType),
      );

      final avatarUrl =
          '${avatars.getPublicUrl(avatarPath)}?v=${DateTime.now().millisecondsSinceEpoch}';

      await _client.from('student_cards').upsert({
        'user_id': user.id,
        'full_name': fullName,
        'student_number': studentNumber,
        'programme': programme,
        'photo_url': photoPath,
        'proof_url': proofPath,
        'status': 'pending',
        'rejection_reason': null,
      }, onConflict: 'user_id');

      await _client.from('profiles').upsert({
        'user_id': user.id,
        'name': fullName,
        'email': user.email ?? '',
        'student_number': studentNumber,
        'programme': programme,
        'image_url': avatarUrl,
      }, onConflict: 'user_id');

      await _fetchStatus(user.id);
      return true;
    } on StorageException catch (e) {
      _errorMessage = 'Upload failed: ${e.message}';
      return false;
    } on PostgrestException catch (e) {
      _errorMessage = e.code == '23505'
          ? 'That student number is already registered.'
          : e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Check your connection.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clear() {
    _isLoading = false;
    _isSubmitting = false;
    _hasLoaded = false;
    _errorMessage = null;
    _status = null;
    _rejectionReason = null;
    _submittedAt = null;
    fullName = '';
    studentNumber = '';
    programme = '';
    notifyListeners();
  }
}